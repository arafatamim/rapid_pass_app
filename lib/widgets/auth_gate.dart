import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/pages/home_page.dart';
import 'package:rapid_pass_info/pages/login_page.dart';
import 'package:rapid_pass_info/services/auth_service.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:rapid_pass_info/store/state.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        ({AuthenticatedSession? session, List<TransitCard>? cards})?>(
      future: _checkAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          final session = data.session!;
          final cards = data.cards;

          if (cards != null) {
            return ChangeNotifierProvider<CardsModel>(
              create: (_) => CardsModel(
                cards: cards,
                session: session,
              ),
              builder: (context, child) {
                return const HomePage();
              },
            );
          } else {
            // Cards failed to load
            return LoginPage(
              initialMessage: AppLocalizations.of(context)!.errorWhileLoading,
            );
          }
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return LoginPage(
            initialMessage: AppLocalizations.of(context)!.errorWhileLoading,
          );
        }
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          // no saved session, so redirect to login page
          return const LoginPage();
        }
        return const LoadingScreen();
      },
    );
  }

  Future<
      ({
        AuthenticatedSession? session,
        List<TransitCard>? cards,
      })?> _checkAutoLogin() async {
    final rememberMe = await AuthService.instance.getRememberMe();

    if (rememberMe) {
      debugPrint("Logging in automatically...");
      final session = await AuthService.instance.autoLogin();
      if (session != null) {
        try {
          final cards = await RapidPassService.instance.getCards(session);
          return (session: session, cards: cards);
        } catch (e) {
          // Return session with null cards to indicate card fetch error
          return (session: session, cards: null);
        }
      }
    }

    return null;
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 100,
              width: 100,
              child: LoadingIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
