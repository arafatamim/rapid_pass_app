import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/pages/home_page.dart';
import 'package:rapid_pass_info/state/state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:relative_time/relative_time.dart';

// TODO: single view when only one card

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const RapidPassApp());
}

class RapidPassApp extends StatelessWidget {
  const RapidPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return ChangeNotifierProvider(
          create: (context) => AppState(),
          child: MaterialApp(
            title: "Amar Rapid Pass",
            localizationsDelegates: const [
              AppLocalizations.delegate,
              RelativeTimeLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'UK'),
              Locale('en', 'US'),
              Locale('en', 'UK'),
              Locale('en', 'IN'),
              Locale("bn", "BD"),
            ],
            theme: ThemeData(
              colorScheme: lightColorScheme ?? const ColorScheme.light(),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme ?? const ColorScheme.dark(),
              useMaterial3: true,
            ),
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
