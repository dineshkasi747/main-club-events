import React, { useState, useEffect } from 'react';

const API_BASE = 'http://localhost:5000/api';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token') || '');
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('user') || 'null'));
  
  // Login Form State
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loginError, setLoginError] = useState('');

  // Navigation state
  const [activeTab, setActiveTab] = useState('overview'); // overview, events, verifications, volunteers, scanner

  // Dashboard Data State
  const [clubs, setClubs] = useState([]);
  const [events, setEvents] = useState([]);
  const [registrations, setRegistrations] = useState([]);
  const [selectedClubId, setSelectedClubId] = useState(null);

  // New Event Form State
  const [showEventForm, setShowEventForm] = useState(false);
  const [eventTitle, setEventTitle] = useState('');
  const [eventDesc, setEventDesc] = useState('');
  const [eventVenue, setEventVenue] = useState('');
  const [eventDate, setEventDate] = useState('');
  const [eventPrice, setEventPrice] = useState('0');
  const [eventCapacity, setEventCapacity] = useState('100');
  const [eventVolReg, setEventVolReg] = useState(false);
  const [eventVolLimit, setEventVolLimit] = useState('10');
  const [formError, setFormError] = useState('');

  // Ticket scanner state
  const [scanCode, setScanCode] = useState('');
  const [scanMessage, setScanMessage] = useState(null);
  const [scanError, setScanError] = useState(null);

  useEffect(() => {
    if (token) {
      fetchDashboardData();
    }
  }, [token, selectedClubId]);

  const fetchDashboardData = async () => {
    try {
      const headers = { 'Authorization': `Bearer ${token}` };
      
      // Fetch registrations
      const regRes = await fetch(`${API_BASE}/registrations`, { headers });
      const regData = await regRes.json();
      setRegistrations(regData);

      // Fetch clubs
      const clubRes = await fetch(`${API_BASE}/clubs`);
      const clubData = await clubRes.json();
      setClubs(clubData);

      // Fetch events
      const eventRes = await fetch(`${API_BASE}/events`);
      const eventData = await eventRes.json();
      
      if (user.role === 'president') {
        const clubId = user.clubId;
        setSelectedClubId(clubId);
        // Load event listing for this club
        const clubDetailRes = await fetch(`${API_BASE}/clubs/${clubId}`);
        const clubDetail = await clubDetailRes.json();
        setEvents(clubDetail.upcomingEvents || []);
      } else {
        // System admin can scope into specific clubs or view all
        if (selectedClubId) {
          const clubDetailRes = await fetch(`${API_BASE}/clubs/${selectedClubId}`);
          const clubDetail = await clubDetailRes.json();
          setEvents(clubDetail.upcomingEvents || []);
        } else {
          setEvents(eventData);
        }
      }
    } catch (e) {
      console.error('Failed to load dashboard data:', e);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoginError('');
    try {
      const res = await fetch(`${API_BASE}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      const data = await res.json();
      if (res.ok) {
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        setToken(data.token);
        setUser(data.user);
        if (data.user.role === 'president') {
          setSelectedClubId(data.user.clubId);
        }
        setActiveTab('overview');
      } else {
        setLoginError(data.error || 'Login failed. Please verify credentials.');
      }
    } catch (err) {
      setLoginError('Server connection error.');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setToken('');
    setUser(null);
    setSelectedClubId(null);
    setEvents([]);
    setRegistrations([]);
  };

  const handleCreateEvent = async (e) => {
    e.preventDefault();
    setFormError('');
    if (!eventTitle || !eventVenue || !eventDate) {
      setFormError('Title, Venue and Date string are required.');
      return;
    }

    try {
      const res = await fetch(`${API_BASE}/events`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          clubId: selectedClubId,
          title: eventTitle,
          description: eventDesc,
          venue: eventVenue,
          dateString: eventDate,
          price: parseFloat(eventPrice),
          capacity: parseInt(eventCapacity),
          volunteerRegistration: eventVolReg,
          volunteerLimit: parseInt(eventVolLimit)
        })
      });
      if (res.ok) {
        setShowEventForm(false);
        setEventTitle('');
        setEventDesc('');
        setEventVenue('');
        setEventDate('');
        setEventPrice('0');
        setEventCapacity('100');
        setEventVolReg(false);
        setEventVolLimit('10');
        fetchDashboardData();
      } else {
        const d = await res.json();
        setFormError(d.error || 'Failed to create event');
      }
    } catch (err) {
      setFormError('Network communication error.');
    }
  };

  const handleVerifyBooking = async (regId) => {
    try {
      const res = await fetch(`${API_BASE}/registrations/${regId}/verify`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        fetchDashboardData();
      } else {
        alert('Verification failed');
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleAdmitTicket = async (e) => {
    e.preventDefault();
    setScanMessage(null);
    setScanError(null);
    if (!scanCode) return;

    try {
      const res = await fetch(`${API_BASE}/registrations/${scanCode}/admit`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await res.json();
      if (res.ok) {
        setScanMessage(`✅ Check-in Success! Student ${data.registration.userName} (${data.registration.userRollNumber}) admitted to ${data.registration.eventTitle}.`);
        setScanCode('');
        fetchDashboardData();
      } else {
        setScanError(data.error || 'Check-in failed. Check booking ID status.');
      }
    } catch (err) {
      setScanError('Network link issue.');
    }
  };

  // Filter registrations based on scoped club
  const filteredRegs = registrations.filter(r => {
    if (user.role === 'president') {
      return r.eventClubId === user.clubId;
    }
    return !selectedClubId || r.eventClubId === selectedClubId;
  });

  const participantsList = filteredRegs.filter(r => r.type === 'participant');
  const volunteersList = filteredRegs.filter(r => r.type === 'volunteer');

  // Math totals
  const totalCollections = participantsList
    .filter(p => p.status === 'approved' || p.status === 'attended')
    .reduce((sum, current) => sum + current.paymentAmount, 0);

  const pendingApprovalsCount = participantsList.filter(p => p.status === 'pending').length;

  if (!token || !user) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%)',
        padding: '20px'
      }}>
        <div className="card fade-in" style={{ maxWidth: '440px', width: '100%', borderRadius: '24px', padding: '40px', boxShadow: '0 20px 40px rgba(15, 23, 42, 0.08)' }}>
          <div style={{ textAlign: 'center', marginBottom: '32px' }}>
            <div style={{
              width: '64px',
              height: '64px',
              borderRadius: '16px',
              background: 'linear-gradient(135deg, #4f46e5 0%, #6366f1 100%)',
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              fontSize: '32px',
              fontWeight: 'bold',
              marginBottom: '16px',
              boxShadow: '0 8px 16px rgba(79, 70, 229, 0.2)'
            }}>
              🏫
            </div>
            <h1 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '8px' }}>Club Admin Portal</h1>
            <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Sign in to manage events, verify tickets & volunteers.</p>
          </div>

          <form onSubmit={handleLogin}>
            {loginError && (
              <div style={{
                backgroundColor: 'var(--color-danger-light)',
                color: 'var(--color-danger)',
                padding: '12px 16px',
                borderRadius: '8px',
                fontSize: '13px',
                fontWeight: '600',
                marginBottom: '20px'
              }}>
                ⚠️ {loginError}
              </div>
            )}

            <div className="form-group">
              <label>College Email Address</label>
              <input
                type="email"
                className="form-control"
                placeholder="president@college.edu"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="form-group" style={{ marginBottom: '28px' }}>
              <label>Secret Password</label>
              <input
                type="password"
                className="form-control"
                placeholder="••••••••"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '14px', borderRadius: '12px' }}>
              Access Dashboard
            </button>
          </form>

          <div style={{ marginTop: '24px', padding: '16px', backgroundColor: '#f8fafc', borderRadius: '12px', border: '1px dashed #cbd5e1' }}>
            <p style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--text-secondary)', marginBottom: '8px' }}>Demo Test Accounts:</p>
            <ul style={{ fontSize: '11px', color: 'var(--text-secondary)', paddingLeft: '16px', lineHeight: '1.6' }}>
              <li><strong>Club Admin (Global):</strong> admin@college.edu / admin</li>
              <li><strong>Coding Club:</strong> coding@college.edu / password</li>
              <li><strong>Music Club:</strong> music@college.edu / password</li>
              <li><strong>Sports Club:</strong> sports@college.edu / password</li>
            </ul>
          </div>
        </div>
      </div>
    );
  }

  const activeClubName = clubs.find(c => c.id === selectedClubId)?.name || 'All Clubs';

  return (
    <div className="app-container">
      {/* Sidebar Navigation */}
      <aside className="sidebar">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '32px' }}>
          <span style={{ fontSize: '28px' }}>🎓</span>
          <div>
            <h2 style={{ fontSize: '16px', fontWeight: '800', lineHeight: '1.2' }}>Clubs Center</h2>
            <span style={{ fontSize: '11px', color: 'var(--color-brand)', fontWeight: '700' }}>
              {user.role === 'admin' ? 'SYSTEM ADMIN' : 'CLUB PRESIDENT'}
            </span>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
          <button
            className={`btn ${activeTab === 'overview' ? 'btn-primary' : 'btn-outline'}`}
            style={{ justifyContent: 'flex-start', width: '100%' }}
            onClick={() => setActiveTab('overview')}
          >
            📊 Analytics Overview
          </button>

          <button
            className={`btn ${activeTab === 'events' ? 'btn-primary' : 'btn-outline'}`}
            style={{ justifyContent: 'flex-start', width: '100%' }}
            onClick={() => setActiveTab('events')}
          >
            📅 Event Manager
          </button>

          <button
            className={`btn ${activeTab === 'verifications' ? 'btn-primary' : 'btn-outline'}`}
            style={{ justifyContent: 'flex-start', width: '100%' }}
            onClick={() => setActiveTab('verifications')}
          >
            💳 Bookings & Payments {pendingApprovalsCount > 0 && <span style={{ backgroundColor: 'var(--color-warning)', color: 'white', fontSize: '10px', padding: '2px 6px', borderRadius: '10px', marginLeft: 'auto' }}>{pendingApprovalsCount}</span>}
          </button>

          <button
            className={`btn ${activeTab === 'volunteers' ? 'btn-primary' : 'btn-outline'}`}
            style={{ justifyContent: 'flex-start', width: '100%' }}
            onClick={() => setActiveTab('volunteers')}
          >
            🤝 Volunteer Roster
          </button>

          <button
            className={`btn ${activeTab === 'scanner' ? 'btn-primary' : 'btn-outline'}`}
            style={{ justifyContent: 'flex-start', width: '100%' }}
            onClick={() => setActiveTab('scanner')}
          >
            🎟️ Entry Validator
          </button>
        </div>

        {/* User Info footer */}
        <div style={{ paddingTop: '20px', borderTop: '1px solid var(--border-color)', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <div>
            <div style={{ fontSize: '13px', fontWeight: 'bold' }}>{user.name}</div>
            <div style={{ fontSize: '11px', color: 'var(--text-secondary)', wordBreak: 'break-all' }}>{user.email}</div>
          </div>
          <button onClick={handleLogout} className="btn btn-outline" style={{ color: 'var(--color-danger)', borderColor: 'rgba(239, 68, 68, 0.2)', width: '100%' }}>
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main Panel Content */}
      <main className="main-content fade-in">
        <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h1 style={{ marginBottom: '4px' }}>{activeClubName} Dashboard</h1>
            <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Welcome back, manage your college operations.</p>
          </div>

          {/* Admin Scope Selector */}
          {user.role === 'admin' && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <span style={{ fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)' }}>Scope club:</span>
              <select
                className="form-control"
                value={selectedClubId || ''}
                onChange={e => setSelectedClubId(e.target.value ? parseInt(e.target.value) : null)}
                style={{ padding: '8px 12px', minWidth: '180px' }}
              >
                <option value="">All Clubs (Global)</option>
                {clubs.map(c => (
                  <option key={c.id} value={c.id}>{c.name}</option>
                ))}
              </select>
            </div>
          )}
        </header>

        {/* Tab 1: Overview */}
        {activeTab === 'overview' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
            <div className="grid-3">
              <div className="card" style={{ borderLeft: '5px solid var(--color-brand)' }}>
                <span style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Financial Collections</span>
                <div style={{ fontSize: '28px', fontWeight: '800', margin: '8px 0', color: 'var(--color-brand)' }}>
                  ₹{totalCollections.toFixed(2)}
                </div>
                <p style={{ fontSize: '11px', color: 'var(--text-muted)' }}>From verified bookings & transactions.</p>
              </div>

              <div className="card" style={{ borderLeft: '5px solid var(--color-success)' }}>
                <span style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Active Volunteers</span>
                <div style={{ fontSize: '28px', fontWeight: '800', margin: '8px 0', color: 'var(--color-success)' }}>
                  {volunteersList.filter(v => v.status === 'approved').length}
                </div>
                <p style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Assigned to support campus operations.</p>
              </div>

              <div className="card" style={{ borderLeft: '5px solid var(--color-warning)' }}>
                <span style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Pending Approvals</span>
                <div style={{ fontSize: '28px', fontWeight: '800', margin: '8px 0', color: 'var(--color-warning)' }}>
                  {pendingApprovalsCount}
                </div>
                <p style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Bookings awaiting payment validation.</p>
              </div>
            </div>

            <div className="grid-2">
              {/* Recent Registrations */}
              <div className="card">
                <h2 style={{ marginBottom: '16px' }}>Recent Registrations</h2>
                {participantsList.length === 0 ? (
                  <p style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>No registrations received yet.</p>
                ) : (
                  <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', boxShadow: 'none', marginTop: '0' }}>
                      <thead>
                        <tr>
                          <th>Student</th>
                          <th>Event</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {participantsList.slice(0, 5).map(r => (
                          <tr key={r.id}>
                            <td>
                              <div style={{ fontWeight: '600', fontSize: '13px' }}>{r.userName}</div>
                              <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{r.userRollNumber}</div>
                            </td>
                            <td style={{ fontSize: '13px' }}>{r.eventTitle}</td>
                            <td>
                              <span className={`badge badge-${r.status}`}>{r.status}</span>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>

              {/* Event capacities summary */}
              <div className="card">
                <h2 style={{ marginBottom: '16px' }}>Upcoming Capacities</h2>
                {events.length === 0 ? (
                  <p style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>No active upcoming events.</p>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                    {events.map(e => {
                      const attendees = participantsList.filter(r => r.eventId === e.id && r.status !== 'cancelled').length;
                      const pct = Math.min(100, Math.round((attendees / e.capacity) * 100));
                      return (
                        <div key={e.id}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', fontWeight: '600', marginBottom: '6px' }}>
                            <span>{e.title}</span>
                            <span style={{ color: 'var(--text-secondary)' }}>{attendees} / {e.capacity} seats</span>
                          </div>
                          <div style={{ height: '8px', backgroundColor: '#e2e8f0', borderRadius: '4px', overflow: 'hidden' }}>
                            <div style={{ width: `${pct}%`, height: '100%', backgroundColor: 'var(--color-brand)', borderRadius: '4px', transition: 'width 0.3s ease' }}></div>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Tab 2: Event Manager */}
        {activeTab === 'events' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2>Active Upcoming Events</h2>
              <button className="btn btn-primary" onClick={() => setShowEventForm(!showEventForm)}>
                {showEventForm ? 'Close Form' : '➕ Post New Event'}
              </button>
            </div>

            {showEventForm && (
              <div className="card fade-in" style={{ backgroundColor: '#f8fafc' }}>
                <h3 style={{ marginBottom: '20px' }}>Post a New Club Event</h3>
                <form onSubmit={handleCreateEvent}>
                  {formError && (
                    <div style={{ backgroundColor: 'var(--color-danger-light)', color: 'var(--color-danger)', padding: '12px 16px', borderRadius: '8px', fontSize: '13px', marginBottom: '20px' }}>
                      ⚠️ {formError}
                    </div>
                  )}

                  <div className="grid-2">
                    <div className="form-group">
                      <label>Event Title</label>
                      <input type="text" className="form-control" placeholder="e.g. CodeSprint 5.0" value={eventTitle} onChange={e => setEventTitle(e.target.value)} required />
                    </div>
                    <div className="form-group">
                      <label>Venue Location</label>
                      <input type="text" className="form-control" placeholder="e.g. Lab 3 / Open Air Theatre" value={eventVenue} onChange={e => setEventVenue(e.target.value)} required />
                    </div>
                  </div>

                  <div className="form-group">
                    <label>Event Description</label>
                    <textarea className="form-control" style={{ minHeight: '80px' }} placeholder="Write a short summary detailing requirements, timings, benefits..." value={eventDesc} onChange={e => setEventDesc(e.target.value)} />
                  </div>

                  <div className="grid-3">
                    <div className="form-group">
                      <label>Date & Time String</label>
                      <input type="text" className="form-control" placeholder="e.g. Aug 27, 2026 @ 09:00 AM" value={eventDate} onChange={e => setEventDate(e.target.value)} required />
                    </div>
                    <div className="form-group">
                      <label>Price (INR) • 0 if Free</label>
                      <input type="number" step="0.01" className="form-control" placeholder="150" value={eventPrice} onChange={e => setEventPrice(e.target.value)} />
                    </div>
                    <div className="form-group">
                      <label>Total Capacity (Seats)</label>
                      <input type="number" className="form-control" placeholder="100" value={eventCapacity} onChange={e => setEventCapacity(e.target.value)} />
                    </div>
                  </div>

                  <div style={{ backgroundColor: 'white', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-color)', margin: '12px 0 24px 0' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <input type="checkbox" id="volReg" style={{ width: '18px', height: '18px', cursor: 'pointer' }} checked={eventVolReg} onChange={e => setEventVolReg(e.target.checked)} />
                      <label htmlFor="volReg" style={{ fontWeight: '600', fontSize: '14px', cursor: 'pointer' }}>Enable Volunteer Registration for this Event</label>
                    </div>

                    {eventVolReg && (
                      <div className="form-group" style={{ marginTop: '16px', maxWidth: '240px' }}>
                        <label>Volunteer Limits (Spots)</label>
                        <input type="number" className="form-control" value={eventVolLimit} onChange={e => setEventVolLimit(e.target.value)} />
                      </div>
                    )}
                  </div>

                  <div style={{ display: 'flex', gap: '12px' }}>
                    <button type="submit" className="btn btn-primary">Publish Portal</button>
                    <button type="button" className="btn btn-outline" onClick={() => setShowEventForm(false)}>Cancel</button>
                  </div>
                </form>
              </div>
            )}

            <div className="grid-responsive">
              {events.map(e => {
                const regCount = participantsList.filter(r => r.eventId === e.id && r.status !== 'cancelled').length;
                const volCount = volunteersList.filter(r => r.eventId === e.id && r.status !== 'cancelled').length;

                return (
                  <div className="card fade-in" key={e.id} style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                    <div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                        <span style={{ fontSize: '11px', fontWeight: 'bold', color: 'var(--color-brand)', textTransform: 'uppercase', padding: '4px 8px', backgroundColor: 'var(--color-brand-light)', borderRadius: '6px' }}>
                          {e.price > 0 ? `₹${e.price}` : 'FREE'}
                        </span>
                        <span className="badge badge-approved">{e.status}</span>
                      </div>
                      <h3 style={{ fontSize: '17px', fontWeight: '700', marginBottom: '8px' }}>{e.title}</h3>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '13px', lineHeight: '1.5', marginBottom: '16px' }}>{e.description}</p>
                      
                      <div style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '6px', padding: '12px', backgroundColor: '#f8fafc', borderRadius: '8px', marginBottom: '16px' }}>
                        <div>📍 {e.venue}</div>
                        <div>📅 {e.dateString}</div>
                        <div>👥 Capacity: {e.capacity} (Booked: {regCount})</div>
                        {e.volunteerRegistration && (
                          <div style={{ color: 'var(--color-success)', fontWeight: '600' }}>🤝 Volunteers: {volCount} / {e.volunteerLimit} limit</div>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Tab 3: Verification List */}
        {activeTab === 'verifications' && (
          <div className="card fade-in">
            <h2>Payment & Bookings Verification</h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '13px', marginTop: '4px' }}>Review bank and gateway transactions submitted by students and approve ticket issues.</p>
            
            {participantsList.length === 0 ? (
              <p style={{ marginTop: '24px', color: 'var(--text-secondary)', textAlign: 'center' }}>No bookings submitted yet.</p>
            ) : (
              <div style={{ overflowX: 'auto' }}>
                <table>
                  <thead>
                    <tr>
                      <th>Booking ID</th>
                      <th>Student Details</th>
                      <th>Event Details</th>
                      <th>Payment Summary</th>
                      <th>Status</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {participantsList.map(r => (
                      <tr key={r.id}>
                        <td style={{ fontWeight: 'bold', fontSize: '13px' }}>#{r.id}</td>
                        <td>
                          <div style={{ fontWeight: '600', fontSize: '13px' }}>{r.userName}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{r.userRollNumber} • {r.userBranch}</div>
                        </td>
                        <td>
                          <div style={{ fontWeight: '600', fontSize: '13px' }}>{r.eventTitle}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{r.eventDate}</div>
                        </td>
                        <td>
                          <div style={{ fontWeight: '700', fontSize: '13px', color: r.paymentAmount > 0 ? 'var(--color-success)' : 'var(--text-secondary)' }}>
                            {r.paymentAmount > 0 ? `₹${r.paymentAmount.toFixed(2)}` : 'FREE'}
                          </div>
                          <div style={{ fontSize: '10px', color: 'var(--text-muted)' }}>
                            {r.paymentMethod} {r.transactionId ? `(${r.transactionId})` : ''}
                          </div>
                        </td>
                        <td>
                          <span className={`badge badge-${r.status}`}>{r.status}</span>
                        </td>
                        <td>
                          {r.status === 'pending' ? (
                            <button className="btn btn-success" style={{ padding: '6px 12px', borderRadius: '6px', fontSize: '12px' }} onClick={() => handleVerifyBooking(r.id)}>
                              Verify & Issue Ticket
                            </button>
                          ) : (
                            <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Checked / Verified</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* Tab 4: Volunteers list */}
        {activeTab === 'volunteers' && (
          <div className="card fade-in">
            <h2>Club Volunteers Roster</h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '13px', marginTop: '4px' }}>Student listing registered as event support crew volunteers.</p>

            {volunteersList.length === 0 ? (
              <p style={{ marginTop: '24px', color: 'var(--text-secondary)', textAlign: 'center' }}>No volunteer registrations found.</p>
            ) : (
              <div style={{ overflowX: 'auto' }}>
                <table>
                  <thead>
                    <tr>
                      <th>Volunteer Name</th>
                      <th>Roll Number</th>
                      <th>Branch</th>
                      <th>Year of Passing</th>
                      <th>Assigned Event</th>
                      <th>Registration Date</th>
                    </tr>
                  </thead>
                  <tbody>
                    {volunteersList.map(r => (
                      <tr key={r.id}>
                        <td style={{ fontWeight: '600', fontSize: '13px' }}>{r.userName}</td>
                        <td style={{ fontSize: '13px' }}>{r.userRollNumber}</td>
                        <td style={{ fontSize: '13px' }}>{r.userBranch}</td>
                        <td style={{ fontSize: '13px' }}>{r.userYearOfPassing}</td>
                        <td>
                          <div style={{ fontWeight: '600', fontSize: '13px' }}>{r.eventTitle}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{r.eventDate}</div>
                        </td>
                        <td style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{new Date(r.timestamp).toLocaleDateString()}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* Tab 5: Scanner Terminal */}
        {activeTab === 'scanner' && (
          <div className="card fade-in" style={{ maxWidth: '600px', margin: '0 auto', width: '100%' }}>
            <h2 style={{ textAlign: 'center', marginBottom: '12px' }}>Venue Ticket Admission Guard</h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '13px', textAlign: 'center', marginBottom: '32px' }}>
              Check-in students at the event gates. Enter the Ticket/Booking ID shown on the student's mobile client.
            </p>

            <form onSubmit={handleAdmitTicket} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div className="form-group">
                <label>Ticket / Booking ID</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="e.g. 5001"
                  value={scanCode}
                  onChange={e => setScanCode(e.target.value)}
                  style={{ fontSize: '18px', textAlign: 'center', padding: '16px', fontWeight: 'bold', letterSpacing: '2px' }}
                  required
                />
              </div>

              <button type="submit" className="btn btn-primary" style={{ padding: '14px', borderRadius: '12px', fontSize: '15px' }}>
                Verify & Admit Entry
              </button>
            </form>

            {scanMessage && (
              <div style={{
                marginTop: '28px',
                backgroundColor: 'var(--color-success-light)',
                color: '#065f46',
                padding: '20px',
                borderRadius: '12px',
                border: '1px solid #a7f3d0',
                fontSize: '14px',
                lineHeight: '1.6'
              }}>
                {scanMessage}
              </div>
            )}

            {scanError && (
              <div style={{
                marginTop: '28px',
                backgroundColor: 'var(--color-danger-light)',
                color: '#991b1b',
                padding: '20px',
                borderRadius: '12px',
                border: '1px solid #fca5a5',
                fontSize: '14px',
                lineHeight: '1.6'
              }}>
                ❌ {scanError}
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}
