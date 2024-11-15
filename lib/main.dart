import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:relative_time/relative_time.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_pass_info/hive_registrar.g.dart';
import 'package:upgrader/upgrader.dart';
import 'package:rapid_pass_info/services/upgrader.dart';

// TODO: single view when only one card

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapters();

  await Hive.openBox<RapidPass>(RapidPass.boxName);
  await Hive.openBox<RapidPassData>(RapidPassData.boxName);

  runApp(const RapidPassApp());
}

const fontFamily = "Lexend Deca";

const textTheme = TextTheme(
  titleLarge: TextStyle(fontSize: 20),
  headlineLarge: TextStyle(fontSize: 34),
);

class RapidPassApp extends StatelessWidget {
  const RapidPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: "Amar Rapid Pass",
          onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            RelativeTimeLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('bn'),
          ],
          theme: ThemeData(
            colorScheme: lightColorScheme ?? const ColorScheme.light(),
            useMaterial3: true,
            textTheme: textTheme,
            fontFamily: fontFamily,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? const ColorScheme.dark(),
            useMaterial3: true,
            textTheme: textTheme,
            fontFamily: fontFamily,
          ),
          home: UpgradeAlert(
            upgrader: Upgrader(
              storeController: UpgraderStoreController(
                onLinux: () => UpgraderGitHubReleases(),
              ),
            ),
            showIgnore: false,
            child: const HomePage(),
          ),
        );
      },
    );
  }
}
