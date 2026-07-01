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
                    <li class="nav-item active" id="nav-item-overview" onclick="switchTab('overview')">📢 Overview & Broadcast</li>
                    <li class="nav-item" id="nav-item-events" onclick="switchTab('events')">📅 Event Manager</li>
                    <li class="nav-item" id="nav-item-verifications" onclick="switchTab('verifications')">🔍 Verify Payments</li>
                    <li class="nav-item" id="nav-item-scanner" onclick="switchTab('scanner')">🎟️ Ticket Scanner</li>
                    <li class="nav-item" id="nav-item-clubs" style="display: none;" onclick="switchTab('clubs')">🏢 Manage Clubs</li>
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

                <!-- TAB: MANAGE CLUBS (Admin only) -->
                <div id="tab-clubs" class="tab-content" style="display: none;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                        <h2>Club Administration</h2>
                        <button class="btn btn-primary" onclick="toggleClubForm(true)">+ Create New Club</button>
                    </div>

                    <!-- Club creation drawer/card -->
                    <div id="club-form-card" class="card" style="display: none; border-top: 4px solid var(--color-brand); margin-bottom: 24px;">
                        <h3>Create New Club & President</h3>
                        <div id="club-form-alert" class="alert alert-error" style="display: none;"></div>
                        <form id="club-creation-form" style="margin-top: 16px;">
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                                <div class="form-group">
                                    <label>Club Name</label>
                                    <input type="text" id="club-name" class="form-control" placeholder="e.g. Robotics Club" required>
                                </div>
                                <div class="form-group">
                                    <label>President Name</label>
                                    <input type="text" id="club-president-name" class="form-control" placeholder="e.g. John Doe" required>
                                </div>
                            </div>
                            <div class="form-group" style="margin-bottom: 16px;">
                                <label>Club Description</label>
                                <textarea id="club-desc" class="form-control" placeholder="Describe the club's mission and activities..." required></textarea>
                            </div>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px;">
                                <div class="form-group">
                                    <label>President Login Email</label>
                                    <input type="email" id="club-president-email" class="form-control" placeholder="e.g. robotics@college.edu" required>
                                </div>
                                <div class="form-group">
                                    <label>President Password</label>
                                    <input type="password" id="club-president-password" class="form-control" placeholder="e.g. securepassword" required>
                                </div>
                            </div>
                            <div style="display: flex; gap: 12px;">
                                <button type="submit" class="btn btn-primary">Create Club</button>
                                <button type="button" class="btn btn-outline" onclick="toggleClubForm(false)">Cancel</button>
                            </div>
                        </form>
                    </div>

                    <div class="grid-2" id="clubs-grid-container">
                        <!-- Filled dynamically -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 3. OVERLAY MODALS -->
    <?php include_once __DIR__ . '/components/modals.php'; ?>

    <script src="js/app.js"></script>
</body>
</html>
