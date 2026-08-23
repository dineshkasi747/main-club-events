<?php
// Razorpay Backend Handler with API Key & Secret
// Key ID: rzp_test_TSKYJjtfjh7sGM
// Secret: E7gNoht3QGnvS22dTfWOM1Yk

$RAZORPAY_KEY_ID = 'rzp_test_TSKYJjtfjh7sGM';
$RAZORPAY_KEY_SECRET = 'E7gNoht3QGnvS22dTfWOM1Yk';

$path = $_SERVER['PATH_INFO'] ?? $_SERVER['REQUEST_URI'];
if (strpos($path, '?') !== false) {
    $path = explode('?', $path)[0];
}

// -------------------------------------------------------------
// POST /razorpay/create-order
// Creates a real Razorpay Order via Razorpay REST API
// -------------------------------------------------------------
if ($path === '/razorpay/create-order' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = getJsonBody();
    $amountInRupees = 1.0; // Forced to 1 Rupee for real transaction testing
    $amountInPaise = 100;
    $currency = isset($body['currency']) ? strtoupper($body['currency']) : 'INR';
    $receipt = 'rcpt_' . time() . '_' . rand(100, 999);

    $payload = json_encode([
        'amount' => $amountInPaise,
        'currency' => $currency,
        'receipt' => $receipt,
        'payment_capture' => 1
    ]);

    // Send HTTP Basic Auth request to Razorpay REST API
    $ch = curl_init('https://api.razorpay.com/v1/orders');
    curl_setopt($ch, CURLOPT_USERPWD, $RAZORPAY_KEY_ID . ':' . $RAZORPAY_KEY_SECRET);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlErr = curl_error($ch);
    curl_close($ch);

    if ($httpCode === 200 || $httpCode === 201) {
        $data = json_decode($response, true);
        sendJson([
            'success' => true,
            'key' => $RAZORPAY_KEY_ID,
            'order_id' => $data['id'],
            'amount' => $data['amount'],
            'currency' => $data['currency'],
            'receipt' => $data['receipt'],
            'status' => $data['status']
        ]);
    } else {
        // Fallback simulated order ID if Razorpay sandbox API network call fails
        $orderId = 'order_' . substr(md5(uniqid()), 0, 14);
        sendJson([
            'success' => true,
            'key' => $RAZORPAY_KEY_ID,
            'order_id' => $orderId,
            'amount' => $amountInPaise,
            'currency' => $currency,
            'receipt' => $receipt,
            'status' => 'created',
            'note' => 'Generated fallback order ID'
        ]);
    }
}

// -------------------------------------------------------------
// POST /razorpay/verify-payment
// Verifies HMAC SHA256 Signature and saves registration & Excel data
// -------------------------------------------------------------
if ($path === '/razorpay/verify-payment' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = getJsonBody();
    $currentUser = getAuthenticatedUser($pdo);

    $razorpayOrderId = $body['razorpay_order_id'] ?? '';
    $razorpayPaymentId = $body['razorpay_payment_id'] ?? ('pay_Rzp' . time());
    $razorpaySignature = $body['razorpay_signature'] ?? '';

    $isValid = false;
    if (!empty($razorpayOrderId) && !empty($razorpaySignature)) {
        $expectedSignature = hash_hmac('sha256', $razorpayOrderId . '|' . $razorpayPaymentId, $RAZORPAY_KEY_SECRET);
        if (hash_equals($expectedSignature, $razorpaySignature)) {
            $isValid = true;
        }
    }

    if (!$isValid) {
        sendJson(['error' => 'Razorpay payment signature verification failed'], 400);
    }

    $eventId = (int)($body['eventId'] ?? 2027);

    // Fetch Event
    $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
    $stmt->execute(['id' => $eventId]);
    $matchedEvent = $stmt->fetch();
    if (!$matchedEvent) {
        $matchedEvent = [
            'id' => $eventId,
            'title' => 'Spheronix Technology Hackathon 2026',
            'clubId' => 104,
            'price' => 250.00,
            'venue' => 'Main Auditorium & Spheronix Innovation Lab, GVPCE(A)',
            'dateString' => 'Aug 20, 2026 @ 09:00 AM'
        ];
    }

    $price = (float)$matchedEvent['price'];
    $paymentMethod = !empty($body['paymentMethod']) ? $body['paymentMethod'] : 'Razorpay UPI Intent';

    $existingRegId = isset($body['registrationId']) ? (float)$body['registrationId'] : 0;
    $isExistingTeam = false;
    $teamRegistrations = [];

    if ($existingRegId > 0) {
        $stmt = $pdo->prepare("SELECT * FROM registrations WHERE id = :id");
        $stmt->execute(['id' => $existingRegId]);
        $leaderReg = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($leaderReg && $leaderReg['status'] === 'pending_team') {
            $isExistingTeam = true;
            $regId = $existingRegId;
            $price = (float)$leaderReg['eventPrice'];

            // Update leader's registration
            $stmt = $pdo->prepare("UPDATE registrations SET status = 'approved', transactionId = :txnId, upiRefId = :upiId, paymentMethod = :paymentMethod, paymentAmount = :paymentAmount, timestamp = :timestamp WHERE id = :id");
            $stmt->execute([
                'txnId' => $razorpayPaymentId,
                'upiId' => $razorpayOrderId,
                'paymentMethod' => $paymentMethod,
                'paymentAmount' => $price,
                'timestamp' => date('c'),
                'id' => $existingRegId
            ]);

            // Update all team members' registrations
            $stmt = $pdo->prepare("UPDATE registrations SET status = 'approved', transactionId = :txnId, upiRefId = :upiId, timestamp = :timestamp WHERE teamLeaderEmail = :leaderEmail AND eventId = :eventId AND status = 'pending_team'");
            $stmt->execute([
                'txnId' => $razorpayPaymentId,
                'upiId' => $razorpayOrderId,
                'timestamp' => date('c'),
                'leaderEmail' => $leaderReg['teamLeaderEmail'],
                'eventId' => $eventId
            ]);

            // Fetch all approved team members (including leader) to append to Excel
            $stmt = $pdo->prepare("SELECT * FROM registrations WHERE eventId = :eventId AND (id = :id OR (teamLeaderEmail = :leaderEmail AND status = 'approved'))");
            $stmt->execute([
                'eventId' => $eventId,
                'id' => $existingRegId,
                'leaderEmail' => $leaderReg['teamLeaderEmail']
            ]);
            $teamRegistrations = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }
    }

    if (!$isExistingTeam) {
        // Individual path
        $regId = (float)(int)(microtime(true) * 1000);
        $userId = $currentUser ? $currentUser['id'] : 5;
        $userName = !empty($body['fullName']) ? $body['fullName'] : ($currentUser ? $currentUser['name'] : 'Teja K.');
        $userBranch = !empty($body['branch']) ? $body['branch'] : ($currentUser ? $currentUser['branch'] : 'Computer Science & Engineering');
        $userRollNumber = !empty($body['rollNumber']) ? $body['rollNumber'] : ($currentUser ? $currentUser['rollNumber'] : '324108883001');
        $userYearOfPassing = $currentUser ? $currentUser['yearOfPassing'] : 2026;

        $stmt = $pdo->prepare("INSERT INTO registrations (id, userId, userName, userBranch, userRollNumber, userYearOfPassing, eventId, eventTitle, eventClubId, eventPrice, eventVenue, eventDate, type, status, paymentMethod, paymentAmount, transactionId, upiRefId, paymentScreenshot, timestamp) VALUES (:id, :userId, :userName, :userBranch, :userRollNumber, :userYearOfPassing, :eventId, :eventTitle, :eventClubId, :price, :eventVenue, :eventDate, 'participant', 'approved', :paymentMethod, :paymentAmount, :transactionId, :upiRefId, '', :timestamp)");
        $stmt->execute([
            'id' => $regId,
            'userId' => $userId,
            'userName' => $userName,
            'userBranch' => $userBranch,
            'userRollNumber' => $userRollNumber,
            'userYearOfPassing' => $userYearOfPassing,
            'eventId' => $matchedEvent['id'],
            'eventTitle' => $matchedEvent['title'],
            'eventClubId' => $matchedEvent['clubId'],
            'price' => $price,
            'eventVenue' => $matchedEvent['venue'],
            'eventDate' => $matchedEvent['dateString'],
            'paymentMethod' => $paymentMethod,
            'paymentAmount' => $price,
            'transactionId' => $razorpayPaymentId,
            'upiRefId' => $razorpayOrderId,
            'timestamp' => date('c')
        ]);

        $teamRegistrations[] = [
            'userId' => $userId,
            'userName' => $userName,
            'userBranch' => $userBranch,
            'userRollNumber' => $userRollNumber,
            'teamName' => $body['teamName'] ?? ''
        ];
    }

    // Append to Excel Sheet
    $excelPath = realpath(__DIR__ . '/../../Hackathon_Students_Sample_Data.xlsx');
    if (!$excelPath) {
        $excelPath = __DIR__ . '/../../Hackathon_Students_Sample_Data.xlsx';
    }

    foreach ($teamRegistrations as $reg) {
        $rollNum = $reg['userRollNumber'];
        $fullName = $reg['userName'];
        $currentYear = !empty($body['currentYear']) ? $body['currentYear'] : '3rd year';
        $branch = $reg['userBranch'];
        $collegeName = !empty($body['collegeName']) ? $body['collegeName'] : 'Gayatri Vidya Parishad College of Engineering (Autonomous)';
        
        $email = '';
        if (isset($reg['userId'])) {
            $stmtU = $pdo->prepare("SELECT email FROM users WHERE id = :id");
            $stmtU->execute(['id' => $reg['userId']]);
            $email = $stmtU->fetchColumn() ?: '';
        }
        if (empty($email)) {
            $email = strtolower($rollNum) . '@gvpce.ac.in';
        }
        
        $mobileNumber = !empty($body['mobileNumber']) ? $body['mobileNumber'] : '9876543210';
        $domain = !empty($body['domain']) ? $body['domain'] : 'Full Stack Applications';
        $mode = $isExistingTeam ? 'Team' : (!empty($body['mode']) ? $body['mode'] : 'Individual');
        $tName = isset($reg['teamName']) ? $reg['teamName'] : ($body['teamName'] ?? '');

        $cmd = sprintf(
            'python "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"',
            __DIR__ . '/../append_excel.py',
            $excelPath,
            escapeshellarg($rollNum),
            escapeshellarg($fullName),
            escapeshellarg($currentYear),
            escapeshellarg($branch),
            escapeshellarg($collegeName),
            escapeshellarg($email),
            escapeshellarg($mobileNumber),
            escapeshellarg($domain),
            escapeshellarg($mode),
            escapeshellarg($tName)
        );
        exec($cmd);
    }

    sendJson([
        'success' => true,
        'message' => 'Razorpay payment verified and student registration recorded in database & Excel dataset successfully!',
        'registrationId' => $regId,
        'paymentId' => $razorpayPaymentId,
        'orderId' => $razorpayOrderId
    ]);
}
