const API_BASE = window.location.origin + '/college/portal/backend/api.php';

let token = localStorage.getItem('token');
let user = JSON.parse(localStorage.getItem('user'));
let activeTab = 'overview';
let subTab = 'paid';

let events = [];
let registrations = [];
let selectedEventDetails = null;

// Initialize App
document.addEventListener('DOMContentLoaded', () => {
    const loginRoot = document.getElementById('login-root');
    const dashboardRoot = document.getElementById('dashboard-root');

    if (!token || !user) {
        if (loginRoot) loginRoot.style.display = 'flex';
        if (dashboardRoot) dashboardRoot.style.display = 'none';
    } else {
        if (loginRoot) loginRoot.style.display = 'none';
        if (dashboardRoot) dashboardRoot.style.display = 'block';
        
        const welcomeTitle = document.getElementById('welcome-title');
        const welcomeSubtitle = document.getElementById('welcome-subtitle');
        if (welcomeTitle) welcomeTitle.innerText = `Hello, ${user.name} 👋`;
        if (welcomeSubtitle) welcomeSubtitle.innerText = `President of Club ID: ${user.clubId || 'Admin'}`;
        
        fetchDashboardData();
    }
});

// Toggle Vol Limit Input in Event form
function toggleVolLimitField() {
    const isChecked = document.getElementById('event-vol-reg').checked;
    const volLimitContainer = document.getElementById('vol-limit-container');
    if (volLimitContainer) volLimitContainer.style.display = isChecked ? 'flex' : 'none';
}

// Toggle creation form drawer
function toggleEventForm(show) {
    const eventFormCard = document.getElementById('event-form-card');
    if (eventFormCard) eventFormCard.style.display = show ? 'block' : 'none';
}

// Switch main sidebar tabs
function switchTab(tabName) {
    activeTab = tabName;
    
    // Highlight nav links
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    const idx = ['overview', 'events', 'verifications', 'scanner'].indexOf(tabName);
    if (idx !== -1) {
        document.querySelectorAll('.nav-item')[idx].classList.add('active');
    }

    // Toggle tab visibility
    document.querySelectorAll('.tab-content').forEach(el => el.style.display = 'none');
    const targetTab = document.getElementById(`tab-${tabName}`);
    if (targetTab) targetTab.style.display = 'block';

    if (tabName === 'verifications') {
        renderVerificationsTable();
    }
}

// Login logic
const loginForm = document.getElementById('login-form');
if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const emailVal = document.getElementById('email').value.trim();
        const passwordVal = document.getElementById('password').value.trim();
        const errorAlert = document.getElementById('login-error');

        if (errorAlert) errorAlert.style.display = 'none';

        try {
            const res = await fetch(`${API_BASE}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: emailVal, password: passwordVal })
            });
            
            if (res.ok) {
                const data = await res.json();
                localStorage.setItem('token', data.token);
                localStorage.setItem('user', JSON.stringify(data.user));
                window.location.reload();
            } else {
                const err = await res.json();
                if (errorAlert) {
                    errorAlert.innerText = err.error || 'Authentication failed';
                    errorAlert.style.display = 'block';
                }
            }
        } catch (err) {
            if (errorAlert) {
                errorAlert.innerText = 'Network communication error';
                errorAlert.style.display = 'block';
            }
        }
    });
}

// Logout logic
function handleLogout() {
    localStorage.clear();
    window.location.reload();
}

// Fetch Dashboard Data
async function fetchDashboardData() {
    try {
        const headers = { 'Authorization': `Bearer ${token}` };
        
        // Fetch events
        const evRes = await fetch(`${API_BASE}/events`);
        if (evRes.ok) {
            events = await evRes.json();
            // filter to only events of the logged in president's club (if user is president)
            if (user.role === 'president') {
                events = events.filter(e => e.clubId === user.clubId);
            }
            renderEventsGrid();
        }

        // Fetch registrations
        const regRes = await fetch(`${API_BASE}/registrations`, { headers });
        if (regRes.ok) {
            registrations = await regRes.json();
            renderStats();
            renderVerificationsTable();
        }
    } catch (err) {
        console.error("Failed to load dashboard data:", err);
    }
}

// Render Overview Stats Card Values
function renderStats() {
    const participantCount = registrations.filter(r => r.type === 'participant').length;
    const approvedCount = registrations.filter(r => r.status === 'approved' || r.status === 'attended').length;
    const volunteerCount = registrations.filter(r => r.type === 'volunteer').length;

    const statsTotalRegs = document.getElementById('stats-total-regs');
    const statsVerifiedRegs = document.getElementById('stats-verified-regs');
    const statsVolunteers = document.getElementById('stats-volunteers');

    if (statsTotalRegs) statsTotalRegs.innerText = participantCount;
    if (statsVerifiedRegs) statsVerifiedRegs.innerText = approvedCount;
    if (statsVolunteers) statsVolunteers.innerText = volunteerCount;
}

// Broadcast Announcement Form Submit
const broadcastForm = document.getElementById('broadcast-form');
if (broadcastForm) {
    broadcastForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const alertBox = document.getElementById('broadcast-alert');
        const titleVal = document.getElementById('ann-title').value.trim();
        const bodyVal = document.getElementById('ann-body').value.trim();

        if (alertBox) alertBox.style.display = 'none';

        try {
            const clubId = user.clubId || 101;
            const res = await fetch(`${API_BASE}/notify/club/${clubId}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ title: titleVal, body: bodyVal })
            });

            if (res.ok) {
                if (alertBox) {
                    alertBox.innerText = '✅ Announcement broadcasted successfully!';
                    alertBox.className = 'alert alert-success';
                    alertBox.style.display = 'block';
                }
                broadcastForm.reset();
                fetchDashboardData();
            } else {
                const err = await res.json();
                if (alertBox) {
                    alertBox.innerText = err.error || 'Failed to send announcement';
                    alertBox.className = 'alert alert-error';
                    alertBox.style.display = 'block';
                }
            }
        } catch (err) {
            if (alertBox) {
                alertBox.innerText = 'Network communication error';
                alertBox.className = 'alert alert-error';
                alertBox.style.display = 'block';
            }
        }
    });
}

// Event Creation Form Submit
const eventCreationForm = document.getElementById('event-creation-form');
if (eventCreationForm) {
    eventCreationForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const formAlert = document.getElementById('event-form-alert');
        if (formAlert) formAlert.style.display = 'none';

        const title = document.getElementById('event-title').value.trim();
        const venue = document.getElementById('event-venue').value.trim();
        const description = document.getElementById('event-desc').value.trim();
        const dateString = document.getElementById('event-date').value.trim();
        const price = parseFloat(document.getElementById('event-price').value) || 0.00;
        const capacity = parseInt(document.getElementById('event-capacity').value) || 100;

        const freeRegistration = document.getElementById('event-free-reg').checked;
        const paidRegistration = document.getElementById('event-paid-reg').checked;
        const volunteerRegistration = document.getElementById('event-vol-reg').checked;
        const volunteerLimit = parseInt(document.getElementById('event-vol-limit').value) || 0;

        try {
            const res = await fetch(`${API_BASE}/events`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    title, venue, description, dateString, price, capacity,
                    freeRegistration, paidRegistration, volunteerRegistration, volunteerLimit
                })
            });

            if (res.ok) {
                eventCreationForm.reset();
                toggleEventForm(false);
                fetchDashboardData();
            } else {
                const err = await res.json();
                if (formAlert) {
                    formAlert.innerText = err.error || 'Failed to publish event';
                    formAlert.style.display = 'block';
                }
            }
        } catch (err) {
            if (formAlert) {
                formAlert.innerText = 'Network communication error';
                formAlert.style.display = 'block';
            }
        }
    });
}

// Render Events Grid
function renderEventsGrid() {
    const container = document.getElementById('events-grid-container');
    if (!container) return;
    container.innerHTML = '';

    if (events.length === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary); grid-column: span 2;">No events found.</p>';
        return;
    }

    events.forEach(e => {
        const regs = registrations.filter(r => r.eventId === e.id && r.status !== 'cancelled');
        const regCount = regs.filter(r => r.type === 'participant').length;
        const volCount = regs.filter(r => r.type === 'volunteer').length;

        const cardHtml = `
            <div class="card event-card">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <span class="badge" style="background-color: var(--color-brand-light); color: var(--color-brand);">
                            ${e.price > 0 ? `₹${e.price}` : 'FREE'}
                        </span>
                        <span class="badge badge-approved">${e.status}</span>
                    </div>
                    <h3 style="font-size: 17px; font-weight: 700; margin-bottom: 8px;">${e.title}</h3>
                    <p style="color: var(--text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 16px;">${e.description}</p>
                    
                    <div class="event-details-box">
                        <div>📍 ${e.venue}</div>
                        <div>📅 ${e.dateString}</div>
                        <div>👥 Capacity: ${e.capacity} (Booked: ${regCount})</div>
                        ${e.volunteerRegistration ? `<div style="color: var(--color-success); font-weight: 600;">🤝 Volunteers: ${volCount} / ${e.volunteerLimit} limit</div>` : ''}
                    </div>
                </div>
                <button class="btn btn-outline" style="width: 100%; margin-top: 12px;" onclick="openRegistrantsModal(${e.id})">
                    📊 Manage Registrants
                </button>
            </div>
        `;
        container.innerHTML += cardHtml;
    });
}

// Render Pending Verify Table
function renderVerificationsTable() {
    const tbody = document.getElementById('verifications-tbody');
    if (!tbody) return;
    tbody.innerHTML = '';

    const pendingBookings = registrations.filter(r => r.type === 'participant');

    if (pendingBookings.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--text-secondary);">No student registrations submitted yet.</td></tr>';
        return;
    }

    pendingBookings.forEach(r => {
        const actionBtn = r.status === 'pending' 
            ? `<button class="btn btn-success" style="padding: 6px 12px; font-size: 12px; border-radius: 6px;" onclick="handleVerifyBooking(${r.id})">Verify & Approve</button>`
            : `<span style="font-size: 12px; color: var(--text-muted);">Verified</span>`;

        const paymentSummary = r.paymentAmount > 0
            ? `<div>
                 <div style="font-weight:700; color:var(--color-success);">₹${parseFloat(r.paymentAmount).toFixed(2)}</div>
                 <div style="font-size: 11px; font-weight: bold; color: var(--color-brand); margin-top: 4px;">Ref: ${r.upiRefId || r.transactionId}</div>
                 ${r.paymentScreenshot ? `<button class="btn btn-outline" style="padding: 2px 6px; font-size: 9px; margin-top: 4px;" onclick="zoomScreenshot('${r.paymentScreenshot}')">View Screenshot 🔍</button>` : ''}
               </div>`
            : '<span style="color: var(--text-secondary);">FREE ENTRY</span>';

        const row = `
            <tr>
                <td style="font-weight: bold;">#${r.id}</td>
                <td>
                    <div style="font-weight: 600;">${r.userName}</div>
                    <div style="font-size: 11px; color: var(--text-secondary);">${r.userRollNumber} • ${r.userBranch}</div>
                </td>
                <td>
                    <div style="font-weight: 600;">${r.eventTitle}</div>
                    <div style="font-size: 11px; color: var(--text-muted);">${r.eventDate}</div>
                </td>
                <td>${paymentSummary}</td>
                <td><span class="badge badge-${r.status}">${r.status}</span></td>
                <td>${actionBtn}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// Verify and approve booking
async function handleVerifyBooking(regId) {
    if (!confirm("Are you sure you want to verify this payment and approve ticket entry?")) return;
    try {
        const res = await fetch(`${API_BASE}/registrations/${regId}/verify`, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
            fetchDashboardData();
        } else {
            alert("Approval failed");
        }
    } catch (err) {
        alert("Network communication error.");
    }
}

// Zoom receipt photo
function zoomScreenshot(url) {
    const screenshotImg = document.getElementById('screenshot-img');
    const screenshotModal = document.getElementById('screenshot-modal');
    if (screenshotImg && screenshotModal) {
        screenshotImg.src = url;
        screenshotModal.style.display = 'flex';
    }
}

function closeScreenshotModal() {
    const screenshotModal = document.getElementById('screenshot-modal');
    if (screenshotModal) screenshotModal.style.display = 'none';
}

// Event detailed registrants modal
function openRegistrantsModal(eventId) {
    selectedEventDetails = events.find(e => e.id === eventId);
    if (!selectedEventDetails) return;

    const regModalTitle = document.getElementById('reg-modal-title');
    const regModalSubtitle = document.getElementById('reg-modal-subtitle');
    const registrantsModal = document.getElementById('registrants-modal');

    if (regModalTitle) regModalTitle.innerText = `${selectedEventDetails.title} Roster`;
    if (regModalSubtitle) regModalSubtitle.innerText = `Event ID: #${selectedEventDetails.id}`;
    
    if (registrantsModal) registrantsModal.style.display = 'flex';
    switchSubTab('paid');
}

function closeRegistrantsModal() {
    const registrantsModal = document.getElementById('registrants-modal');
    if (registrantsModal) registrantsModal.style.display = 'none';
    selectedEventDetails = null;
}

function switchSubTab(subTabName) {
    subTab = subTabName;
    
    // Highlight subtabs
    document.querySelectorAll('.subtab-btn').forEach(btn => btn.classList.remove('active'));
    const targetSubtabBtn = document.getElementById(`subtab-${subTabName}`);
    if (targetSubtabBtn) targetSubtabBtn.classList.add('active');

    renderRegistrantsSubTabList();
}

function renderRegistrantsSubTabList() {
    const tableContainer = document.getElementById('registrants-table-container');
    if (!tableContainer) return;
    tableContainer.innerHTML = '';

    const eventRegs = registrations.filter(r => r.eventId === selectedEventDetails.id && r.status !== 'cancelled');
    
    const eventPaid = eventRegs.filter(r => r.type === 'participant' && r.eventPrice > 0);
    const eventFree = eventRegs.filter(r => r.type === 'participant' && r.eventPrice === 0);
    const eventVolunteers = eventRegs.filter(r => r.type === 'volunteer');

    // Update count badges
    const subtabPaid = document.getElementById('subtab-paid');
    const subtabFree = document.getElementById('subtab-free');
    const subtabVol = document.getElementById('subtab-vol');

    if (subtabPaid) subtabPaid.innerText = `💰 Paid Registrants (${eventPaid.length})`;
    if (subtabFree) subtabFree.innerText = `🎟️ Free Registrants (${eventFree.length})`;
    if (subtabVol) subtabVol.innerText = `🤝 Volunteers (${eventVolunteers.length})`;

    let targetList = [];
    if (subTab === 'paid') targetList = eventPaid;
    if (subTab === 'free') targetList = eventFree;
    if (subTab === 'volunteer') targetList = eventVolunteers;

    if (targetList.length === 0) {
        tableContainer.innerHTML = `<p style="text-align: center; color: var(--text-secondary); padding: 32px 0;">No registrations listed in this category.</p>`;
        return;
    }

    let tableHtml = `
        <table>
            <thead>
                <tr>
                    <th>Student</th>
                    ${subTab === 'paid' ? '<th>Payment Details</th>' : ''}
                    ${subTab !== 'paid' ? '<th>Roll Number</th><th>Branch</th>' : ''}
                    <th>Status</th>
                    ${subTab === 'paid' ? '<th>Action</th>' : ''}
                </tr>
            </thead>
            <tbody>
    `;

    targetList.forEach(r => {
        let actionTd = '';
        if (subTab === 'paid') {
            const actionBtn = r.status === 'pending'
                ? `<button class="btn btn-success" style="padding: 4px 10px; font-size: 11px; border-radius: 6px;" onclick="handleVerifyBooking(${r.id}); closeRegistrantsModal();">Verify Payment</button>`
                : `<span style="font-size: 11px; color: var(--text-muted);">Verified</span>`;
            actionTd = `<td>${actionBtn}</td>`;
        }

        let detailsTd = '';
        if (subTab === 'paid') {
            detailsTd = `
                <td>
                    <div style="font-weight: bold;">₹${parseFloat(r.paymentAmount).toFixed(2)}</div>
                    <div style="font-size: 10px; color: var(--color-brand); font-weight: bold;">Ref: ${r.upiRefId || r.transactionId}</div>
                    ${r.paymentScreenshot ? `<button class="btn btn-outline" style="padding: 2px 6px; font-size: 9px; margin-top: 4px;" onclick="zoomScreenshot('${r.paymentScreenshot}')">View Screenshot 🔍</button>` : ''}
                </td>
            `;
        } else {
            detailsTd = `
                <td>${r.userRollNumber}</td>
                <td>${r.userBranch}</td>
            `;
        }

        tableHtml += `
            <tr>
                <td>
                    <div style="font-weight: 600;">${r.userName}</div>
                    <div style="font-size: 11px; color: var(--text-muted);">${r.userRollNumber} • ${r.userBranch}</div>
                </td>
                ${detailsTd}
                <td><span class="badge badge-${r.status}">${r.status}</span></td>
                ${actionTd}
            </tr>
        `;
    });

    tableHtml += `</tbody></table>`;
    tableContainer.innerHTML = tableHtml;
}

// Ticket checkin form submit
const scannerForm = document.getElementById('scanner-form');
if (scannerForm) {
    scannerForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const alertBox = document.getElementById('scanner-alert');
        const scanCode = document.getElementById('scan-code').value.trim();

        if (alertBox) alertBox.style.display = 'none';

        try {
            const res = await fetch(`${API_BASE}/registrations/${scanCode}/admit`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` }
            });

            if (res.ok) {
                const data = await res.json();
                if (alertBox) {
                    alertBox.innerHTML = `✅ Ticket Verified! <strong>${data.registration.userName}</strong> (Roll: ${data.registration.userRollNumber}) checked in successfully!`;
                    alertBox.className = 'alert alert-success';
                    alertBox.style.display = 'block';
                }
                document.getElementById('scan-code').value = '';
                fetchDashboardData();
            } else {
                const err = await res.json();
                if (alertBox) {
                    alertBox.innerText = `❌ Error: ${err.error || 'Check-in verification failed'}`;
                    alertBox.className = 'alert alert-error';
                    alertBox.style.display = 'block';
                }
            }
        } catch (err) {
            if (alertBox) {
                alertBox.innerText = 'Network communication error';
                alertBox.className = 'alert alert-error';
                alertBox.style.display = 'block';
            }
        }
    });
}
