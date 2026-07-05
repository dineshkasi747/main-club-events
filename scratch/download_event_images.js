const fs = require('fs');
const https = require('https');
const path = require('path');

// Read saved cookie
const cookieValue = fs.readFileSync('e:/college/scratch/cookie.txt', 'utf8').trim();

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
        if (buffer.length < 1000) {
            console.log(`Warning: buffer length too small (${buffer.length} bytes), likely challenge page or not found.`);
            return;
        }
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
    const events = [
        { name: "clash_of_minds.jpg", url: "https://ieeesbgvpce.org/events/images/2024/92_clash_of_minds/92_clash_of_minds.jpg" },
        { name: "blockchain.jpg", url: "https://ieeesbgvpce.org/events/images/cs/2023/68_blockchain_workshop/event_poster.jpg" },
        { name: "break_the_code.jpeg", url: "https://ieeesbgvpce.org/events/images/cs/2023/66_break_the_code/event_poster.jpeg" },
        { name: "codher.jpg", url: "https://ieeesbgvpce.org/events/images/2022/57_codher.jpg" },
        { name: "jam.jpeg", url: "https://ieeesbgvpce.org/events/images/2022/40_jam.jpeg" },
        { name: "brain_hacks.jpeg", url: "https://ieeesbgvpce.org/events/images/2022/36_brain_hacks.jpeg" },
        { name: "ml_workshop.jpeg", url: "https://ieeesbgvpce.org/events/images/2022/34_cs_mlworkshop.jpeg" }
    ];

    for (const ev of events) {
        await downloadFile(ev.url, `e:/college/mobile/assets/ieee_cs/posters/${ev.name}`);
    }

    console.log("Downloads finished!");
}

main();
