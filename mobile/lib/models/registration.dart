class Registration {
  final int id;
  final int userId;
  final String userName;
  final String userBranch;
  final String userRollNumber;
  final int userYearOfPassing;
  final int eventId;
  final String eventTitle;
  final int eventClubId;
  final double eventPrice;
  final String eventVenue;
  final String eventDate;
  final String type; // 'participant' or 'volunteer'
  final String status; // 'pending', 'approved', 'attended', 'cancelled'
  final String paymentMethod;
  final double paymentAmount;
  final String transactionId;
  final String upiRefId;
  final String paymentScreenshot;
  final String timestamp;

  Registration({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userBranch,
    required this.userRollNumber,
    required this.userYearOfPassing,
    required this.eventId,
    required this.eventTitle,
    required this.eventClubId,
    required this.eventPrice,
    required this.eventVenue,
    required this.eventDate,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.paymentAmount,
    required this.transactionId,
    required this.upiRefId,
    required this.paymentScreenshot,
    required this.timestamp,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      userBranch: json['userBranch'] ?? 'General',
      userRollNumber: json['userRollNumber'] ?? 'N/A',
      userYearOfPassing: (json['userYearOfPassing'] as num? ?? 2026).toInt(),
      eventId: (json['eventId'] as num).toInt(),
      eventTitle: json['eventTitle'] ?? '',
      eventClubId: (json['eventClubId'] as num).toInt(),
      eventPrice: (json['eventPrice'] as num? ?? 0.0).toDouble(),
      eventVenue: json['eventVenue'] ?? '',
      eventDate: json['eventDate'] ?? '',
      type: json['type'] ?? 'participant',
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentAmount: (json['paymentAmount'] as num? ?? 0.0).toDouble(),
      transactionId: json['transactionId'] ?? '',
      upiRefId: json['upiRefId'] ?? '',
      paymentScreenshot: json['paymentScreenshot'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
