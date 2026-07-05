<?php
require 'portal/backend/config/db.php';

echo "Reading schema.sql...\n";
$sql = file_get_contents('schema.sql');

// Remove SQL comments
$sql = preg_replace('/--.*\n/', '', $sql);
$sql = preg_replace('/\/\*.*?\*\//s', '', $sql);

// Split SQL by semicolon
$queries = explode(';', $sql);

echo "Executing queries...\n";
$count = 0;
foreach ($queries as $query) {
    $query = trim($query);
    if (!empty($query)) {
        try {
            $pdo->exec($query);
            $count++;
        } catch (PDOException $e) {
            echo "Error executing query: " . substr($query, 0, 100) . "...\nError: " . $e->getMessage() . "\n";
        }
    }
}
echo "Successfully executed $count queries.\n";
