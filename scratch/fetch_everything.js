const fs = require('fs');
const https = require('https');

// Helper to fetch text with TLS verification disabled and optional cookie
function fetchUrl(url, cookie = null) {
    return new Promise((resolve, reject) => {
        const parsedUrl = new URL(url);
        const options = {
            hostname: parsedUrl.hostname,
            path: parsedUrl.pathname + parsedUrl.search,
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
            },
            rejectUnauthorized: false
        };
        if (cookie) {
            options.headers['Cookie'] = `__test=${cookie}`;
        }
        https.get(options, (res) => {
            const chunks = [];
            res.on('data', (chunk) => { chunks.push(chunk); });
            res.on('end', () => { resolve(Buffer.concat(chunks).toString('utf8')); });
        }).on('error', reject);
    });
}

async function main() {
    try {
        console.log("1. Triggering challenge by fetching ieee_cs.html?i=1...");
        const challengeHtml = await fetchUrl("https://ieeesbgvpce.org/ieee_cs.html?i=1");
        
        // Find parameters a, b, c
        const matchA = challengeHtml.match(/var a=toNumbers\("([a-f0-9]+)"\)/);
        const matchB = challengeHtml.match(/b=toNumbers\("([a-f0-9]+)"\)/);
        const matchC = challengeHtml.match(/c=toNumbers\("([a-f0-9]+)"\)/);
        
        if (!matchA || !matchB || !matchC) {
            console.error("Could not parse challenge parameters");
            console.log("Response was:", challengeHtml.substring(0, 1000));
            return;
        }
        
        const hexA = matchA[1];
        const hexB = matchB[1];
        const hexC = matchC[1];
        
        console.log("Parsed parameters successfully:");
        console.log(`  a: ${hexA}`);
        console.log(`  b: ${hexB}`);
        console.log(`  c: ${hexC}`);
        
        console.log("2. Fetching aes.js...");
        const aesJs = await fetchUrl("https://ieeesbgvpce.org/aes.js");
        
        // Evaluate slowAES decryption to get the cookie
        const contextCode = `
            ${aesJs}
            function toNumbers(d){var e=[];d.replace(/(..)/g,function(d){e.push(parseInt(d,16))});return e}
            function toHex(){for(var d=[],d=1==arguments.length&&arguments[0].constructor==Array?arguments[0]:arguments,e="",f=0;f<d.length;f++)e+=(16>d[f]?"0":"")+d[f].toString(16);return e.toLowerCase()}
            var a=toNumbers("${hexA}");
            var b=toNumbers("${hexB}");
            var c=toNumbers("${hexC}");
            var decrypted = slowAES.decrypt(c, 2, a, b);
            var resultCookie = toHex(decrypted);
            resultCookie;
        `;
        
        const cookie = eval(contextCode);
        console.log(`Solved cookie: __test=${cookie}`);
        
        // Save the cookie for future use
        fs.writeFileSync("e:/college/scratch/cookie.txt", cookie);
        
        // 3. Fetch target pages with the cookie!
        console.log("3. Fetching ieee_cs.html?i=2 with cookie...");
        const csHtml = await fetchUrl("https://ieeesbgvpce.org/ieee_cs.html?i=2", cookie);
        console.log(`Loaded ieee_cs.html length: ${csHtml.length}`);
        fs.writeFileSync("e:/college/scratch/ieee_cs_loaded.html", csHtml);
        
        console.log("4. Fetching team.html?i=2 with cookie...");
        const teamHtml = await fetchUrl("https://ieeesbgvpce.org/team.html?i=2", cookie);
        console.log(`Loaded team.html length: ${teamHtml.length}`);
        fs.writeFileSync("e:/college/scratch/team_loaded.html", teamHtml);
        
        console.log("Done!");
    } catch (e) {
        console.error("Error:", e);
    }
}

main();
