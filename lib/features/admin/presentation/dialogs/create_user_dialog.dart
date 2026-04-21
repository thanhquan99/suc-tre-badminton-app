import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/models/user_role.dart';
import '../../../../core/users/models/create_user_response.dart';
import '../../../../core/users/users_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CreateUserDialog extends ConsumerStatefulWidget {
  const CreateUserDialog({super.key});

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  UserRole _role = UserRole.member;
  bool _submitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final result =
          await ref.read(createUserNotifierProvider.notifier).create(
                displayName: _displayNameController.text.trim(),
                role: _role,
              );
      if (!mounted) return;
      Navigator.of(context).pop<CreateUserResponse>(result);
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createUserErrorGeneric)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createUserErrorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.createUserTitle),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _displayNameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.createUserDisplayNameLabel,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) {
                    return l10n.createUserDisplayNameValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.createUserRoleLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<UserRole>(
                segments: [
                  ButtonSegment(
                    value: UserRole.member,
                    label: Text(l10n.roleMember),
                    icon: const Icon(Icons.person_outline),
                  ),
                  ButtonSegment(
                    value: UserRole.manager,
                    label: Text(l10n.roleManager),
                    icon: const Icon(Icons.shield_outlined),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: _submitting
                    ? null
                    : (selection) => setState(() => _role = selection.first),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.createUserCancelButton),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.createUserSubmitButton),
        ),
      ],
    );
  }
}
