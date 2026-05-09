import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/activities/models/activity.dart';

const double _hourGutterWidth = 56;
const double _hourSlotHeight = 56;
const double _headerHeight = 56;
const double _eventMinHeight = 24;

class WeekGridView extends StatefulWidget {
  const WeekGridView({
    super.key,
    required this.weekStart,
    required this.activities,
    required this.locale,
    required this.onTapActivity,
    required this.onTapEmptySlot,
  });

  /// Monday (or whatever the locale considers the first day) at 00:00 local.
  final DateTime weekStart;
  final List<Activity> activities;
  final String locale;
  final void Function(Activity activity) onTapActivity;

  /// Fired when the user taps an empty slot. The DateTime is snapped to
  /// the nearest 30-minute boundary (local time).
  final void Function(DateTime slotStart) onTapEmptySlot;

  @override
  State<WeekGridView> createState() => _WeekGridViewState();
}

class _WeekGridViewState extends State<WeekGridView> {
  late final ScrollController _vertical;

  @override
  void initState() {
    super.initState();
    _vertical = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_vertical.hasClients) return;
      // Scroll to ~7am so the user lands on something useful.
      const offset = _hourSlotHeight * 7;
      _vertical.jumpTo(offset.clamp(0, _vertical.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _vertical.dispose();
    super.dispose();
  }

  DateTime _normalizeDay(DateTime d) => DateTime(d.year, d.month, d.day);

  List<List<Activity>> _bucketByDayIndex() {
    final byDay = List<List<Activity>>.generate(7, (_) => []);
    final weekStartDay = _normalizeDay(widget.weekStart);
    for (final a in widget.activities) {
      final diff = _normalizeDay(a.startAt).difference(weekStartDay).inDays;
      if (diff >= 0 && diff < 7) {
        byDay[diff].add(a);
      }
    }
    return byDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byDay = _bucketByDayIndex();
    final now = DateTime.now();
    final todayIdx = _normalizeDay(now)
        .difference(_normalizeDay(widget.weekStart))
        .inDays;
    final showNowLine = todayIdx >= 0 && todayIdx < 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth =
            ((constraints.maxWidth - _hourGutterWidth) / 7).floorToDouble();
        final totalWidth = _hourGutterWidth + dayWidth * 7;

        return Column(
          children: [
            _WeekHeader(
              weekStart: widget.weekStart,
              dayWidth: dayWidth,
              gutterWidth: _hourGutterWidth,
              locale: widget.locale,
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: _vertical,
                child: SizedBox(
                  width: totalWidth,
                  height: _hourSlotHeight * 24,
                  child: Stack(
                    children: [
                      // Hour grid background + gutter labels.
                      _GridBackground(
                        gutterWidth: _hourGutterWidth,
                        dayWidth: dayWidth,
                        locale: widget.locale,
                      ),
                      // Day columns with events + empty-tap handler.
                      for (int i = 0; i < 7; i++)
                        Positioned(
                          left: _hourGutterWidth + i * dayWidth,
                          top: 0,
                          bottom: 0,
                          width: dayWidth,
                          child: _DayColumn(
                            day: widget.weekStart.add(Duration(days: i)),
                            activities: byDay[i],
                            onTapActivity: widget.onTapActivity,
                            onTapEmptySlot: widget.onTapEmptySlot,
                          ),
                        ),
                      // Current-time indicator.
                      if (showNowLine)
                        _NowIndicator(
                          now: now,
                          gutterWidth: _hourGutterWidth,
                          dayWidth: dayWidth,
                          dayIndex: todayIdx,
                          color: theme.colorScheme.error,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekStart,
    required this.dayWidth,
    required this.gutterWidth,
    required this.locale,
  });

  final DateTime weekStart;
  final double dayWidth;
  final double gutterWidth;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final weekdayFmt = DateFormat.E(locale);

    return SizedBox(
      height: _headerHeight,
      child: Row(
        children: [
          SizedBox(width: gutterWidth),
          for (int i = 0; i < 7; i++)
            SizedBox(
              width: dayWidth,
              child: _HeaderCell(
                day: weekStart.add(Duration(days: i)),
                isToday: _isSameDay(
                  weekStart.add(Duration(days: i)),
                  today,
                ),
                weekdayLabel: weekdayFmt
                    .format(weekStart.add(Duration(days: i)))
                    .toUpperCase(),
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.day,
    required this.isToday,
    required this.weekdayLabel,
    required this.theme,
  });
  final DateTime day;
  final bool isToday;
  final String weekdayLabel;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          weekdayLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isToday ? theme.colorScheme.primary : null,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isToday
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground({
    required this.gutterWidth,
    required this.dayWidth,
    required this.locale,
  });
  final double gutterWidth;
  final double dayWidth;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hourLineColor = theme.colorScheme.outlineVariant;
    final halfHourLineColor =
        theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
    final hourLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Stack(
      children: [
        // Hour labels in gutter.
        for (int h = 0; h < 24; h++)
          Positioned(
            left: 0,
            top: h * _hourSlotHeight - 6,
            width: gutterWidth - 8,
            child: SizedBox(
              height: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  // Hide the very first "00:00" label, conventional in calendars
                  h == 0
                      ? ''
                      : '${h.toString().padLeft(2, '0')}:00',
                  style: hourLabelStyle,
                ),
              ),
            ),
          ),
        // Hour gridlines (across 7-day span).
        for (int h = 0; h <= 24; h++)
          Positioned(
            left: gutterWidth,
            top: h * _hourSlotHeight,
            width: dayWidth * 7,
            child: Container(height: 0.5, color: hourLineColor),
          ),
        // Half-hour gridlines.
        for (int h = 0; h < 24; h++)
          Positioned(
            left: gutterWidth,
            top: h * _hourSlotHeight + _hourSlotHeight / 2,
            width: dayWidth * 7,
            child: Container(height: 0.5, color: halfHourLineColor),
          ),
        // Day separators (vertical).
        for (int i = 0; i < 7; i++)
          Positioned(
            left: gutterWidth + i * dayWidth,
            top: 0,
            bottom: 0,
            width: 0.5,
            child: ColoredBox(color: hourLineColor),
          ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.activities,
    required this.onTapActivity,
    required this.onTapEmptySlot,
  });
  final DateTime day;
  final List<Activity> activities;
  final void Function(Activity) onTapActivity;
  final void Function(DateTime) onTapEmptySlot;

  double _yForTime(DateTime t) {
    return (t.hour + t.minute / 60) * _hourSlotHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayStart = DateTime(day.year, day.month, day.day);
    return Stack(
      children: [
        // Empty-area gesture detector underneath events.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final dy = details.localPosition.dy;
              final minutes = ((dy / _hourSlotHeight) * 60).round();
              final snapped = (minutes / 30).round() * 30;
              final clamped = snapped.clamp(0, 23 * 60 + 30);
              onTapEmptySlot(
                dayStart.add(Duration(minutes: clamped)),
              );
            },
            child: const SizedBox.expand(),
          ),
        ),
        // Event blocks.
        for (final a in activities)
          () {
            final top = _yForTime(a.startAt);
            final rawHeight = _yForTime(a.endAt) - top;
            final height = rawHeight < _eventMinHeight
                ? _eventMinHeight
                : rawHeight;
            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height,
              child: _EventBlock(
                activity: a,
                onTap: () => onTapActivity(a),
                theme: theme,
              ),
            );
          }(),
      ],
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.activity,
    required this.onTap,
    required this.theme,
  });
  final Activity activity;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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

    final timeFmt = DateFormat.Hm();
    final timeRange =
        '${timeFmt.format(activity.startAt)} – ${timeFmt.format(activity.endAt)}';
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: stripe),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  final children = <Widget>[
                    Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ];
                  if (constraints.maxHeight >= 36) {
                    children.add(const SizedBox(height: 2));
                    children.add(
                      Text(
                        timeRange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: fg.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowIndicator extends StatelessWidget {
  const _NowIndicator({
    required this.now,
    required this.gutterWidth,
    required this.dayWidth,
    required this.dayIndex,
    required this.color,
  });
  final DateTime now;
  final double gutterWidth;
  final double dayWidth;
  final int dayIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final y = (now.hour + now.minute / 60) * _hourSlotHeight;
    return Positioned(
      top: y - 1,
      left: gutterWidth - 6,
      width: 6 + dayWidth,
      height: 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 5,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 6,
            top: 5,
            right: 0,
            child: Container(height: 2, color: color),
          ),
        ],
      ),
    );
  }
}
