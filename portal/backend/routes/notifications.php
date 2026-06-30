<?php
$currentUser = getAuthenticatedUser($pdo);
if (!$currentUser) {
    sendJson(['error' => 'Unauthorized. Invalid or expired token.'], 401);
}

if ($path === '/users/fcm-token' && $method === 'POST') {
    $body = getJsonBody();
    $token = isset($body['token']) ? $body['token'] : '';
    if (!$token) {
        sendJson(['error' => 'Token is required'], 400);
    }

    $stmt = $pdo->prepare("UPDATE users SET fcm_token = :token WHERE id = :userId");
    $stmt->execute(['userId' => $currentUser['id'], 'token' => $token]);
    
    sendJson(['message' => 'FCM token saved successfully']);
}

elseif (preg_match('#^/notify/club/(\d+)$#', $path, $matches) && $method === 'POST') {
    if ($currentUser['role'] !== 'admin' && $currentUser['role'] !== 'president') {
        sendJson(['error' => 'Unauthorized'], 403);
    }

    $clubId = (int)$matches[1];
    $body = getJsonBody();
    $title = isset($body['title']) ? $body['title'] : '';
    $notificationBody = isset($body['body']) ? $body['body'] : '';

    if (!$title || !$notificationBody) {
        sendJson(['error' => 'Title and body are required'], 400);
    }

    $stmt = $pdo->prepare("SELECT * FROM clubs WHERE id = :id");
    $stmt->execute(['id' => $clubId]);
    $matchedClub = $stmt->fetch();
    $clubName = $matchedClub ? $matchedClub['name'] : 'Club';

    $notifId = (float)(int)(microtime(true) * 1000);
    $timestamp = date('c');

    $stmt = $pdo->prepare("INSERT INTO notifications (id, clubId, clubName, title, body, timestamp) VALUES (:id, :clubId, :clubName, :title, :body, :timestamp)");
    $stmt->execute([
        'id' => $notifId,
        'clubId' => $clubId,
        'clubName' => $clubName,
        'title' => $title,
        'body' => $notificationBody,
        'timestamp' => $timestamp
    ]);

    // Send push notification if tokens are present
    $stmt = $pdo->query("SELECT fcm_token FROM users WHERE fcm_token IS NOT NULL AND fcm_token != ''");
    $tokens = $stmt->fetchAll(PDO::FETCH_COLUMN) ?: [];

    $serviceAccountJson = getEnvValue('FIREBASE_SERVICE_ACCOUNT_JSON');
    if ($serviceAccountJson && count($tokens) > 0) {
        $serviceAccount = json_decode($serviceAccountJson, true);
        if ($serviceAccount && isset($serviceAccount['project_id']) && isset($serviceAccount['private_key'])) {
            sendPushNotification($serviceAccount, $title, $notificationBody, $tokens);
        }
    }

    sendJson([
        'message' => 'Announcement created & pushed successfully',
        'notification' => [
            'id' => $notifId,
            'clubId' => $clubId,
            'clubName' => $clubName,
            'title' => $title,
            'body' => $notificationBody,
            'timestamp' => $timestamp
        ]
    ], 201);
}

elseif ($path === '/notifications' && $method === 'GET') {
    $stmt = $pdo->query("SELECT * FROM notifications ORDER BY id DESC");
    $notifications = $stmt->fetchAll() ?: [];
    foreach ($notifications as &$n) {
        $n['id'] = (float)$n['id'];
        $n['clubId'] = (int)$n['clubId'];
    }
    sendJson($notifications);
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
