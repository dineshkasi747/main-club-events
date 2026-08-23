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
} elseif ($path === '/auth/register' && $method === 'POST') {
    $body = getJsonBody();
    $name = isset($body['name']) ? trim($body['name']) : '';
    $email = isset($body['email']) ? trim($body['email']) : '';
    $password = isset($body['password']) ? trim($body['password']) : '';

    if (empty($name) || empty($email) || empty($password)) {
        sendJson(['error' => 'All fields (name, email, password) are required.'], 400);
    }

    if (substr(strrchr($email, "@"), 1) !== 'gvpce.ac.in') {
        sendJson(['error' => 'Access Denied: Only @gvpce.ac.in accounts are permitted.'], 403);
    }

    // Check if user already exists
    $stmt = $pdo->prepare("SELECT * FROM users WHERE LOWER(email) = LOWER(:email)");
    $stmt->execute(['email' => $email]);
    if ($stmt->fetch()) {
        sendJson(['error' => 'Email is already registered.'], 400);
    }

    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    $stmt = $pdo->prepare("INSERT INTO users (name, email, role, password) VALUES (:name, :email, 'student', :password)");
    $stmt->execute([
        'name' => $name,
        'email' => $email,
        'password' => $hashedPassword
    ]);

    sendJson(['success' => true, 'message' => 'Registration successful. You can now log in.']);
} elseif ($path === '/users/search' && $method === 'GET') {
    $query = isset($_GET['query']) ? trim($_GET['query']) : '';
    if (empty($query)) {
        sendJson(['exists' => false, 'error' => 'Query parameter is required.'], 400);
    }

    $stmt = $pdo->prepare("SELECT name, email, rollNumber, branch FROM users WHERE LOWER(email) = LOWER(:query) OR LOWER(rollNumber) = LOWER(:query)");
    $stmt->execute(['query' => $query]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        sendJson([
            'exists' => true,
            'name' => $user['name'],
            'email' => $user['email'],
            'rollNumber' => $user['rollNumber'] ?: $query,
            'branch' => $user['branch'] ?: 'General'
        ]);
    } else {
        sendJson(['exists' => false]);
    }
} else {
    sendJson(['error' => 'Method not allowed'], 405);
}
