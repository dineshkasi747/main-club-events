const fs = require('fs');
const https = require('https');
const path = require('path');

// Read saved cookie
const cookieValue = fs.readFileSync('e:/college/scratch/cookie.txt', 'utf8').trim();
console.log(`Using cookie: ${cookieValue}`);

function fetchUrlWithCookie(url, isBinary = false) {
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
            if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
                console.log(`Redirecting to ${res.headers.location}...`);
                resolve(fetchUrlWithCookie(new URL(res.headers.location, url).toString(), isBinary));
                return;
            }
            
            const chunks = [];
            res.on('data', (chunk) => { chunks.push(chunk); });
            res.on('end', () => {
                const buffer = Buffer.concat(chunks);
                if (isBinary) {
                    resolve(buffer);
                } else {
                    resolve(buffer.toString('utf8'));
                }
            });
        }).on('error', reject);
    });
}

async function downloadFile(url, destPath) {
    try {
        console.log(`Downloading ${url} to ${destPath}...`);
        const buffer = await fetchUrlWithCookie(url, true);
        const dir = path.dirname(destPath);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(destPath, buffer);
        console.log(`Saved ${destPath}`);
    } catch (e) {
        console.error(`Failed to download ${url}:`, e);
    }
}

async function main() {
    // 1. Download HTML pages
    console.log("Fetching IEEE CS Page...");
    const ieeeCsHtml = await fetchUrlWithCookie("https://ieeesbgvpce.org/ieee_cs.html?i=1");
    fs.writeFileSync("e:/college/scratch/ieee_cs_loaded.html", ieeeCsHtml);
    console.log("Saved ieee_cs_loaded.html");

    console.log("Fetching Team Page...");
    const teamHtml = await fetchUrlWithCookie("https://ieeesbgvpce.org/team.html?i=1");
    fs.writeFileSync("e:/college/scratch/team_loaded.html", teamHtml);
    console.log("Saved team_loaded.html");

    // 2. Download Club Logo
    const logoUrl = "https://ieeesbgvpce.org/images/cs/IEEE-CS_LogoTM-white.png";
    await downloadFile(logoUrl, "e:/college/mobile/assets/ieee_cs/images/logo.png");

    // Let's also download a black/dark logo if it exists or if we can use the white one
    // Let's check if there is an alternative logo
    const alternativeLogoUrl = "https://ieeesbgvpce.org/images/cs/IEEE-CS_LogoTM-black.png";
    // We will attempt to download it, it might fail if not exists
    await downloadFile(alternativeLogoUrl, "e:/college/mobile/assets/ieee_cs/images/logo_black.png");

    // 3. Download CS Team Images
    const csTeamImages = [
        { name: "satyakeerthi.png", url: "https://ieeesbgvpce.org/images/team/coreteam-2025/satyakeerthi%20sir.png" },
        { name: "pallavi.jpg", url: "https://ieeesbgvpce.org/images/team/coreteam-2025/CS%20CHAIR.jpg" },
        { name: "hemanth.jpg", url: "https://ieeesbgvpce.org/images/team/coreteam-2025/CS%20VICECHAIR.jpg" },
        { name: "rishitha.jpg", url: "https://ieeesbgvpce.org/images/team/coreteam-2025/CS%20SEC.jpg" },
        { name: "harika.jpg", url: "https://ieeesbgvpce.org/images/team/coreteam-2025/CS%20EXEC.jpg" }
    ];

    for (const img of csTeamImages) {
        await downloadFile(img.url, `e:/college/mobile/assets/ieee_cs/images/${img.name}`);
    }

    console.log("Downloads finished!");
}

main();
