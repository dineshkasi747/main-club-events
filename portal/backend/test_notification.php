<?php
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
    $err = curl_error($ch);
    curl_close($ch);
    
    if ($err) {
        echo "cURL Error in token request: $err\n";
    }
    
    echo "Raw response from Google Token Endpoint:\n$res\n\n";
    
    $data = json_decode($res, true);
    return isset($data['access_token']) ? $data['access_token'] : null;
}

echo "Reading FIREBASE_SERVICE_ACCOUNT_JSON from .env...\n";
$serviceAccountJson = getEnvValue('FIREBASE_SERVICE_ACCOUNT_JSON');

if (!$serviceAccountJson) {
    die("Error: FIREBASE_SERVICE_ACCOUNT_JSON is empty or not found in .env\n");
}

echo "Decoding JSON...\n";
$serviceAccount = json_decode($serviceAccountJson, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    die("JSON Decode Error: " . json_last_error_msg() . "\n");
}

echo "Project ID: " . $serviceAccount['project_id'] . "\n";
echo "Client Email: " . $serviceAccount['client_email'] . "\n";

echo "Attempting to generate Google OAuth Access Token...\n";
$accessToken = getGoogleAccessToken($serviceAccount);

if ($accessToken) {
    echo "Success! Access Token generated: " . substr($accessToken, 0, 30) . "...\n";
} else {
    echo "Failure: Access Token is NULL. Checking OpenSSL errors...\n";
    while ($msg = openssl_error_string()) {
        echo "OpenSSL Error: $msg\n";
    }
}
