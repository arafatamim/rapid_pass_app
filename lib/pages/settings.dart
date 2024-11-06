import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/state/state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? child) {
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
                              state.clearAllPasses();
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
                    applicationVersion: '1.0.0',
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
      },
    );
  }
}
