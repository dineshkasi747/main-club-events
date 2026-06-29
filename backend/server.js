const express = require('express');
const cors = require('cors');
const { readData, writeData } = require('./dataStore');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Helper function to find a user by token (for simple mock header-based auth)
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Authorization header missing' });
  }
  const token = authHeader.replace('Bearer ', '');
  const db = readData();
  const user = db.users.find(u => u.email === token);
  if (!user) {
    return res.status(401).json({ error: 'Invalid or expired session token' });
  }
  req.user = user;
  next();
}

// 1. Auth Login Endpoint
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const db = readData();
  const user = db.users.find(u => u.email.toLowerCase() === email.toLowerCase());

  if (!user) {
    return res.status(401).json({ error: 'User not found' });
  }

  // Admin and Presidents require password verification
  if (user.role === 'admin' || user.role === 'president') {
    if (user.password !== password) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
  }
  // For students, let's allow demo bypass (password is not hard-checked)
  
  res.json({
    token: user.email,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      clubId: user.clubId,
      branch: user.branch,
      rollNumber: user.rollNumber,
      yearOfPassing: user.yearOfPassing
    }
  });
});

// 2. Fetch all clubs
app.get('/api/clubs', (req, res) => {
  const db = readData();
  res.json(db.clubs);
});

// 3. Get single club details with both upcoming events and historical events
app.get('/api/clubs/:id', (req, res) => {
  const clubId = parseInt(req.params.id);
  const db = readData();
  const club = db.clubs.find(c => c.id === clubId);
  if (!club) {
    return res.status(404).json({ error: 'Club not found' });
  }

  const upcomingEvents = db.events.filter(e => e.clubId === clubId && e.status === 'active');
  const pastEvents = db.historicalEvents.filter(h => h.clubId === clubId);

  res.json({
    ...club,
    upcomingEvents,
    pastEvents
  });
});

// 4. Fetch all upcoming active events
app.get('/api/events', (req, res) => {
  const db = readData();
  const activeEvents = db.events.filter(e => e.status === 'active');
  res.json(activeEvents);
});

// 5. Get single event
app.get('/api/events/:id', (req, res) => {
  const eventId = parseInt(req.params.id);
  const db = readData();
  const event = db.events.find(e => e.id === eventId);
  if (!event) {
    return res.status(404).json({ error: 'Event not found' });
  }
  res.json(event);
});

// 6. Create Event (Admin/President only)
app.post('/api/events', authenticate, (req, res) => {
  if (req.user.role !== 'admin' && req.user.role !== 'president') {
    return res.status(403).json({ error: 'Unauthorized. Only club presidents and admins can post events.' });
  }

  const { title, description, venue, dateString, price, capacity, volunteerRegistration, volunteerLimit, imagePath } = req.body;
  const db = readData();

  const newEvent = {
    id: Date.now(),
    clubId: req.user.clubId || parseInt(req.body.clubId),
    title,
    description,
    venue,
    dateString,
    price: parseFloat(price) || 0.00,
    capacity: parseInt(capacity) || 100,
    volunteerRegistration: !!volunteerRegistration,
    volunteerLimit: parseInt(volunteerLimit) || 0,
    status: 'active',
    imagePath: imagePath || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&auto=format&fit=crop&q=80'
  };

  db.events.push(newEvent);
  writeData(db);
  res.status(201).json(newEvent);
});

// 7. Register for Event (Participants or Volunteers)
app.post('/api/events/:id/register', authenticate, (req, res) => {
  const eventId = parseInt(req.params.id);
  const { type, paymentMethod, transactionId } = req.body; // type is 'participant' or 'volunteer'
  
  const db = readData();
  const event = db.events.find(e => e.id === eventId);
  if (!event) {
    return res.status(404).json({ error: 'Event not found' });
  }

  // Check if student is already registered
  const alreadyRegistered = db.registrations.some(
    r => r.userId === req.user.id && r.eventId === eventId && r.status !== 'cancelled'
  );
  if (alreadyRegistered) {
    return res.status(400).json({ error: 'You are already registered for this event.' });
  }

  // Handing Volunteer Registration
  if (type === 'volunteer') {
    if (!event.volunteerRegistration) {
      return res.status(400).json({ error: 'Volunteering is not open for this event.' });
    }
    const currentVolunteers = db.registrations.filter(r => r.eventId === eventId && r.type === 'volunteer' && r.status !== 'cancelled').length;
    if (currentVolunteers >= event.volunteerLimit) {
      return res.status(400).json({ error: 'Volunteering spots are full!' });
    }

    const registration = {
      id: Date.now(),
      userId: req.user.id,
      userName: req.user.name,
      userBranch: req.user.branch || 'General',
      userRollNumber: req.user.rollNumber || 'N/A',
      userYearOfPassing: req.user.yearOfPassing || 2026,
      eventId: event.id,
      eventTitle: event.title,
      eventClubId: event.clubId,
      eventPrice: 0.00,
      eventVenue: event.venue,
      eventDate: event.dateString,
      type: 'volunteer',
      status: 'approved', // volunteers approved instantly
      paymentMethod: 'free',
      paymentAmount: 0.00,
      transactionId: 'VOLUNTEER_REG',
      timestamp: new Date().toISOString()
    };

    db.registrations.push(registration);
    writeData(db);
    return res.status(201).json(registration);
  }

  // Participant Registration
  const isPaid = event.price > 0;
  
  // Check seat capacity
  const currentParticipants = db.registrations.filter(r => r.eventId === eventId && r.type === 'participant' && r.status !== 'cancelled').length;
  if (currentParticipants >= event.capacity) {
    return res.status(400).json({ error: 'This event is sold out!' });
  }

  const registration = {
    id: Date.now(),
    userId: req.user.id,
    userName: req.user.name,
    userBranch: req.user.branch || 'General',
    userRollNumber: req.user.rollNumber || 'N/A',
    userYearOfPassing: req.user.yearOfPassing || 2026,
    eventId: event.id,
    eventTitle: event.title,
    eventClubId: event.clubId,
    eventPrice: event.price,
    eventVenue: event.venue,
    eventDate: event.dateString,
    type: 'participant',
    status: isPaid ? 'pending' : 'approved', // If free, approve instantly. If paid, pending verification
    paymentMethod: isPaid ? paymentMethod : 'free',
    paymentAmount: isPaid ? event.price : 0.00,
    transactionId: isPaid ? transactionId : 'FREE_REG',
    timestamp: new Date().toISOString()
  };

  db.registrations.push(registration);
  writeData(db);
  res.status(201).json(registration);
});

// 8. Fetch registrations (Student's bookings or Club's bookings)
app.get('/api/registrations', authenticate, (req, res) => {
  const db = readData();
  
  if (req.user.role === 'student') {
    // Return student bookings
    const bookings = db.registrations.filter(r => r.userId === req.user.id);
    return res.json(bookings);
  } else if (req.user.role === 'president') {
    // Return bookings for the president's club
    const clubBookings = db.registrations.filter(r => r.eventClubId === req.user.clubId);
    return res.json(clubBookings);
  } else if (req.user.role === 'admin') {
    // System admin sees everything
    return res.json(db.registrations);
  }

  res.json([]);
});

// 9. Verify/Approve Registration (President/Admin only)
app.post('/api/registrations/:id/verify', authenticate, (req, res) => {
  if (req.user.role !== 'admin' && req.user.role !== 'president') {
    return res.status(403).json({ error: 'Unauthorized' });
  }

  const regId = parseInt(req.params.id);
  const db = readData();
  const registration = db.registrations.find(r => r.id === regId);

  if (!registration) {
    return res.status(404).json({ error: 'Booking not found' });
  }

  // Scoped checks: Ensure president only verifies their own club's events
  if (req.user.role === 'president' && registration.eventClubId !== req.user.clubId) {
    return res.status(403).json({ error: 'Access Denied: Scoped to assigned club only.' });
  }

  registration.status = 'approved';
  writeData(db);
  res.json({ message: 'Registration payment verified & approved successfully', registration });
});

// 10. Admit ticket at venue (President/Admin only)
app.post('/api/registrations/:id/admit', authenticate, (req, res) => {
  if (req.user.role !== 'admin' && req.user.role !== 'president') {
    return res.status(403).json({ error: 'Unauthorized' });
  }

  const regId = parseInt(req.params.id);
  const db = readData();
  const registration = db.registrations.find(r => r.id === regId);

  if (!registration) {
    return res.status(404).json({ error: 'Booking ticket not found' });
  }

  if (req.user.role === 'president' && registration.eventClubId !== req.user.clubId) {
    return res.status(403).json({ error: 'Access Denied: Scoped to assigned club only.' });
  }

  if (registration.status !== 'approved') {
    return res.status(400).json({ error: 'Ticket is not approved/paid. Verify payment first.' });
  }

  registration.status = 'attended';
  writeData(db);
  res.json({ message: 'Ticket checked in. Student allowed entry!', registration });
});

// Start Server
app.listen(PORT, () => {
  console.log(`🚀 College Clubs Server running on http://localhost:${PORT}`);
});
