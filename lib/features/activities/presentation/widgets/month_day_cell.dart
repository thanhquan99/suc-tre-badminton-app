import 'package:flutter/material.dart';

import '../../../../core/activities/models/activity.dart';

const double monthCellHeight = 96;

class MonthDayCell extends StatelessWidget {
  const MonthDayCell({
    super.key,
    required this.day,
    required this.events,
    required this.isToday,
    required this.isSelected,
    required this.isOutsideMonth,
    required this.onTapEmpty,
    required this.onTapEvent,
  });

  final DateTime day;
  final List<Activity> events;
  final bool isToday;
  final bool isSelected;
  final bool isOutsideMonth;
  final VoidCallback onTapEmpty;
  final void Function(Activity) onTapEvent;

  static const int _maxVisible = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final visible = events.take(_maxVisible).toList();
    final overflow = events.length - visible.length;

    final cellBg = isSelected
        ? scheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapEmpty,
      child: Container(
        height: monthCellHeight,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        decoration: BoxDecoration(
          color: cellBg,
          border: Border(
            right: BorderSide(
              color: scheme.outlineVariant,
              width: 0.5,
            ),
            bottom: BorderSide(
              color: scheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DayNumber(
              day: day,
              isToday: isToday,
              isOutsideMonth: isOutsideMonth,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final a in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _EventChip(
                        activity: a,
                        onTap: () => onTapEvent(a),
                      ),
                    ),
                  if (overflow > 0)
                    _OverflowChip(count: overflow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayNumber extends StatelessWidget {
  const _DayNumber({
    required this.day,
    required this.isToday,
    required this.isOutsideMonth,
  });
  final DateTime day;
  final bool isToday;
  final bool isOutsideMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final color = isOutsideMonth
        ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
        : scheme.onSurface;

    if (isToday) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SizedBox(
      height: 24,
      child: Center(
        child: Text(
          '${day.day}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.activity, required this.onTap});
  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final past = activity.isPast;

    final Color bg;
    final Color fg;
    final Color stripe;
    if (past) {
      bg = scheme.tertiaryContainer.withValues(alpha: 0.6);
      fg = scheme.onTertiaryContainer;
      stripe = scheme.tertiary.withValues(alpha: 0.6);
    } else if (activity.isJoined) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
      stripe = scheme.primary;
    } else {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
      stripe = scheme.primary;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(width: 3, height: 18, color: stripe),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  height: 18,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        '+$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}
