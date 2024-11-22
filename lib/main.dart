import 'package:flutter/foundation.dart';
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
import 'package:rapid_pass_info/helpers/upgrader.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/meta.dart';
import 'package:url_launcher/url_launcher.dart';

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

const navigationBarTheme = NavigationBarThemeData(
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
            TransportRouteLocalizations.delegate,
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
            useMaterial3: true,
            colorScheme: lightColorScheme ?? const ColorScheme.light(),
            textTheme: textTheme,
            fontFamily: fontFamily,
            navigationBarTheme: navigationBarTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? const ColorScheme.dark(),
            textTheme: textTheme,
            fontFamily: fontFamily,
            navigationBarTheme: navigationBarTheme,
          ),
          home: UpgradeAlert(
            upgrader: !kDebugMode ? upgrader : null,
            showIgnore: false,
            showReleaseNotes: false,
            onUpdate: () {
              final repoUrlStr = meta["repoUrl"];
              if (repoUrlStr == null) {
                return false;
              }
              final repoUrl = Uri.parse("$repoUrlStr/releases/latest");
              launchUrl(repoUrl);

              return true;
            },
            child: const HomePage(),
          ),
        );
      },
    );
  }
}
