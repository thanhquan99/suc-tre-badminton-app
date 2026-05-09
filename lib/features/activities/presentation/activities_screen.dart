import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/activities/activities_providers.dart';
import '../../../core/activities/models/activities_query.dart';
import '../../../core/activities/models/activity.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/models/user_role.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/month_day_cell.dart';
import 'widgets/week_grid_view.dart';

enum _ViewMode { month, week }

DateTime _normalizeDay(DateTime d) => DateTime(d.year, d.month, d.day);

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  _ViewMode _mode = _ViewMode.month;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _focusedDay = today;
    _selectedDay = today;
  }

  ActivitiesQuery _windowQuery() {
    final from = _normalizeDay(_focusedDay)
        .subtract(const Duration(days: 14));
    final to = _normalizeDay(_focusedDay)
        .add(const Duration(days: 60));
    return ActivitiesQuery(from: from, to: to);
  }

  Map<DateTime, List<Activity>> _bucketByDay(List<Activity> activities) {
    final map = <DateTime, List<Activity>>{};
    for (final a in activities) {
      final key = _normalizeDay(a.startAt);
      map.putIfAbsent(key, () => []).add(a);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.startAt.compareTo(b.startAt));
    }
    return map;
  }

  DateTime _weekStartFor(DateTime day, int firstDayOfWeek) {
    // firstDayOfWeek: 0 = Sunday, 1 = Monday (Material Localizations).
    final weekday = day.weekday; // Monday = 1, Sunday = 7
    final shift =
        firstDayOfWeek == 0 ? weekday % 7 : (weekday - 1) % 7;
    return _normalizeDay(day).subtract(Duration(days: shift));
  }

  void _goCreateForSlot(DateTime slot) {
    final iso = slot.toIso8601String();
    context.push('/activities/new?slot=$iso');
  }

  void _goCreateForDay(DateTime day) {
    final iso = _normalizeDay(day).toIso8601String();
    context.push('/activities/new?date=$iso');
  }

  String _appBarTitle(DateTime day, String locale) {
    if (_mode == _ViewMode.week) {
      // Show range, e.g. "May 4 – 10"
      final firstDow =
          MaterialLocalizations.of(context).firstDayOfWeekIndex;
      final start = _weekStartFor(day, firstDow);
      final end = start.add(const Duration(days: 6));
      final monthFmt = DateFormat.MMM(locale);
      if (start.month == end.month) {
        return '${monthFmt.format(start)} ${start.day} – ${end.day}';
      }
      return '${monthFmt.format(start)} ${start.day} – '
          '${monthFmt.format(end)} ${end.day}';
    }
    return DateFormat.yMMMM(locale).format(day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authNotifierProvider);
    final canWrite = auth is AuthAuthenticated &&
        (auth.user.role == UserRole.admin ||
            auth.user.role == UserRole.manager);

    final query = _windowQuery();
    final async = ref.watch(activitiesListProvider(query));
    final locale = Localizations.localeOf(context).toLanguageTag();
    final firstDow = MaterialLocalizations.of(context).firstDayOfWeekIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(_focusedDay, locale)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: l10n.activitiesScreenTitle,
            onPressed: () {
              setState(() {
                final today = DateTime.now();
                _focusedDay = today;
                _selectedDay = today;
              });
            },
          ),
          PopupMenuButton<_ViewMode>(
            icon: Icon(
              _mode == _ViewMode.month
                  ? Icons.calendar_view_month
                  : Icons.view_week,
            ),
            tooltip: _mode == _ViewMode.month
                ? l10n.activityFormatMonth
                : l10n.activityFormatWeek,
            initialValue: _mode,
            onSelected: (m) => setState(() => _mode = m),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _ViewMode.month,
                child: Text(l10n.activityFormatMonth),
              ),
              PopupMenuItem(
                value: _ViewMode.week,
                child: Text(l10n.activityFormatWeek),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: canWrite
          ? FloatingActionButton(
              onPressed: () => context.push('/activities/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: l10n.activitiesLoadError,
          onRetry: () => ref.invalidate(activitiesListProvider(query)),
        ),
        data: (page) {
          final byDay = _bucketByDay(page.data);
          if (_mode == _ViewMode.month) {
            return _MonthView(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              byDay: byDay,
              firstDayOfWeek: firstDow,
              locale: locale,
              onDaySelected: (sel, foc) {
                setState(() {
                  _selectedDay = sel;
                  _focusedDay = foc;
                });
              },
              onPageChanged: (foc) =>
                  setState(() => _focusedDay = foc),
              onTapEmpty: _goCreateForDay,
              onTapEvent: (a) => context.push('/activities/${a.id}'),
            );
          }
          final weekStart = _weekStartFor(_focusedDay, firstDow);
          final weekActivities = <Activity>[];
          for (int i = 0; i < 7; i++) {
            final key = _normalizeDay(weekStart.add(Duration(days: i)));
            final list = byDay[key];
            if (list != null) weekActivities.addAll(list);
          }
          return Column(
            children: [
              _WeekNavBar(
                weekStart: weekStart,
                onPrev: () => setState(() {
                  _focusedDay =
                      _focusedDay.subtract(const Duration(days: 7));
                }),
                onNext: () => setState(() {
                  _focusedDay =
                      _focusedDay.add(const Duration(days: 7));
                }),
              ),
              Expanded(
                child: WeekGridView(
                  weekStart: weekStart,
                  activities: weekActivities,
                  locale: locale,
                  onTapActivity: (a) =>
                      context.push('/activities/${a.id}'),
                  onTapEmptySlot: _goCreateForSlot,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.focusedDay,
    required this.selectedDay,
    required this.byDay,
    required this.firstDayOfWeek,
    required this.locale,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onTapEmpty,
    required this.onTapEvent,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<Activity>> byDay;
  final int firstDayOfWeek;
  final String locale;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final void Function(DateTime day) onTapEmpty;
  final void Function(Activity) onTapEvent;

  StartingDayOfWeek _startingDayOfWeek() {
    return firstDayOfWeek == 0
        ? StartingDayOfWeek.sunday
        : StartingDayOfWeek.monday;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return TableCalendar<Activity>(
      locale: locale,
      firstDay: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      calendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      startingDayOfWeek: _startingDayOfWeek(),
      rowHeight: monthCellHeight,
      daysOfWeekHeight: 28,
      headerVisible: false,
      eventLoader: (day) => byDay[_normalizeDay(day)] ?? const [],
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: theme.textTheme.labelSmall!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.6,
        ),
        weekendStyle: theme.textTheme.labelSmall!.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.6,
        ),
      ),
      calendarBuilders: CalendarBuilders<Activity>(
        defaultBuilder: (context, day, focused) => MonthDayCell(
          day: day,
          events: byDay[_normalizeDay(day)] ?? const [],
          isToday: isSameDay(day, today),
          isSelected: isSameDay(day, selectedDay),
          isOutsideMonth: false,
          onTapEmpty: () => onTapEmpty(day),
          onTapEvent: onTapEvent,
        ),
        todayBuilder: (context, day, focused) => MonthDayCell(
          day: day,
          events: byDay[_normalizeDay(day)] ?? const [],
          isToday: true,
          isSelected: isSameDay(day, selectedDay),
          isOutsideMonth: false,
          onTapEmpty: () => onTapEmpty(day),
          onTapEvent: onTapEvent,
        ),
        selectedBuilder: (context, day, focused) => MonthDayCell(
          day: day,
          events: byDay[_normalizeDay(day)] ?? const [],
          isToday: isSameDay(day, today),
          isSelected: true,
          isOutsideMonth: false,
          onTapEmpty: () => onTapEmpty(day),
          onTapEvent: onTapEvent,
        ),
        outsideBuilder: (context, day, focused) => MonthDayCell(
          day: day,
          events: byDay[_normalizeDay(day)] ?? const [],
          isToday: isSameDay(day, today),
          isSelected: false,
          isOutsideMonth: true,
          onTapEmpty: () => onTapEmpty(day),
          onTapEvent: onTapEvent,
        ),
      ),
    );
  }
}

class _WeekNavBar extends StatelessWidget {
  const _WeekNavBar({
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
  });
  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(l10n.activityRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}
