import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce/hive.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/meta.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.clearAll),
            onTap: () {
              // show confirmation dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                        AppLocalizations.of(context)!.clearAllConfirmation),
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
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppLocalizations.of(context)!.title,
                applicationVersion: meta["version"],
                applicationIcon: Image.asset(
                  'assets/icon/icon.png',
                  width: 48,
                  height: 48,
                ),
                children: [
                  Text(
                    AppLocalizations.of(context)!.aboutDescription,
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
