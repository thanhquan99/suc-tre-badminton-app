import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/activities/activities_providers.dart';
import '../../../core/activities/models/activities_query.dart';
import '../../../core/activities/models/activity.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/models/user_role.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/activity_agenda_tile.dart';

DateTime _normalizeDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _focusedDay = today;
    _selectedDay = today;
  }

  ActivitiesQuery _windowQueryFor(DateTime focused) {
    // Pad by 7 days on either side so week-boundary cells (which can show
    // days from neighbouring months in month view) still get their data.
    final monthStart = DateTime(focused.year, focused.month, 1);
    final monthEnd = DateTime(focused.year, focused.month + 1, 0, 23, 59, 59);
    final from = monthStart.subtract(const Duration(days: 7));
    final to = monthEnd.add(const Duration(days: 7));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authNotifierProvider);
    final canWrite = auth is AuthAuthenticated &&
        (auth.user.role == UserRole.admin ||
            auth.user.role == UserRole.manager);

    final query = _windowQueryFor(_focusedDay);
    final async = ref.watch(activitiesListProvider(query));
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activitiesScreenTitle),
        actions: [
          PopupMenuButton<CalendarFormat>(
            icon: Icon(
              _format == CalendarFormat.month
                  ? Icons.calendar_view_month
                  : Icons.view_week,
            ),
            tooltip: _format == CalendarFormat.month
                ? l10n.activityFormatMonth
                : l10n.activityFormatWeek,
            initialValue: _format,
            onSelected: (f) => setState(() => _format = f),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: CalendarFormat.month,
                child: Text(l10n.activityFormatMonth),
              ),
              PopupMenuItem(
                value: CalendarFormat.week,
                child: Text(l10n.activityFormatWeek),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/activities/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.activityCreateButton),
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
          final dayKey = _normalizeDay(_selectedDay);
          final dayActivities = byDay[dayKey] ?? const <Activity>[];

          return Column(
            children: [
              TableCalendar<Activity>(
                locale: locale,
                firstDay:
                    DateTime.now().subtract(const Duration(days: 365 * 2)),
                lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(day, _selectedDay),
                calendarFormat: _format,
                availableCalendarFormats: {
                  CalendarFormat.month: l10n.activityFormatMonth,
                  CalendarFormat.week: l10n.activityFormatWeek,
                },
                eventLoader: (day) => byDay[_normalizeDay(day)] ?? const [],
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (focused) {
                  setState(() => _focusedDay = focused);
                },
                onFormatChanged: (f) => setState(() => _format = f),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: dayActivities.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 8),
                              Text(l10n.activitiesEmptyDay),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: dayActivities.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (_, i) {
                          final a = dayActivities[i];
                          return ActivityAgendaTile(
                            key: ValueKey(a.id),
                            activity: a,
                            locale: locale,
                            onTap: () =>
                                context.push('/activities/${a.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
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
