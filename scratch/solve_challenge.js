const fs = require('fs');
const https = require('https');

// Helper to fetch text with TLS verification disabled
function fetchUrl(url) {
    return new Promise((resolve, reject) => {
        const options = {
            rejectUnauthorized: false
        };
        https.get(url, options, (res) => {
            let data = '';
            res.on('data', (chunk) => { data += chunk; });
            res.on('end', () => { resolve(data); });
        }).on('error', reject);
    });
}

async function main() {
    try {
        console.log("Fetching challenge page...");
        const challengeHtml = await fetchUrl("https://ieeesbgvpce.org/ieee_cs.html?i=1");
        
        // Find parameters a, b, c
        const matchA = challengeHtml.match(/var a=toNumbers\("([a-f0-9]+)"\)/);
        const matchB = challengeHtml.match(/b=toNumbers\("([a-f0-9]+)"\)/);
        const matchC = challengeHtml.match(/c=toNumbers\("([a-f0-9]+)"\)/);
        
        if (!matchA || !matchB || !matchC) {
            console.error("Could not parse challenge parameters");
            console.log("Challenge HTML:", challengeHtml);
            return;
        }
        
        const hexA = matchA[1];
        const hexB = matchB[1];
        const hexC = matchC[1];
        
        console.log(`Parameters parsed:`);
        console.log(`  a: ${hexA}`);
        console.log(`  b: ${hexB}`);
        console.log(`  c: ${hexC}`);
        
        console.log("Fetching aes.js...");
        const aesJs = await fetchUrl("https://ieeesbgvpce.org/aes.js");
        
        // Create evaluation context
        const sandbox = {};
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
        
        const cookieValue = eval(contextCode);
        console.log(`__test cookie value: ${cookieValue}`);
        
        fs.writeFileSync("e:/college/scratch/cookie.txt", cookieValue);
        console.log("Saved cookie to cookie.txt");
    } catch (e) {
        console.error("Error solving challenge:", e);
    }
}

main();
