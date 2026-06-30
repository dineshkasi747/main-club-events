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
    }

    $matchedClub['upcomingEvents'] = $upcomingEvents;
    $matchedClub['pastEvents'] = $pastEvents;
    sendJson($matchedClub);
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
