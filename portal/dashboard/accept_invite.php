<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accept Team Invitation - CampusLink</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --background: #0f172a;
            --surface: rgba(30, 41, 59, 0.7);
            --border: rgba(255, 255, 255, 0.08);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --success: #10b981;
            --danger: #ef4444;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: radial-gradient(circle at top right, #1e1b4b 0%, #0f172a 100%);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            overflow-x: hidden;
        }

        h1, h2, h3 {
            font-family: 'Outfit', sans-serif;
        }

        .container {
            width: 100%;
            max-width: 480px;
            perspective: 1000px;
        }

        .card {
            background: var(--surface);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 40px 32px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            transition: all 0.4s ease;
        }

        .logo {
            text-align: center;
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            font-size: 28px;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #a5b4fc 0%, #6366f1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 28px;
        }

        .title {
            text-align: center;
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .subtitle {
            text-align: center;
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 32px;
            line-height: 1.5;
        }

        .tabs {
            display: flex;
            background: rgba(15, 23, 42, 0.6);
            padding: 6px;
            border-radius: 14px;
            margin-bottom: 24px;
            border: 1px solid rgba(255, 255, 255, 0.04);
        }

        .tab-btn {
            flex: 1;
            background: none;
            border: none;
            color: var(--text-muted);
            padding: 10px;
            font-size: 14px;
            font-weight: 600;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .tab-btn.active {
            background: var(--primary);
            color: #fff;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            background: rgba(15, 23, 42, 0.4);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
            color: #fff;
            font-family: inherit;
            font-size: 15px;
            transition: all 0.2s ease;
            outline: none;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
            background: rgba(15, 23, 42, 0.6);
        }

        .btn {
            width: 100%;
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 14px;
            padding: 16px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn:hover {
            background: var(--primary-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
        }

        .btn:active {
            transform: translateY(0);
        }

        .btn-outline {
            background: transparent;
            border: 2px solid var(--border);
            box-shadow: none;
            color: var(--text-main);
        }

        .btn-outline:hover {
            background: rgba(255, 255, 255, 0.04);
            border-color: var(--text-muted);
            box-shadow: none;
        }

        .btn-success {
            background: var(--success);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
        }

        .btn-success:hover {
            background: #059669;
            box-shadow: 0 6px 16px rgba(16, 185, 129, 0.35);
        }

        .btn-danger {
            background: var(--danger);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);
        }

        .btn-danger:hover {
            background: #dc2626;
            box-shadow: 0 6px 16px rgba(239, 68, 68, 0.35);
        }

        .alert {
            padding: 14px 16px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 24px;
            display: none;
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #fca5a5;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            border: 1px solid rgba(16, 185, 129, 0.3);
            color: #a7f3d0;
        }

        .invite-details {
            background: rgba(15, 23, 42, 0.5);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 32px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
            font-size: 14px;
        }

        .detail-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .detail-label {
            color: var(--text-muted);
            font-weight: 500;
        }

        .detail-val {
            font-weight: 600;
            text-align: right;
        }

        .actions {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .spinner {
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            display: none;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .fade-in {
            animation: fadeIn 0.4s ease-out forwards;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

    <div class="container">
        <!-- Main Card -->
        <div class="card fade-in" id="mainCard">
            <div class="logo">CampusLink</div>
            
            <!-- Alert Component -->
            <div class="alert alert-error" id="errorAlert"></div>
            <div class="alert alert-success" id="successAlert"></div>

            <!-- Panel 1: Login / Sign Up Forms -->
            <div id="authPanel">
                <h2 class="title" id="authTitle">Join Your Team</h2>
                <p class="subtitle" id="authSubtitle">To accept this invitation, please log in with your college account.</p>
                
                <div class="tabs">
                    <button class="tab-btn active" onclick="switchTab('login')">Sign In</button>
                    <button class="tab-btn" onclick="switchTab('signup')">Sign Up</button>
                </div>

                <!-- Login Form -->
                <form id="loginForm" onsubmit="handleLogin(event)">
                    <div class="form-group">
                        <label for="loginEmail">Student Email</label>
                        <input type="email" id="loginEmail" class="form-control" placeholder="e.g. 22cse1000@gvpce.ac.in" required>
                    </div>
                    <div class="form-group">
                        <label for="loginPassword">Password</label>
                        <input type="password" id="loginPassword" class="form-control" placeholder="••••••••" required>
                    </div>
                    <button type="submit" class="btn" id="loginSubmitBtn">
                        <span class="spinner" id="loginSpinner"></span>
                        Sign In & Continue
                    </button>
                </form>

                <!-- Signup Form -->
                <form id="signupForm" style="display: none;" onsubmit="handleSignup(event)">
                    <div class="form-group">
                        <label for="signupName">Full Name</label>
                        <input type="text" id="signupName" class="form-control" placeholder="e.g. Dinesh Kasi" required>
                    </div>
                    <div class="form-group">
                        <label for="signupEmail">College Email</label>
                        <input type="email" id="signupEmail" class="form-control" placeholder="username@gvpce.ac.in" required>
                    </div>
                    <div class="form-group">
                        <label for="signupPassword">Password</label>
                        <input type="password" id="signupPassword" class="form-control" placeholder="Min. 6 characters" required>
                    </div>
                    <button type="submit" class="btn" id="signupSubmitBtn">
                        <span class="spinner" id="signupSpinner"></span>
                        Create Account & Continue
                    </button>
                </form>
            </div>

            <!-- Panel 2: Invitation Details & Actions -->
            <div id="invitePanel" style="display: none;">
                <h2 class="title">Team Invitation</h2>
                <p class="subtitle">You have been invited to join the following hackathon team. Accepting will link your registration.</p>

                <div class="invite-details">
                    <div class="detail-row">
                        <span class="detail-label">Event</span>
                        <span class="detail-val" id="detailEvent">--</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Team Name</span>
                        <span class="detail-val" id="detailTeam">--</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Leader</span>
                        <span class="detail-val" id="detailLeader">--</span>
                    </div>
                    <div class="detail-row" id="statusRow" style="display: none;">
                        <span class="detail-label">Status</span>
                        <span class="detail-val" id="detailStatus">--</span>
                    </div>
                </div>

                <div class="actions" id="actionButtons">
                    <button class="btn btn-success" onclick="processInvitation('accept')">
                        <span class="spinner" id="acceptSpinner"></span>
                        Accept Invitation
                    </button>
                    <button class="btn btn-outline" onclick="processInvitation('decline')">
                        <span class="spinner" id="declineSpinner"></span>
                        Decline
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        const API_BASE = '/portal/backend/api.php';
        let currentTab = 'login';
        let invitationId = new URLSearchParams(window.location.search).get('id');

        window.onload = function() {
            if (!invitationId) {
                showError("Error: Invalid or missing invitation ID in URL.");
                document.getElementById('authPanel').style.display = 'none';
                return;
            }
            
            // Check if logged in
            const token = localStorage.getItem('token');
            if (token) {
                loadInvitationDetails();
            }
        };

        function switchTab(tab) {
            currentTab = tab;
            const tabButtons = document.querySelectorAll('.tab-btn');
            const loginForm = document.getElementById('loginForm');
            const signupForm = document.getElementById('signupForm');
            
            if (tab === 'login') {
                tabButtons[0].classList.add('active');
                tabButtons[1].classList.remove('active');
                loginForm.style.display = 'block';
                signupForm.style.display = 'none';
                document.getElementById('authTitle').innerText = "Join Your Team";
                document.getElementById('authSubtitle').innerText = "To accept this invitation, please log in with your college account.";
            } else {
                tabButtons[0].classList.remove('active');
                tabButtons[1].classList.add('active');
                loginForm.style.display = 'none';
                signupForm.style.display = 'block';
                document.getElementById('authTitle').innerText = "Create Account";
                document.getElementById('authSubtitle').innerText = "Sign up using your college email address to join your team.";
            }
            clearAlerts();
        }

        function showError(msg) {
            const errorAlert = document.getElementById('errorAlert');
            errorAlert.innerText = msg;
            errorAlert.style.display = 'block';
            document.getElementById('successAlert').style.display = 'none';
        }

        function showSuccess(msg) {
            const successAlert = document.getElementById('successAlert');
            successAlert.innerText = msg;
            successAlert.style.display = 'block';
            document.getElementById('errorAlert').style.display = 'none';
        }

        function clearAlerts() {
            document.getElementById('errorAlert').style.display = 'none';
            document.getElementById('successAlert').style.display = 'none';
        }

        function handleLogin(e) {
            e.preventDefault();
            clearAlerts();
            
            const email = document.getElementById('loginEmail').value.trim();
            const password = document.getElementById('loginPassword').value.trim();
            
            document.getElementById('loginSpinner').style.display = 'inline-block';
            document.getElementById('loginSubmitBtn').disabled = true;

            fetch(`${API_BASE}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            })
            .then(res => res.json())
            .then(data => {
                document.getElementById('loginSpinner').style.display = 'none';
                document.getElementById('loginSubmitBtn').disabled = false;
                
                if (data.error) {
                    showError(data.error);
                } else {
                    localStorage.setItem('token', data.token);
                    localStorage.setItem('user', JSON.stringify(data.user));
                    loadInvitationDetails();
                }
            })
            .catch(err => {
                document.getElementById('loginSpinner').style.display = 'none';
                document.getElementById('loginSubmitBtn').disabled = false;
                showError("Network error. Please try again.");
            });
        }

        function handleSignup(e) {
            e.preventDefault();
            clearAlerts();

            const name = document.getElementById('signupName').value.trim();
            const email = document.getElementById('signupEmail').value.trim();
            const password = document.getElementById('signupPassword').value.trim();

            if (password.length < 6) {
                showError("Password must be at least 6 characters.");
                return;
            }

            document.getElementById('signupSpinner').style.display = 'inline-block';
            document.getElementById('signupSubmitBtn').disabled = true;

            fetch(`${API_BASE}/auth/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, email, password })
            })
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    document.getElementById('signupSpinner').style.display = 'none';
                    document.getElementById('signupSubmitBtn').disabled = false;
                    showError(data.error);
                } else {
                    // Automatically log the user in after registration
                    fetch(`${API_BASE}/auth/login`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ email, password })
                    })
                    .then(res => res.json())
                    .then(loginData => {
                        document.getElementById('signupSpinner').style.display = 'none';
                        document.getElementById('signupSubmitBtn').disabled = false;
                        
                        if (loginData.error) {
                            showError("Registration succeeded, but auto-login failed. Please sign in manually.");
                            switchTab('login');
                        } else {
                            localStorage.setItem('token', loginData.token);
                            localStorage.setItem('user', JSON.stringify(loginData.user));
                            loadInvitationDetails();
                        }
                    });
                }
            })
            .catch(err => {
                document.getElementById('signupSpinner').style.display = 'none';
                document.getElementById('signupSubmitBtn').disabled = false;
                showError("Network error. Please try again.");
            });
        }

        function loadInvitationDetails() {
            clearAlerts();
            const token = localStorage.getItem('token');
            
            fetch(`${API_BASE}/team/invitations/detail?id=${invitationId}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            })
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    showError(data.error);
                    // If unauthorized, clear tokens and show login
                    if (data.error.includes("Unauthorized") || data.error.includes("expired")) {
                        localStorage.removeItem('token');
                        localStorage.removeItem('user');
                        document.getElementById('authPanel').style.display = 'block';
                        document.getElementById('invitePanel').style.display = 'none';
                    }
                } else {
                    document.getElementById('authPanel').style.display = 'none';
                    document.getElementById('invitePanel').style.display = 'block';
                    
                    document.getElementById('detailEvent').innerText = data.eventTitle;
                    document.getElementById('detailTeam').innerText = data.teamName;
                    document.getElementById('detailLeader').innerText = data.leaderEmail;

                    if (data.status !== 'pending') {
                        document.getElementById('statusRow').style.display = 'flex';
                        document.getElementById('detailStatus').innerText = data.status.toUpperCase();
                        document.getElementById('actionButtons').style.display = 'none';
                        
                        if (data.status === 'accepted') {
                            showSuccess("You have already accepted this invitation!");
                        } else {
                            showError("This invitation has already been declined.");
                        }
                    }
                }
            })
            .catch(err => {
                showError("Could not fetch invitation details.");
            });
        }

        function processInvitation(action) {
            clearAlerts();
            const token = localStorage.getItem('token');
            const spinner = document.getElementById(`${action}Spinner`);
            const buttons = document.querySelectorAll('.actions .btn');
            
            spinner.style.display = 'inline-block';
            buttons.forEach(btn => btn.disabled = true);

            fetch(`${API_BASE}/team/invitations/${action}`, {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ inviteId: parseInt(invitationId) })
            })
            .then(res => res.json())
            .then(data => {
                spinner.style.display = 'none';
                buttons.forEach(btn => btn.disabled = false);
                
                if (data.error) {
                    showError(data.error);
                } else {
                    document.getElementById('actionButtons').style.display = 'none';
                    document.getElementById('statusRow').style.display = 'flex';
                    document.getElementById('detailStatus').innerText = (action === 'accept' ? 'ACCEPTED' : 'DECLINED');

                    if (action === 'accept') {
                        showSuccess("Invitation accepted successfully! Your registration is now pending leader checkout. You can download the mobile app to view your tickets once payment is completed.");
                    } else {
                        showError("Invitation declined.");
                    }
                }
            })
            .catch(err => {
                spinner.style.display = 'none';
                buttons.forEach(btn => btn.disabled = false);
                showError("Network error. Please try again.");
            });
        }
    </script>
</body>
</html>
