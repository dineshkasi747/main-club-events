<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusLink Portal — Club Administration</title>
    <meta name="description" content="CampusLink Portal — Premium club event administration dashboard for campus organizations.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <!-- 1. LOGIN SCREEN -->
    <?php include_once __DIR__ . '/login.php'; ?>

    <!-- 2. DASHBOARD SCREEN -->
    <div id="dashboard-root" style="display: none;">
        <div class="dashboard-wrapper">
            <nav class="sidebar" role="navigation" aria-label="Main navigation">
                <div class="logo-section">
                    <h2>CampusLink</h2>
                </div>
                <ul class="nav-links">
                    <li class="nav-item active" id="nav-item-overview" onclick="switchTab('overview')">
                        <span class="nav-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"></path><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"></path></svg></span>
                        Overview & Broadcast
                    </li>
                    <li class="nav-item" id="nav-item-events" onclick="switchTab('events')">
                        <span class="nav-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"></rect><line x1="16" x2="16" y1="2" y2="6"></line><line x1="8" x2="8" y1="2" y2="6"></line><line x1="3" x2="21" y1="10" y2="10"></line></svg></span>
                        Event Manager
                    </li>
                    <li class="nav-item" id="nav-item-verifications" onclick="switchTab('verifications')">
                        <span class="nav-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10"></path><path d="m9 12 2 2 4-4"></path></svg></span>
                        Verify Payments
                    </li>
                    <li class="nav-item" id="nav-item-scanner" onclick="switchTab('scanner')">
                        <span class="nav-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2Z"></path><path d="M13 5v2"></path><path d="M13 17v2"></path><path d="M13 11v2"></path></svg></span>
                        Ticket Scanner
                    </li>
                    <li class="nav-item" id="nav-item-clubs" style="display: none;" onclick="switchTab('clubs')">
                        <span class="nav-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"></path><path d="M9 8h1"></path><path d="M9 12h1"></path><path d="M9 16h1"></path><path d="M14 8h1"></path><path d="M14 12h1"></path><path d="M14 16h1"></path><path d="M5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16"></path></svg></span>
                        Manage Clubs
                    </li>
                </ul>
                <div style="margin-top: auto;">
                    <button class="btn btn-outline" style="width: 100%;" onclick="handleLogout()">Sign Out</button>
                </div>
            </nav>

            <main class="main-content">
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
                    <div id="club-form-card" class="card" style="display: none; margin-bottom: 24px;">
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
            </main>
        </div>
    </div>

    <!-- 3. OVERLAY MODALS -->
    <?php include_once __DIR__ . '/components/modals.php'; ?>

    <script src="js/app.js"></script>
</body>
</html>
