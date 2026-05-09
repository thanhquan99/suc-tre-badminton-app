import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/activities/models/activity_participant.dart';

class ParticipantTile extends StatelessWidget {
  const ParticipantTile({
    super.key,
    required this.participant,
    required this.locale,
  });

  final ActivityParticipant participant;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat.MMMd(locale).add_Hm();
    final initial = participant.displayName.isNotEmpty
        ? participant.displayName.characters.first.toUpperCase()
        : '?';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Text(
          initial,
          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
        ),
      ),
      title: Text(participant.displayName),
      subtitle: Text(dateFmt.format(participant.joinedAt)),
    );
  }
}
