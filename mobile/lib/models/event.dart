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
    if (clubId == 101 || clubId == 104) return 'Technical';
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
    );
  }
}
