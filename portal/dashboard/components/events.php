<div id="tab-events" class="tab-content" style="display: none;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h2>Event Catalogs</h2>
        <div>
            <button class="btn btn-primary" id="btn-publish-active" onclick="toggleEventForm(true)">+ Publish New Portal</button>
            <button class="btn btn-primary" id="btn-upload-past" style="display: none;" onclick="togglePastEventForm(true)">+ Upload Past Event</button>
        </div>
    </div>

    <!-- Event Category Subtabs -->
    <div class="subtab-buttons" style="margin-bottom: 24px;">
        <button id="event-subtab-active" class="subtab-btn active" onclick="switchEventSubTab('active')">📅 Active Events</button>
        <button id="event-subtab-past" class="subtab-btn" onclick="switchEventSubTab('past')">📜 Past Events</button>
    </div>

    <!-- Event creation drawer/card -->
    <div id="event-form-card" class="card" style="display: none; border-top: 4px solid var(--color-brand); margin-bottom: 20px;">
        <h3>Create New Club Event</h3>
        <div id="event-form-alert" class="alert alert-error" style="display: none;"></div>
        <form id="event-creation-form" style="margin-top: 16px;">
            <div class="form-group" id="event-club-group" style="display: none; margin-bottom: 16px;">
                <label>Assigned Club (Admin Only)</label>
                <select id="event-club-select" class="form-control">
                    <!-- Filled dynamically -->
                </select>
            </div>
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

    <!-- Past Event creation drawer/card -->
    <div id="past-event-form-card" class="card" style="display: none; border-top: 4px solid var(--color-brand); margin-bottom: 20px;">
        <h3>Upload Past / Historical Event</h3>
        <div id="past-event-form-alert" class="alert alert-error" style="display: none;"></div>
        <form id="past-event-creation-form" style="margin-top: 16px;">
            <div class="form-group" id="past-event-club-group" style="display: none; margin-bottom: 16px;">
                <label>Assigned Club (Admin Only)</label>
                <select id="past-event-club-select" class="form-control">
                    <!-- Filled dynamically -->
                </select>
            </div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div class="form-group">
                    <label>Event Title</label>
                    <input type="text" id="past-event-title" class="form-control" placeholder="e.g. Web Dev Bootcamp 2023" required>
                </div>
                <div class="form-group">
                    <label>Academic Year</label>
                    <input type="text" id="past-event-year" class="form-control" placeholder="e.g. 2023-24" required>
                </div>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label>Description / Event Summary</label>
                <textarea id="past-event-desc" class="form-control" placeholder="Describe the outcome, guest lectures, topics covered..." required></textarea>
            </div>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 16px;">
                <div class="form-group">
                    <label>Date String</label>
                    <input type="text" id="past-event-date" class="form-control" placeholder="e.g. Oct 15, 2023" required>
                </div>
                <div class="form-group">
                    <label>Venue</label>
                    <input type="text" id="past-event-venue" class="form-control" placeholder="e.g. Seminar Hall 1" required>
                </div>
                <div class="form-group">
                    <label>Volunteers Participated</label>
                    <input type="number" id="past-event-vols" class="form-control" value="5">
                </div>
            </div>
            <div class="form-group" style="margin-bottom: 24px;">
                <label>Event Images (Comma-separated URLs)</label>
                <input type="text" id="past-event-images" class="form-control" placeholder="e.g. https://image1.jpg, https://image2.jpg">
            </div>
            <div style="display: flex; gap: 12px;">
                <button type="submit" class="btn btn-primary">Upload Past Event</button>
                <button type="button" class="btn btn-outline" onclick="togglePastEventForm(false)">Cancel</button>
            </div>
        </form>
    </div>

    <!-- Active Events List -->
    <div class="grid-2" id="events-grid-container">
        <!-- Filled dynamically -->
    </div>

    <!-- Past Events List -->
    <div class="grid-2" id="past-events-grid-container" style="display: none;">
        <!-- Filled dynamically -->
    </div>
</div>
