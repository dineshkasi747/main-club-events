<?php
if ($path === '/auth/google-login' && $method === 'POST') {
    $body = getJsonBody();
    $email = isset($body['email']) ? trim($body['email']) : '';
    $name = isset($body['name']) ? trim($body['name']) : '';

    if (empty($email)) {
        sendJson(['error' => 'Email is required'], 400);
    }

    // Backend domain verification check
    if (substr(strrchr($email, "@"), 1) !== 'gvpce.ac.in') {
        sendJson(['error' => 'Access Denied: Only @gvpce.ac.in accounts are permitted.'], 403);
    }

    // Check if user exists
    $stmt = $pdo->prepare("SELECT * FROM users WHERE LOWER(email) = LOWER(:email)");
    $stmt->execute(['email' => $email]);
    $matchedUser = $stmt->fetch();

    if (!$matchedUser) {
        // Auto-register new student user
        $stmt = $pdo->prepare("INSERT INTO users (name, email, role, password) VALUES (:name, :email, 'student', '')");
        $stmt->execute([
            'name' => $name ?: 'Student',
            'email' => $email
        ]);
        
        $newId = $pdo->lastInsertId();
        
        // Refetch the created user
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = :id");
        $stmt->execute(['id' => $newId]);
        $matchedUser = $stmt->fetch();
    }

    $clubId = null;
    if (isset($matchedUser['clubId']) && $matchedUser['clubId'] !== null) {
        $clubId = (int)$matchedUser['clubId'];
    } elseif (isset($matchedUser['club_id']) && $matchedUser['club_id'] !== null) {
        $clubId = (int)$matchedUser['club_id'];
    }

    $branch = isset($matchedUser['branch']) ? $matchedUser['branch'] : '';
    $rollNumber = isset($matchedUser['rollNumber']) ? $matchedUser['rollNumber'] : (isset($matchedUser['roll_number']) ? $matchedUser['roll_number'] : '');
    
    $yearOfPassing = null;
    if (isset($matchedUser['yearOfPassing']) && $matchedUser['yearOfPassing'] !== null) {
        $yearOfPassing = (int)$matchedUser['yearOfPassing'];
    } elseif (isset($matchedUser['year_of_passing']) && $matchedUser['year_of_passing'] !== null) {
        $yearOfPassing = (int)$matchedUser['year_of_passing'];
    }

    sendJson([
        'token' => $matchedUser['email'],
        'user' => [
            'id' => (int)$matchedUser['id'],
            'name' => $matchedUser['name'],
            'email' => $matchedUser['email'],
            'role' => $matchedUser['role'],
            'clubId' => $clubId,
            'branch' => $branch,
            'rollNumber' => $rollNumber,
            'yearOfPassing' => $yearOfPassing,
        ]
    ]);
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
