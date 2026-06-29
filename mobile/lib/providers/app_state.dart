import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/club.dart';
import '../models/event.dart';
import '../models/registration.dart';

class AppState extends ChangeNotifier {
  // Automatically resolve 10.0.2.2 for Android emulator, localhost for others
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  static final List<Club> _defaultClubs = [
    Club(
      id: 101,
      name: "Tech Brew",
      description: "The official coding club of the campus. We organize hackathons, dev bootcamps, and build awesome software solutions.",
      presidentName: "Karan Malhotra",
      membersCount: 512,
      members: const ["Aarav Mehta", "Rohan Gupta", "Priya Das", "Siddharth Roy", "Sneha Rao"],
    ),
    Club(
      id: 102,
      name: "Nritya & Raga",
      description: "Where music meets dance. The cultural hub for vocalists, instrumentalists, and dancers to perform and express.",
      presidentName: "Ananya Sen",
      membersCount: 430,
      members: const ["Vikram Seth", "Kabir Shah", "Aditi Iyer", "Ishita Sen", "Rhea Nair"],
    ),
    Club(
      id: 103,
      name: "FinEdge & Sports",
      description: "Dedicated to athletic excellence and physical fitness. Organizing league matches, athletic meets, and fitness programs.",
      presidentName: "Rahul Verma",
      membersCount: 298,
      members: const ["Amit Singh", "Arjun Kapoor", "Neha Sharma", "Dev Patel", "Pooja Reddy"],
    ),
    Club(
      id: 104,
      name: "AIML Club",
      description: "The official Artificial Intelligence and Machine Learning club of GVP. We organize Deep Learning workshops, LLM guest lectures, and competitive hackathons.",
      presidentName: "Kalyan Ram",
      membersCount: 350,
      members: const ["Raghunadh", "Kalyan Ram", "Harsha", "Sandeep", "Sai Krishna"],
    ),
  ];

  static final List<Event> _defaultEvents = [
    Event(
      id: 1001,
      clubId: 101,
      title: "CodeSprint 5.0 Hackathon",
      description: "The annual flag-ship 24-hour build challenge. Form a team, design an innovative solution, and present it to top-industry leaders. Pizza and energy drinks are on us!",
      venue: "Main Block, Lab 3",
      dateString: "Aug 27, 2026 @ 09:00 AM",
      price: 150.0,
      capacity: 120,
      volunteerRegistration: true,
      volunteerLimit: 15,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1002,
      clubId: 102,
      title: "Raga - The Music Night",
      description: "An enchanting evening of acoustic performances, rock bands, and classical recitals. Join us under the stars to celebrate the spirit of rhythm and expression.",
      venue: "Open Air Theatre",
      dateString: "Sep 05, 2026 @ 06:00 PM",
      price: 0.0,
      capacity: 300,
      volunteerRegistration: true,
      volunteerLimit: 25,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1003,
      clubId: 103,
      title: "Campus Cricket League",
      description: "Dust off your bats and shoes! The inter-branch cricket league is back. Matches will be held in the main sports arena with live commentary.",
      venue: "College Ground A",
      dateString: "Oct 12, 2026 @ 08:00 AM",
      price: 80.0,
      capacity: 80,
      volunteerRegistration: false,
      volunteerLimit: 0,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1004,
      clubId: 104,
      title: "AI & Deep Learning Hackathon",
      description: "Deploy deep learning models onto real-world datasets in a 12-hour coding sprint. Prizes for the most accurate and creative neural networks!",
      venue: "IBM Lab, Main Block",
      dateString: "Nov 14, 2026 @ 09:00 AM",
      price: 100.0,
      capacity: 150,
      volunteerRegistration: false,
      volunteerLimit: 0,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1677442136019-21780efad99a?w=600&auto=format&fit=crop&q=80",
    ),
  ];

  static final List<HistoricalEvent> _defaultHistoricalEvents = [
    HistoricalEvent(
      id: 2001,
      clubId: 101,
      academicYear: "2023-24",
      title: "Web Dev Bootcamp 2023",
      date: "Oct 15, 2023",
      venue: "Seminar Hall 1",
      description: "A comprehensive hands-on boot camp covering HTML, CSS, JavaScript, and modern frameworks like React.",
      volunteersCount: 12,
      images: const [
        "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2002,
      clubId: 101,
      academicYear: "2024-25",
      title: "CodeSprint 4.0 Hackathon",
      date: "May 27, 2025",
      venue: "Main Block Lab",
      description: "Last year's edition of the famous 12-Hour Build Challenge focusing on Generative AI and web tools.",
      volunteersCount: 18,
      images: const [
        "https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2003,
      clubId: 101,
      academicYear: "2025-26",
      title: "Cybersecurity Workshop",
      date: "Jan 10, 2026",
      venue: "IT Lab 2",
      description: "A workshop focused on white-hat hacking, capture-the-flag (CTF) basics, and securing web APIs.",
      volunteersCount: 8,
      images: const [
        "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2101,
      clubId: 102,
      academicYear: "2023-24",
      title: "Unplugged Acoustic Night",
      date: "Nov 22, 2023",
      venue: "Library lawns",
      description: "Cozy, warm musical performance featuring acoustic guitars, violins, and raw vocals on a winter evening.",
      volunteersCount: 10,
      images: const [
        "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2102,
      clubId: 102,
      academicYear: "2024-25",
      title: "Tarang: Battle of the Bands",
      date: "Feb 14, 2025",
      venue: "Open Air Theatre",
      description: "Deafening drums, roaring guitars, and thousands in the crowd. The biggest rock competition on campus.",
      volunteersCount: 24,
      images: const [
        "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2103,
      clubId: 102,
      academicYear: "2025-26",
      title: "Classical Symphony Concert",
      date: "Mar 05, 2026",
      venue: "Auditorium 2",
      description: "An exhibition of Indian classical raagas and orchestra pieces by student instrument players.",
      volunteersCount: 15,
      images: const [
        "https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2201,
      clubId: 103,
      academicYear: "2023-24",
      title: "Inter-House Football Cup",
      date: "Dec 05, 2023",
      venue: "Main Arena Pitch",
      description: "An intense, high-energy football championship between departments showing incredible sportsmanship.",
      volunteersCount: 15,
      images: const [
        "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1517649763962-0c623066013b?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2202,
      clubId: 103,
      academicYear: "2024-25",
      title: "Annual Athletic Meet",
      date: "Mar 11, 2025",
      venue: "Athletic Track",
      description: "Events ranging from 100m dashes to relay runs and long jumps, highlighting speed and endurance.",
      volunteersCount: 35,
      images: const [
        "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2203,
      clubId: 103,
      academicYear: "2025-26",
      title: "Table Tennis Invitational",
      date: "Apr 18, 2026",
      venue: "Indoor Stadium",
      description: "A rapid-paced table tennis competition hosting players from multiple colleges.",
      volunteersCount: 6,
      images: const [
        "https://images.unsplash.com/photo-1534067783941-51c9c23eccfd?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1511067007398-7e4b90cfa4bc?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2301,
      clubId: 104,
      academicYear: "2025-26",
      title: "Git & GitHub Workshop",
      date: "Sep 09, 2025",
      venue: "IBM Lab",
      description: "A hands-on version control and collaborative platform workshop designed exclusively for students to understand branching, pull requests, and open source.",
      volunteersCount: 15,
      images: const [
        "https://images.unsplash.com/photo-1618401471353-b98aedd07871?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2302,
      clubId: 104,
      academicYear: "2025-26",
      title: "Tool Wave AI Session",
      date: "Sep 24, 2025",
      venue: "Main Auditorium",
      description: "An interactive session exploring generative AI tools for code completion, image synthesis, and layout design acceleration.",
      volunteersCount: 8,
      images: const [
        "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500&auto=format&fit=crop"
      ],
    ),
  ];

  static final List<Registration> _defaultBookings = [
    Registration(
      id: 5001,
      userId: 5,
      userName: "Teja K.",
      userBranch: "Computer Science & Engineering",
      userRollNumber: "22CSE1084",
      userYearOfPassing: 2026,
      eventId: 1001,
      eventTitle: "CodeSprint 5.0 Hackathon",
      eventClubId: 101,
      eventPrice: 150.00,
      eventVenue: "Main Block, Lab 3",
      eventDate: "Aug 27, 2026 @ 09:00 AM",
      type: "participant",
      status: "pending",
      paymentMethod: "UPI (PhonePe)",
      paymentAmount: 150.00,
      transactionId: "TXN987654321",
      timestamp: "2026-06-26T12:00:00.000Z",
    )
  ];

  String? _token;
  Map<String, dynamic>? _user;
  List<Club> _clubs = List.from(_defaultClubs);
  List<Event> _events = List.from(_defaultEvents);
  List<Registration> _bookings = List.from(_defaultBookings);
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  List<Club> get clubs => _clubs;
  List<Event> get events => _events;
  List<Registration> get bookings => _bookings;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchClubs(),
        fetchEvents(),
        fetchBookings(),
      ]);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Mock login details directly for demo/offline functionality
      _token = "demo-jwt-token";
      _user = {
        "id": 5,
        "name": "Teja K.",
        "email": email.isNotEmpty ? email : "student@college.edu",
        "role": "student",
        "branch": "Computer Science & Engineering",
        "rollNumber": "22CSE1084",
        "yearOfPassing": 2026
      };
      
      // Also reset bookings list to default to keep it fresh
      _bookings = List.from(_defaultBookings);
      notifyListeners();

      // Attempt to hit the actual API if the server is alive, otherwise swallow error and proceed
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _token = data['token'];
          _user = data['user'];
          notifyListeners();
          await fetchAllData();
        }
      } catch (e) {
        print('Backend offline or failed, using demo/mock mode: $e');
        // Pre-fetch clubs and events from mock data if server fails
        _clubs = List.from(_defaultClubs);
        _events = List.from(_defaultEvents);
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Login error: $e');
      return true; // Return true anyway for offline/demo APK
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> demoLogin() async {
    return await login('student@college.edu', 'password');
  }

  void logout() {
    _token = null;
    _user = null;
    _bookings = [];
    notifyListeners();
  }

  Future<void> fetchClubs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clubs')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _clubs = data.map((json) => Club.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch clubs error: $e');
      if (_clubs.isEmpty) {
        _clubs = List.from(_defaultClubs);
        notifyListeners();
      }
    }
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _events = data.map((json) => Event.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch events error: $e');
      if (_events.isEmpty) {
        _events = List.from(_defaultEvents);
        notifyListeners();
      }
    }
  }

  Future<void> fetchBookings() async {
    if (!isAuthenticated) return;
    try {
      final response = await http.get(Uri.parse('$baseUrl/registrations'), headers: _headers).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _bookings = data.map((json) => Registration.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch bookings error: $e');
      if (_bookings.isEmpty) {
        _bookings = List.from(_defaultBookings);
        notifyListeners();
      }
    }
  }

  Future<Map<String, dynamic>?> fetchClubDetails(int clubId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clubs/$clubId')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        final List<dynamic> upcomingJson = data['upcomingEvents'] ?? [];
        final List<dynamic> pastJson = data['pastEvents'] ?? [];
        
        final upcoming = upcomingJson.map((j) => Event.fromJson(j)).toList();
        final past = pastJson.map((j) => HistoricalEvent.fromJson(j)).toList();

        return {
          'upcoming': upcoming,
          'past': past,
        };
      }
      return null;
    } catch (e) {
      print('Fetch club details error: $e');
      final upcoming = _events.where((ev) => ev.clubId == clubId).toList();
      final past = _defaultHistoricalEvents.where((ev) => ev.clubId == clubId).toList();
      return {
        'upcoming': upcoming,
        'past': past,
      };
    }
  }

  Future<bool> registerForEvent({
    required int eventId,
    required String type,
    String paymentMethod = 'free',
    String transactionId = 'FREE_REG',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/register'),
        headers: _headers,
        body: jsonEncode({
          'type': type,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration failed: $e');
      final event = _events.firstWhere((ev) => ev.id == eventId, orElse: () => _events[0]);
      final newReg = Registration(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: _user != null ? _user!['id'] : 5,
        userName: _user != null ? _user!['name'] : 'Teja K.',
        userBranch: _user != null ? _user!['branch'] : 'Computer Science & Engineering',
        userRollNumber: _user != null ? _user!['rollNumber'] : '22CSE1084',
        userYearOfPassing: _user != null ? _user!['yearOfPassing'] : 2026,
        eventId: event.id,
        eventTitle: event.title,
        eventClubId: event.clubId,
        eventPrice: event.price,
        eventVenue: event.venue,
        eventDate: event.dateString,
        type: type,
        status: 'approved',
        paymentMethod: paymentMethod,
        paymentAmount: type == 'volunteer' ? 0.0 : event.price,
        transactionId: transactionId,
        timestamp: DateTime.now().toIso8601String(),
      );
      _bookings.add(newReg);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String venue,
    required String dateString,
    required double price,
    required int capacity,
    required bool volunteerRegistration,
    required int volunteerLimit,
    required int clubId,
    required String imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'venue': venue,
          'dateString': dateString,
          'price': price,
          'capacity': capacity,
          'volunteerRegistration': volunteerRegistration,
          'volunteerLimit': volunteerLimit,
          'clubId': clubId,
          'imagePath': imagePath,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        final newEvent = Event.fromJson(jsonDecode(response.body));
        _events.insert(0, newEvent);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Create event failed, performing offline mock addition: $e');
      final newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch,
        clubId: clubId,
        title: title,
        description: description,
        venue: venue,
        dateString: dateString,
        price: price,
        capacity: capacity,
        volunteerRegistration: volunteerRegistration,
        volunteerLimit: volunteerLimit,
        status: 'active',
        imagePath: imagePath.isNotEmpty ? imagePath : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&auto=format&fit=crop&q=80',
      );
      _events.insert(0, newEvent);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
