class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final String createdById;
  final int participantCount;
  final bool isJoined;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.createdById,
    required this.participantCount,
    required this.isJoined,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      startAt: DateTime.parse(json['startAt'] as String).toLocal(),
      endAt: DateTime.parse(json['endAt'] as String).toLocal(),
      createdById: json['createdById'] as String,
      participantCount: json['participantCount'] as int,
      isJoined: json['isJoined'] as bool,
    );
  }

  bool get isPast => DateTime.now().isAfter(startAt);
}
