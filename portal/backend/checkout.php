<?php
// PHP checkout helper served on local server
require_once __DIR__ . '/config/db.php';

$orderId = $_GET['order_id'] ?? '';
$amount = $_GET['amount'] ?? '';
$key = $_GET['key'] ?? '';
$fullName = $_GET['fullName'] ?? '';
$email = $_GET['email'] ?? '';
$contact = $_GET['contact'] ?? '';
$rollNumber = $_GET['rollNumber'] ?? '';
$branch = $_GET['branch'] ?? '';
$currentYear = $_GET['currentYear'] ?? '';
$collegeName = $_GET['collegeName'] ?? '';
$domain = $_GET['domain'] ?? '';
$mode = $_GET['mode'] ?? '';
$teamName = $_GET['teamName'] ?? '';
$eventId = $_GET['eventId'] ?? '';
$token = $_GET['token'] ?? '';

if (empty($orderId) || empty($amount) || empty($key)) {
    die("Error: Missing payment parameters (order_id, amount, key).");
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Razorpay Checkout</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #F8FAFC;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            padding: 16px;
            box-sizing: border-box;
        }
        .card {
            background: white;
            padding: 32px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(15, 23, 42, 0.05);
            text-align: center;
            max-width: 400px;
            width: 100%;
            border: 1px solid #E2E8F0;
        }
        .loader {
            border: 4px solid #F1F5F9;
            border-top: 4px solid #4F46E5;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        h2 {
            color: #0F172A;
            margin-bottom: 8px;
            font-size: 20px;
        }
        p {
            color: #64748B;
            font-size: 14px;
            margin-bottom: 24px;
            line-height: 1.5;
        }
        .btn {
            background-color: #4F46E5;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 12px;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            font-size: 14px;
            transition: background 0.2s;
        }
        .btn:hover {
            background-color: #4338CA;
        }
    </style>
</head>
<body>

<div class="card" id="checkout-card">
    <div class="loader"></div>
    <h2>Redirecting to Razorpay Gateway</h2>
    <p>Please wait while we connect to the secure payment portal...</p>
    <button class="btn" id="pay-btn" onclick="openRazorpay()">Pay Now</button>
</div>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
    const options = {
        "key": "<?php echo htmlspecialchars($key); ?>",
        "amount": "<?php echo htmlspecialchars($amount); ?>",
        "currency": "INR",
        "name": "Gayatri Vidya Parishad Clubs",
        "description": "Spheronix Registration Fee",
        "image": "https://gvp-college-portal.loca.lt/college/portal/ds_logo.png",
        "order_id": "<?php echo htmlspecialchars($orderId); ?>",
        "handler": function (response){
            // On successful payment, send values to verify-payment endpoint
            document.getElementById('checkout-card').innerHTML = `
                <div class="loader"></div>
                <h2>Verifying Payment</h2>
                <p>Registering ticket details in database...</p>
            `;
            
            const payload = {
                razorpay_order_id: response.razorpay_order_id,
                razorpay_payment_id: response.razorpay_payment_id,
                razorpay_signature: response.razorpay_signature,
                eventId: <?php echo (int)$eventId; ?>,
                fullName: "<?php echo addslashes($fullName); ?>",
                email: "<?php echo addslashes($email); ?>",
                rollNumber: "<?php echo addslashes($rollNumber); ?>",
                branch: "<?php echo addslashes($branch); ?>",
                currentYear: "<?php echo addslashes($currentYear); ?>",
                collegeName: "<?php echo addslashes($collegeName); ?>",
                domain: "<?php echo addslashes($domain); ?>",
                mode: "<?php echo addslashes($mode); ?>",
                teamName: "<?php echo addslashes($teamName); ?>",
                paymentMethod: "Razorpay Standard Checkout"
            };

            fetch('api.php/razorpay/verify-payment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + '<?php echo htmlspecialchars($token); ?>'
                },
                body: jsonString = JSON.stringify(payload)
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('checkout-card').innerHTML = `
                        <div style="font-size: 40px; margin-bottom: 16px;">✅</div>
                        <h2>Registration Confirmed!</h2>
                        <p>Your payment ID: <b>\${data.paymentId}</b> has been verified. You can now close this browser tab and return to the app.</p>
                        <button class="btn" onclick="window.close()">Close Window</button>
                    `;
                } else {
                    alert('Signature verification failed: ' + (data.error || 'Unknown error'));
                    location.reload();
                }
            })
            .catch(err => {
                alert('Connection error: ' + err);
                location.reload();
            });
        },
        "prefill": {
            "name": "<?php echo htmlspecialchars($fullName); ?>",
            "email": "<?php echo htmlspecialchars($email); ?>",
            "contact": "<?php echo htmlspecialchars($contact); ?>"
        },
        "theme": {
            "color": "#4F46E5"
        },
        "modal": {
            "ondismiss": function() {
                // If payment cancelled, reload page or show retry options
                alert("Payment cancelled by student.");
            }
        }
    };

    const rzp = new Razorpay(options);

    function openRazorpay() {
        rzp.open();
    }

    // Automatically trigger on page load
    window.onload = function() {
        openRazorpay();
    };
</script>
</body>
</html>
