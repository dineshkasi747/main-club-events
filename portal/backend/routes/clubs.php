<?php
if ($path === '/clubs' && $method === 'GET') {
    $stmt = $pdo->query("SELECT * FROM clubs");
    $clubsList = $stmt->fetchAll();
    
    foreach ($clubsList as &$c) {
        $c['id'] = (int)$c['id'];
        $c['presidentId'] = (int)$c['presidentId'];
        $c['membersCount'] = (int)$c['membersCount'];
        $c['members'] = json_decode($c['members'], true) ?: [];
    }
    sendJson($clubsList);
}

elseif (preg_match('#^/clubs/(\d+)$#', $path, $matches) && $method === 'GET') {
    $clubId = (int)$matches[1];
    
    $stmt = $pdo->prepare("SELECT * FROM clubs WHERE id = :id");
    $stmt->execute(['id' => $clubId]);
    $matchedClub = $stmt->fetch();

    if (!$matchedClub) {
        sendJson(['error' => 'Club not found'], 404);
    }

    $matchedClub['id'] = (int)$matchedClub['id'];
    $matchedClub['presidentId'] = (int)$matchedClub['presidentId'];
    $matchedClub['membersCount'] = (int)$matchedClub['membersCount'];
    $matchedClub['members'] = json_decode($matchedClub['members'], true) ?: [];

    // Fetch upcoming events
    $stmt = $pdo->prepare("SELECT * FROM events WHERE clubId = :clubId AND status = 'active'");
    $stmt->execute(['clubId' => $clubId]);
    $upcomingEvents = $stmt->fetchAll();
    foreach ($upcomingEvents as &$e) {
        $e['id'] = (float)$e['id'];
        $e['clubId'] = (int)$e['clubId'];
        $e['price'] = (float)$e['price'];
        $e['capacity'] = (int)$e['capacity'];
        $e['freeRegistration'] = (bool)$e['freeRegistration'];
        $e['paidRegistration'] = (bool)$e['paidRegistration'];
        $e['volunteerRegistration'] = (bool)$e['volunteerRegistration'];
        $e['volunteerLimit'] = (int)$e['volunteerLimit'];
    }

    // Fetch past historical events
    $stmt = $pdo->prepare("SELECT * FROM historical_events WHERE clubId = :clubId");
    $stmt->execute(['clubId' => $clubId]);
    $pastEvents = $stmt->fetchAll();
    foreach ($pastEvents as &$h) {
        $h['id'] = (int)$h['id'];
        $h['clubId'] = (int)$h['clubId'];
        $h['volunteersCount'] = (int)$h['volunteersCount'];
        $h['images'] = json_decode($h['images'], true) ?: [];
        $h['reportData'] = isset($h['report_data']) ? json_decode($h['report_data'], true) : null;
    }

    $matchedClub['upcomingEvents'] = $upcomingEvents;
    $matchedClub['pastEvents'] = $pastEvents;
    sendJson($matchedClub);
}

elseif ($path === '/clubs' && $method === 'POST') {
    $currentUser = getAuthenticatedUser($pdo);
    if (!$currentUser || $currentUser['role'] !== 'admin') {
        sendJson(['error' => 'Unauthorized. Main admin only.'], 403);
    }

    $body = getJsonBody();
    $clubName = isset($body['name']) ? trim($body['name']) : '';
    $clubDesc = isset($body['description']) ? trim($body['description']) : '';
    $presName = isset($body['presidentName']) ? trim($body['presidentName']) : '';
    $presEmail = isset($body['presidentEmail']) ? trim($body['presidentEmail']) : '';
    $presPassword = isset($body['presidentPassword']) ? trim($body['presidentPassword']) : '';

    if (empty($clubName) || empty($clubDesc) || empty($presName) || empty($presEmail) || empty($presPassword)) {
        sendJson(['error' => 'All fields (club name, description, president name, email, password) are required.'], 400);
    }

    // Check if email already exists
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE LOWER(email) = LOWER(:email)");
    $stmt->execute(['email' => $presEmail]);
    if ($stmt->fetchColumn() > 0) {
        sendJson(['error' => 'Email is already registered.'], 400);
    }

    try {
        $pdo->beginTransaction();

        // 1. Create a unique club ID
        $stmt = $pdo->query("SELECT MAX(id) FROM clubs");
        $maxId = $stmt->fetchColumn();
        $newClubId = $maxId ? ((int)$maxId + 1) : 101;
        if ($newClubId < 101) {
            $newClubId = 101;
        }

        // 2. Create the president user
        $stmt = $pdo->prepare("INSERT INTO users (email, password, role, name, clubId) VALUES (:email, :password, 'president', :name, :clubId)");
        $stmt->execute([
            'email' => $presEmail,
            'password' => $presPassword,
            'name' => $presName,
            'clubId' => $newClubId
        ]);
        $presidentUserId = (int)$pdo->lastInsertId();

        // 3. Create the club
        $stmt = $pdo->prepare("INSERT INTO clubs (id, name, description, presidentId, presidentName, membersCount, members) VALUES (:id, :name, :description, :presidentId, :presidentName, 0, '[]')");
        $stmt->execute([
            'id' => $newClubId,
            'name' => $clubName,
            'description' => $clubDesc,
            'presidentId' => $presidentUserId,
            'presidentName' => $presName
        ]);

        $pdo->commit();

        sendJson([
            'message' => 'Club and President created successfully!',
            'club' => [
                'id' => $newClubId,
                'name' => $clubName,
                'description' => $clubDesc,
                'presidentId' => $presidentUserId,
                'presidentName' => $presName,
                'membersCount' => 0,
                'members' => []
            ]
        ], 201);

    } catch (Exception $e) {
        $pdo->rollBack();
        sendJson(['error' => 'Transaction failed: ' . $e->getMessage()], 500);
    }
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
