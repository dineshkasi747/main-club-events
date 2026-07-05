<?php
require 'portal/backend/config/db.php';
try {
    $pdo->exec("ALTER TABLE historical_events ADD COLUMN report_data LONGTEXT DEFAULT NULL");
    echo "Successfully added report_data column.\n";
} catch (PDOException $e) {
    echo "Column may already exist or error: " . $e->getMessage() . "\n";
}
