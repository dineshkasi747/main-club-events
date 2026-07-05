import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/event.dart';
import '../models/club.dart';
import '../models/registration.dart';
import 'club_detail_screen.dart';
import 'event_detail_screen.dart';
import 'ticket_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import '../widgets/premium_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    final tabs = [
      HomeTab(onViewAllEvents: () {
        setState(() {
          _currentIndex = 2;
        });
      }),
      const ClubsTab(),
      const EventsTab(), // Lists all active events vertically with search
      const ProfileTab(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: appState.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
            : SafeArea(child: tabs[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4F46E5),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Clubs'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showCreateEventModal(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final venueController = TextEditingController();
    final dateController = TextEditingController(text: "Sep 20, 2026 @ 10:00 AM");
    final priceController = TextEditingController(text: "100.00");
    final volunteerLimitController = TextEditingController(text: "10");
    final capacityController = TextEditingController(text: "150");

    int selectedClubId = 101;
    String registrationType = 'free'; // 'free', 'paid', 'volunteer'
    String selectedImagePath = 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&auto=format&fit=crop&q=80';

    final presetImages = [
      {'label': 'Coding', 'url': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=600&auto=format&fit=crop&q=80'},
      {'label': 'Music', 'url': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80'},
      {'label': 'Sports', 'url': 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600&auto=format&fit=crop&q=80'},
      {'label': 'Workshop', 'url': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=600&auto=format&fit=crop&q=80'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create New Event',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Event Title', hintText: 'Enter title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description', hintText: 'Enter details'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: venueController,
                            decoration: const InputDecoration(labelText: 'Venue', hintText: 'e.g. Auditorium 1'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: dateController,
                            decoration: const InputDecoration(labelText: 'Date & Time', hintText: 'e.g. Sep 20, 2026 @ 10:00 AM'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dropdown for Club Selector
                    DropdownButtonFormField<int>(
                      value: selectedClubId,
                      decoration: const InputDecoration(labelText: 'Host Club'),
                      items: appState.clubs.map((c) {
                        String categoryLabel = 'Technical';
                        if (c.id == 102) categoryLabel = 'Cultural';
                        if (c.id == 103) categoryLabel = 'Sports';
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text('${c.name} ($categoryLabel)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedClubId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Registration Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    // Registration Selector Segment
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Free Entry'),
                            selected: registrationType == 'free',
                            onSelected: (selected) {
                              if (selected) setModalState(() => registrationType = 'free');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Paid Ticket'),
                            selected: registrationType == 'paid',
                            onSelected: (selected) {
                              if (selected) setModalState(() => registrationType = 'paid');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Volunteer'),
                            selected: registrationType == 'volunteer',
                            onSelected: (selected) {
                              if (selected) setModalState(() => registrationType = 'volunteer');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (registrationType == 'paid') ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Price (₹)', hintText: '100.00'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: capacityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Capacity Limit', hintText: '150'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else if (registrationType == 'volunteer') ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: volunteerLimitController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Volunteer Limit', hintText: '10'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: capacityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Total Capacity', hintText: '150'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text('Choose Banner Preset Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 64,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: presetImages.length,
                        itemBuilder: (context, index) {
                          final item = presetImages[index];
                          final isSelected = selectedImagePath == item['url'];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedImagePath = item['url']!;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                                  width: 2.5,
                                ),
                                image: DecorationImage(image: NetworkImage(item['url']!), fit: BoxFit.cover),
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.4),
                                child: Center(
                                  child: Text(
                                    item['label']!,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final desc = descController.text.trim();
                        final venue = venueController.text.trim();
                        final dateStr = dateController.text.trim();

                        if (title.isEmpty || venue.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill title and venue fields.')),
                          );
                          return;
                        }

                        double price = 0.0;
                        bool volunteerReg = false;
                        int volunteerLim = 0;

                        if (registrationType == 'paid') {
                          price = double.tryParse(priceController.text) ?? 100.0;
                        } else if (registrationType == 'volunteer') {
                          volunteerReg = true;
                          volunteerLim = int.tryParse(volunteerLimitController.text) ?? 10;
                        }

                        final capacity = int.tryParse(capacityController.text) ?? 150;

                        Navigator.pop(context); // Close sheet first
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Row(children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 14), Text('Publishing event...')])),
                        );

                        final success = await appState.createEvent(
                          title: title,
                          description: desc,
                          venue: venue,
                          dateString: dateStr,
                          price: price,
                          capacity: capacity,
                          freeRegistration: price == 0.0,
                          paidRegistration: price > 0.0,
                          volunteerRegistration: volunteerReg,
                          volunteerLimit: volunteerLim,
                          clubId: selectedClubId,
                          imagePath: selectedImagePath,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event Published Successfully!'), backgroundColor: Color(0xFF10B981)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to publish event.'), backgroundColor: Color(0xFFEF4444)),
                          );
                        }
                      },
                      child: const Text('Publish Event to Campus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 1. Home Tab Revamped matching the screenshots
class HomeTab extends StatefulWidget {
  final VoidCallback onViewAllEvents;
  const HomeTab({super.key, required this.onViewAllEvents});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.auto_awesome, 'color': const Color(0xFF4F46E5)},
    {'name': 'Cultural', 'icon': Icons.theater_comedy, 'color': const Color(0xFF8B5CF6)},
    {'name': 'Technical', 'icon': Icons.code, 'color': const Color(0xFF06B6D4)},
    {'name': 'Sports', 'icon': Icons.emoji_events, 'color': const Color(0xFF10B981)},
    {'name': 'Social', 'icon': Icons.handshake, 'color': const Color(0xFFF59E0B)},
    {'name': 'Literary', 'icon': Icons.menu_book, 'color': const Color(0xFFEC4899)},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    final events = appState.events;
    final clubs = appState.clubs;

    final userName = user != null ? user['name'] : 'Student';
    // Split user first name
    final firstName = userName.split(' ')[0];

    // Filter upcoming events based on category selection
    final filteredEvents = _selectedCategory == 'All'
        ? events
        : events.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return RefreshIndicator(
      onRefresh: () => appState.fetchAllData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName 👋',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Discover. Join. Make an impact.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Circular search
                _buildCircularActionButton(Icons.search, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search tool active.')));
                }),
                const SizedBox(width: 10),
                // Circular notifications
                Stack(
                  children: [
                    _buildCircularActionButton(Icons.notifications_none, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    }),
                    if (appState.notifications.isNotEmpty)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Profile Avatar Image
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEEF2F6),
                  backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Categories Horizontal Row
          SizedBox(
            height: 86,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['name'];
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? cat['color'] : (cat['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: (cat['color'] as Color).withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ]
                                : null,
                          ),
                          child: Icon(
                            cat['icon'],
                            color: isSelected ? Colors.white : cat['color'],
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Featured Slider / Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FeaturedCarousel(events: events),
          ),
          const SizedBox(height: 24),

          // Upcoming Events Horizontal List
          _buildSectionHeader('Upcoming Events', widget.onViewAllEvents),
          const SizedBox(height: 12),
          _buildUpcomingHorizontalList(filteredEvents.take(5).toList()),
          const SizedBox(height: 24),

          // Popular Clubs Horizontal List
          _buildSectionHeader('Popular Clubs', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Showing all clubs')));
          }),
          const SizedBox(height: 12),
          _buildPopularClubsHorizontalList(clubs),
          const SizedBox(height: 24),

          // Be an Active Member Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildBeActiveCard(),
          ),
          const SizedBox(height: 24),

          // Happening on Campus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              'Happening on Campus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 12),
          _buildHappeningOnCampusList(),
          const SizedBox(height: 24),

          // What's New List
          _buildSectionHeader("What's New", () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Showing what's new")));
          }),
          const SizedBox(height: 12),
          _buildWhatsNewList(events),
        ],
      ),
    );
  }

  Widget _buildCircularActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingHorizontalList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text('No events in this category yet.', style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final dateParts = event.dateString.split(','); // "Aug 27, 2026 @ 09:00 AM" -> "Aug 27"
          final dayAndMonth = dateParts[0].split(' '); // "Aug 27" -> ["Aug", "27"]
          final month = dayAndMonth.isNotEmpty ? dayAndMonth[0].toUpperCase() : 'MAY';
          final day = dayAndMonth.length > 1 ? dayAndMonth[1] : '24';

          return Container(
            width: 220,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Image with Date badge
                    Expanded(
                      flex: 4,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: PremiumImage(
                              url: event.imagePath,
                              category: event.category,
                              customBorderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                            ),
                          ),
                          // Date Badge overlay
                          Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    month,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
                                  ),
                                  Text(
                                    day,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Details area
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  event.category,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                                ),
                                const Icon(Icons.bookmark_border, size: 14, color: Color(0xFF94A3B8)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            // Time
                            Text(
                              event.dateString.contains('@') ? event.dateString.split('@')[1].trim() : '9:00 AM - 5:00 PM',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 2),
                            // Venue
                            Text(
                              event.venue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            ),
                            const Spacer(),
                            // Going avatars and Register button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildAvatarStack(index == 0 ? 120 : (index == 1 ? 85 : 44))),
                                const SizedBox(width: 4),
                                Container(
                                  height: 26,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF4F46E5), width: 1.2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Register',
                                      style: TextStyle(color: Color(0xFF4F46E5), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarStack(int count) {
    final List<String> avatarUrls = [
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop',
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            avatarUrls.length,
            (index) => Align(
              widthFactor: 0.6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  image: DecorationImage(image: NetworkImage(avatarUrls[index]), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '+$count',
          style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPopularClubsHorizontalList(List<Club> clubs) {
    String getClubLogo(Club club) {
      if (club.name.toLowerCase().contains('data science') || club.id == 105) {
        return 'assets/dsclub/images/DSlogo.jpg';
      }
      if (club.id == 104) {
        return 'assets/aiclub/images/logo2.png';
      }
      if (club.id == 101) {
        return 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=200';
      }
      if (club.id == 102) {
        return 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200';
      }
      if (club.id == 106) {
        return 'assets/ieee_cs/images/logo.png';
      }
      return 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=200';
    }

    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];
          final imgUrl = getClubLogo(club);

          return Container(
            width: 130,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEEF2F6),
                        backgroundImage: imgUrl.startsWith('assets/')
                            ? AssetImage(imgUrl) as ImageProvider
                            : NetworkImage(imgUrl),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        club.name.split(' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${club.membersCount} Members',
                        style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBeActiveCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Be an Active Member',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Participate in events, earn points and unlock exclusive perks!',
                  style: TextStyle(fontSize: 11, color: const Color(0xFF92400E).withOpacity(0.85)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Learn More',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHappeningOnCampusList() {
    final list = [
      {
        'title': 'Club Fair',
        'date': 'Aug 12, 2026',
        'sub': 'Registration Open',
        'icon': Icons.campaign,
        'bg': const Color(0xFFECFDF5),
        'accent': const Color(0xFF059669)
      },
      {
        'title': 'Rewards',
        'date': 'Check points',
        'sub': 'Redeem now!',
        'icon': Icons.card_giftcard,
        'bg': const Color(0xFFF5F3FF),
        'accent': const Color(0xFF7C3AED)
      },
    ];

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            width: 190,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item['bg'] as Color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (item['accent'] as Color).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, color: item['accent'] as Color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text(item['sub'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item['accent'] as Color)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhatsNewList(List<Event> events) {
    if (events.isEmpty) return const SizedBox.shrink();
    // Use last event as a sample for What's New
    final event = events.last;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              PremiumImage(
                url: event.imagePath,
                category: event.category,
                width: 72,
                height: 72,
                borderRadius: 12,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.category,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                        ),
                        const Text(
                          'MAY 30',
                          style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Featured Carousel widget
class FeaturedCarousel extends StatefulWidget {
  final List<Event> events;
  const FeaturedCarousel({super.key, required this.events});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();
    final itemCount = min(3, widget.events.length);
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            itemCount: itemCount,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PremiumImage(
                        url: event.imagePath,
                        category: event.category,
                        borderRadius: 20,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.laptop, color: Colors.white70, size: 12),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${event.description.split('.')[0]} • ${event.dateString.split(' @')[0]} • ${event.venue.split(',')[0]}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            itemCount,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: _currentIndex == index ? 14 : 5,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentIndex == index ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 2. Clubs Tab
class ClubsTab extends StatefulWidget {
  const ClubsTab({super.key});

  @override
  State<ClubsTab> createState() => _ClubsTabState();
}

class _ClubsTabState extends State<ClubsTab> {
  String _searchQuery = '';
  String _selectedCategory = 'All Clubs';

  final List<String> _categories = [
    'All Clubs',
    'Technology',
    'Arts & Creative',
    'Sports',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final clubs = appState.clubs;

    // Helper to get category for each club dynamically based on name/ID
    String getClubCategory(Club club) {
      if (club.name.toLowerCase().contains('data science') || club.id == 105) return 'Technology';
      if (club.id == 101 || club.id == 104 || club.id == 106) return 'Technology';
      if (club.id == 102) return 'Arts & Creative';
      return 'Sports';
    }

    // Helper to get Unsplash/Asset banner for each club category
    String getClubBanner(Club club) {
      if (club.name.toLowerCase().contains('data science') || club.id == 105) {
        return 'assets/dsclub/images/DSlogo.jpg';
      }
      if (club.id == 101) {
        return 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400';
      } else if (club.id == 104) {
        return 'assets/aiclub/images/logo2.png';
      } else if (club.id == 102) {
        return 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400';
      } else if (club.id == 106) {
        return 'assets/ieee_cs/images/logo.png';
      } else {
        return 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=400&auto=format&fit=crop';
      }
    }

    // Helper to get fast-loading club logos (local assets or Unsplash)
    String getClubLogo(Club club) {
      if (club.name.toLowerCase().contains('data science') || club.id == 105) {
        return 'assets/dsclub/images/DSlogo.jpg';
      }
      if (club.id == 104) {
        return 'assets/aiclub/images/logo2.png';
      }
      if (club.id == 101) {
        return 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=200';
      }
      if (club.id == 102) {
        return 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200';
      }
      if (club.id == 106) {
        return 'assets/ieee_cs/images/logo.png';
      }
      return 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=200';
    }

    // Filter list
    final filtered = clubs.where((club) {
      final matchesSearch = club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          club.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final cat = getClubCategory(club);
      final matchesCategory = _selectedCategory == 'All Clubs' || cat == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Discover Clubs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Text(
                '${filtered.length} Active Clubs',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name or category...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
          ),
        ),

        // Horizontal Category Filter Chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF4F46E5),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Grid View of Clubs
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => appState.fetchAllData(),
            child: filtered.isEmpty
                ? const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Center(
                      heightFactor: 4.0,
                      child: Text(
                        'No clubs match your query.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.64,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                    final club = filtered[index];
                    final catName = getClubCategory(club);
                    final banner = getClubBanner(club);

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card image top
                            Expanded(
                              flex: 12,
                              child: PremiumImage(
                                url: banner,
                                category: catName,
                                customBorderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                            // Details
                            Expanded(
                              flex: 11,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                club.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 14,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          club.description,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF64748B),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.people_outline,
                                              size: 11,
                                              color: Color(0xFF4F46E5),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${club.membersCount}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2F6),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            catName,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4F46E5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }
}

// 3. Events Tab (Search and list view)
class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final events = appState.events;

    final filtered = events.where((e) {
      final q = _searchQuery.toLowerCase();
      return e.title.toLowerCase().contains(q) || e.venue.toLowerCase().contains(q) || e.category.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Campus Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search events, venue or category...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => appState.fetchAllData(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
              final event = filtered[index];
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        PremiumImage(
                          url: event.imagePath,
                          category: event.category,
                          width: 64,
                          height: 64,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.category,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                event.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${event.dateString.split(' @')[0]} • ${event.venue}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
  }
}

// 4. Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    final bookings = appState.bookings;

    if (user == null) {
      return const Center(child: Text('Loading profile...'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Top Profile card
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                      onPressed: () {
                        appState.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFEEF2F6),
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop'),
                ),
                const SizedBox(height: 14),
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const Divider(height: 28, color: Color(0xFFE2E8F0)),
                _profileRow('Branch', user['branch'] ?? 'N/A'),
                _profileRow('Roll Number', user['rollNumber'] ?? 'N/A'),
                _profileRow('Graduation Year', user['yearOfPassing']?.toString() ?? 'N/A'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'My Registered Bookings & Tickets',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 14),

        if (bookings.isEmpty)
          const Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('No bookings found. Register for events to generate tickets.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ),
            ),
          )
        else
          ...bookings.map((booking) {
            Color badgeColor;
            Color textBadgeColor;
            if (booking.status == 'approved') {
              badgeColor = const Color(0xFFD1FAE5);
              textBadgeColor = const Color(0xFF047857);
            } else if (booking.status == 'attended') {
              badgeColor = const Color(0xFFE0E7FF);
              textBadgeColor = const Color(0xFF4F46E5);
            } else {
              badgeColor = const Color(0xFFFEF3C7);
              textBadgeColor = const Color(0xFFB45309);
            }

            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.confirmation_num, color: Color(0xFF4F46E5)),
                ),
                title: Text(
                  booking.eventTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(booking.eventVenue, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    const SizedBox(height: 2),
                    Text(
                      'Booking ID: #${booking.id} • ${booking.type.toUpperCase()}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textBadgeColor),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
