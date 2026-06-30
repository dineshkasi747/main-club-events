<div id="tab-events" class="tab-content" style="display: none;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <h2>Event Catalogs</h2>
        <button class="btn btn-primary" onclick="toggleEventForm(true)">+ Publish New Portal</button>
    </div>

    <!-- Event creation drawer/card -->
    <div id="event-form-card" class="card" style="display: none; border-top: 4px solid var(--color-brand);">
        <h3>Create New Club Event</h3>
        <div id="event-form-alert" class="alert alert-error" style="display: none;"></div>
        <form id="event-creation-form" style="margin-top: 16px;">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div class="form-group">
                    <label>Event Title</label>
                    <input type="text" id="event-title" class="form-control" placeholder="CodeSprint Hackathon" required>
                </div>
                <div class="form-group">
                    <label>Venue Location</label>
                    <input type="text" id="event-venue" class="form-control" placeholder="Main Block, Lab 3" required>
                </div>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label>Description</label>
                <textarea id="event-desc" class="form-control" placeholder="Brief event description..." required></textarea>
            </div>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 16px;">
                <div class="form-group">
                    <label>Date & Time String</label>
                    <input type="text" id="event-date" class="form-control" placeholder="Aug 27, 2026 @ 09:00 AM" required>
                </div>
                <div class="form-group">
                    <label>Price (INR) • 0 if Free</label>
                    <input type="number" step="0.01" id="event-price" class="form-control" value="0">
                </div>
                <div class="form-group">
                    <label>Total Capacity (Seats)</label>
                    <input type="number" id="event-capacity" class="form-control" value="100">
                </div>
            </div>

            <div style="background-color: var(--bg-primary); padding: 16px; border-radius: 12px; border: 1px solid var(--border-color); margin-bottom: 24px; display: flex; flex-direction: column; gap: 16px;">
                <div style="display: flex; alignItems: center; gap: 12px;">
                    <input type="checkbox" id="event-free-reg" style="width: 18px; height: 18px; cursor: pointer;" checked>
                    <label for="event-free-reg" style="cursor: pointer;">Allow Free Registration Mode</label>
                </div>
                <div style="display: flex; alignItems: center; gap: 12px;">
                    <input type="checkbox" id="event-paid-reg" style="width: 18px; height: 18px; cursor: pointer;">
                    <label for="event-paid-reg" style="cursor: pointer;">Allow Paid Registration Mode (Requires price &gt; 0)</label>
                </div>
                <div style="display: flex; alignItems: center; gap: 12px;">
                    <input type="checkbox" id="event-vol-reg" style="width: 18px; height: 18px; cursor: pointer;" onchange="toggleVolLimitField()">
                    <label for="event-vol-reg" style="cursor: pointer;">Enable Volunteer Registration for this Event</label>
                </div>
                <div id="vol-limit-container" class="form-group" style="display: none; max-width: 240px; margin-top: 4px;">
                    <label>Volunteer Limits (Spots)</label>
                    <input type="number" id="event-vol-limit" class="form-control" value="10">
                </div>
            </div>

            <div style="display: flex; gap: 12px;">
                <button type="submit" class="btn btn-primary">Publish Portal</button>
                <button type="button" class="btn btn-outline" onclick="toggleEventForm(false)">Cancel</button>
            </div>
        </form>
    </div>

    <div class="grid-2" id="events-grid-container">
        <!-- Filled dynamically -->
    </div>
</div>
