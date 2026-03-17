import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/helpers/upgrader.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/meta.dart';
import 'package:rapid_pass_info/pages/home_page.dart';
import 'package:rapid_pass_info/pages/login_page.dart';
import 'package:rapid_pass_info/services/account_service.dart';
import 'package:rapid_pass_info/services/nfc.dart';
import 'package:relative_time/relative_time.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await AccountService.instance.initialize();
  await RapidPassNfcService.instance.initialize();

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
        final light =
            lightColorScheme ?? ColorScheme.fromSeed(seedColor: Colors.blue);
        final dark = darkColorScheme ??
            ColorScheme.fromSeed(
                seedColor: Colors.lightBlue, brightness: Brightness.dark);

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
            colorScheme: light,
            textTheme: textTheme,
            fontFamily: fontFamily,
            navigationBarTheme: navigationBarTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: dark,
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
            child: ChangeNotifierProvider(
              create: (_) => AccountService.instance,
              builder: (context, child) {
                final hasAccounts =
                    context.read<AccountService>().accounts.isNotEmpty;
                if (!hasAccounts) {
                  return const LoginPage(isFirstAccount: true);
                }
                return const HomePage();
              },
            ),
          ),
        );
      },
    );
  }
}
