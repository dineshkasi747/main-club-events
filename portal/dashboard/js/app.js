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
        if (welcomeSubtitle) welcomeSubtitle.innerText = `Role: ${user.role === 'admin' ? 'Campus Admin' : `President of Club ID: ${user.clubId}`}`;

        // Admin-only layout additions
        if (user.role === 'admin') {
            const navClubs = document.getElementById('nav-item-clubs');
            const clubGroup = document.getElementById('event-club-group');
            const pastClubGroup = document.getElementById('past-event-club-group');
            if (navClubs) navClubs.style.display = 'block';
            if (clubGroup) clubGroup.style.display = 'block';
            if (pastClubGroup) pastClubGroup.style.display = 'block';
        }
        
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
    document.querySelectorAll('.nav-links .nav-item').forEach(el => el.classList.remove('active'));
    const activeNav = document.getElementById(`nav-item-${tabName}`);
    if (activeNav) {
        activeNav.classList.add('active');
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
            // filter registrations scoped to president
            if (user.role === 'president') {
                registrations = registrations.filter(r => r.eventClubId === user.clubId);
            }
            renderStats();
            renderVerificationsTable();
        }

        // Fetch past historical events
        const pastEvRes = await fetch(`${API_BASE}/historical-events`);
        if (pastEvRes.ok) {
            let pastEventsList = await pastEvRes.json();
            if (user.role === 'president') {
                pastEventsList = pastEventsList.filter(e => e.clubId === user.clubId);
            }
            renderPastEventsGrid(pastEventsList);
        }

        // Admin-only fetch for clubs
        if (user.role === 'admin') {
            const clubsRes = await fetch(`${API_BASE}/clubs`);
            if (clubsRes.ok) {
                const clubs = await clubsRes.json();
                
                // Populate club select in event creation & past event creation
                const selectElement = document.getElementById('event-club-select');
                const pastSelectElement = document.getElementById('past-event-club-select');
                if (selectElement) {
                    selectElement.innerHTML = '';
                    clubs.forEach(c => {
                        selectElement.innerHTML += `<option value="${c.id}">${c.name} (ID: ${c.id})</option>`;
                    });
                }
                if (pastSelectElement) {
                    pastSelectElement.innerHTML = '';
                    clubs.forEach(c => {
                        pastSelectElement.innerHTML += `<option value="${c.id}">${c.name} (ID: ${c.id})</option>`;
                    });
                }
                
                renderClubsGrid(clubs);
            }
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

        let clubId = null;
        if (user.role === 'admin') {
            const selectEl = document.getElementById('event-club-select');
            if (selectEl) clubId = parseInt(selectEl.value);
        }

        try {
            const res = await fetch(`${API_BASE}/events`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    title, venue, description, dateString, price, capacity,
                    freeRegistration, paidRegistration, volunteerRegistration, volunteerLimit,
                    clubId: clubId
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

// Toggle Club Creation Drawer
function toggleClubForm(show) {
    const clubFormCard = document.getElementById('club-form-card');
    if (clubFormCard) clubFormCard.style.display = show ? 'block' : 'none';
}

// Club Creation Form Submit
const clubCreationForm = document.getElementById('club-creation-form');
if (clubCreationForm) {
    clubCreationForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const formAlert = document.getElementById('club-form-alert');
        if (formAlert) formAlert.style.display = 'none';

        const name = document.getElementById('club-name').value.trim();
        const presidentName = document.getElementById('club-president-name').value.trim();
        const description = document.getElementById('club-desc').value.trim();
        const presidentEmail = document.getElementById('club-president-email').value.trim();
        const presidentPassword = document.getElementById('club-president-password').value.trim();

        try {
            const res = await fetch(`${API_BASE}/clubs`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    name, presidentName, description, presidentEmail, presidentPassword
                })
            });

            if (res.ok) {
                clubCreationForm.reset();
                toggleClubForm(false);
                fetchDashboardData();
            } else {
                const err = await res.json();
                if (formAlert) {
                    formAlert.innerText = err.error || 'Failed to create club';
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

// Render Clubs Grid (Admin Only)
function renderClubsGrid(clubs) {
    const container = document.getElementById('clubs-grid-container');
    if (!container) return;
    container.innerHTML = '';

    if (clubs.length === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary); grid-column: span 2;">No clubs registered yet.</p>';
        return;
    }

    clubs.forEach(c => {
        const membersList = Array.isArray(c.members) ? c.members : [];
        const membersHtml = membersList.length > 0
            ? membersList.map(m => `<li>${m}</li>`).join('')
            : '<span style="font-style: italic; font-size: 12px; color: var(--text-muted);">No members registered yet</span>';

        const cardHtml = `
            <div class="card">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                    <h3 style="font-size: 18px; font-weight: 700; color: var(--color-brand);">${c.name}</h3>
                    <span class="badge" style="background-color: var(--color-brand-light); color: var(--color-brand);">ID: ${c.id}</span>
                </div>
                <p style="color: var(--text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 16px;">${c.description}</p>
                <div style="font-size: 13px; color: var(--text-primary); border-top: 1px solid var(--border-color); padding-top: 12px; margin-bottom: 12px;">
                    👤 <strong>President:</strong> ${c.presidentName} (User ID: ${c.presidentId})
                </div>
                <div style="font-size: 13px;">
                    👥 <strong>Members Count:</strong> ${c.membersCount}
                    <ul style="margin: 8px 0 0 16px; padding: 0; font-size: 12px; color: var(--text-secondary);">
                        ${membersHtml}
                    </ul>
                </div>
            </div>
        `;
        container.innerHTML += cardHtml;
    });
}

// Generate & Show Event Report
function generateEventReport() {
    if (!selectedEventDetails) return;
    
    const eventRegs = registrations.filter(r => r.eventId === selectedEventDetails.id && r.status !== 'cancelled');
    const participants = eventRegs.filter(r => r.type === 'participant');
    const volunteers = eventRegs.filter(r => r.type === 'volunteer');
    
    const approvedParticipants = participants.filter(r => r.status === 'approved' || r.status === 'attended');
    const pendingParticipants = participants.filter(r => r.status === 'pending');
    
    const totalRevenue = approvedParticipants.reduce((sum, r) => sum + parseFloat(r.paymentAmount), 0);
    const pendingRevenue = pendingParticipants.reduce((sum, r) => sum + parseFloat(r.paymentAmount), 0);
    
    const reportHtml = `
        <div class="print-section" style="font-family: 'Plus Jakarta Sans', sans-serif;">
            <div style="text-align: center; margin-bottom: 24px; border-bottom: 2px solid var(--color-brand); padding-bottom: 16px;">
                <h1 style="color: var(--color-brand); margin-bottom: 4px; font-weight: 800;">GVP College Clubs & Events</h1>
                <p style="color: var(--text-secondary); font-size: 13px; text-transform: uppercase; font-weight: bold; letter-spacing: 1px;">Official Event Progress Report</p>
            </div>
            
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 24px;">
                <div>
                    <h3 style="margin-bottom: 8px; font-size: 18px; color: var(--text-primary);">${selectedEventDetails.title}</h3>
                    <p style="margin-bottom: 12px; font-size: 13px; line-height: 1.5; color: var(--text-secondary);">${selectedEventDetails.description}</p>
                    <div style="font-size: 13px; color: var(--text-secondary);">
                        <div style="margin-bottom: 4px;">📍 <strong>Venue:</strong> ${selectedEventDetails.venue}</div>
                        <div>📅 <strong>Date & Time:</strong> ${selectedEventDetails.dateString}</div>
                    </div>
                </div>
                <div style="background-color: var(--bg-primary); padding: 16px; border-radius: 12px; border: 1px solid var(--border-color); display: flex; flex-direction: column; gap: 8px; font-size: 13px;">
                    <div>🎫 <strong>Ticket Price:</strong> ${selectedEventDetails.price > 0 ? `₹${selectedEventDetails.price}` : 'Free Entry'}</div>
                    <div>👥 <strong>Capacity Limit:</strong> ${selectedEventDetails.capacity}</div>
                    <div>👥 <strong>Seats Booked:</strong> ${participants.length} / ${selectedEventDetails.capacity}</div>
                    <div>🤝 <strong>Volunteers Registered:</strong> ${volunteers.length} / ${selectedEventDetails.volunteerLimit}</div>
                </div>
            </div>
            
            <h3 style="margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 6px; font-size: 14px; color: var(--color-brand); font-weight: 700;">📈 Registration Statistics</h3>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; text-align: center;">
                <div style="background: var(--bg-primary); padding: 12px; border-radius: 8px; border: 1px solid var(--border-color);">
                    <div style="font-size: 11px; color: var(--text-secondary);">Total Registered</div>
                    <div style="font-size: 18px; font-weight: 800; margin-top: 4px; color: var(--text-primary);">${participants.length}</div>
                </div>
                <div style="background: var(--bg-primary); padding: 12px; border-radius: 8px; border: 1px solid var(--border-color);">
                    <div style="font-size: 11px; color: var(--text-secondary);">Approved Admissions</div>
                    <div style="font-size: 18px; font-weight: 800; margin-top: 4px; color: var(--color-success);">${approvedParticipants.length}</div>
                </div>
                <div style="background: var(--bg-primary); padding: 12px; border-radius: 8px; border: 1px solid var(--border-color);">
                    <div style="font-size: 11px; color: var(--text-secondary);">Total Revenue</div>
                    <div style="font-size: 18px; font-weight: 800; margin-top: 4px; color: var(--color-success);">₹${totalRevenue.toFixed(2)}</div>
                </div>
                <div style="background: var(--bg-primary); padding: 12px; border-radius: 8px; border: 1px solid var(--border-color);">
                    <div style="font-size: 11px; color: var(--text-secondary);">Pending Payments</div>
                    <div style="font-size: 18px; font-weight: 800; margin-top: 4px; color: var(--color-warning);">₹${pendingRevenue.toFixed(2)}</div>
                </div>
            </div>
            
            <h3 style="margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 6px; font-size: 14px; color: var(--color-brand); font-weight: 700;">👥 Roster of Registered Students</h3>
            <table style="width: 100%; border-collapse: collapse; margin-bottom: 24px; font-size: 12px;">
                <thead>
                    <tr style="background-color: var(--bg-primary); border-bottom: 1px solid var(--border-color); text-align: left;">
                        <th style="padding: 8px;">Student Name</th>
                        <th style="padding: 8px;">Roll Number</th>
                        <th style="padding: 8px;">Branch</th>
                        <th style="padding: 8px;">Type</th>
                        <th style="padding: 8px;">Status</th>
                        <th style="padding: 8px; text-align: right;">Paid Amt</th>
                    </tr>
                </thead>
                <tbody>
                    ${participants.length === 0 ? '<tr><td colspan="6" style="padding:8px; text-align:center; color:var(--text-secondary);">No participants registered yet.</td></tr>' : participants.map(r => `
                        <tr style="border-bottom: 1px solid var(--border-color);">
                            <td style="padding: 8px; font-weight: 600;">${r.userName}</td>
                            <td style="padding: 8px;">${r.userRollNumber}</td>
                            <td style="padding: 8px;">${r.userBranch}</td>
                            <td style="padding: 8px; text-transform: capitalize;">${r.type}</td>
                            <td style="padding: 8px;"><span class="badge badge-${r.status}" style="font-size: 10px; padding: 2px 6px;">${r.status}</span></td>
                            <td style="padding: 8px; font-weight: bold; text-align: right;">₹${parseFloat(r.paymentAmount).toFixed(2)}</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
            
            <h3 style="margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 6px; font-size: 14px; color: var(--color-brand); font-weight: 700;">🤝 Volunteers list</h3>
            ${volunteers.length === 0 ? '<p style="color: var(--text-secondary); font-size: 13px; padding-left: 8px;">No volunteers registered yet.</p>' : `
            <table style="width: 100%; border-collapse: collapse; font-size: 12px;">
                <thead>
                    <tr style="background-color: var(--bg-primary); border-bottom: 1px solid var(--border-color); text-align: left;">
                        <th style="padding: 8px;">Volunteer Name</th>
                        <th style="padding: 8px;">Roll Number</th>
                        <th style="padding: 8px;">Branch</th>
                        <th style="padding: 8px; text-align: right;">Year of Passing</th>
                    </tr>
                </thead>
                <tbody>
                    ${volunteers.map(v => `
                        <tr style="border-bottom: 1px solid var(--border-color);">
                            <td style="padding: 8px; font-weight: 600;">${v.userName}</td>
                            <td style="padding: 8px;">${v.userRollNumber}</td>
                            <td style="padding: 8px;">${v.userBranch}</td>
                            <td style="padding: 8px; text-align: right;">${v.userYearOfPassing}</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
            `}
            
            <div style="margin-top: 40px; font-size: 11px; text-align: center; color: var(--text-muted); border-top: 1px dashed var(--border-color); padding-top: 12px;">
                Report generated on ${new Date().toLocaleString()} • CampusLink Portal System
            </div>
        </div>
    `;
    
    document.getElementById('report-content').innerHTML = reportHtml;
    document.getElementById('report-modal').style.display = 'flex';
}

function closeReportModal() {
    document.getElementById('report-modal').style.display = 'none';
}

function printReport() {
    const printContents = document.getElementById('report-content').innerHTML;
    const printWindow = window.open('', '_blank', 'height=600,width=800');
    
    printWindow.document.write('<html><head><title>Event Analytics Report</title>');
    document.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
        printWindow.document.write(`<link rel="stylesheet" href="${link.href}">`);
    });
    printWindow.document.write(`
        <style>
            body {
                font-family: 'Plus Jakarta Sans', sans-serif;
                background-color: white !important;
                color: black !important;
                padding: 40px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 10px;
                margin-bottom: 20px;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: left;
            }
            th {
                background-color: #f2f2f2 !important;
                font-weight: bold;
            }
            .badge {
                border: 1px solid #999;
                padding: 2px 6px;
                border-radius: 4px;
                font-size: 10px;
                text-transform: uppercase;
                color: black !important;
                background: transparent !important;
            }
        </style>
    `);
    printWindow.document.write('</head><body>');
    printWindow.document.write(printContents);
    printWindow.document.write('</body></html>');
    printWindow.document.close();
    
    setTimeout(() => {
        printWindow.print();
        printWindow.close();
    }, 500);
}

// Active vs. Past Events Tab switcher
let activeEventSubTab = 'active';
function switchEventSubTab(subTabName) {
    activeEventSubTab = subTabName;
    document.getElementById('event-subtab-active').classList.toggle('active', subTabName === 'active');
    document.getElementById('event-subtab-past').classList.toggle('active', subTabName === 'past');
    
    document.getElementById('btn-publish-active').style.display = subTabName === 'active' ? 'block' : 'none';
    document.getElementById('btn-upload-past').style.display = subTabName === 'past' ? 'block' : 'none';
    
    document.getElementById('events-grid-container').style.display = subTabName === 'active' ? 'grid' : 'none';
    document.getElementById('past-events-grid-container').style.display = subTabName === 'past' ? 'grid' : 'none';
    
    toggleEventForm(false);
    togglePastEventForm(false);
}

// Toggle Past Event Drawer
function togglePastEventForm(show) {
    const formCard = document.getElementById('past-event-form-card');
    if (formCard) formCard.style.display = show ? 'block' : 'none';
}

// Past Event creation form submit
const pastEventCreationForm = document.getElementById('past-event-creation-form');
if (pastEventCreationForm) {
    pastEventCreationForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const formAlert = document.getElementById('past-event-form-alert');
        if (formAlert) formAlert.style.display = 'none';

        const title = document.getElementById('past-event-title').value.trim();
        const academicYear = document.getElementById('past-event-year').value.trim();
        const description = document.getElementById('past-event-desc').value.trim();
        const date = document.getElementById('past-event-date').value.trim();
        const venue = document.getElementById('past-event-venue').value.trim();
        const volunteersCount = parseInt(document.getElementById('past-event-vols').value) || 0;
        const images = document.getElementById('past-event-images').value.trim();

        let clubId = null;
        if (user.role === 'admin') {
            const selectEl = document.getElementById('past-event-club-select');
            if (selectEl) clubId = parseInt(selectEl.value);
        }

        try {
            const res = await fetch(`${API_BASE}/historical-events`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    title, academicYear, description, date, venue, volunteersCount, images, clubId
                })
            });

            if (res.ok) {
                pastEventCreationForm.reset();
                togglePastEventForm(false);
                fetchDashboardData();
            } else {
                const err = await res.json();
                if (formAlert) {
                    formAlert.innerText = err.error || 'Failed to upload past event';
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

// Render Past/Historical Events Grid
function renderPastEventsGrid(pastEvents) {
    const container = document.getElementById('past-events-grid-container');
    if (!container) return;
    container.innerHTML = '';

    if (pastEvents.length === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary); grid-column: span 2;">No past events found for this club tenure.</p>';
        return;
    }

    pastEvents.forEach(e => {
        let imagesHtml = '';
        if (e.images && e.images.length > 0) {
            const imagesList = Array.isArray(e.images) ? e.images : [];
            imagesHtml = `
                <div style="display:flex; gap:8px; margin-top:12px; overflow-x:auto;">
                    ${imagesList.map(url => `<img src="${url}" style="width: 80px; height: 60px; object-fit: cover; border-radius: 6px; border: 1px solid var(--border-color);" />`).join('')}
                </div>
            `;
        }

        const cardHtml = `
            <div class="card event-card">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <span class="badge" style="background-color: var(--color-brand-light); color: var(--color-brand);">
                            🎓 Year: ${e.academicYear}
                        </span>
                        <span class="badge badge-approved" style="background-color: #F1F5F9; color: #475569;">PAST TENURE</span>
                    </div>
                    <h3 style="font-size: 17px; font-weight: 700; margin-bottom: 8px;">${e.title}</h3>
                    <p style="color: var(--text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 16px;">${e.description}</p>
                    
                    <div class="event-details-box">
                        <div>📍 ${e.venue}</div>
                        <div>📅 Date: ${e.date}</div>
                        <div style="color: var(--color-brand); font-weight: 600;">🤝 Volunteers: ${e.volunteersCount} staff</div>
                    </div>
                    ${imagesHtml}
                </div>
            </div>
        `;
        container.innerHTML += cardHtml;
    });
}
