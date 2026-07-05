<?php
require 'portal/backend/config/db.php';
foreach($pdo->query('select id, title, images, academicYear from historical_events where clubId = 104')->fetchAll() as $row) {
    echo $row['id'] . ' | ' . $row['title'] . ' | ' . $row['images'] . ' | ' . $row['academicYear'] . "\n";
}
