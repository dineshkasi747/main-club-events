<!-- Screenshot Zoom Modal -->
<div id="screenshot-modal" class="modal-overlay" onclick="closeScreenshotModal()">
    <div class="modal-card screenshot-zoom-card" onclick="event.stopPropagation()">
        <h3 style="margin-bottom: 16px;">Student UPI Payment Screenshot</h3>
        <img id="screenshot-img" src="" alt="UPI receipt">
        <button class="btn btn-primary" style="margin-top: 20px; width: 120px;" onclick="closeScreenshotModal()">Close View</button>
    </div>
</div>

<!-- Registrants Tab Drawer Modal -->
<div id="registrants-modal" class="modal-overlay" onclick="closeRegistrantsModal()">
    <div class="modal-card" onclick="event.stopPropagation()">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <div>
                <h2 id="reg-modal-title">Event Registrations</h2>
                <span id="reg-modal-subtitle" style="font-size: 12px; color: var(--text-secondary); font-weight: 500;">Event ID: #000</span>
            </div>
            <div style="display: flex; gap: 8px;">
                <button class="btn btn-outline" style="border-color: var(--color-brand); color: var(--color-brand); font-weight: 600;" onclick="generateEventReport()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px; vertical-align: text-bottom;"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path><polyline points="14 2 14 8 20 8"></polyline></svg> Generate Report
                </button>
                <button class="btn btn-outline" onclick="closeRegistrantsModal()">Close</button>
            </div>
        </div>

        <!-- Subtab selectors -->
        <div class="subtab-buttons">
            <button id="subtab-paid" class="subtab-btn active" onclick="switchSubTab('paid')">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px; vertical-align: text-bottom;"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg> Paid Registrants (0)
            </button>
            <button id="subtab-free" class="subtab-btn" onclick="switchSubTab('free')">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px; vertical-align: text-bottom;"><path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2Z"></path><path d="M13 5v2"></path><path d="M13 17v2"></path><path d="M13 11v2"></path></svg> Free Registrants (0)
            </button>
            <button id="subtab-vol" class="subtab-btn" onclick="switchSubTab('volunteer')">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px; vertical-align: text-bottom;"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg> Volunteers (0)
            </button>
        </div>

        <div style="flex: 1; overflow-y: auto;" id="registrants-table-container">
            <!-- Filled dynamically -->
        </div>
    </div>
</div>

<!-- Event Report Modal -->
<div id="report-modal" class="modal-overlay" onclick="closeReportModal()">
    <div class="modal-card report-card" onclick="event.stopPropagation()" style="max-width: 800px; width: 90%; display: flex; flex-direction: column;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px;">
            <h2><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 8px;"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>Event Progress & Analytics Report</h2>
            <div style="display: flex; gap: 8px;">
                <button class="btn btn-primary" onclick="printReport()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect width="12" height="8" x="6" y="14"></rect></svg> Print Report
                </button>
                <button class="btn btn-outline" onclick="closeReportModal()">Close</button>
            </div>
        </div>
        <div id="report-content" style="flex: 1; overflow-y: auto; padding-right: 8px;">
            <!-- Generated dynamically -->
        </div>
    </div>
</div>

<!-- Custom Confirmation Modal -->
<div id="confirm-modal" class="modal-overlay" style="display: none; z-index: 9999;" onclick="closeConfirmModal()">
    <div class="modal-card" style="max-width: 400px; padding: 32px; text-align: center; border-radius: var(--radius-xl);" onclick="event.stopPropagation()">
        <div style="margin-bottom: 20px; color: var(--color-brand); display: flex; justify-content: center;">
            <div style="width: 56px; height: 56px; border-radius: 50%; background: var(--color-brand-light); display: flex; align-items: center; justify-content: center;">
                <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M12 8v4"></path><path d="M12 16h.01"></path></svg>
            </div>
        </div>
        <h3 id="confirm-modal-title" style="margin-bottom: 12px; font-size: 20px; font-family: 'Outfit', sans-serif; letter-spacing: -0.3px;">Confirm Action</h3>
        <p id="confirm-modal-desc" style="color: var(--text-secondary); font-size: 14px; margin-bottom: 32px; line-height: 1.6; font-weight: 500;">Are you sure you want to proceed with this action?</p>
        <div style="display: flex; gap: 12px; justify-content: center;">
            <button class="btn btn-outline" style="flex: 1; border-color: var(--border-color); color: var(--text-primary);" onclick="closeConfirmModal()">Cancel</button>
            <button id="confirm-modal-action-btn" class="btn btn-primary" style="flex: 1; box-shadow: var(--shadow-low-1);">Confirm</button>
        </div>
    </div>
</div>
