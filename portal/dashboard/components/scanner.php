<div id="tab-scanner" class="tab-content" style="display: none;">
    <div class="card" style="max-width: 600px;">
        <h2>Admissions Ticket Check-in</h2>
        <p style="color: var(--text-secondary); font-size: 13px; margin: 4px 0 20px 0;">Enter the student registration/ticket ID scanned from the app to verify check-in.</p>
        
        <div id="scanner-alert" class="alert" style="display: none;"></div>
        <form id="scanner-form" style="display: flex; flex-direction: column; gap: 16px;">
            <div class="form-group">
                <label>Ticket / Registration ID</label>
                <input type="number" id="scan-code" class="form-control" placeholder="e.g. 17290123" required>
            </div>
            <button type="submit" class="btn btn-primary" style="align-self: flex-start;">Verify & Admit Student</button>
        </form>
    </div>
</div>
