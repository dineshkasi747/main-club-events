import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/club.dart';
import '../models/event.dart';
import '../providers/app_state.dart';
import '../widgets/premium_image.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  List<Event> upcomingEvents = [];
  List<HistoricalEvent> pastEvents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final state = Provider.of<AppState>(context, listen: false);
    final data = await state.fetchClubDetails(widget.club.id);
    if (data != null && mounted) {
      setState(() {
        upcomingEvents = data['upcoming'] as List<Event>;
        pastEvents = data['past'] as List<HistoricalEvent>;
        loading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group past events by year
    final Map<String, List<HistoricalEvent>> groupedPast = {
      '2023-24': [],
      '2024-25': [],
      '2025-26': [],
    };

    for (var ev in pastEvents) {
      if (groupedPast.containsKey(ev.academicYear)) {
        groupedPast[ev.academicYear]!.add(ev);
      } else {
        groupedPast[ev.academicYear] = [ev];
      }
    }

    // Dynamic club banner and category based on club ID
    String bannerUrl = '';
    String category = 'Sports';
    if (widget.club.id == 101 || widget.club.id == 104) {
      bannerUrl = widget.club.id == 104
          ? 'https://images.unsplash.com/photo-1677442136019-21780efad99a?w=600&auto=format&fit=crop'
          : 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600&auto=format&fit=crop';
      category = 'Technical';
    } else if (widget.club.id == 102) {
      bannerUrl = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop';
      category = 'Cultural';
    } else {
      bannerUrl = 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=600&auto=format&fit=crop';
      category = 'Sports';
    }

    // Dynamic Core Team Data
    final List<Map<String, String>> coreTeam = [
      {
        'name': 'Dr. Amit Kumar',
        'role': 'HOD & Coordinator',
        'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=120&auto=format&fit=crop'
      },
      {
        'name': widget.club.presidentName,
        'role': 'Club President',
        'avatar': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=120&auto=format&fit=crop'
      },
      {
        'name': 'Prof. R.K. Sharma',
        'role': 'Faculty Advisor',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&auto=format&fit=crop'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : CustomScrollView(
              slivers: [
                // 1. Silver AppBar with Club banner
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: const Color(0xFF4F46E5),
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.club.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        PremiumImage(url: bannerUrl, category: category),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Club Details Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Details Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFFEEF2F6),
                                    child: ClipOval(
                                      child: PremiumImage(url: bannerUrl, category: category, width: 48, height: 48),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.club.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 2),
                                        Text('$category Club', style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFE2E8F0)),
                              Text(
                                widget.club.description,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.people_outline, color: Color(0xFF64748B), size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Members:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                  const SizedBox(width: 4),
                                  Text('${widget.club.membersCount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 3. Previous Year Tenure Folders
                        const Text(
                          'Previous Conducted Events (Archives)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 12),
                        ...groupedPast.keys.map((year) {
                          final eventsInYear = groupedPast[year] ?? [];
                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFFFFBEB),
                                child: Icon(Icons.folder, color: Color(0xFFF59E0B)),
                              ),
                              title: Text(
                                'Tenure $year Archives',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                              subtitle: Text(
                                '${eventsInYear.length} events archived',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => YearlyEventsScreen(
                                      year: year,
                                      events: eventsInYear,
                                      clubName: widget.club.name,
                                      category: category,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // 4. Executive Club Committee Section
                        const Text(
                          'Executive Club Committee',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: coreTeam.length,
                            itemBuilder: (context, index) {
                              final member = coreTeam[index];
                              return Container(
                                width: 110,
                                margin: const EdgeInsets.only(right: 14),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(member['avatar']!),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      member['name']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member['role']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ----------------------------------------------------
// Screen listing historical events in selected year
// ----------------------------------------------------
class YearlyEventsScreen extends StatelessWidget {
  final String year;
  final List<HistoricalEvent> events;
  final String clubName;
  final String category;

  const YearlyEventsScreen({
    super.key,
    required this.year,
    required this.events,
    required this.clubName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Tenure $year Archives', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: events.isEmpty
          ? const Center(child: Text('No historical events archived in this tenure.', style: TextStyle(color: Color(0xFF94A3B8))))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final ev = events[index];
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoricalEventDetailScreen(event: ev, category: category),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Display the first image of the archive if available
                        if (ev.images.isNotEmpty)
                          SizedBox(
                            height: 140,
                            child: PremiumImage(
                              url: ev.images.first,
                              category: category,
                              customBorderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                                  ),
                                  Text(
                                    ev.date,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ev.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ev.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.people_outline, size: 14, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 4),
                                  Text('Volunteers: ${ev.volunteersCount}', style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5))),
                                  const Spacer(),
                                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 2),
                                  Text(ev.venue, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ----------------------------------------------------
// Details & Gallery view for Historical events
// ----------------------------------------------------
class HistoricalEventDetailScreen extends StatelessWidget {
  final HistoricalEvent event;
  final String category;

  const HistoricalEventDetailScreen({super.key, required this.event, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Event Archives', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView(
        children: [
          // Banner Image (using first gallery photo as banner)
          if (event.images.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: PremiumImage(url: event.images.first, category: category),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TENURE ${event.academicYear}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                ),
                const SizedBox(height: 16),

                // Location, date, volunteers cards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF4F46E5), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Venue Place', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text(event.venue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF4F46E5), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Conducted On', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text(event.date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Color(0xFF4F46E5), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Volunteers Engaged', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text('${event.volunteersCount} Active Students', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Event Details & Summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.6),
                ),
                const SizedBox(height: 28),

                // Gallery Grid Section
                if (event.images.isNotEmpty) ...[
                  const Text(
                    'Event Gallery (Tap to expand)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: event.images.length,
                    itemBuilder: (context, idx) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenGalleryScreen(
                                images: event.images,
                                initialIndex: idx,
                                category: category,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PremiumImage(url: event.images[idx], category: category),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Zoomable Full Screen Gallery Screen
// ----------------------------------------------------
class FullScreenGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String category;

  const FullScreenGalleryScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.category,
  });

  @override
  State<FullScreenGalleryScreen> createState() => _FullScreenGalleryScreenState();
}

class _FullScreenGalleryScreenState extends State<FullScreenGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable PageView of images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (idx) {
              setState(() {
                _currentIndex = idx;
              });
            },
            itemBuilder: (context, idx) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.5,
                  child: PremiumImage(
                    url: widget.images[idx],
                    category: widget.category,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Top action bar (Close & counter)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 48), // Spacer to balance layout
              ],
            ),
          ),
        ],
      ),
    );
  }
}
