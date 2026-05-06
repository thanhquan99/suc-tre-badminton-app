import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/models/user_role.dart';
import '../../../core/users/models/create_user_response.dart';
import '../../../core/users/models/users_query.dart';
import '../../../core/users/users_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'dialogs/create_user_dialog.dart';
import 'dialogs/credentials_modal.dart';
import 'widgets/user_list_tile.dart';
import 'widgets/users_pagination.dart';
import 'widgets/users_search_bar.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  UsersQuery _query = const UsersQuery();
  String? _justCreatedId;

  void _setQuery(UsersQuery next) {
    if (next == _query) return;
    setState(() => _query = next);
  }

  void _onSearchChanged(String q, UserRole? role) {
    _setQuery(
      _query.copyWith(q: q, role: role, page: 1),
    );
  }

  void _onPageChanged(int page) {
    _setQuery(_query.copyWith(page: page));
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<CreateUserResponse>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CreateUserDialog(),
    );
    if (result == null || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CredentialsModal(response: result),
    );
    if (!mounted) return;

    setState(() => _justCreatedId = result.user.id);
    ref.invalidate(usersListProvider);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _justCreatedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(usersListProvider(_query));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.usersScreenTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.createUserTitle),
      ),
      body: Column(
        children: [
          UsersSearchBar(
            initialQuery: _query.q ?? '',
            initialRole: _query.role,
            onChanged: _onSearchChanged,
          ),
          const Divider(height: 1),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 8),
                      Text(l10n.usersLoadError),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () =>
                            ref.invalidate(usersListProvider(_query)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (page) {
                if (page.data.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(l10n.usersEmpty),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: page.data.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (_, i) {
                          final user = page.data[i];
                          return UserListTile(
                            key: ValueKey(user.id),
                            user: user,
                            highlight: user.id == _justCreatedId,
                          );
                        },
                      ),
                    ),
                    UsersPagination(
                      page: page.page,
                      totalPages: page.totalPages,
                      onPageChanged: _onPageChanged,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
