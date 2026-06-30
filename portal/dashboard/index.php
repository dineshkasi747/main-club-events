<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusLink Portal - Club Administration</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <!-- 1. LOGIN SCREEN -->
    <?php include_once __DIR__ . '/login.php'; ?>

    <!-- 2. DASHBOARD SCREEN -->
    <div id="dashboard-root" style="display: none;">
        <div class="dashboard-wrapper">
            <div class="sidebar">
                <div class="logo-section">
                    <h2>CampusLink</h2>
                </div>
                <ul class="nav-links">
                    <li class="nav-item active" onclick="switchTab('overview')">📢 Overview & Broadcast</li>
                    <li class="nav-item" onclick="switchTab('events')">📅 Event Manager</li>
                    <li class="nav-item" onclick="switchTab('verifications')">🔍 Verify Payments</li>
                    <li class="nav-item" onclick="switchTab('scanner')">🎟️ Ticket Scanner</li>
                </ul>
                <div style="margin-top: auto;">
                    <button class="btn btn-outline" style="width: 100%;" onclick="handleLogout()">Sign Out</button>
                </div>
            </div>

            <div class="main-content">
                <header>
                    <div class="header-title">
                        <h1 id="welcome-title">Welcome Admin</h1>
                        <p id="welcome-subtitle">Club administration controls</p>
                    </div>
                </header>

                <!-- TAB: OVERVIEW & ANNOUNCEMENT -->
                <?php include_once __DIR__ . '/components/overview.php'; ?>

                <!-- TAB: EVENTS -->
                <?php include_once __DIR__ . '/components/events.php'; ?>

                <!-- TAB: VERIFY PAYMENTS -->
                <?php include_once __DIR__ . '/components/verifications.php'; ?>

                <!-- TAB: SCANNER -->
                <?php include_once __DIR__ . '/components/scanner.php'; ?>
            </div>
        </div>
    </div>

    <!-- 3. OVERLAY MODALS -->
    <?php include_once __DIR__ . '/components/modals.php'; ?>

    <script src="js/app.js"></script>
</body>
</html>
