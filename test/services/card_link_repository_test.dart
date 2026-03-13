import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_pass_info/constants/transport_routes/hatirjheel_bus.dart';
import 'package:rapid_pass_info/constants/transport_routes/line_6.dart';
import 'package:rapid_pass_info/models/account.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/services/card_link_repository.dart';
import 'package:rapid_pass_info/services/nfc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CardLinkRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = CardLinkRepository();
    await repository.initialize();
  });

  test('keeps server history and appends unmatched newer NFC history',
      () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: [_serverCard(balance: '100')],
    );

    await repository.syncServerSnapshots([account]);

    var merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards, hasLength(1));
    expect(merged.allCards.first.effectiveBalance, 100.0);
    expect(merged.allCards.first.isServerStale, isFalse);
    expect(merged.allCards.first.effectiveActivities.first.source,
        CardActivitySource.server);

    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _readResult(balance: 130),
      scannedAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards.first.isLinked, isTrue);
    expect(merged.allCards.first.isServerStale, isTrue);
    expect(merged.allCards.first.effectiveBalance, 130.0);
    expect(merged.allCards.first.nfcGapFillCount, 1);
    expect(merged.allCards.first.effectiveActivities, hasLength(2));
    expect(
      merged.allCards.first.effectiveActivities.first.source,
      CardActivitySource.nfc,
    );
    expect(
      merged.allCards.first.effectiveActivities.last.source,
      CardActivitySource.server,
    );
  });

  test('does not duplicate an NFC transaction already reflected by the server',
      () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: [_serverTripCard(balance: '120')],
    );

    await repository.syncServerSnapshots([account]);
    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _matchingTripReadResult(balance: 120),
      scannedAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    final merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards.first.nfcGapFillCount, 0);
    expect(merged.allCards.first.effectiveActivities, hasLength(1));
    expect(
      merged.allCards.first.effectiveActivities.single.source,
      CardActivitySource.server,
    );
    expect(merged.allCards.first.effectiveActivities.single.routeIndex, 5);
  });

  test('does not append NFC card issue rows when the server already has issue',
      () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: [_serverIssueCard(balance: '200')],
    );

    await repository.syncServerSnapshots([account]);
    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _issueReadResult(balance: 200),
      scannedAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    final merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards.first.nfcGapFillCount, 0);
    expect(merged.allCards.first.effectiveActivities, hasLength(1));
    expect(
      merged.allCards.first.effectiveActivities.single.title,
      'Issue',
    );
    expect(
      merged.allCards.first.effectiveActivities.single.source,
      CardActivitySource.server,
    );
  });

  test('does not surface duplicate Hatirjheel boarding and alighting rows',
      () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: [_serverBusTripCard(balance: '113')],
    );

    await repository.syncServerSnapshots([account]);
    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _busTripReadResult(),
      scannedAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    final merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards.first.nfcGapFillCount, 0);
    expect(merged.allCards.first.effectiveActivities, hasLength(1));
    expect(
      merged.allCards.first.effectiveActivities.single.source,
      CardActivitySource.server,
    );
    expect(merged.allCards.first.effectiveActivities.single.routeIndex, 6);
  });

  test('deduplicates Hatirjheel trips when server uses HJ suffixes', () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: [_serverHatirjheelSuffixTripCard(balance: '113')],
    );

    await repository.syncServerSnapshots([account]);
    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _hatirjheelAlightingReadResult(),
      scannedAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    final merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards.first.nfcGapFillCount, 0);
    expect(merged.allCards.first.effectiveActivities, hasLength(2));
    expect(
      merged.allCards.first.effectiveActivities
          .where((activity) => activity.source == CardActivitySource.nfc),
      isEmpty,
    );
  });

  test('derives metro fare from adjacent NFC balances', () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: const [],
    );

    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _metroGapFillReadResult(),
      scannedAt: DateTime.now(),
    );

    final merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards, hasLength(1));
    expect(merged.allCards.first.effectiveActivities, hasLength(2));
    expect(merged.allCards.first.effectiveActivities.first.charge, -20);
    expect(merged.allCards.first.effectiveActivities.last.charge, isNull);
  });

  test('derives balance update amount from adjacent NFC balances', () async {
    final account = Account(
      id: 'account-1',
      username: 'alice',
      cards: const [],
    );

    await repository.attachNfcSnapshot(
      accountId: account.id,
      cardNumber: '12345678901234',
      readResult: _balanceUpdateGapFillReadResult(),
      scannedAt: DateTime.now(),
    );

    final merged = repository.getMergedCardCollection([account]);
    expect(merged.allCards, hasLength(1));
    expect(merged.allCards.first.effectiveActivities, hasLength(2));
    expect(merged.allCards.first.effectiveActivities.first.charge, 250);
    expect(merged.allCards.first.effectiveActivities.last.charge, isNull);
  });

  test('rejects linking one IDm to two different cards', () async {
    await repository.attachNfcSnapshot(
      accountId: 'account-1',
      cardNumber: '12345678901234',
      readResult: _readResult(idm: 'AA BB CC DD EE FF 00 11'),
    );

    expect(
      () => repository.attachNfcSnapshot(
        accountId: 'account-2',
        cardNumber: '99999999999999',
        readResult: _readResult(idm: 'AA BB CC DD EE FF 00 11'),
      ),
      throwsA(isA<CardLinkConflictException>()),
    );
  });

  test('persists linked records across repository instances', () async {
    await repository.attachNfcSnapshot(
      accountId: 'account-1',
      cardNumber: '12345678901234',
      readResult: _readResult(),
    );

    final reloaded = CardLinkRepository();
    await reloaded.initialize();

    final record = reloaded.getRecord(
      accountId: 'account-1',
      cardNumber: '12345678901234',
    );
    expect(record, isNotNull);
    expect(record!.linkedIdm, '01 02 03 04 05 06 07 08');
    expect(record.nfcSnapshot!.transactions, hasLength(1));
  });
}

TransitCard _serverCard({required String balance}) {
  return TransitCard(
    id: 1,
    userId: 7,
    username: 'alice',
    cardNumber: '12345678901234',
    hexCardNo: 'ABCD1234',
    name: 'Test Card',
    phoneNumber: '01700000000',
    fatherName: null,
    motherName: null,
    address: null,
    dateOfBirth: '1990-01-01',
    gender: 'N/A',
    nationality: 'Bangladeshi',
    photoId: null,
    photoIdNumber: null,
    profession: null,
    balance: balance,
    cardType: 'Rapid Pass',
    serverStatus: 'Active',
    totalTransactions: 1,
    transactionStartDate: '2025-01-01',
    transactionEndDate: '2025-01-01',
    status: 'active',
    syncStatus: 'synced',
    syncedAt: '2025-01-01T00:00:00Z',
    pendingAt: null,
    updateAt: null,
    unsyncedAt: null,
    createdAt: '2025-01-01T00:00:00Z',
    updatedAt: '2025-01-01T00:00:00Z',
    transactionHistory: [
      RawTransaction(
        id: 11,
        phoneNumber: '01700000000',
        cardNumber: '12345678901234',
        serviceType: 'Recharge',
        transactionDataId: 'tx-1',
        svLogId: 'sv-1',
        originStation: null,
        destinationStation: null,
        spentAmount: '100',
        balance: balance,
        dateStamp: '2025-01-01',
        timeStamp: '10:00:00',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ],
  );
}

TransitCard _serverTripCard({required String balance}) {
  return TransitCard(
    id: 1,
    userId: 7,
    username: 'alice',
    cardNumber: '12345678901234',
    hexCardNo: 'ABCD1234',
    name: 'Test Card',
    phoneNumber: '01700000000',
    fatherName: null,
    motherName: null,
    address: null,
    dateOfBirth: '1990-01-01',
    gender: 'N/A',
    nationality: 'Bangladeshi',
    photoId: null,
    photoIdNumber: null,
    profession: null,
    balance: balance,
    cardType: 'Rapid Pass',
    serverStatus: 'Active',
    totalTransactions: 1,
    transactionStartDate: '2026-03-12',
    transactionEndDate: '2026-03-12',
    status: 'active',
    syncStatus: 'synced',
    syncedAt: '2026-03-12T00:00:00Z',
    pendingAt: null,
    updateAt: null,
    unsyncedAt: null,
    createdAt: '2026-03-12T00:00:00Z',
    updatedAt: '2026-03-12T00:00:00Z',
    transactionHistory: [
      RawTransaction(
        id: 12,
        phoneNumber: '01700000000',
        cardNumber: '12345678901234',
        serviceType: 'Exit',
        transactionDataId: 'tx-2',
        svLogId: 'sv-2',
        originStation: 'Agargaon',
        destinationStation: 'Motijheel',
        spentAmount: '-20',
        balance: balance,
        dateStamp: '2026-03-12',
        timeStamp: '09:15:00',
        createdAt: '2026-03-12T09:15:00Z',
        updatedAt: '2026-03-12T09:15:00Z',
      ),
    ],
  );
}

TransitCard _serverIssueCard({required String balance}) {
  return TransitCard(
    id: 1,
    userId: 7,
    username: 'alice',
    cardNumber: '12345678901234',
    hexCardNo: 'ABCD1234',
    name: 'Test Card',
    phoneNumber: '01700000000',
    fatherName: null,
    motherName: null,
    address: null,
    dateOfBirth: '1990-01-01',
    gender: 'N/A',
    nationality: 'Bangladeshi',
    photoId: null,
    photoIdNumber: null,
    profession: null,
    balance: balance,
    cardType: 'Rapid Pass',
    serverStatus: 'Active',
    totalTransactions: 1,
    transactionStartDate: '2024-02-10',
    transactionEndDate: '2024-02-10',
    status: 'active',
    syncStatus: 'synced',
    syncedAt: '2024-02-10T00:00:00Z',
    pendingAt: null,
    updateAt: null,
    unsyncedAt: null,
    createdAt: '2024-02-10T00:00:00Z',
    updatedAt: '2024-02-10T00:00:00Z',
    transactionHistory: [
      RawTransaction(
        id: 13,
        phoneNumber: '01700000000',
        cardNumber: '12345678901234',
        serviceType: 'Issue',
        transactionDataId: 'tx-3',
        svLogId: 'sv-3',
        originStation: null,
        destinationStation: null,
        spentAmount: '0',
        balance: balance,
        dateStamp: '2024-02-10',
        timeStamp: '22:00:00',
        createdAt: '2024-02-10T22:00:00Z',
        updatedAt: '2024-02-10T22:00:00Z',
      ),
    ],
  );
}

TransitCard _serverBusTripCard({required String balance}) {
  return TransitCard(
    id: 1,
    userId: 7,
    username: 'alice',
    cardNumber: '12345678901234',
    hexCardNo: 'ABCD1234',
    name: 'Test Card',
    phoneNumber: '01700000000',
    fatherName: null,
    motherName: null,
    address: null,
    dateOfBirth: '1990-01-01',
    gender: 'N/A',
    nationality: 'Bangladeshi',
    photoId: null,
    photoIdNumber: null,
    profession: null,
    balance: balance,
    cardType: 'Rapid Pass',
    serverStatus: 'Active',
    totalTransactions: 1,
    transactionStartDate: '2025-07-27',
    transactionEndDate: '2025-07-27',
    status: 'active',
    syncStatus: 'synced',
    syncedAt: '2025-07-27T00:00:00Z',
    pendingAt: null,
    updateAt: null,
    unsyncedAt: null,
    createdAt: '2025-07-27T00:00:00Z',
    updatedAt: '2025-07-27T00:00:00Z',
    transactionHistory: [
      RawTransaction(
        id: 14,
        phoneNumber: '01700000000',
        cardNumber: '12345678901234',
        serviceType: 'Exit',
        transactionDataId: 'tx-4',
        svLogId: 'sv-4',
        originStation: null,
        destinationStation: 'Police Plaza',
        spentAmount: '-20',
        balance: balance,
        dateStamp: '2025-07-27',
        timeStamp: '11:57:00',
        createdAt: '2025-07-27T11:57:00Z',
        updatedAt: '2025-07-27T11:57:00Z',
      ),
    ],
  );
}

TransitCard _serverHatirjheelSuffixTripCard({required String balance}) {
  return TransitCard(
    id: 1,
    userId: 7,
    username: 'alice',
    cardNumber: '12345678901234',
    hexCardNo: 'ABCD1234',
    name: 'Test Card',
    phoneNumber: '01700000000',
    fatherName: null,
    motherName: null,
    address: null,
    dateOfBirth: '1990-01-01',
    gender: 'N/A',
    nationality: 'Bangladeshi',
    photoId: null,
    photoIdNumber: null,
    profession: null,
    balance: balance,
    cardType: 'Rapid Pass',
    serverStatus: 'Active',
    totalTransactions: 2,
    transactionStartDate: '2025-07-27',
    transactionEndDate: '2025-07-27',
    status: 'active',
    syncStatus: 'synced',
    syncedAt: '2025-07-27T00:00:00Z',
    pendingAt: null,
    updateAt: null,
    unsyncedAt: null,
    createdAt: '2025-07-27T00:00:00Z',
    updatedAt: '2025-07-27T00:00:00Z',
    transactionHistory: [
      RawTransaction(
        id: 15,
        phoneNumber: '01700000000',
        cardNumber: '12345678901234',
        serviceType: 'Exit',
        transactionDataId: 'tx-5',
        svLogId: 'sv-5',
        originStation: null,
        destinationStation: 'Police Plaza(HJ)',
        spentAmount: '-20',
        balance: '113',
        dateStamp: '2025-07-27',
        timeStamp: '11:57:00',
        createdAt: '2025-07-27T11:57:00Z',
        updatedAt: '2025-07-27T11:57:00Z',
      ),
      RawTransaction(
        id: 16,
        phoneNumber: '01700000000',
        cardNumber: '12345678901234',
        serviceType: 'Exit',
        transactionDataId: 'tx-6',
        svLogId: 'sv-6',
        originStation: null,
        destinationStation: 'Kunipara(HJ)',
        spentAmount: '-20',
        balance: '133',
        dateStamp: '2025-07-27',
        timeStamp: '11:46:00',
        createdAt: '2025-07-27T11:46:00Z',
        updatedAt: '2025-07-27T11:46:00Z',
      ),
    ],
  );
}

CardReadResult _readResult({
  String idm = '01 02 03 04 05 06 07 08',
  int balance = 120,
}) {
  final encodedTimestamp = _encodeTimestamp(
    year: 2026,
    month: 3,
    day: 12,
    hour: 9,
  );
  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '08 52 10 00',
        timestamp: DateTime(2026, 3, 12, 9),
        transactionType: '00 32',
        transactionKind: const CommuteDhakaMetro(),
        serviceName: const DhakaMetroLine6Service(),
        eventPhase: const TripPhase(),
        routeIndex: 5,
        fromStationIndex: Line6Station.agargaon,
        toStationIndex: Line6Station.motijheel,
        fromStationRawCode: 50,
        toStationRawCode: 10,
        balance: balance,
        trailing: 'AA BB',
        rawBlock: Uint8List.fromList([
          0x08,
          0x52,
          0x10,
          0x00,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0x00,
          0x32,
          0x00,
          0x0A,
          balance & 0xFF,
          (balance >> 8) & 0xFF,
          (balance >> 16) & 0xFF,
          0xAA,
          0xBB,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

CardReadResult _matchingTripReadResult({
  String idm = '01 02 03 04 05 06 07 08',
  int balance = 120,
}) {
  final encodedTimestamp = _encodeTimestamp(
    year: 2026,
    month: 3,
    day: 12,
    hour: 9,
  );
  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '08 52 10 00',
        timestamp: DateTime(2026, 3, 12, 9),
        transactionType: '00 32',
        transactionKind: const CommuteDhakaMetro(),
        serviceName: const DhakaMetroLine6Service(),
        eventPhase: const TripPhase(),
        routeIndex: 5,
        fromStationIndex: Line6Station.agargaon,
        toStationIndex: Line6Station.motijheel,
        fromStationRawCode: 50,
        toStationRawCode: 10,
        balance: balance,
        trailing: 'AA BB',
        rawBlock: Uint8List.fromList([
          0x08,
          0x52,
          0x10,
          0x00,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0x00,
          0x32,
          0x00,
          0x0A,
          balance & 0xFF,
          (balance >> 8) & 0xFF,
          (balance >> 16) & 0xFF,
          0xAA,
          0xBB,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

CardReadResult _issueReadResult({
  String idm = '01 02 03 04 05 06 07 08',
  int balance = 200,
}) {
  final encodedTimestamp = _encodeTimestamp(
    year: 2024,
    month: 2,
    day: 10,
    hour: 22,
  );
  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '44 20 02 01',
        timestamp: DateTime(2024, 2, 10, 22),
        transactionType: 'B0 FD',
        transactionKind: const CardIssueRecord(),
        serviceName: const RapidPassCardSystemService(),
        eventPhase: const IssuePhase(),
        routeIndex: null,
        fromStationIndex: null,
        toStationIndex: null,
        fromStationRawCode: 193,
        toStationRawCode: 0,
        balance: balance,
        trailing: '00 01',
        rawBlock: Uint8List.fromList([
          0x44,
          0x20,
          0x02,
          0x01,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0xFD,
          0xC1,
          0x00,
          0x00,
          balance & 0xFF,
          (balance >> 8) & 0xFF,
          (balance >> 16) & 0xFF,
          0x00,
          0x01,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

CardReadResult _busTripReadResult({
  String idm = '01 02 03 04 05 06 07 08',
}) {
  final encodedTimestamp = _encodeTimestamp(
    year: 2025,
    month: 7,
    day: 27,
    hour: 11,
  );
  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '42 D6 30 00',
        timestamp: DateTime(2025, 7, 27, 11),
        transactionType: '58 8C',
        transactionKind: const CommuteHatirjheelBusEnd(),
        serviceName: const HatirjheelCircularBusService(),
        eventPhase: const AlightingPhase(),
        routeIndex: 6,
        fromStationIndex: HatirjheelBus.kunipara,
        toStationIndex: HatirjheelBus.policePlaza,
        fromStationRawCode: 22,
        toStationRawCode: 19,
        balance: 113,
        trailing: '00 10',
        rawBlock: Uint8List.fromList([
          0x42,
          0xD6,
          0x30,
          0x00,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0x8C,
          0x16,
          0x8C,
          0x13,
          0x71,
          0x00,
          0x00,
          0x00,
          0x10,
        ]),
      ),
      NfcTransaction(
        fixedHeader: '08 D2 20 00',
        timestamp: DateTime(2025, 7, 27, 11),
        transactionType: '58 8C',
        transactionKind: const CommuteHatirjheelBusStart(),
        serviceName: const HatirjheelCircularBusService(),
        eventPhase: const BoardingPhase(),
        routeIndex: 6,
        fromStationIndex: HatirjheelBus.kunipara,
        toStationIndex: null,
        fromStationRawCode: 22,
        toStationRawCode: 0,
        balance: 93,
        trailing: '00 0F',
        rawBlock: Uint8List.fromList([
          0x08,
          0xD2,
          0x20,
          0x00,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0x8C,
          0x16,
          0x00,
          0x00,
          0x5D,
          0x00,
          0x00,
          0x00,
          0x0F,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

CardReadResult _hatirjheelAlightingReadResult({
  String idm = '01 02 03 04 05 06 07 08',
}) {
  final encodedTimestamp = _encodeTimestamp(
    year: 2025,
    month: 7,
    day: 27,
    hour: 11,
  );

  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '42 D6 30 00',
        timestamp: DateTime(2025, 7, 27, 11),
        transactionType: '58 8C',
        transactionKind: const CommuteHatirjheelBusEnd(),
        serviceName: const HatirjheelCircularBusService(),
        eventPhase: const AlightingPhase(),
        routeIndex: 6,
        fromStationIndex: HatirjheelBus.kunipara,
        toStationIndex: HatirjheelBus.policePlaza,
        fromStationRawCode: 22,
        toStationRawCode: 19,
        balance: 113,
        trailing: '00 10',
        rawBlock: Uint8List.fromList([
          0x42,
          0xD6,
          0x30,
          0x00,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0x8C,
          0x16,
          0x8C,
          0x13,
          0x71,
          0x00,
          0x00,
          0x00,
          0x10,
        ]),
      ),
      NfcTransaction(
        fixedHeader: '42 D6 30 00',
        timestamp: DateTime(2025, 7, 27, 11),
        transactionType: '58 8C',
        transactionKind: const CommuteHatirjheelBusEnd(),
        serviceName: const HatirjheelCircularBusService(),
        eventPhase: const AlightingPhase(),
        routeIndex: 6,
        fromStationIndex: HatirjheelBus.rampura,
        toStationIndex: HatirjheelBus.kunipara,
        fromStationRawCode: 16,
        toStationRawCode: 22,
        balance: 133,
        trailing: '00 0E',
        rawBlock: Uint8List.fromList([
          0x42,
          0xD6,
          0x30,
          0x00,
          (encodedTimestamp >> 16) & 0xFF,
          (encodedTimestamp >> 8) & 0xFF,
          encodedTimestamp & 0xFF,
          0x8C,
          0x10,
          0x8C,
          0x16,
          0x85,
          0x00,
          0x00,
          0x00,
          0x0E,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

CardReadResult _metroGapFillReadResult({
  String idm = '01 02 03 04 05 06 07 08',
}) {
  final newerTimestamp = _encodeTimestamp(
    year: 2026,
    month: 3,
    day: 12,
    hour: 9,
  );
  final olderTimestamp = _encodeTimestamp(
    year: 2026,
    month: 3,
    day: 12,
    hour: 8,
  );

  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '08 52 10 00',
        timestamp: DateTime(2026, 3, 12, 9),
        transactionType: '00 32',
        transactionKind: const CommuteDhakaMetro(),
        serviceName: const DhakaMetroLine6Service(),
        eventPhase: const TripPhase(),
        routeIndex: 5,
        fromStationIndex: Line6Station.agargaon,
        toStationIndex: Line6Station.motijheel,
        fromStationRawCode: 50,
        toStationRawCode: 10,
        balance: 120,
        trailing: 'AA BB',
        rawBlock: Uint8List.fromList([
          0x08,
          0x52,
          0x10,
          0x00,
          (newerTimestamp >> 16) & 0xFF,
          (newerTimestamp >> 8) & 0xFF,
          newerTimestamp & 0xFF,
          0x00,
          0x32,
          0x00,
          0x0A,
          0x78,
          0x00,
          0x00,
          0xAA,
          0xBB,
        ]),
      ),
      NfcTransaction(
        fixedHeader: '08 52 10 00',
        timestamp: DateTime(2026, 3, 12, 8),
        transactionType: '00 32',
        transactionKind: const CommuteDhakaMetro(),
        serviceName: const DhakaMetroLine6Service(),
        eventPhase: const TripPhase(),
        routeIndex: 5,
        fromStationIndex: Line6Station.motijheel,
        toStationIndex: Line6Station.agargaon,
        fromStationRawCode: 10,
        toStationRawCode: 50,
        balance: 140,
        trailing: 'AA BC',
        rawBlock: Uint8List.fromList([
          0x08,
          0x52,
          0x10,
          0x00,
          (olderTimestamp >> 16) & 0xFF,
          (olderTimestamp >> 8) & 0xFF,
          olderTimestamp & 0xFF,
          0x00,
          0x0A,
          0x00,
          0x32,
          0x8C,
          0x00,
          0x00,
          0xAA,
          0xBC,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

CardReadResult _balanceUpdateGapFillReadResult({
  String idm = '01 02 03 04 05 06 07 08',
}) {
  final newerTimestamp = _encodeTimestamp(
    year: 2025,
    month: 5,
    day: 28,
    hour: 15,
  );
  final olderTimestamp = _encodeTimestamp(
    year: 2025,
    month: 4,
    day: 14,
    hour: 20,
  );

  return CardReadResult(
    idm: idm,
    transactions: [
      NfcTransaction(
        fixedHeader: '1D 60 02 01',
        timestamp: DateTime(2025, 5, 28, 15),
        transactionType: '78 01',
        transactionKind: const BalanceUpdate(),
        serviceName: const RapidPassBalanceService(),
        eventPhase: const BalanceUpdatePhase(),
        routeIndex: null,
        fromStationIndex: null,
        toStationIndex: null,
        fromStationRawCode: 35,
        toStationRawCode: 0,
        balance: 297,
        trailing: '00 08',
        rawBlock: Uint8List.fromList([
          0x1D,
          0x60,
          0x02,
          0x01,
          (newerTimestamp >> 16) & 0xFF,
          (newerTimestamp >> 8) & 0xFF,
          newerTimestamp & 0xFF,
          0x01,
          0x23,
          0x00,
          0x00,
          0x29,
          0x01,
          0x00,
          0x00,
          0x08,
        ]),
      ),
      NfcTransaction(
        fixedHeader: '08 52 10 00',
        timestamp: DateTime(2025, 4, 14, 20),
        transactionType: 'A0 01',
        transactionKind: const CommuteDhakaMetro(),
        serviceName: const DhakaMetroLine6Service(),
        eventPhase: const TripPhase(),
        routeIndex: 5,
        fromStationIndex: Line6Station.farmgate,
        toStationIndex: Line6Station.bangladeshSecretariat,
        fromStationRawCode: 40,
        toStationRawCode: 20,
        balance: 47,
        trailing: '00 07',
        rawBlock: Uint8List.fromList([
          0x08,
          0x52,
          0x10,
          0x00,
          (olderTimestamp >> 16) & 0xFF,
          (olderTimestamp >> 8) & 0xFF,
          olderTimestamp & 0xFF,
          0x01,
          0x28,
          0x01,
          0x14,
          0x2F,
          0x00,
          0x00,
          0x00,
          0x07,
        ]),
      ),
    ],
    rawResponse1: Uint8List.fromList([0x01, 0x02, 0x03]),
    rawResponse2: Uint8List.fromList([0x04, 0x05, 0x06]),
  );
}

int _encodeTimestamp({
  required int year,
  required int month,
  required int day,
  required int hour,
}) {
  final yearOffset = year % 100;
  return ((yearOffset & 0x1F) << 17) |
      ((month & 0x0F) << 13) |
      ((day & 0x1F) << 8) |
      ((hour & 0x1F) << 3);
}
