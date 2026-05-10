import 'package:flutter/material.dart';

import '../../../../core/activities/models/activity_type.dart';
import '../../../../l10n/generated/app_localizations.dart';

IconData activityTypeIcon(ActivityType type) {
  switch (type) {
    case ActivityType.badmintonPlay:
      return Icons.sports_tennis;
    case ActivityType.party:
      return Icons.celebration;
    case ActivityType.other:
      return Icons.event;
  }
}

String activityTypeLabel(ActivityType type, AppLocalizations l10n) {
  switch (type) {
    case ActivityType.badmintonPlay:
      return l10n.activityTypeBadmintonPlay;
    case ActivityType.party:
      return l10n.activityTypeParty;
    case ActivityType.other:
      return l10n.activityTypeOther;
  }
}
