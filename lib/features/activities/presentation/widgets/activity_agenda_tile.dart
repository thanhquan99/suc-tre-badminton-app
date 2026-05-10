import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/activities/models/activity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'activity_type_icon.dart';

class ActivityAgendaTile extends StatelessWidget {
  const ActivityAgendaTile({
    super.key,
    required this.activity,
    required this.onTap,
    required this.locale,
  });

  final Activity activity;
  final VoidCallback onTap;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final timeFormat = DateFormat.Hm(locale);
    final timeRange =
        '${timeFormat.format(activity.startAt)} – ${timeFormat.format(activity.endAt)}';
    final past = activity.isPast;

    return Opacity(
      opacity: past ? 0.6 : 1,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            activityTypeIcon(activity.type),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          activity.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(timeRange),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 16),
                const SizedBox(width: 4),
                Text('${activity.participantCount}'),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: activity.isJoined
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                activity.isJoined
                    ? l10n.activityDetailJoinedBadge
                    : l10n.activityDetailNotJoinedBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: activity.isJoined
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
