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
                <span id="reg-modal-subtitle" style="font-size: 12px; color: var(--text-secondary);">Event ID: #000</span>
            </div>
            <div style="display: flex; gap: 8px;">
                <button class="btn btn-outline" style="border-color: var(--color-brand); color: var(--color-brand); font-weight: 600;" onclick="generateEventReport()">📋 Generate Report</button>
                <button class="btn btn-outline" onclick="closeRegistrantsModal()">Close</button>
            </div>
        </div>

        <!-- Subtab selectors -->
        <div class="subtab-buttons">
            <button id="subtab-paid" class="subtab-btn active" onclick="switchSubTab('paid')">💰 Paid Registrants (0)</button>
            <button id="subtab-free" class="subtab-btn" onclick="switchSubTab('free')">🎟️ Free Registrants (0)</button>
            <button id="subtab-vol" class="subtab-btn" onclick="switchSubTab('volunteer')">🤝 Volunteers (0)</button>
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
            <h2>📋 Event Progress & Analytics Report</h2>
            <div style="display: flex; gap: 8px;">
                <button class="btn btn-primary" onclick="printReport()">Print Report 🖨️</button>
                <button class="btn btn-outline" onclick="closeReportModal()">Close</button>
            </div>
        </div>
        <div id="report-content" style="flex: 1; overflow-y: auto; padding-right: 8px;">
            <!-- Generated dynamically -->
        </div>
    </div>
</div>
