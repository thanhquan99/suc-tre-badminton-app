class ActivityCreator {
  final String id;
  final String displayName;

  const ActivityCreator({
    required this.id,
    required this.displayName,
  });

  factory ActivityCreator.fromJson(Map<String, dynamic> json) {
    return ActivityCreator(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
    );
  }
}
