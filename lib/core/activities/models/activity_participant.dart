class ActivityParticipant {
  final String id;
  final String displayName;
  final DateTime joinedAt;

  const ActivityParticipant({
    required this.id,
    required this.displayName,
    required this.joinedAt,
  });

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) {
    return ActivityParticipant(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String).toLocal(),
    );
  }
}
