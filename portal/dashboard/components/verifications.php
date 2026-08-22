<div id="tab-verifications" class="tab-content" style="display: none;">
    <div class="card">
        <div class="section-header" style="display: flex; align-items: center; justify-content: space-between;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <span class="section-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10"></path><path d="m9 12 2 2 4-4"></path></svg></span>
                <h2>Razorpay Payment & Bookings Verification</h2>
            </div>
            <button class="btn btn-outline" style="padding: 6px 14px; font-size: 12px;" onclick="fetchDashboardData()">
                🔄 Refresh Data
            </button>
        </div>
        <p style="color: var(--text-secondary); font-size: 13px; margin-top: 4px; font-weight: 500; letter-spacing: -0.16px;">
            Review Razorpay UPI, NetBanking & Bank transactions submitted by students. Approve ticket entry or reject invalid registrations.
        </p>

        <!-- Stats Overview Row -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-top: 18px; margin-bottom: 20px;">
            <div style="background: #F8FAFC; border: 1px solid #E2E8F0; padding: 14px; border-radius: 12px;">
                <div style="font-size: 11px; font-weight: 700; color: #64748B; text-transform: uppercase;">Total Registrations</div>
                <div id="stat-total-regs" style="font-size: 22px; font-weight: 800; color: #0F172A; margin-top: 4px;">0</div>
            </div>
            <div style="background: #FFFBEB; border: 1px solid #FCD34D; padding: 14px; border-radius: 12px;">
                <div style="font-size: 11px; font-weight: 700; color: #B45309; text-transform: uppercase;">Pending Admin Approval</div>
                <div id="stat-pending-regs" style="font-size: 22px; font-weight: 800; color: #D97706; margin-top: 4px;">0</div>
            </div>
            <div style="background: #ECFDF5; border: 1px solid #6EE7B7; padding: 14px; border-radius: 12px;">
                <div style="font-size: 11px; font-weight: 700; color: #047857; text-transform: uppercase;">Approved & Ticketed</div>
                <div id="stat-approved-regs" style="font-size: 22px; font-weight: 800; color: #10B981; margin-top: 4px;">0</div>
            </div>
            <div style="background: #EFF6FF; border: 1px solid #93C5FD; padding: 14px; border-radius: 12px;">
                <div style="font-size: 11px; font-weight: 700; color: #1E40AF; text-transform: uppercase;">Total Razorpay Revenue</div>
                <div id="stat-revenue" style="font-size: 22px; font-weight: 800; color: #2563EB; margin-top: 4px;">₹0.00</div>
            </div>
        </div>

        <!-- Filter Bar -->
        <div style="display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap;">
            <button class="btn btn-sm filter-btn active" id="filter-all" onclick="filterVerifications('all')">All Bookings</button>
            <button class="btn btn-sm filter-btn" id="filter-pending" style="border-color: #F59E0B; color: #D97706;" onclick="filterVerifications('pending')">Pending Approval ⏳</button>
            <button class="btn btn-sm filter-btn" id="filter-approved" style="border-color: #10B981; color: #059669;" onclick="filterVerifications('approved')">Approved ✓</button>
            <button class="btn btn-sm filter-btn" id="filter-cancelled" style="border-color: #EF4444; color: #DC2626;" onclick="filterVerifications('cancelled')">Cancelled / Rejected ✕</button>
        </div>
        
        <div style="overflow-x: auto; margin-top: 8px;">
            <table>
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Student & Roll No</th>
                        <th>Event Details</th>
                        <th>Razorpay Gateway Summary</th>
                        <th>Status</th>
                        <th>Admin Action</th>
                    </tr>
                </thead>
                <tbody id="verifications-tbody">
                    <!-- Filled dynamically -->
                </tbody>
            </table>
        </div>
    </div>
</div>

