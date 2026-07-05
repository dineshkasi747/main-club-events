<?php
require 'portal/backend/config/db.php';
echo "--- CLUBS ---\n";
foreach($pdo->query('select id, name from clubs')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['name'] . "\n";
}
echo "--- EVENTS FOR AIML (104) ---\n";
foreach($pdo->query('select id, title from events where clubId = 104')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
echo "--- HISTORICAL EVENTS FOR AIML (104) ---\n";
foreach($pdo->query('select id, title from historical_events where clubId = 104')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
echo "--- EVENTS FOR DS (105) ---\n";
foreach($pdo->query('select id, title from events where clubId = 105')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
echo "--- HISTORICAL EVENTS FOR DS (105) ---\n";
foreach($pdo->query('select id, title from historical_events where clubId = 105')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
echo "--- EVENTS FOR IEEE CS (106) ---\n";
foreach($pdo->query('select id, title from events where clubId = 106')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
echo "--- HISTORICAL EVENTS FOR IEEE CS (106) ---\n";
foreach($pdo->query('select id, title from historical_events where clubId = 106')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
