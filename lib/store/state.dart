import 'package:flutter/widgets.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/services/auth_service.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';

class CardsModel extends ChangeNotifier {
  AuthenticatedSession session;
  List<TransitCard> cards;

  CardsModel({
    required this.session,
    required this.cards,
  });

  Future<void> refreshCards() async {
    final sessionCookie = session.getCookie("rapidpass_session");
    if (sessionCookie == null) {
      throw Exception("Session cookie not found");
    }
    final expireDate = sessionCookie.expires;
    if (expireDate != null && expireDate.isBefore(DateTime.now())) {
      debugPrint("Refreshing session");
      final newSession = await AuthService.instance.autoLogin();
      if (newSession != null) {
        session = newSession;
      } else {
        throw Exception("Failed to refresh session");
      }
    }

    final newCards = await RapidPassService.instance.getCards(session);
    cards = newCards;
    notifyListeners();
  }
}
