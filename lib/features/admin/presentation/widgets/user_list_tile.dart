import 'package:flutter/material.dart';

import '../../../../core/auth/models/auth_user.dart';
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: highlight
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: ListTile(
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
        trailing: RoleBadge(role: user.role),
      ),
    );
  }
}
