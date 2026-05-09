import 'activity.dart';
import 'activity_creator.dart';
import 'activity_participant.dart';

class ActivityDetail extends Activity {
  final ActivityCreator? createdBy;
  final List<ActivityParticipant> participants;

  const ActivityDetail({
    required super.id,
    required super.title,
    required super.description,
    required super.startAt,
    required super.endAt,
    required super.createdById,
    required super.participantCount,
    required super.isJoined,
    required this.createdBy,
    required this.participants,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> json) {
    final createdByJson = json['createdBy'];
    final participantsJson = (json['participants'] as List?) ?? const [];
    return ActivityDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      startAt: DateTime.parse(json['startAt'] as String).toLocal(),
      endAt: DateTime.parse(json['endAt'] as String).toLocal(),
      createdById: json['createdById'] as String,
      participantCount: json['participantCount'] as int,
      isJoined: json['isJoined'] as bool,
      createdBy: createdByJson is Map<String, dynamic>
          ? ActivityCreator.fromJson(createdByJson)
          : null,
      participants: participantsJson
          .map(
            (p) => ActivityParticipant.fromJson(p as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
