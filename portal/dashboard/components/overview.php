<div id="tab-overview" class="tab-content">
    <div class="grid-3">
        <div class="stat-card">
            <span class="label">Total Registrations</span>
            <span class="value" id="stats-total-regs">0</span>
        </div>
        <div class="stat-card">
            <span class="label">Approved / Paid Tickets</span>
            <span class="value" id="stats-verified-regs">0</span>
        </div>
        <div class="stat-card">
            <span class="label">Volunteer Staff</span>
            <span class="value" id="stats-volunteers">0</span>
        </div>
    </div>

    <div class="card" style="border-top: 4px solid var(--color-brand);">
        <div class="section-header">
            <span class="section-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"></path><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"></path></svg></span>
            <h2>Broadcast Club Announcement</h2>
        </div>
        <p style="color: var(--text-secondary); font-size: 13px; margin: 0 0 20px 0; font-weight: 500; letter-spacing: -0.16px;">
            Compose a message to broadcast to all members. This triggers a real-time push notification via Firebase.
        </p>
        <div id="broadcast-alert" class="alert" style="display: none;"></div>
        <form id="broadcast-form" style="max-width: 600px; display: flex; flex-direction: column; gap: 16px;">
            <div class="form-group">
                <label>Announcement Title</label>
                <input type="text" id="ann-title" class="form-control" placeholder="e.g. AI Hackathon Guidelines PDF Released" required>
            </div>
            <div class="form-group">
                <label>Message Content</label>
                <textarea id="ann-body" class="form-control" style="min-height: 80px;" placeholder="Please bring your own laptops..." required></textarea>
            </div>
            <button type="submit" class="btn btn-primary" style="align-self: flex-start;">Send Announcement & Push</button>
        </form>
    </div>
</div>
