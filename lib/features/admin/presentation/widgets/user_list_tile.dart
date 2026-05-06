import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/models/auth_user.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/role_badge.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.user,
    this.highlight = false,
  });

  final AuthUser user;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dim = !user.isActive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: highlight
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: Opacity(
        opacity: dim ? 0.55 : 1.0,
        child: ListTile(
          onTap: () => context.push('/admin/users/${user.id}'),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName.characters.first.toUpperCase()
                  : '?',
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('@${user.username}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dim)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.userListTileInactiveChip,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              RoleBadge(role: user.role),
            ],
          ),
        ),
      ),
    );
  }
}
