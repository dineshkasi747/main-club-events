<?php
$arrContextOptions=array(
    "ssl"=>array(
        "verify_peer"=>false,
        "verify_peer_name"=>false,
    ),
);

$url = isset($argv[1]) ? $argv[1] : "https://ieeesbgvpce.org/ieee_cs.html?i=1";
echo "Fetching $url...\n";
$html = file_get_contents($url, false, stream_context_create($arrContextOptions));
if ($html === false) {
    echo "Failed to fetch.\n";
} else {
    echo "Length: " . strlen($html) . "\n";
    file_put_contents("e:/college/scratch/page.html", $html);
    echo "Saved to page.html\n";
}
