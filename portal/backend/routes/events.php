<?php
if ($path === '/events' && $method === 'GET') {
    $stmt = $pdo->query("SELECT * FROM events WHERE status = 'active'");
    $activeEvents = $stmt->fetchAll();
    foreach ($activeEvents as &$e) {
        $e['id'] = (float)$e['id'];
        $e['clubId'] = (int)$e['clubId'];
        $e['price'] = (float)$e['price'];
        $e['capacity'] = (int)$e['capacity'];
        $e['freeRegistration'] = (bool)$e['freeRegistration'];
        $e['paidRegistration'] = (bool)$e['paidRegistration'];
        $e['volunteerRegistration'] = (bool)$e['volunteerRegistration'];
        $e['volunteerLimit'] = (int)$e['volunteerLimit'];
    }
    sendJson($activeEvents);
}

elseif (preg_match('#^/events/(\d+)$#', $path, $matches) && $method === 'GET') {
    $eventId = (float)$matches[1];
    
    $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
    $stmt->execute(['id' => $eventId]);
    $matchedEvent = $stmt->fetch();

    if (!$matchedEvent) {
        sendJson(['error' => 'Event not found'], 404);
    }
    
    $matchedEvent['id'] = (float)$matchedEvent['id'];
    $matchedEvent['clubId'] = (int)$matchedEvent['clubId'];
    $matchedEvent['price'] = (float)$matchedEvent['price'];
    $matchedEvent['capacity'] = (int)$matchedEvent['capacity'];
    $matchedEvent['freeRegistration'] = (bool)$matchedEvent['freeRegistration'];
    $matchedEvent['paidRegistration'] = (bool)$matchedEvent['paidRegistration'];
    $matchedEvent['volunteerRegistration'] = (bool)$matchedEvent['volunteerRegistration'];
    $matchedEvent['volunteerLimit'] = (int)$matchedEvent['volunteerLimit'];
    
    sendJson($matchedEvent);
}

// Authentication required endpoints below
else {
    $currentUser = getAuthenticatedUser($pdo);
    if (!$currentUser) {
        sendJson(['error' => 'Unauthorized. Invalid or expired token.'], 401);
    }

    if ($path === '/events' && $method === 'POST') {
        if ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president') {
            sendJson(['error' => 'Unauthorized. Presidents & admins only.'], 403);
        }

        $body = getJsonBody();
        $title = isset($body['title']) ? $body['title'] : '';
        $description = isset($body['description']) ? $body['description'] : '';
        $venue = isset($body['venue']) ? $body['venue'] : '';
        $dateString = isset($body['dateString']) ? $body['dateString'] : '';
        $price = isset($body['price']) ? (float)$body['price'] : 0.00;
        $capacity = isset($body['capacity']) ? (int)$body['capacity'] : 100;
        $freeReg = isset($body['freeRegistration']) ? (bool)$body['freeRegistration'] : ($price == 0);
        $paidReg = isset($body['paidRegistration']) ? (bool)$body['paidRegistration'] : ($price > 0);
        $volReg = isset($body['volunteerRegistration']) ? (bool)$body['volunteerRegistration'] : false;
        $volLimit = isset($body['volunteerLimit']) ? (int)$body['volunteerLimit'] : 0;
        $imagePath = isset($body['imagePath']) ? $body['imagePath'] : '';

        $eventId = (float)(int)(microtime(true) * 1000);
        $userClubId = null;
        if (isset($currentUser['clubId']) && $currentUser['clubId'] !== null) {
            $userClubId = (int)$currentUser['clubId'];
        } elseif (isset($currentUser['club_id']) && $currentUser['club_id'] !== null) {
            $userClubId = (int)$currentUser['club_id'];
        }

        $clubId = $userClubId !== null ? $userClubId : (isset($body['clubId']) ? (int)$body['clubId'] : null);

        $stmt = $pdo->prepare("INSERT INTO events (id, clubId, title, description, venue, dateString, price, capacity, freeRegistration, paidRegistration, volunteerRegistration, volunteerLimit, status, imagePath) VALUES (:id, :clubId, :title, :description, :venue, :dateString, :price, :capacity, :freeReg, :paidReg, :volReg, :volLimit, 'active', :imagePath)");
        $stmt->execute([
            'id' => $eventId,
            'clubId' => $clubId,
            'title' => $title,
            'description' => $description,
            'venue' => $venue,
            'dateString' => $dateString,
            'price' => $price,
            'capacity' => $capacity,
            'freeReg' => $freeReg ? 1 : 0,
            'paidReg' => $paidReg ? 1 : 0,
            'volReg' => $volReg ? 1 : 0,
            'volLimit' => $volLimit,
            'imagePath' => $imagePath ?: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&auto=format&fit=crop&q=80'
        ]);

        // Send push notification to all users about new event
        try {
            $clubName = 'Club';
            if ($clubId) {
                $stmtClub = $pdo->prepare("SELECT name FROM clubs WHERE id = :id");
                $stmtClub->execute(['id' => $clubId]);
                $matchedClub = $stmtClub->fetch();
                if ($matchedClub) {
                    $clubName = $matchedClub['name'];
                }
            }

            $stmtTokens = $pdo->query("SELECT token FROM fcm_tokens");
            $tokens = $stmtTokens->fetchAll(PDO::FETCH_COLUMN) ?: [];
            
            $serviceAccountJson = getGoogleAccessToken ? getEnvValue('FIREBASE_SERVICE_ACCOUNT_JSON') : null; // check if helper exists in scope
            if (!$serviceAccountJson) {
                // If it is in api.php scope we can fetch it
                $serviceAccountJson = getEnvValue('FIREBASE_SERVICE_ACCOUNT_JSON');
            }
            
            if ($serviceAccountJson && count($tokens) > 0) {
                $serviceAccount = json_decode($serviceAccountJson, true);
                if ($serviceAccount && isset($serviceAccount['project_id']) && isset($serviceAccount['private_key'])) {
                    $notifTitle = "New Event: " . $title;
                    $notifBody = $clubName . " is hosting this event on " . $dateString . " at " . $venue;
                    sendPushNotification($serviceAccount, $notifTitle, $notifBody, $tokens);
                }
            }
        } catch (Exception $pushEx) {
            // Silently capture any push notification errors to avoid breaking event creation
        }

        sendJson([
            'id' => $eventId,
            'clubId' => $clubId,
            'title' => $title,
            'description' => $description,
            'venue' => $venue,
            'dateString' => $dateString,
            'price' => $price,
            'capacity' => $capacity,
            'freeRegistration' => $freeReg,
            'paidRegistration' => $paidReg,
            'volunteerRegistration' => $volReg,
            'volunteerLimit' => $volLimit,
            'status' => 'active',
            'imagePath' => $imagePath ?: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&auto=format&fit=crop&q=80'
        ], 201);
    }

    elseif (preg_match('#^/events/(\d+)/register$#', $path, $matches) && $method === 'POST') {
        $eventId = (float)$matches[1];
        $body = getJsonBody();
        $type = isset($body['type']) ? $body['type'] : 'participant';
        $regMode = isset($body['regMode']) ? $body['regMode'] : '';
        $paymentMethod = isset($body['paymentMethod']) ? $body['paymentMethod'] : '';
        $transactionId = isset($body['transactionId']) ? $body['transactionId'] : '';
        $upiRefId = isset($body['upiRefId']) ? $body['upiRefId'] : '';
        $paymentScreenshot = isset($body['paymentScreenshot']) ? $body['paymentScreenshot'] : '';

        // Fetch event details
        $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
        $stmt->execute(['id' => $eventId]);
        $matchedEvent = $stmt->fetch();
        
        if (!$matchedEvent) {
            sendJson(['error' => 'Event not found'], 404);
        }

        // Check already registered
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM registrations WHERE userId = :userId AND eventId = :eventId AND status != 'cancelled'");
        $stmt->execute(['userId' => $currentUser['id'], 'eventId' => $eventId]);
        if ($stmt->fetchColumn() > 0) {
            sendJson(['error' => 'You are already registered for this event.'], 400);
        }

        $selectedMode = $regMode ?: ($type === 'volunteer' ? 'volunteer' : ($matchedEvent['price'] > 0 ? 'paid' : 'free'));

        if ($selectedMode === 'volunteer') {
            if (!$matchedEvent['volunteerRegistration']) {
                sendJson(['error' => 'Volunteering is not open for this event.'], 400);
            }
            
            $stmt = $pdo->prepare("SELECT COUNT(*) FROM registrations WHERE eventId = :eventId AND type = 'volunteer' AND status != 'cancelled'");
            $stmt->execute(['eventId' => $eventId]);
            if ($stmt->fetchColumn() >= $matchedEvent['volunteerLimit']) {
                sendJson(['error' => 'Volunteering spots are full!'], 400);
            }

            $regId = (float)(int)(microtime(true) * 1000);
            
            $stmt = $pdo->prepare("INSERT INTO registrations (id, userId, userName, userBranch, userRollNumber, userYearOfPassing, eventId, eventTitle, eventClubId, eventPrice, eventVenue, eventDate, type, status, paymentMethod, paymentAmount, transactionId, upiRefId, paymentScreenshot, timestamp) VALUES (:id, :userId, :userName, :userBranch, :userRollNumber, :userYearOfPassing, :eventId, :eventTitle, :eventClubId, 0.00, :eventVenue, :eventDate, 'volunteer', 'approved', 'free', 0.00, 'VOLUNTEER_REG', '', '', :timestamp)");
            $stmt->execute([
                'id' => $regId,
                'userId' => $currentUser['id'],
                'userName' => $currentUser['name'],
                'userBranch' => $currentUser['branch'] ?: 'General',
                'userRollNumber' => $currentUser['rollNumber'] ?: 'N/A',
                'userYearOfPassing' => $currentUser['yearOfPassing'] ?: 2026,
                'eventId' => $matchedEvent['id'],
                'eventTitle' => $matchedEvent['title'],
                'eventClubId' => $matchedEvent['clubId'],
                'eventVenue' => $matchedEvent['venue'],
                'eventDate' => $matchedEvent['dateString'],
                'timestamp' => date('c')
            ]);

            sendJson([
                'id' => $regId,
                'userId' => $currentUser['id'],
                'userName' => $currentUser['name'],
                'userBranch' => $currentUser['branch'] ?: 'General',
                'userRollNumber' => $currentUser['rollNumber'] ?: 'N/A',
                'userYearOfPassing' => $currentUser['yearOfPassing'] ?: 2026,
                'eventId' => $matchedEvent['id'],
                'eventTitle' => $matchedEvent['title'],
                'eventClubId' => $matchedEvent['clubId'],
                'eventPrice' => 0.00,
                'eventVenue' => $matchedEvent['venue'],
                'eventDate' => $matchedEvent['dateString'],
                'type' => 'volunteer',
                'status' => 'approved',
                'paymentMethod' => 'free',
                'paymentAmount' => 0.00,
                'transactionId' => 'VOLUNTEER_REG',
                'upiRefId' => '',
                'paymentScreenshot' => '',
                'timestamp' => date('c')
            ], 201);
        }

        // Participant path
        $isPaid = $selectedMode === 'paid';
        if ($isPaid && (!$matchedEvent['paidRegistration'])) {
            sendJson(['error' => 'Paid registration is not open for this event.'], 400);
        }
        if (!$isPaid && (!$matchedEvent['freeRegistration'])) {
            sendJson(['error' => 'Free registration is not open for this event.'], 400);
        }

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM registrations WHERE eventId = :eventId AND type = 'participant' AND status != 'cancelled'");
        $stmt->execute(['eventId' => $eventId]);
        if ($stmt->fetchColumn() >= $matchedEvent['capacity']) {
            sendJson(['error' => 'This event is sold out!'], 400);
        }

        $regId = (float)(int)(microtime(true) * 1000);
        $price = $isPaid ? (float)$matchedEvent['price'] : 0.00;

        $stmt = $pdo->prepare("INSERT INTO registrations (id, userId, userName, userBranch, userRollNumber, userYearOfPassing, eventId, eventTitle, eventClubId, eventPrice, eventVenue, eventDate, type, status, paymentMethod, paymentAmount, transactionId, upiRefId, paymentScreenshot, timestamp) VALUES (:id, :userId, :userName, :userBranch, :userRollNumber, :userYearOfPassing, :eventId, :eventTitle, :eventClubId, :price, :eventVenue, :eventDate, 'participant', :status, :paymentMethod, :paymentAmount, :transactionId, :upiRefId, :paymentScreenshot, :timestamp)");
        $stmt->execute([
            'id' => $regId,
            'userId' => $currentUser['id'],
            'userName' => $currentUser['name'],
            'userBranch' => $currentUser['branch'] ?: 'General',
            'userRollNumber' => $currentUser['rollNumber'] ?: 'N/A',
            'userYearOfPassing' => $currentUser['yearOfPassing'] ?: 2026,
            'eventId' => $matchedEvent['id'],
            'eventTitle' => $matchedEvent['title'],
            'eventClubId' => $matchedEvent['clubId'],
            'price' => $price,
            'eventVenue' => $matchedEvent['venue'],
            'eventDate' => $matchedEvent['dateString'],
            'status' => $isPaid ? 'pending' : 'approved',
            'paymentMethod' => $isPaid ? ($paymentMethod ?: 'UPI') : 'free',
            'paymentAmount' => $price,
            'transactionId' => $isPaid ? ($transactionId ?: 'PENDING') : 'FREE_REG',
            'upiRefId' => $isPaid ? ($upiRefId ?: $transactionId) : '',
            'paymentScreenshot' => $isPaid ? $paymentScreenshot : '',
            'timestamp' => date('c')
        ]);

        sendJson([
            'id' => $regId,
            'userId' => $currentUser['id'],
            'userName' => $currentUser['name'],
            'userBranch' => $currentUser['branch'] ?: 'General',
            'userRollNumber' => $currentUser['rollNumber'] ?: 'N/A',
            'userYearOfPassing' => $currentUser['yearOfPassing'] ?: 2026,
            'eventId' => $matchedEvent['id'],
            'eventTitle' => $matchedEvent['title'],
            'eventClubId' => $matchedEvent['clubId'],
            'eventPrice' => $price,
            'eventVenue' => $matchedEvent['venue'],
            'eventDate' => $matchedEvent['dateString'],
            'type' => 'participant',
            'status' => $isPaid ? 'pending' : 'approved',
            'paymentMethod' => $isPaid ? ($paymentMethod ?: 'UPI') : 'free',
            'paymentAmount' => $price,
            'transactionId' => $isPaid ? ($transactionId ?: 'PENDING') : 'FREE_REG',
            'upiRefId' => $isPaid ? ($upiRefId ?: $transactionId) : '',
            'paymentScreenshot' => $isPaid ? $paymentScreenshot : '',
            'timestamp' => date('c')
        ], 201);
    } elseif ($path === '/historical-events' && $method === 'GET') {
        $stmt = $pdo->query("SELECT * FROM historical_events");
        $pastEvents = $stmt->fetchAll();
        foreach ($pastEvents as &$h) {
            $h['id'] = (int)$h['id'];
            $h['clubId'] = (int)$h['clubId'];
            $h['volunteersCount'] = (int)$h['volunteersCount'];
            $h['images'] = json_decode($h['images'], true) ?: [];
            $h['reportData'] = isset($h['report_data']) ? json_decode($h['report_data'], true) : null;
        }
        sendJson($pastEvents);
    } elseif ($path === '/historical-events' && $method === 'POST') {
        if ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president') {
            sendJson(['error' => 'Unauthorized. Presidents & admins only.'], 403);
        }

        $body = getJsonBody();
        $academicYear = isset($body['academicYear']) ? trim($body['academicYear']) : '';
        $title = isset($body['title']) ? trim($body['title']) : '';
        $date = isset($body['date']) ? trim($body['date']) : '';
        $venue = isset($body['venue']) ? trim($body['venue']) : '';
        $description = isset($body['description']) ? trim($body['description']) : '';
        $volunteersCount = isset($body['volunteersCount']) ? (int)$body['volunteersCount'] : 0;
        $imagesInput = isset($body['images']) ? $body['images'] : [];
        $reportDataInput = isset($body['reportData']) ? $body['reportData'] : null;

        if (empty($academicYear) || empty($title) || empty($date) || empty($venue) || empty($description)) {
            sendJson(['error' => 'All fields (academic year, title, date, venue, description) are required.'], 400);
        }

        $userClubId = null;
        if (isset($currentUser['clubId']) && $currentUser['clubId'] !== null) {
            $userClubId = (int)$currentUser['clubId'];
        } elseif (isset($currentUser['club_id']) && $currentUser['club_id'] !== null) {
            $userClubId = (int)$currentUser['club_id'];
        }

        $clubId = $userClubId !== null ? $userClubId : (isset($body['clubId']) ? (int)$body['clubId'] : null);
        if (!$clubId) {
            sendJson(['error' => 'Club ID is required.'], 400);
        }

        $stmt = $pdo->query("SELECT MAX(id) FROM historical_events");
        $maxId = $stmt->fetchColumn();
        $newId = $maxId ? ((int)$maxId + 1) : 2001;

        if (is_string($imagesInput)) {
            $images = array_filter(array_map('trim', explode(',', $imagesInput)));
        } else {
            $images = (array)$imagesInput;
        }
        $imagesJson = json_encode($images);
        $reportDataJson = $reportDataInput !== null ? json_encode($reportDataInput) : null;

        $stmt = $pdo->prepare("INSERT INTO historical_events (id, clubId, academicYear, title, date, venue, description, volunteersCount, images, report_data) VALUES (:id, :clubId, :academicYear, :title, :date, :venue, :description, :volunteersCount, :images, :reportData)");
        $stmt->execute([
            'id' => $newId,
            'clubId' => $clubId,
            'academicYear' => $academicYear,
            'title' => $title,
            'date' => $date,
            'venue' => $venue,
            'description' => $description,
            'volunteersCount' => $volunteersCount,
            'images' => $imagesJson,
            'reportData' => $reportDataJson
        ]);

        sendJson([
            'id' => $newId,
            'clubId' => $clubId,
            'academicYear' => $academicYear,
            'title' => $title,
            'date' => $date,
            'venue' => $venue,
            'description' => $description,
            'volunteersCount' => $volunteersCount,
            'images' => $images,
            'reportData' => $reportDataInput
        ], 201);
    } elseif (preg_match('#^/historical-events/(\d+)$#', $path, $matches) && $method === 'PUT') {
        $currentUser = getAuthenticatedUser($pdo);
        if (!$currentUser || ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president')) {
            sendJson(['error' => 'Unauthorized. Presidents & admins only.'], 403);
        }

        $histId = (int)$matches[1];

        // Verify event belongs to president's club
        $chkStmt = $pdo->prepare("SELECT * FROM historical_events WHERE id = :id");
        $chkStmt->execute(['id' => $histId]);
        $existing = $chkStmt->fetch();
        if (!$existing) {
            sendJson(['error' => 'Historical event not found.'], 404);
        }
        if ($currentUser['role'] === 'president' && (int)$existing['clubId'] !== (int)$currentUser['clubId']) {
            sendJson(['error' => 'Access denied.'], 403);
        }

        $body = getJsonBody();
        $academicYear  = isset($body['academicYear'])     ? trim($body['academicYear'])     : $existing['academicYear'];
        $title         = isset($body['title'])            ? trim($body['title'])            : $existing['title'];
        $date          = isset($body['date'])             ? trim($body['date'])             : $existing['date'];
        $venue         = isset($body['venue'])            ? trim($body['venue'])            : $existing['venue'];
        $description   = isset($body['description'])      ? trim($body['description'])      : $existing['description'];
        $volunteersCount = isset($body['volunteersCount']) ? (int)$body['volunteersCount']  : (int)$existing['volunteersCount'];

        $imagesInput = isset($body['images']) ? $body['images'] : json_decode($existing['images'], true);
        if (is_string($imagesInput)) {
            $images = array_filter(array_map('trim', explode(',', $imagesInput)));
        } else {
            $images = (array)$imagesInput;
        }
        $imagesJson = json_encode(array_values($images));

        $reportDataInput = isset($body['reportData']) ? $body['reportData'] : (isset($existing['report_data']) ? json_decode($existing['report_data'], true) : null);
        $reportDataJson  = $reportDataInput !== null ? json_encode($reportDataInput) : null;

        $stmt = $pdo->prepare("UPDATE historical_events SET academicYear=:academicYear, title=:title, date=:date, venue=:venue, description=:description, volunteersCount=:volunteersCount, images=:images, report_data=:reportData WHERE id=:id");
        $stmt->execute([
            'academicYear'   => $academicYear,
            'title'          => $title,
            'date'           => $date,
            'venue'          => $venue,
            'description'    => $description,
            'volunteersCount'=> $volunteersCount,
            'images'         => $imagesJson,
            'reportData'     => $reportDataJson,
            'id'             => $histId,
        ]);

        sendJson(['message' => 'Past event updated successfully.', 'id' => $histId]);
    } elseif (preg_match('#^/events/(\d+)/close$#', $path, $matches) && $method === 'POST') {

        $currentUser = getAuthenticatedUser($pdo);
        if (!$currentUser || ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president')) {
            sendJson(['error' => 'Unauthorized.'], 403);
        }

        $eventId = (float)$matches[1];

        $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
        $stmt->execute(['id' => $eventId]);
        $event = $stmt->fetch();

        if (!$event) {
            sendJson(['error' => 'Event not found.'], 404);
        }

        if ($currentUser['role'] === 'president' && (int)$event['clubId'] !== (int)$currentUser['clubId']) {
            sendJson(['error' => 'Access denied.'], 403);
        }

        // Determine academic year from event dateString or use current year
        $academicYear = '2025-26';
        if (preg_match('/2023/', $event['dateString'])) {
            $academicYear = '2023-24';
        } elseif (preg_match('/2024/', $event['dateString'])) {
            $academicYear = '2024-25';
        } elseif (preg_match('/2025/', $event['dateString'])) {
            $academicYear = '2025-26';
        } elseif (preg_match('/2026/', $event['dateString'])) {
            $academicYear = '2026-27';
        }

        // Count volunteer registrants
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM registrations WHERE eventId = :eventId AND type = 'volunteer' AND status != 'cancelled'");
        $stmt->execute(['eventId' => $eventId]);
        $volsCount = (int)$stmt->fetchColumn();

        // Get max ID for historical events to calculate new ID
        $stmt = $pdo->query("SELECT MAX(id) FROM historical_events");
        $maxId = $stmt->fetchColumn();
        $newId = $maxId ? ((int)$maxId + 1) : 2001;

        $imagesArr = $event['imagePath'] ? [$event['imagePath']] : [];
        $imagesJson = json_encode($imagesArr);

        // Insert into historical_events
        $stmt = $pdo->prepare("INSERT INTO historical_events (id, clubId, academicYear, title, date, venue, description, volunteersCount, images, report_data) VALUES (:id, :clubId, :academicYear, :title, :date, :venue, :description, :volunteersCount, :images, NULL)");
        $stmt->execute([
            'id' => $newId,
            'clubId' => $event['clubId'],
            'academicYear' => $academicYear,
            'title' => $event['title'],
            'date' => $event['dateString'],
            'venue' => $event['venue'],
            'description' => $event['description'],
            'volunteersCount' => $volsCount,
            'images' => $imagesJson
        ]);

        // Delete from active events
        $stmt = $pdo->prepare("DELETE FROM events WHERE id = :id");
        $stmt->execute(['id' => $eventId]);

        sendJson(['message' => 'Event closed and archived to past events successfully.', 'historicalId' => $newId]);
    } elseif (preg_match('#^/events/(\d+)$#', $path, $matches) && $method === 'DELETE') {
        $currentUser = getAuthenticatedUser($pdo);
        if (!$currentUser || ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president')) {
            sendJson(['error' => 'Unauthorized.'], 403);
        }

        $eventId = (float)$matches[1];

        $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
        $stmt->execute(['id' => $eventId]);
        $event = $stmt->fetch();

        if (!$event) {
            sendJson(['error' => 'Event not found.'], 404);
        }

        if ($currentUser['role'] === 'president' && (int)$event['clubId'] !== (int)$currentUser['clubId']) {
            sendJson(['error' => 'Access denied.'], 403);
        }

        $stmt = $pdo->prepare("DELETE FROM events WHERE id = :id");
        $stmt->execute(['id' => $eventId]);

        sendJson(['message' => 'Event closed successfully.']);
    } else {
        sendJson(['error' => 'Method not allowed'], 405);
    }
}
