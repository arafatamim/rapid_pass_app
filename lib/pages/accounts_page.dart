import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/account.dart';
import 'package:rapid_pass_info/pages/login_page.dart';
import 'package:rapid_pass_info/services/account_service.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.accounts),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.addAnAccount,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const LoginPage();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AccountService>(
        builder: (context, accountService, child) {
          return ReorderableListView.builder(
            itemCount: accountService.accounts.length,
            itemBuilder: (context, index) {
              final account = accountService.accounts[index];
              return Dismissible(
                direction: DismissDirection.startToEnd,
                confirmDismiss: (_) => _confirmDeleteAccount(context, account),
                onDismissed: (_) => _onDeleteAccount(context, account.id),
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ],
                  ),
                ),
                key: ValueKey(account.id),
                child: ListTile(
                  key: ValueKey(account.id),
                  title: Text(account.username),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              accountService.reorderAccounts(oldIndex, newIndex);
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDeleteAccount(
      BuildContext context, Account account) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.removeAccountFromDeviceTitle,
        ),
        content: Text(
          AppLocalizations.of(context)!
              .removeAccountFromDeviceMessage(account.username),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.removeFromDevice),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _onDeleteAccount(BuildContext context, String id) {
    AccountService.instance.removeAccount(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.savedAccountRemoved),
      ),
    );
  }
}
