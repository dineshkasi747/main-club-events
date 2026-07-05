<?php
require 'portal/backend/config/db.php';
print_r($pdo->query('select * from clubs')->fetchAll(PDO::FETCH_ASSOC));
