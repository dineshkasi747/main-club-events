<?php
require 'portal/backend/config/db.php';
$q = $pdo->query("DESCRIBE historical_events");
foreach ($q->fetchAll() as $col) {
    echo $col['Field'] . ' - ' . $col['Type'] . "\n";
}
