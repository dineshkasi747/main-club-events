class Club {
  final int id;
  final String name;
  final String description;
  final String presidentName;
  final int membersCount;
  final List<String> members;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.presidentName,
    required this.membersCount,
    required this.members,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      presidentName: json['presidentName'] as String,
      membersCount: (json['membersCount'] as num).toInt(),
      members: List<String>.from(json['members'] ?? []),
    );
  }
}
