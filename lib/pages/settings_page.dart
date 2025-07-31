import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/services/auth_service.dart';
import 'package:rapid_pass_info/store/state.dart';
import 'package:rapid_pass_info/widgets/auth_gate.dart';
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
      body: Consumer<CardsModel>(
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
                        "${AppLocalizations.of(context)!.logout} ${state.session.username}",
                      ),
                      onTap: () {
                        // show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.logout),
                              content: Text(
                                AppLocalizations.of(context)!
                                    .logoutConfirmation(state.session.username),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppLocalizations.of(context)!.no),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await AuthService.instance
                                        .clearCredentials();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .credentialsCleared,
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AuthGate(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  child:
                                      Text(AppLocalizations.of(context)!.yes),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    ListTile(
                      title:
                          Text(AppLocalizations.of(context)!.viewPrivacyPolicy),
                      onTap: () async {
                        try {
                          final repoUrlStr = meta["repoUrl"];
                          if (repoUrlStr == null) {
                            throw Exception("repoUrl is not defined in meta");
                          }
                          final docUrl = Uri.parse(
                              "$repoUrlStr/blob/master/privacy-policy.md");
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
                      title: Text(AppLocalizations.of(context)!.viewSource),
                      onTap: () async {
                        try {
                          final repoUrlStr = meta["repoUrl"];
                          if (repoUrlStr == null) {
                            throw Exception("repoUrl is not defined in meta");
                          }
                          final repoUrl = Uri.parse(repoUrlStr);
                          if (!await launchUrl(repoUrl)) {
                            throw Exception("Failed to launch $repoUrl");
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
