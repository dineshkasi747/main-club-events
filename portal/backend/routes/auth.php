<?php
if ($path === '/auth/login' && $method === 'POST') {
    $body = getJsonBody();
    $email = isset($body['email']) ? trim($body['email']) : '';
    $password = isset($body['password']) ? trim($body['password']) : '';

    $stmt = $pdo->prepare("SELECT * FROM users WHERE LOWER(email) = LOWER(:email)");
    $stmt->execute(['email' => $email]);
    $matchedUser = $stmt->fetch();

    if (!$matchedUser) {
        sendJson(['error' => 'User not found'], 401);
    }

    if ($matchedUser['role'] === 'admin' || $matchedUser['role'] === 'president') {
        $passwordMatch = false;
        if ($matchedUser['password'] === $password) {
            $passwordMatch = true;
        } elseif (password_verify($password, $matchedUser['password'])) {
            $passwordMatch = true;
        }

        if (!$passwordMatch) {
            sendJson(['error' => 'Invalid credentials'], 401);
        }
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
