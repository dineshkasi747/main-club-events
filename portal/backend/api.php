<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/config/db.php';

function getAuthorizationHeader() {
    if (isset($_SERVER['Authorization'])) {
        return trim($_SERVER["Authorization"]);
    } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        return trim($_SERVER["HTTP_AUTHORIZATION"]);
    } else if (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
        if (isset($requestHeaders['Authorization'])) {
            return trim($requestHeaders['Authorization']);
        }
    }
    return null;
}

function getAuthenticatedUser($pdo) {
    $authHeader = getAuthorizationHeader();
    if (!$authHeader) {
        return null;
    }
    $token = str_replace('Bearer ', '', $authHeader);
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = :email");
    $stmt->execute(['email' => $token]);
    return $stmt->fetch() ?: null;
}

// JSON API response helper
function sendJson($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

// Helper to get raw json body
function getJsonBody() {
    $raw = file_get_contents("php://input");
    return json_decode($raw, true) ?: [];
}

// Parse request path info
$path = isset($_SERVER['PATH_INFO']) ? $_SERVER['PATH_INFO'] : '';
if (empty($path)) {
    $requestUri = $_SERVER['REQUEST_URI'];
    $parts = explode('?', $requestUri);
    $requestPath = $parts[0];
    
    $pos = strpos($requestPath, 'api.php');
    if ($pos !== false) {
        $path = substr($requestPath, $pos + 7);
    } else {
        $path = $requestPath;
    }
}
$path = '/' . trim($path, '/');

// Normalize path: strip leading '/api' if present
if (strpos($path, '/api') === 0) {
    $path = substr($path, 4);
}
$path = '/' . trim($path, '/');

$method = $_SERVER['REQUEST_METHOD'];

function getEnvValue($key) {
    $envFile = __DIR__ . '/.env';
    if (file_exists($envFile)) {
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            if (strpos(trim($line), '#') === 0) continue;
            $parts = explode('=', $line, 2);
            if (count($parts) === 2 && trim($parts[0]) === $key) {
                return trim($parts[1], "\"' ");
            }
        }
    }
    return getenv($key);
}

function getGoogleAccessToken($serviceAccount) {
    $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
    $now = time();
    $claim = json_encode([
        'iss' => $serviceAccount['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => 'https://oauth2.googleapis.com/token',
        'exp' => $now + 3600,
        'iat' => $now
    ]);
    
    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlClaim = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($claim));
    
    $signature = '';
    $success = openssl_sign(
        $base64UrlHeader . "." . $base64UrlClaim,
        $signature,
        $serviceAccount['private_key'],
        OPENSSL_ALGO_SHA256
    );
    
    if (!$success) {
        return null;
    }
    
    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    $jwt = $base64UrlHeader . "." . $base64UrlClaim . "." . $base64UrlSignature;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'https://oauth2.googleapis.com/token');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt
    ]));
    
    $res = curl_exec($ch);
    curl_close($ch);
    
    $data = json_decode($res, true);
    return isset($data['access_token']) ? $data['access_token'] : null;
}

function sendPushNotification($serviceAccount, $title, $body, $tokens) {
    $accessToken = getGoogleAccessToken($serviceAccount);
    if (!$accessToken) {
        return false;
    }
    
    $projectId = $serviceAccount['project_id'];
    $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";
    
    $successCount = 0;
    foreach ($tokens as $token) {
        $payload = json_encode([
            'message' => [
                'token' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $body
                ]
            ]
        ]);
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Authorization: Bearer {$accessToken}",
            "Content-Type: application/json"
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
        
        $res = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode === 200) {
            $successCount++;
        }
    }
    return $successCount;
}

if ($path === '/auth/login') {
    require_once __DIR__ . '/routes/auth.php';
} elseif ($path === '/auth/google-login') {
    require_once __DIR__ . '/routes/google.php';
} elseif ($path === '/clubs' || preg_match('#^/clubs/\d+$#', $path)) {
    require_once __DIR__ . '/routes/clubs.php';
} elseif ($path === '/events' || preg_match('#^/events/\d+$#', $path) || preg_match('#^/events/\d+/register$#', $path)) {
    require_once __DIR__ . '/routes/events.php';
} elseif ($path === '/registrations' || preg_match('#^/registrations/\d+/verify$#', $path) || preg_match('#^/registrations/\d+/admit$#', $path)) {
    require_once __DIR__ . '/routes/registrations.php';
} elseif ($path === '/users/fcm-token' || preg_match('#^/notify/club/\d+$#', $path) || $path === '/notifications') {
    require_once __DIR__ . '/routes/notifications.php';
} else {
    sendJson(['error' => 'Resource not found'], 404);
}
