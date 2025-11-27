import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';

class Account {
  final String id;
  final String username;
  final List<TransitCard> cards;
  final AuthenticatedSession? session;

  Account({
    required this.id,
    required this.username,
    this.cards = const [],
    this.session,
  });

  double get totalBalance => cards.fold(
        0.0,
        (sum, card) => sum + double.parse(card.balance),
      );

  List<Transaction> get allTransactions {
    final allTransactions = <Transaction>[];
    for (final card in cards) {
      allTransactions.addAll(card.getFormattedTransactions());
    }
    allTransactions.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return allTransactions;
  }

  Account copyWith({
    String? id,
    String? username,
    String? displayName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    List<TransitCard>? cards,
    AuthenticatedSession? session,
  }) {
    return Account(
      id: id ?? this.id,
      username: username ?? this.username,
      cards: cards ?? this.cards,
      session: session ?? this.session,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'cards': cards.map((card) => card.toJson()).toList(),
      'session': session?.toJson(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'],
      cards: (json['cards'] as List?)
              ?.map((card) => TransitCard.fromJson(card, json['username']))
              .toList() ??
          [],
      session:
          json['session'] != null ? _sessionFromJson(json['session']) : null,
    );
  }

  static AuthenticatedSession _sessionFromJson(String sessionJson) {
    return AuthenticatedSession(
      username: "",
      cookies: [],
      redirectUri: Uri.parse(""),
    );
  }

  @override
  String toString() {
    return "Account(id: $id, username: $username, cards: $cards, session: $session)";
  }
}
