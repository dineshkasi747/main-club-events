<?php
require 'portal/backend/config/db.php';
echo "--- EVENTS FOR DS (105) ---\n";
foreach($pdo->query('select id, title from events where clubId = 105')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
echo "--- HISTORICAL EVENTS FOR DS (105) ---\n";
foreach($pdo->query('select id, title from historical_events where clubId = 105')->fetchAll() as $row) {
    echo $row['id'] . ' - ' . $row['title'] . "\n";
}
