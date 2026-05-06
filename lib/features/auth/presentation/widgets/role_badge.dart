import 'package:flutter/material.dart';

import '../../../../core/auth/models/user_role.dart';
import '../../../../l10n/generated/app_localizations.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (role) {
      UserRole.admin => l10n.roleAdmin,
      UserRole.manager => l10n.roleManager,
      UserRole.member => l10n.roleMember,
    };
    final color = switch (role) {
      UserRole.admin => Colors.red.shade700,
      UserRole.manager => Colors.orange.shade700,
      UserRole.member => Colors.blue.shade700,
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
