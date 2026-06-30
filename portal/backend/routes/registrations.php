<?php
$currentUser = getAuthenticatedUser($pdo);
if (!$currentUser) {
    sendJson(['error' => 'Unauthorized. Invalid or expired token.'], 401);
}

if ($path === '/registrations' && $method === 'GET') {
    if ($currentUser['role'] === 'student') {
        $stmt = $pdo->prepare("SELECT * FROM registrations WHERE userId = :userId");
        $stmt->execute(['userId' => $currentUser['id']]);
        $bookings = $stmt->fetchAll();
    } elseif ($currentUser['role'] === 'president') {
        $stmt = $pdo->prepare("SELECT * FROM registrations WHERE eventClubId = :clubId");
        $stmt->execute(['clubId' => $currentUser['clubId']]);
        $bookings = $stmt->fetchAll();
    } elseif ($currentUser['role'] === 'admin') {
        $stmt = $pdo->query("SELECT * FROM registrations");
        $bookings = $stmt->fetchAll();
    } else {
        $bookings = [];
    }
    
    foreach ($bookings as &$b) {
        $b['id'] = (float)$b['id'];
        $b['userId'] = (int)$b['userId'];
        $b['userYearOfPassing'] = (int)$b['userYearOfPassing'];
        $b['eventId'] = (float)$b['eventId'];
        $b['eventClubId'] = (int)$b['eventClubId'];
        $b['eventPrice'] = (float)$b['eventPrice'];
        $b['paymentAmount'] = (float)$b['paymentAmount'];
    }
    sendJson($bookings);
}

elseif (preg_match('#^/registrations/(\d+)/verify$#', $path, $matches) && $method === 'POST') {
    if ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president') {
        sendJson(['error' => 'Unauthorized'], 403);
    }

    $regId = (float)$matches[1];
    
    $stmt = $pdo->prepare("SELECT * FROM registrations WHERE id = :id");
    $stmt->execute(['id' => $regId]);
    $registration = $stmt->fetch();

    if (!$registration) {
        sendJson(['error' => 'Booking not found'], 404);
    }

    if ($currentUser['role'] === 'president' && (int)$registration['eventClubId'] !== (int)$currentUser['clubId']) {
        sendJson(['error' => 'Access Denied: Scoped to assigned club only.'], 403);
    }

    $stmt = $pdo->prepare("UPDATE registrations SET status = 'approved' WHERE id = :id");
    $stmt->execute(['id' => $regId]);

    $registration['status'] = 'approved';
    $registration['id'] = (float)$registration['id'];
    $registration['userId'] = (int)$registration['userId'];
    $registration['userYearOfPassing'] = (int)$registration['userYearOfPassing'];
    $registration['eventId'] = (float)$registration['eventId'];
    $registration['eventClubId'] = (int)$registration['eventClubId'];
    $registration['eventPrice'] = (float)$registration['eventPrice'];
    $registration['paymentAmount'] = (float)$registration['paymentAmount'];

    sendJson(['message' => 'Registration payment verified & approved successfully', 'registration' => $registration]);
}

elseif (preg_match('#^/registrations/(\d+)/admit$#', $path, $matches) && $method === 'POST') {
    if ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president') {
        sendJson(['error' => 'Unauthorized'], 403);
    }

    $regId = (float)$matches[1];
    
    $stmt = $pdo->prepare("SELECT * FROM registrations WHERE id = :id");
    $stmt->execute(['id' => $regId]);
    $registration = $stmt->fetch();

    if (!$registration) {
        sendJson(['error' => 'Booking ticket not found'], 404);
    }

    if ($currentUser['role'] === 'president' && (int)$registration['eventClubId'] !== (int)$currentUser['clubId']) {
        sendJson(['error' => 'Access Denied: Scoped to assigned club only.'], 403);
    }

    if ($registration['status'] !== 'approved') {
        sendJson(['error' => 'Ticket is not approved/paid. Verify payment first.'], 400);
    }

    $stmt = $pdo->prepare("UPDATE registrations SET status = 'attended' WHERE id = :id");
    $stmt->execute(['id' => $regId]);

    $registration['status'] = 'attended';
    $registration['id'] = (float)$registration['id'];
    $registration['userId'] = (int)$registration['userId'];
    $registration['userYearOfPassing'] = (int)$registration['userYearOfPassing'];
    $registration['eventId'] = (float)$registration['eventId'];
    $registration['eventClubId'] = (int)$registration['eventClubId'];
    $registration['eventPrice'] = (float)$registration['eventPrice'];
    $registration['paymentAmount'] = (float)$registration['paymentAmount'];

    sendJson(['message' => 'Ticket checked in. Student allowed entry!', 'registration' => $registration]);
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
