import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    // Group past events by year dynamically and sort descending
    final Map<String, List<HistoricalEvent>> groupedPast = {};
    for (var ev in pastEvents) {
      groupedPast.putIfAbsent(ev.academicYear, () => []).add(ev);
    }
    final sortedYears = groupedPast.keys.toList()..sort((a, b) => b.compareTo(a));

    // Dynamic club banner, logo and category based on club ID
    String bannerUrl = '';
    String logoUrl = '';
    String category = 'Sports';
    if (widget.club.name.toLowerCase().contains('data science') || widget.club.id == 105) {
      bannerUrl = 'assets/dsclub/images/DSlogo.jpg';
      logoUrl = 'assets/dsclub/images/DSlogo.jpg';
      category = 'Technical';
    } else if (widget.club.id == 104) {
      bannerUrl = 'assets/aiclub/images/logo2.png';
      logoUrl = 'assets/aiclub/images/logo2.png';
      category = 'Technical';
    } else if (widget.club.id == 101) {
      bannerUrl = 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600&auto=format&fit=crop';
      logoUrl = 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=200';
      category = 'Technical';
    } else if (widget.club.id == 102) {
      bannerUrl = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop';
      logoUrl = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200';
      category = 'Cultural';
    } else if (widget.club.id == 106) {
      bannerUrl = 'assets/ieee_cs/images/logo.png';
      logoUrl = 'assets/ieee_cs/images/logo.png';
      category = 'Technical';
    } else {
      bannerUrl = 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=600&auto=format&fit=crop';
      logoUrl = 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=200';
      category = 'Sports';
    }

    // Dynamic Core Team Data
    final List<Map<String, String>> coreTeam = [];
    if (widget.club.name.toLowerCase().contains('data science') || widget.club.id == 105) {
      coreTeam.addAll([
        {
          'name': 'Dr. Y. Anuradha',
          'role': 'Faculty Head',
          'avatar': 'assets/dsclub/images/anuradha.jpg'
        },
        {
          'name': 'M. Rithvik',
          'role': 'Advisor',
          'avatar': 'assets/dsclub/images/rithvik.jpg'
        },
        {
          'name': 'M. Pallavi',
          'role': 'Advisor',
          'avatar': 'assets/dsclub/images/pallavi.jpg'
        },
        {
          'name': 'G. Surya Chaitanya',
          'role': 'President',
          'avatar': 'assets/dsclub/images/Surya.jpg'
        },
        {
          'name': 'A. Geethika',
          'role': 'Vice-President',
          'avatar': 'assets/dsclub/images/Geethika.jpg'
        },
        {
          'name': 'K.J.S.S. Manohar',
          'role': 'Treasurer',
          'avatar': 'assets/dsclub/images/manohar.jpg'
        },
        {
          'name': 'Ch. Surya Teja',
          'role': 'Organizing Lead',
          'avatar': 'assets/dsclub/images/SuryaTeja.jpg'
        },
        {
          'name': 'D.Y.N. Nandhitha',
          'role': 'Organizing Co-Lead',
          'avatar': 'assets/dsclub/images/Nanditha.jpg'
        },
        {
          'name': 'R. Naga Sai Nikhil',
          'role': 'Web Lead',
          'avatar': 'assets/dsclub/images/Nikhil.jpg'
        },
        {
          'name': 'S. Charith',
          'role': 'Technical Lead',
          'avatar': 'assets/dsclub/images/Charith.jpg'
        },
        {
          'name': 'P. Sasank',
          'role': 'Technical Co-Lead',
          'avatar': 'assets/dsclub/images/Sasank.jpg'
        },
        {
          'name': 'G. Amrutha Varshini',
          'role': 'Social Media Lead',
          'avatar': 'assets/dsclub/images/Amrutha.jpg'
        },
        {
          'name': 'B. Syam Chand',
          'role': 'Out Reach Lead',
          'avatar': 'assets/dsclub/images/Syam Chand.png'
        },
      ]);
    } else if (widget.club.id == 104) {
      coreTeam.addAll([
        {
          'name': 'Dr. D Uma Devi',
          'role': 'Faculty Head & HOD',
          'avatar': 'assets/aiclub/images/uma.jpeg'
        },
        {
          'name': 'Dr.A.Ajay Kumar',
          'role': 'Associate Professor',
          'avatar': 'assets/aiclub/images/ajay.jpg'
        },
        {
          'name': 'Dr. G. Satya Keerthi',
          'role': 'Associate Professor',
          'avatar': 'assets/aiclub/images/satyakeerthi.jpg'
        },
        {
          'name': 'Dr. K. Beulah',
          'role': 'Assistant Professor',
          'avatar': 'assets/aiclub/images/beulah.jpg'
        },
        {
          'name': 'T. Sai Sindhuja',
          'role': 'Assistant Professor',
          'avatar': 'assets/aiclub/images/sindhuja.jpg'
        },
        {
          'name': 'Mrs Dasari Madhavi',
          'role': 'Assistant Professor',
          'avatar': 'assets/aiclub/images/madhavi.jpg'
        },
        {
          'name': 'Saripalli CK MahaLakshmi',
          'role': 'Assistant Professor',
          'avatar': 'assets/aiclub/images/lakshmi.jpg'
        },
        {
          'name': 'SK.Abdul Razaq',
          'role': 'President',
          'avatar': 'assets/aiclub/images/razaq.jpg'
        },
        {
          'name': 'Reddi Karthika',
          'role': 'Vice President',
          'avatar': 'assets/aiclub/images/karthika.jpeg'
        },
        {
          'name': 'Rishitha Garapati',
          'role': 'Secretary',
          'avatar': 'assets/aiclub/images/rishitha.jpg'
        },
        {
          'name': 'Yeddu Tejaswani',
          'role': 'Joint Secretary',
          'avatar': 'assets/aiclub/images/tejaswini.jpg'
        },
        {
          'name': 'D.Adithya Yadav',
          'role': 'Treasurer',
          'avatar': 'assets/aiclub/images/aditya.jpg'
        },
        {
          'name': 'M. Kalyan Ram',
          'role': 'Technical Lead',
          'avatar': 'assets/aiclub/images/kalyan.jpeg'
        },
        {
          'name': 'P.Preethika',
          'role': 'Technical Lead',
          'avatar': 'assets/aiclub/images/preethika.jpg'
        },
        {
          'name': 'T. Sai Sankar',
          'role': 'Technical Lead',
          'avatar': 'assets/aiclub/images/shankar.jpg'
        },
        {
          'name': 'Anand Mahadev P',
          'role': 'Creative Content Lead',
          'avatar': 'assets/aiclub/images/anand222.jpg'
        },
        {
          'name': 'Y. Hiranvika',
          'role': 'Creative Content Lead',
          'avatar': 'assets/aiclub/images/hiranvika.jpg'
        },
        {
          'name': 'V. Sai Gautam',
          'role': 'Editorial Lead',
          'avatar': 'assets/aiclub/images/gautham.jpg'
        },
        {
          'name': 'Sathvic Devabathula',
          'role': 'Editorial Lead',
          'avatar': 'assets/aiclub/images/sathvic.jpg'
        },
        {
          'name': 'Ravi Kolli',
          'role': 'PR & Media Lead',
          'avatar': 'assets/aiclub/images/ravi.jpg'
        },
        {
          'name': 'K.Sirisha',
          'role': 'PR & Media Lead',
          'avatar': 'assets/aiclub/images/siri.jpg'
        },
        {
          'name': 'M.Shiva Gowtham',
          'role': 'Logistics & Hospitality Lead',
          'avatar': 'assets/aiclub/images/sivagautham.jpg'
        },
        {
          'name': 'Dileep Kumar Chelluri',
          'role': 'Logistics & Hospitality Lead',
          'avatar': 'assets/aiclub/images/dileep.jpg'
        },
        {
          'name': 'V S Siddhard sai',
          'role': 'Technical Team',
          'avatar': 'assets/aiclub/images/siddhardh.jpg'
        },
        {
          'name': 'Ch. Niharika',
          'role': 'Technical Team',
          'avatar': 'assets/aiclub/images/niharika.jpeg'
        },
        {
          'name': 'Sirisha Maragada',
          'role': 'Creative Content Team',
          'avatar': 'assets/aiclub/images/sirisha.jpg'
        },
        {
          'name': 'M.D.N Sarvani',
          'role': 'Creative Content Team',
          'avatar': 'assets/aiclub/images/sarvani.jpeg'
        },
        {
          'name': 'B.Mahesh',
          'role': 'Editorial Team',
          'avatar': 'assets/aiclub/images/mahesh.jpg'
        },
        {
          'name': 'P. Harshini',
          'role': 'Editorial Team',
          'avatar': 'assets/aiclub/images/harshini.jpeg'
        },
        {
          'name': 'B. Leela Sri SatyaVathi',
          'role': 'PR & Media Team',
          'avatar': 'assets/aiclub/images/leela.jpg'
        },
        {
          'name': 'Bhavya Sadhanala',
          'role': 'PR & Media Team',
          'avatar': 'assets/aiclub/images/bhavya.jpg'
        },
        {
          'name': 'G. Sri Sai Harshita',
          'role': 'PR & Media Team',
          'avatar': 'assets/aiclub/images/harshitha.jpg'
        },
        {
          'name': 'P.Sai Siva Kumar',
          'role': 'Logistics & Hospitality',
          'avatar': 'assets/aiclub/images/shivakumar.jpg'
        },
        {
          'name': 'V.Harsha Vardhan',
          'role': 'Logistics & Hospitality',
          'avatar': 'assets/aiclub/images/vaedhan.jpeg'
        },
        {
          'name': 'G.Prabhas',
          'role': 'Executive Head',
          'avatar': 'assets/aiclub/images/prabhas.jpeg'
        },
        {
          'name': 'Mr.B.Ajay Ram',
          'role': 'Past Coordinator',
          'avatar': 'assets/aiclub/images/ajayram.jpg'
        },
        {
          'name': 'Dr.R.Seeta Sireesha',
          'role': 'Past Coordinator',
          'avatar': 'assets/aiclub/images/sitasirisha.jpeg'
        },
      ]);
    } else if (widget.club.id == 106) {
      coreTeam.addAll([
        {
          'name': 'Dr. G. Satya Keerthi',
          'role': 'CS Chapter Advisor',
          'avatar': 'assets/ieee_cs/images/satyakeerthi.png'
        },
        {
          'name': 'Mukalla Pallavi',
          'role': 'Chair Person',
          'avatar': 'assets/ieee_cs/images/pallavi.jpg'
        },
        {
          'name': 'B N V Hemanth',
          'role': 'Vice Chair Person',
          'avatar': 'assets/ieee_cs/images/hemanth.jpg'
        },
        {
          'name': 'Sandra Rishitha M',
          'role': 'Secretary',
          'avatar': 'assets/ieee_cs/images/rishitha.jpg'
        },
        {
          'name': 'B Harika',
          'role': 'Executive Member',
          'avatar': 'assets/ieee_cs/images/harika.jpg'
        },
      ]);
    } else {
      coreTeam.addAll([
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
      ]);
    }

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
                                      child: PremiumImage(url: logoUrl, category: category, width: 48, height: 48),
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
                        ...sortedYears.map((year) {
                          final eventsInYear = groupedPast[year]!;
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
                                      backgroundImage: member['avatar']!.startsWith('assets/')
                                          ? AssetImage(member['avatar']!) as ImageProvider
                                          : NetworkImage(member['avatar']!),
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
                if (event.reportData != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventReportScreen(event: event, category: category),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment, size: 20),
                    label: const Text(
                      'View Detailed Report & Committee',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
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

// ----------------------------------------------------
// Official Event Report Screen (Matches GVP PDF structure)
// ----------------------------------------------------
class EventReportScreen extends StatelessWidget {
  final HistoricalEvent event;
  final String category;

  const EventReportScreen({super.key, required this.event, required this.category});

  void _openPdf(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch PDF Link: $url')),
        );
      }
    }
  }

  Widget _buildBulletList(String title, String text, IconData icon, Color color) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final items = text.split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCommitteeRow(String title, String names) {
    if (names.trim().isEmpty) return const SizedBox.shrink();
    final list = names.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: list.map((name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                name,
                style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w500),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = event.reportData!;
    final teams = report.studentTeams;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Official Event Report', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          if (report.reportPdf.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFE11D48)),
              tooltip: 'Open original PDF Report',
              onPressed: () => _openPdf(context, report.reportPdf),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Report Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GAYATRI VIDYA PARISHAD COLLEGE OF ENGINEERING',
                  style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  event.title.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white24,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CONDUCTED ON', style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(event.date, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TENURE YEAR', style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(event.academicYear, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Narrative/Article Section
          if (report.article.isNotEmpty) ...[
            const Text(
              'Event Narrative & Report',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                report.article,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Scope & Objectives & Outcomes
          _buildBulletList('Scope and Objective', report.scopeAndObjectives, Icons.radar, const Color(0xFF0EA5E9)),
          _buildBulletList('Key Outcomes', report.outcomes, Icons.check_circle_outline, const Color(0xFF10B981)),

          // 4. Organizing Committee Card
          if (report.guestsOfHonour.isNotEmpty || report.conveners.isNotEmpty || report.coordinators.isNotEmpty) ...[
            const Text(
              'Organizing Committee',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (report.guestsOfHonour.isNotEmpty) ...[
                    const Text('GUESTS OF HONOUR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(report.guestsOfHonour, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  ],
                  if (report.conveners.isNotEmpty) ...[
                    const Text('PROGRAMME CONVENERS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(report.conveners, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                  ],
                  if (report.coordinators.isNotEmpty) ...[
                    const Text('PROGRAMME COORDINATORS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(report.coordinators, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 5. Student Committee Roles
          const Text(
            'Core Student Committee Roster',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommitteeRow('Student Conveners / Executive Lead', report.studentConveners),
                _buildCommitteeRow('Organizing Team', teams['organizers'] ?? ''),
                _buildCommitteeRow('Canvassing Team', teams['canvassing'] ?? ''),
                _buildCommitteeRow('Poster Making Team', teams['posterMaking'] ?? ''),
                _buildCommitteeRow('Photography Team', teams['photography'] ?? ''),
                _buildCommitteeRow('Social Media Management', teams['socialMedia'] ?? ''),
                _buildCommitteeRow('Technical Management', teams['technicalManagement'] ?? ''),
                _buildCommitteeRow('Volunteers', teams['volunteers'] ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 6. Action: PDF Link Button
          if (report.reportPdf.isNotEmpty)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _openPdf(context, report.reportPdf),
              icon: const Icon(Icons.picture_as_pdf, size: 22),
              label: const Text('Open Official Report PDF Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}
