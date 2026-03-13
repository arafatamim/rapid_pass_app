import 'package:flutter/foundation.dart';
import 'package:rapid_pass_info/models/account.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/services/nfc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Raised when an NFC IDm is already attached to another logical card.
final class CardLinkConflictException implements Exception {
  const CardLinkConflictException({
    required this.idm,
    required this.existingAccountId,
    required this.existingCardNumber,
  });

  final String idm;
  final String existingAccountId;
  final String existingCardNumber;

  @override
  String toString() {
    return 'CardLinkConflictException(idm: $idm, existingAccountId: '
        '$existingAccountId, existingCardNumber: $existingCardNumber)';
  }
}

/// Local repository that persists server/NFC card links and merged snapshots.
final class CardLinkRepository extends ChangeNotifier {
  CardLinkRepository({
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static final CardLinkRepository instance = CardLinkRepository();
  static const _storageKey = 'linked_cards_v1';

  final Future<SharedPreferences> Function() _preferencesLoader;
  final Map<String, LinkedCardRecord> _records = {};

  SharedPreferences? _preferences;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _preferences = await _preferencesLoader();
    final encoded = _preferences!.getString(_storageKey);
    if (encoded != null && encoded.isNotEmpty) {
      final decodedRecords = decodeLinkedCardRecords(encoded);
      for (final record in decodedRecords) {
        _records[record.storageKey] = record;
      }
    }

    _initialized = true;
  }

  List<LinkedCardRecord> get records => _records.values.toList(growable: false);

  LinkedCardRecord? getRecord({
    required String accountId,
    required String cardNumber,
  }) {
    return _records[_storageKeyFor(accountId, cardNumber)];
  }

  LinkedCardRecord? getRecordByIdm(String idm) {
    for (final record in _records.values) {
      if (record.linkedIdm == idm) {
        return record;
      }
    }
    return null;
  }

  Future<void> upsertServerSnapshot({
    required String accountId,
    required TransitCard card,
    required DateTime fetchedAt,
  }) async {
    await initialize();

    final record = _getOrCreateRecord(
      accountId: accountId,
      cardNumber: card.cardNumber,
      now: fetchedAt,
    );

    _records[record.storageKey] = record.copyWith(
      serverSnapshot: ServerCardSnapshot(
        accountId: accountId,
        cardNumber: card.cardNumber,
        username: card.username,
        card: card,
        fetchedAt: fetchedAt,
      ),
      updatedAt: fetchedAt,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> attachNfcSnapshot({
    required String accountId,
    required String cardNumber,
    required CardReadResult readResult,
    DateTime? scannedAt,
  }) async {
    await initialize();

    final now = scannedAt ?? DateTime.now();
    final existingLink = getRecordByIdm(readResult.idm);
    if (existingLink != null &&
        (existingLink.accountId != accountId ||
            existingLink.cardNumber != cardNumber)) {
      throw CardLinkConflictException(
        idm: readResult.idm,
        existingAccountId: existingLink.accountId,
        existingCardNumber: existingLink.cardNumber,
      );
    }

    final record = _getOrCreateRecord(
      accountId: accountId,
      cardNumber: cardNumber,
      now: now,
    );

    _records[record.storageKey] = record.copyWith(
      linkedIdm: readResult.idm,
      nfcSnapshot: NfcCardSnapshot.fromReadResult(
        readResult,
        scannedAt: now,
      ),
      updatedAt: now,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> unlinkNfcSnapshot({
    required String accountId,
    required String cardNumber,
  }) async {
    await initialize();

    final record = getRecord(accountId: accountId, cardNumber: cardNumber);
    if (record == null) {
      return;
    }

    _records[record.storageKey] = record.copyWith(
      clearLinkedIdm: true,
      clearNfcSnapshot: true,
      updatedAt: DateTime.now(),
    );

    await _persist();
    notifyListeners();
  }

  Future<void> removeAccountRecords(String accountId) async {
    await initialize();

    _records.removeWhere((_, record) => record.accountId == accountId);
    await _persist();
    notifyListeners();
  }

  Future<void> syncServerSnapshots(List<Account> accounts) async {
    await initialize();

    final fetchedAt = DateTime.now();
    for (final account in accounts) {
      for (final card in account.cards) {
        final record = _getOrCreateRecord(
          accountId: account.id,
          cardNumber: card.cardNumber,
          now: fetchedAt,
        );
        _records[record.storageKey] = record.copyWith(
          serverSnapshot: ServerCardSnapshot(
            accountId: account.id,
            cardNumber: card.cardNumber,
            username: card.username,
            card: card,
            fetchedAt: fetchedAt,
          ),
          updatedAt: fetchedAt,
        );
      }
    }

    await _persist();
    notifyListeners();
  }

  List<MergedTransitCard> getMergedCardsForAccounts(List<Account> accounts) {
    final activeAccountIds = accounts.map((account) => account.id).toSet();
    final mergedCards = <MergedTransitCard>[];
    final seenKeys = <String>{};

    for (final account in accounts) {
      for (final card in account.cards) {
        final record = getRecord(
          accountId: account.id,
          cardNumber: card.cardNumber,
        );
        if (record == null) {
          continue;
        }
        mergedCards.add(MergedTransitCard.fromRecord(record));
        seenKeys.add(record.storageKey);
      }
    }

    for (final record in _records.values) {
      if (!activeAccountIds.contains(record.accountId) ||
          seenKeys.contains(record.storageKey)) {
        continue;
      }
      mergedCards.add(MergedTransitCard.fromRecord(record));
    }

    return mergedCards;
  }

  List<CardActivity> getMergedActivitiesForAccounts(List<Account> accounts) {
    final activities = getMergedCardsForAccounts(accounts)
        .expand((card) => card.effectiveActivities)
        .toList(growable: false);

    activities.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return activities;
  }

  MergedCardCollection getMergedCardCollection(List<Account> accounts) {
    final mergedCards = getMergedCardsForAccounts(accounts);
    final mergedActivities = getMergedActivitiesForAccounts(accounts);
    final totalBalance = mergedCards.fold<double>(
      0,
      (sum, card) => sum + card.effectiveBalance,
    );

    return MergedCardCollection(
      allCards: mergedCards,
      allActivities: mergedActivities,
      totalBalance: totalBalance,
    );
  }

  LinkedCardRecord _getOrCreateRecord({
    required String accountId,
    required String cardNumber,
    required DateTime now,
  }) {
    return getRecord(accountId: accountId, cardNumber: cardNumber) ??
        LinkedCardRecord(
          accountId: accountId,
          cardNumber: cardNumber,
          createdAt: now,
          updatedAt: now,
        );
  }

  Future<void> _persist() async {
    final preferences = _preferences ?? await _preferencesLoader();
    final encoded = encodeLinkedCardRecords(records);
    await preferences.setString(_storageKey, encoded);
    _preferences = preferences;
  }

  String _storageKeyFor(String accountId, String cardNumber) {
    return '$accountId::$cardNumber';
  }
}
