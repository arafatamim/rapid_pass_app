import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/pages/home_page.dart';
import 'package:rapid_pass_info/state/state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO: single view when only one card

void main() {
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [
              Locale('en', 'UK'),
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
