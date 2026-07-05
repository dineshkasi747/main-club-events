<?php
require 'portal/backend/config/db.php';
$events = $pdo->query('select * from historical_events where clubId = 105 limit 4')->fetchAll(PDO::FETCH_ASSOC);
foreach($events as $ev) {
    $images = json_decode($ev['images'], true) ?? [];
    $imgString = 'const [' . implode(', ', array_map(function($img) { return '"' . $img . '"'; }, $images)) . ']';
    
    echo "    HistoricalEvent(\n";
    echo "      id: " . $ev['id'] . ",\n";
    echo "      clubId: 105,\n";
    echo "      academicYear: \"" . $ev['academicYear'] . "\",\n";
    echo "      title: \"" . addslashes($ev['title']) . "\",\n";
    echo "      date: \"" . addslashes($ev['date']) . "\",\n";
    echo "      venue: \"" . addslashes($ev['venue']) . "\",\n";
    echo "      description: \"" . addslashes($ev['description']) . "\",\n";
    echo "      volunteersCount: " . ($ev['volunteersCount'] ?? 0) . ",\n";
    echo "      images: " . $imgString . ",\n";
    echo "    ),\n";
}
