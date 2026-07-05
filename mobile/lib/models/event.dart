class Event {
  final int id;
  final int clubId;
  final String title;
  final String description;
  final String venue;
  final String dateString;
  final double price;
  final int capacity;
  final bool freeRegistration;
  final bool paidRegistration;
  final bool volunteerRegistration;
  final int volunteerLimit;
  final String status;
  final String imagePath;

  Event({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.venue,
    required this.dateString,
    required this.price,
    required this.capacity,
    required this.freeRegistration,
    required this.paidRegistration,
    required this.volunteerRegistration,
    required this.volunteerLimit,
    required this.status,
    required this.imagePath,
  });

  String get category {
    if (clubId == 101 || clubId == 104 || clubId == 105 || clubId == 106) return 'Technical';
    if (clubId == 102) return 'Cultural';
    return 'Sports';
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    final priceVal = (json['price'] as num).toDouble();
    return Event(
      id: (json['id'] as num).toInt(),
      clubId: (json['clubId'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] ?? '',
      venue: json['venue'] ?? '',
      dateString: json['dateString'] ?? '',
      price: priceVal,
      capacity: (json['capacity'] as num).toInt(),
      freeRegistration: json['freeRegistration'] as bool? ?? (priceVal == 0.0),
      paidRegistration: json['paidRegistration'] as bool? ?? (priceVal > 0.0),
      volunteerRegistration: json['volunteerRegistration'] as bool? ?? false,
      volunteerLimit: json['volunteerLimit'] as int? ?? 0,
      status: json['status'] ?? 'active',
      imagePath: json['imagePath'] ?? '',
    );
  }
}

class EventReportData {
  final String guestsOfHonour;
  final String conveners;
  final String coordinators;
  final String scopeAndObjectives;
  final String outcomes;
  final String article;
  final String reportPdf;
  final String studentConveners;
  final Map<String, String> studentTeams;

  EventReportData({
    required this.guestsOfHonour,
    required this.conveners,
    required this.coordinators,
    required this.scopeAndObjectives,
    required this.outcomes,
    required this.article,
    required this.reportPdf,
    required this.studentConveners,
    required this.studentTeams,
  });

  factory EventReportData.fromJson(Map<String, dynamic> json) {
    final teams = Map<String, dynamic>.from(json['studentTeams'] ?? {});
    return EventReportData(
      guestsOfHonour: json['guestsOfHonour'] as String? ?? '',
      conveners: json['conveners'] as String? ?? '',
      coordinators: json['coordinators'] as String? ?? '',
      scopeAndObjectives: json['scopeAndObjectives'] as String? ?? '',
      outcomes: json['outcomes'] as String? ?? '',
      article: json['article'] as String? ?? '',
      reportPdf: json['reportPdf'] as String? ?? '',
      studentConveners: json['studentConveners'] as String? ?? '',
      studentTeams: teams.map((key, value) => MapEntry(key, value as String? ?? '')),
    );
  }
}

class HistoricalEvent {
  final int id;
  final int clubId;
  final String academicYear;
  final String title;
  final String date;
  final String venue;
  final String description;
  final int volunteersCount;
  final List<String> images;
  final EventReportData? reportData;

  HistoricalEvent({
    required this.id,
    required this.clubId,
    required this.academicYear,
    required this.title,
    required this.date,
    required this.venue,
    required this.description,
    required this.volunteersCount,
    required this.images,
    this.reportData,
  });

  factory HistoricalEvent.fromJson(Map<String, dynamic> json) {
    return HistoricalEvent(
      id: (json['id'] as num).toInt(),
      clubId: (json['clubId'] as num).toInt(),
      academicYear: json['academicYear'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      venue: json['venue'] as String,
      description: json['description'] as String,
      volunteersCount: (json['volunteersCount'] as num).toInt(),
      images: List<String>.from(json['images'] ?? []),
      reportData: json['reportData'] != null
          ? EventReportData.fromJson(Map<String, dynamic>.from(json['reportData']))
          : null,
    );
  }
}
