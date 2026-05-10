import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/activities/activities_providers.dart';
import '../../../core/activities/models/activity_detail.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/models/user_role.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/activity_type_icon.dart';
import 'widgets/participant_tile.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(activityByIdProvider(activityId));

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          final isNotFound =
              err is DioException && err.response?.statusCode == 404;
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
                  Text(
                    isNotFound
                        ? l10n.activityDetailNotFound
                        : l10n.activityDetailLoadError,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(activityByIdProvider(activityId)),
                    child: Text(l10n.activityRetryButton),
                  ),
                ],
              ),
            ),
          );
        },
        data: (activity) => _ActivityBody(activity: activity),
      ),
    );
  }
}

class _ActivityBody extends ConsumerStatefulWidget {
  const _ActivityBody({required this.activity});
  final ActivityDetail activity;

  @override
  ConsumerState<_ActivityBody> createState() => _ActivityBodyState();
}

class _ActivityBodyState extends ConsumerState<_ActivityBody> {
  bool _busy = false;

  Future<void> _toggleJoin() async {
    final l10n = AppLocalizations.of(context);
    final activity = widget.activity;
    setState(() => _busy = true);
    try {
      final notifier =
          ref.read(joinActivityNotifierProvider(activity.id).notifier);
      if (activity.isJoined) {
        await notifier.leave();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.activityLeaveSuccess)),
        );
      } else {
        await notifier.join();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.activityJoinSuccess)),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_mapError(e, l10n))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.activityErrorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.activityDeleteConfirmTitle),
        content: Text(l10n.activityDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.activityDeleteCancelButton),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.activityDeleteConfirmButton),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(deleteActivityNotifierProvider(widget.activity.id).notifier)
          .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.activityDeleteSuccess)),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.activityErrorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapError(DioException e, AppLocalizations l10n) {
    final body = e.response?.data;
    if (e.response?.statusCode == 400 && body is Map) {
      final msg = body['message'];
      final text = msg is String ? msg : (msg is List ? msg.join(' ') : '');
      if (text.toLowerCase().contains('past')) {
        return l10n.activityErrorPastJoin;
      }
    }
    return l10n.activityErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authNotifierProvider);
    final canWrite = auth is AuthAuthenticated &&
        (auth.user.role == UserRole.admin ||
            auth.user.role == UserRole.manager);
    final theme = Theme.of(context);
    final activity = widget.activity;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFmt = DateFormat.yMMMMEEEEd(locale);
    final timeFmt = DateFormat.Hm(locale);
    final timeRange =
        '${timeFmt.format(activity.startAt)} – ${timeFmt.format(activity.endAt)}';
    final past = activity.isPast;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      activityTypeIcon(activity.type),
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activity.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activityTypeLabel(activity.type, l10n),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${dateFmt.format(activity.startAt)}  $timeRange',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                if (activity.createdBy != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.activityDetailCreatedBy(
                          activity.createdBy!.displayName,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (activity.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(activity.description),
          ),
        ],
        if (past) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.activityDetailPastBanner,
              style: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _toggleJoin,
            icon: Icon(
              activity.isJoined ? Icons.event_busy : Icons.event_available,
            ),
            label: Text(
              activity.isJoined
                  ? l10n.activityDetailLeaveButton
                  : l10n.activityDetailJoinButton,
            ),
          ),
        ],
        if (canWrite) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => context
                          .push('/activities/${activity.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.activityDetailEditButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.activityDetailDeleteButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text(
          l10n.activityDetailParticipantsHeading(activity.participantCount),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (activity.participants.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text(l10n.activityDetailNoParticipants)),
          )
        else
          ...activity.participants.map(
            (p) => ParticipantTile(participant: p, locale: locale),
          ),
      ],
    );
  }
}
