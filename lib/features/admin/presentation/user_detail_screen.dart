import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/models/auth_user.dart';
import '../../../core/users/users_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/widgets/role_badge.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(userByIdProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userDetailScreenTitle)),
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
                        ? l10n.userDetailNotFound
                        : l10n.userDetailLoadError,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(userByIdProvider(userId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (user) => _UserDetailForm(user: user),
      ),
    );
  }
}

class _UserDetailForm extends ConsumerStatefulWidget {
  const _UserDetailForm({required this.user});
  final AuthUser user;

  @override
  ConsumerState<_UserDetailForm> createState() => _UserDetailFormState();
}

class _UserDetailFormState extends ConsumerState<_UserDetailForm> {
  late final TextEditingController _displayNameController;
  late String _initialDisplayName;
  late bool _isActive;
  late bool _initialIsActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initialDisplayName = widget.user.displayName;
    _displayNameController = TextEditingController(text: _initialDisplayName);
    _displayNameController.addListener(() => setState(() {}));
    _isActive = widget.user.isActive;
    _initialIsActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  bool get _dirty {
    final name = _displayNameController.text.trim();
    return name != _initialDisplayName || _isActive != _initialIsActive;
  }

  String? _validateDisplayName(String? v) {
    final trimmed = v?.trim() ?? '';
    if (trimmed.isEmpty) return AppLocalizations.of(context).createUserDisplayNameValidation;
    if (trimmed.length > 100) return null;
    return null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _displayNameController.text.trim();
    if (_validateDisplayName(name) != null) return;

    setState(() => _saving = true);
    try {
      String? nextDisplayName;
      bool? nextIsActive;
      if (name != _initialDisplayName) nextDisplayName = name;
      if (_isActive != _initialIsActive) nextIsActive = _isActive;

      await ref.read(updateUserNotifierProvider(widget.user.id).notifier).save(
            displayName: nextDisplayName,
            isActive: nextIsActive,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userUpdatedSuccess)),
      );
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = _mapError(e, l10n);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userUpdateErrorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _mapError(DioException e, AppLocalizations l10n) {
    final status = e.response?.statusCode;
    if (status == 400) {
      final body = e.response?.data;
      if (body is Map &&
          body['message'] is String &&
          (body['message'] as String).contains('deactivate your own')) {
        return l10n.userUpdateErrorSelfDeactivate;
      }
    }
    if (status == 404) return l10n.userDetailNotFound;
    return l10n.userUpdateErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = widget.user;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName.characters.first.toUpperCase()
                  : '?',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '@${user.username}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: RoleBadge(role: user.role)),
        const SizedBox(height: 24),
        Text(
          l10n.userDetailDisplayNameLabel,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _displayNameController,
          enabled: !_saving,
          maxLength: 100,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: _validateDisplayName,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(l10n.userDetailIsActiveLabel),
          value: _isActive,
          onChanged: _saving ? null : (v) => setState(() => _isActive = v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _dirty && !_saving ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.userDetailSaveButton),
        ),
      ],
    );
  }
}
