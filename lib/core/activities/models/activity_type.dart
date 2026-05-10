enum ActivityType {
  badmintonPlay('badminton_play'),
  party('party'),
  other('other');

  const ActivityType(this.wireValue);

  final String wireValue;

  static ActivityType fromWire(String? raw) {
    return ActivityType.values.firstWhere(
      (t) => t.wireValue == raw,
      orElse: () => ActivityType.other,
    );
  }
}
