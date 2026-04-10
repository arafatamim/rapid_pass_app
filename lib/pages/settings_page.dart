import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/services/account_service.dart';
import 'package:rapid_pass_info/pages/accounts_page.dart';
import 'package:upgrader/upgrader.dart';
import 'package:rapid_pass_info/helpers/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rapid_pass_info/meta.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Consumer<AccountService>(
        builder: (context, state, child) {
          return Column(
            children: [
              UpgradeCard(
                showIgnore: false,
                margin: const EdgeInsets.all(8),
                upgrader: upgrader,
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.manageAccountsOnDevice,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!
                            .manageAccountsOnDeviceDescription,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: state,
                              child: const AccountsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title:
                          Text(AppLocalizations.of(context)!.accountDeletion),
                      subtitle: Text(
                        AppLocalizations.of(context)!
                            .accountDeletionDescription,
                      ),
                      onTap: () async {
                        try {
                          final docUrlStr = meta["accountDeletionUrl"];
                          if (docUrlStr == null) {
                            throw Exception(
                                "accountDeletionUrl is not defined in meta");
                          }
                          final docUrl = Uri.parse(docUrlStr);
                          if (!await launchUrl(docUrl)) {
                            throw Exception("Failed to launch $docUrl");
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .cannotLaunchUrl),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    ListTile(
                      title:
                          Text(AppLocalizations.of(context)!.viewPrivacyPolicy),
                      onTap: () async {
                        try {
                          final docUrlStr = meta["privacyPolicyUrl"];
                          if (docUrlStr == null) {
                            throw Exception(
                                "privacyPolicyUrl is not defined in meta");
                          }
                          final docUrl = Uri.parse(docUrlStr);
                          if (!await launchUrl(docUrl)) {
                            throw Exception("Failed to launch $docUrl");
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .cannotLaunchUrl),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.about),
                      onTap: () async {
                        final packageInfo = await PackageInfo.fromPlatform();

                        final installerStore = packageInfo.installerStore;

                        if (!context.mounted) return;
                        showAboutDialog(
                          context: context,
                          applicationName: AppLocalizations.of(context)!.title,
                          applicationVersion: packageInfo.version,
                          applicationIcon: Image.asset(
                            'assets/icon/icon.png',
                            width: 48,
                            height: 48,
                          ),
                          children: [
                            Text(
                              AppLocalizations.of(context)!.aboutDescription,
                            ),
                            if (installerStore != null) Text(installerStore)
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
