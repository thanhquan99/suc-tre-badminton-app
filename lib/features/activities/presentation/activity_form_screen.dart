import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/activities/activities_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/datetime_picker_field.dart';

class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.activityId});

  final String? activityId;

  bool get isEdit => activityId != null;

  @override
  ConsumerState<ActivityFormScreen> createState() =>
      _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _startAt;
  DateTime? _endAt;
  bool _saving = false;
  bool _hydrated = false;

  String? _initialTitle;
  String? _initialDesc;
  DateTime? _initialStartAt;
  DateTime? _initialEndAt;

  @override
  void initState() {
    super.initState();
    if (!widget.isEdit) {
      final now = DateTime.now();
      _startAt = DateTime(now.year, now.month, now.day, now.hour + 1);
      _endAt = _startAt!.add(const Duration(hours: 1));
      _hydrated = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _dirty {
    if (!widget.isEdit) {
      return _titleController.text.trim().isNotEmpty;
    }
    return _titleController.text != (_initialTitle ?? '') ||
        _descController.text != (_initialDesc ?? '') ||
        _startAt != _initialStartAt ||
        _endAt != _initialEndAt;
  }

  String? _validateTitle(String? v, AppLocalizations l10n) {
    final trimmed = v?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.activityValidationTitleRequired;
    if (trimmed.length > 100) return null;
    return null;
  }

  bool _datesValid() {
    if (_startAt == null || _endAt == null) return false;
    return _endAt!.isAfter(_startAt!);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (_validateTitle(title, l10n) != null) return;
    if (!_datesValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.activityValidationEndAfterStart)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.isEdit) {
        final notifier = ref.read(
          updateActivityNotifierProvider(widget.activityId!).notifier,
        );
        await notifier.save(
          title: title != _initialTitle ? title : null,
          description: _descController.text != _initialDesc
              ? _descController.text
              : null,
          startAt: _startAt != _initialStartAt ? _startAt : null,
          endAt: _endAt != _initialEndAt ? _endAt : null,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.activityUpdateSuccess)),
        );
      } else {
        final notifier = ref.read(createActivityNotifierProvider.notifier);
        await notifier.create(
          title: title,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          startAt: _startAt!,
          endAt: _endAt!,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.activityCreateSuccess)),
        );
      }
      if (!mounted) return;
      context.pop();
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
      if (mounted) setState(() => _saving = false);
    }
  }

  String _mapError(DioException e, AppLocalizations l10n) {
    return l10n.activityErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    if (widget.isEdit) {
      final async = ref.watch(activityByIdProvider(widget.activityId!));
      return Scaffold(
        appBar: AppBar(title: Text(l10n.activityEditTitle)),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.activityDetailLoadError)),
          data: (activity) {
            if (!_hydrated) {
              _titleController.text = activity.title;
              _descController.text = activity.description;
              _startAt = activity.startAt;
              _endAt = activity.endAt;
              _initialTitle = activity.title;
              _initialDesc = activity.description;
              _initialStartAt = activity.startAt;
              _initialEndAt = activity.endAt;
              _hydrated = true;
            }
            return _buildForm(context, l10n, locale, isEdit: true);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityCreateTitle)),
      body: _buildForm(context, l10n, locale, isEdit: false),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    String locale, {
    required bool isEdit,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _titleController,
          enabled: !_saving,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: l10n.activityFieldTitle,
            border: const OutlineInputBorder(),
          ),
          validator: (v) => _validateTitle(v, l10n),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descController,
          enabled: !_saving,
          maxLength: 500,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.activityFieldDescription,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DateTimePickerField(
          label: l10n.activityFieldStartAt,
          value: _startAt,
          enabled: !_saving,
          locale: locale,
          onChanged: (v) => setState(() => _startAt = v),
        ),
        const SizedBox(height: 12),
        DateTimePickerField(
          label: l10n.activityFieldEndAt,
          value: _endAt,
          enabled: !_saving,
          locale: locale,
          onChanged: (v) => setState(() => _endAt = v),
        ),
        if (_startAt != null && _endAt != null && !_datesValid())
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.activityValidationEndAfterStart,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving || !_dirty ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isEdit
                      ? l10n.activitySaveButton
                      : l10n.activityCreateButton,
                ),
        ),
      ],
    );
  }
}
