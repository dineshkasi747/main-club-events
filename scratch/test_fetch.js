const fs = require('fs');
const https = require('https');

const cookieValue = fs.readFileSync('e:/college/scratch/cookie.txt', 'utf8').trim();

function fetchUrlWithCookie(url) {
    return new Promise((resolve, reject) => {
        const parsedUrl = new URL(url);
        const options = {
            hostname: parsedUrl.hostname,
            path: parsedUrl.pathname + parsedUrl.search,
            headers: {
                'Cookie': `__test=${cookieValue}`,
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
            },
            rejectUnauthorized: false
        };
        
        https.get(options, (res) => {
            const chunks = [];
            res.on('data', (chunk) => { chunks.push(chunk); });
            res.on('end', () => {
                resolve(Buffer.concat(chunks).toString('utf8'));
            });
        }).on('error', reject);
    });
}

async function main() {
    // Try with i=2
    console.log("Fetching with i=2...");
    const res2 = await fetchUrlWithCookie("https://ieeesbgvpce.org/ieee_cs.html?i=2");
    console.log(`Length for i=2: ${res2.length}`);
    if (res2.length > 2000) {
        fs.writeFileSync("e:/college/scratch/ieee_cs_loaded.html", res2);
        console.log("Saved ieee_cs_loaded.html!");
    }
    
    // Try team with i=2
    console.log("Fetching team with i=2...");
    const resTeam2 = await fetchUrlWithCookie("https://ieeesbgvpce.org/team.html?i=2");
    console.log(`Length for team i=2: ${resTeam2.length}`);
    if (resTeam2.length > 2000) {
        fs.writeFileSync("e:/college/scratch/team_loaded.html", resTeam2);
        console.log("Saved team_loaded.html!");
    }
}

main();
