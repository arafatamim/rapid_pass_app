import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce/hive.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
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
      body: Column(
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
                  title: Text(AppLocalizations.of(context)!.clearAll),
                  onTap: () {
                    // show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!
                              .clearAllConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.no),
                            ),
                            TextButton(
                              onPressed: () {
                                Hive.box<RapidPass>(RapidPass.boxName).clear();
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.yes),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.viewPrivacyPolicy),
                  onTap: () async {
                    final repoUrlStr = meta["repoUrl"];
                    if (repoUrlStr != null) {
                      final docUrl = Uri.parse(
                          "$repoUrlStr/blob/master/privacy-policy.md");
                      if (await canLaunchUrl(docUrl)) {
                        launchUrl(docUrl);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.cannotLaunchUrl),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.viewSource),
                  onTap: () async {
                    final repoUrlStr = meta["repoUrl"];
                    if (repoUrlStr != null) {
                      final repoUrl = Uri.parse(repoUrlStr);
                      if (await canLaunchUrl(repoUrl)) {
                        launchUrl(repoUrl);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.cannotLaunchUrl),
                        ),
                      );
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
      ),
    );
  }
}
