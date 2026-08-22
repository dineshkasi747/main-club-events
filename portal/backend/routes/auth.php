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

    $emailParts = explode('@', $matchedUser['email']);
    $possibleRoll = $emailParts[0];

    $rollNumber = !empty($matchedUser['rollNumber']) 
        ? $matchedUser['rollNumber'] 
        : (!empty($matchedUser['roll_number']) ? $matchedUser['roll_number'] : $possibleRoll);

    $parsed = parseRollNumberDetails($rollNumber);

    $branch = (!empty($matchedUser['branch']) && $matchedUser['branch'] !== 'Engineering') 
        ? $matchedUser['branch'] 
        : ($parsed['branch'] ?: 'Engineering');

    $yearOfPassing = (isset($matchedUser['yearOfPassing']) && $matchedUser['yearOfPassing'] !== null)
        ? (int)$matchedUser['yearOfPassing']
        : ((isset($matchedUser['year_of_passing']) && $matchedUser['year_of_passing'] !== null)
            ? (int)$matchedUser['year_of_passing']
            : ($parsed['yearOfPassing'] ?: 2026));

    $year = $parsed['year'];

    if ($matchedUser['role'] === 'student') {
        $updateStmt = $pdo->prepare("UPDATE users SET branch = :branch, rollNumber = :rollNumber, yearOfPassing = :yearOfPassing WHERE id = :id");
        $updateStmt->execute([
            'branch' => $branch,
            'rollNumber' => $rollNumber,
            'yearOfPassing' => $yearOfPassing,
            'id' => $matchedUser['id']
        ]);
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
            'year' => $year,
        ]
    ]);
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
