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
        <h2>📢 Broadcast Club Announcement</h2>
        <p style="color: var(--text-secondary); font-size: 13px; margin: 4px 0 16px 0;">
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
