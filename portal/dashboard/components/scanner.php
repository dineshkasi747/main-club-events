<div id="tab-scanner" class="tab-content" style="display: none;">
    <div class="card" style="max-width: 600px;">
        <div class="section-header">
            <span class="section-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2Z"></path><path d="M13 5v2"></path><path d="M13 17v2"></path><path d="M13 11v2"></path></svg></span>
            <h2>Admissions Ticket Check-in</h2>
        </div>
        <p style="color: var(--text-secondary); font-size: 13px; margin: 4px 0 20px 0; font-weight: 500; letter-spacing: -0.16px;">Enter the student registration/ticket ID scanned from the app to verify check-in.</p>
        
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
