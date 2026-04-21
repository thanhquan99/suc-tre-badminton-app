import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/models/user_role.dart';
import '../../../../l10n/generated/app_localizations.dart';

class UsersSearchBar extends StatefulWidget {
  const UsersSearchBar({
    super.key,
    required this.initialQuery,
    required this.initialRole,
    required this.onChanged,
  });

  final String initialQuery;
  final UserRole? initialRole;
  final void Function(String q, UserRole? role) onChanged;

  @override
  State<UsersSearchBar> createState() => _UsersSearchBarState();
}

class _UsersSearchBarState extends State<UsersSearchBar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);
  Timer? _debounce;
  UserRole? _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(text.trim(), _role);
    });
  }

  void _onRoleChanged(UserRole? role) {
    setState(() => _role = role);
    widget.onChanged(_controller.text.trim(), role);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              hintText: l10n.usersSearchHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onTextChanged('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.usersRoleFilterAll),
                  selected: _role == null,
                  onSelected: (_) => _onRoleChanged(null),
                ),
                ChoiceChip(
                  label: Text(l10n.roleAdmin),
                  selected: _role == UserRole.admin,
                  onSelected: (_) => _onRoleChanged(UserRole.admin),
                ),
                ChoiceChip(
                  label: Text(l10n.roleManager),
                  selected: _role == UserRole.manager,
                  onSelected: (_) => _onRoleChanged(UserRole.manager),
                ),
                ChoiceChip(
                  label: Text(l10n.roleMember),
                  selected: _role == UserRole.member,
                  onSelected: (_) => _onRoleChanged(UserRole.member),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
