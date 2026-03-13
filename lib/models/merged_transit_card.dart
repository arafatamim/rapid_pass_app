import 'dart:convert';
import 'dart:typed_data';

import 'package:rapid_pass_info/constants/transport_routes/transport_routes.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/services/nfc.dart';

/// Merge-layer models for combining server cards with locally scanned NFC data.
///
/// The core policy in this file is:
/// - server cards remain the primary source of truth for card identity and
///   known transaction history
/// - NFC scans enrich a card with a physical IDm and on-card history
/// - NFC transactions are only surfaced when they do not appear to already
///   exist in server history
/// - newer NFC balance can override stale server balance, but server history is
///   kept intact and NFC is used as gap fill

/// Snapshot of a server-backed card as fetched by this app at a specific time.
final class ServerCardSnapshot {
  const ServerCardSnapshot({
    required this.accountId,
    required this.cardNumber,
    required this.username,
    required this.card,
    required this.fetchedAt,
  });

  final String accountId;
  final String cardNumber;
  final String username;
  final TransitCard card;
  final DateTime fetchedAt;

  factory ServerCardSnapshot.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String;
    return ServerCardSnapshot(
      accountId: json['accountId'] as String,
      cardNumber: json['cardNumber'] as String,
      username: username,
      card: TransitCard.fromJson(
        json['card'] as Map<String, dynamic>,
        username,
      ),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'cardNumber': cardNumber,
      'username': username,
      'card': card.toJson(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }
}

/// Snapshot of a local NFC scan linked to a specific physical card.
final class NfcCardSnapshot {
  const NfcCardSnapshot({
    required this.idm,
    required this.scannedAt,
    required this.currentBalance,
    required this.rawResponse1Hex,
    required this.rawResponse2Hex,
    required this.transactionBlocksHex,
  });

  final String idm;
  final DateTime scannedAt;
  final int currentBalance;
  final String rawResponse1Hex;
  final String rawResponse2Hex;
  final List<String> transactionBlocksHex;

  factory NfcCardSnapshot.fromReadResult(
    CardReadResult readResult, {
    DateTime? scannedAt,
  }) {
    return NfcCardSnapshot(
      idm: readResult.idm,
      scannedAt: scannedAt ?? DateTime.now(),
      currentBalance: readResult.currentBalance ?? 0,
      rawResponse1Hex: ByteParser.toHexString(readResult.rawResponse1),
      rawResponse2Hex: ByteParser.toHexString(readResult.rawResponse2),
      transactionBlocksHex: readResult.transactions
          .map((transaction) => ByteParser.toHexString(transaction.rawBlock))
          .toList(growable: false),
    );
  }

  factory NfcCardSnapshot.fromJson(Map<String, dynamic> json) {
    return NfcCardSnapshot(
      idm: json['idm'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      currentBalance: json['currentBalance'] as int,
      rawResponse1Hex: json['rawResponse1Hex'] as String? ?? '',
      rawResponse2Hex: json['rawResponse2Hex'] as String? ?? '',
      transactionBlocksHex:
          (json['transactionBlocksHex'] as List<dynamic>? ?? const [])
              .cast<String>(),
    );
  }

  /// Rebuilds parsed NFC transactions from the persisted raw block hex.
  ///
  /// The raw blocks are stored instead of the parsed objects so the serialized
  /// format stays stable even if parser details evolve later.
  List<NfcTransaction> get transactions {
    return transactionBlocksHex
        .map(_hexToBytes)
        .map(NfcTransactionParser.parseTransactionBlock)
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'idm': idm,
      'scannedAt': scannedAt.toIso8601String(),
      'currentBalance': currentBalance,
      'rawResponse1Hex': rawResponse1Hex,
      'rawResponse2Hex': rawResponse2Hex,
      'transactionBlocksHex': transactionBlocksHex,
    };
  }
}

/// Persisted record that links a server card number to an NFC IDm.
final class LinkedCardRecord {
  const LinkedCardRecord({
    required this.accountId,
    required this.cardNumber,
    required this.createdAt,
    required this.updatedAt,
    this.linkedIdm,
    this.serverSnapshot,
    this.nfcSnapshot,
  });

  final String accountId;
  final String cardNumber;
  final String? linkedIdm;
  final ServerCardSnapshot? serverSnapshot;
  final NfcCardSnapshot? nfcSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get storageKey => _storageKeyFor(accountId, cardNumber);

  factory LinkedCardRecord.fromJson(Map<String, dynamic> json) {
    return LinkedCardRecord(
      accountId: json['accountId'] as String,
      cardNumber: json['cardNumber'] as String,
      linkedIdm: json['linkedIdm'] as String?,
      serverSnapshot: json['serverSnapshot'] == null
          ? null
          : ServerCardSnapshot.fromJson(
              json['serverSnapshot'] as Map<String, dynamic>,
            ),
      nfcSnapshot: json['nfcSnapshot'] == null
          ? null
          : NfcCardSnapshot.fromJson(
              json['nfcSnapshot'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Returns a shallow copy while allowing either snapshot/link to be replaced
  /// or explicitly cleared.
  LinkedCardRecord copyWith({
    String? linkedIdm,
    bool clearLinkedIdm = false,
    ServerCardSnapshot? serverSnapshot,
    bool clearServerSnapshot = false,
    NfcCardSnapshot? nfcSnapshot,
    bool clearNfcSnapshot = false,
    DateTime? updatedAt,
  }) {
    return LinkedCardRecord(
      accountId: accountId,
      cardNumber: cardNumber,
      linkedIdm: clearLinkedIdm ? null : linkedIdm ?? this.linkedIdm,
      serverSnapshot:
          clearServerSnapshot ? null : serverSnapshot ?? this.serverSnapshot,
      nfcSnapshot: clearNfcSnapshot ? null : nfcSnapshot ?? this.nfcSnapshot,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'cardNumber': cardNumber,
      'linkedIdm': linkedIdm,
      'serverSnapshot': serverSnapshot?.toJson(),
      'nfcSnapshot': nfcSnapshot?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String _storageKeyFor(String accountId, String cardNumber) {
    return '$accountId::$cardNumber';
  }
}

/// Where an activity came from after merge resolution.
enum CardActivitySource { server, nfc }

enum CardActivityKind {
  trip,
  issue,
  recharge,
  fine,
  balanceUpdate,
  unknown,
}

enum CardActivityPhase {
  boarding,
  alighting,
  trip,
  balanceUpdate,
  issue,
  recharge,
  fine,
  unknown,
}

enum CardActivityService {
  dhakaMetroLine6,
  hatirjheelCircularBus,
  rapidPassBalanceSystem,
  rapidPassCardSystem,
  unknown,
}

extension on CardActivityKind {
  String get label => switch (this) {
        CardActivityKind.trip => 'Trip',
        CardActivityKind.issue => 'Issue',
        CardActivityKind.recharge => 'Recharge',
        CardActivityKind.fine => 'Fine',
        CardActivityKind.balanceUpdate => 'Balance Update',
        CardActivityKind.unknown => 'Unknown',
      };
}

extension on CardActivityPhase {
  String get label => switch (this) {
        CardActivityPhase.boarding => 'Boarding',
        CardActivityPhase.alighting => 'Alighting',
        CardActivityPhase.trip => 'Trip',
        CardActivityPhase.balanceUpdate => 'Balance Update',
        CardActivityPhase.issue => 'Issue',
        CardActivityPhase.recharge => 'Recharge',
        CardActivityPhase.fine => 'Fine',
        CardActivityPhase.unknown => 'Unknown',
      };
}

extension on CardActivityService {
  String get label => switch (this) {
        CardActivityService.dhakaMetroLine6 => 'MRT Line 6',
        CardActivityService.hatirjheelCircularBus => 'Hatirjheel Circular Bus',
        CardActivityService.rapidPassBalanceSystem =>
          'Rapid Pass Balance System',
        CardActivityService.rapidPassCardSystem => 'Rapid Pass Card System',
        CardActivityService.unknown => 'Unknown Service',
      };
}

CardActivityKind _kindFromServerTransactionType(TransactionType type) {
  return switch (type) {
    TransactionType.trip => CardActivityKind.trip,
    TransactionType.issue => CardActivityKind.issue,
    TransactionType.recharge => CardActivityKind.recharge,
    TransactionType.fine => CardActivityKind.fine,
    TransactionType.unknown => CardActivityKind.unknown,
  };
}

CardActivityKind _kindFromNfcPhase(NfcEventPhase phase) {
  return switch (phase) {
    TripPhase() || BoardingPhase() || AlightingPhase() => CardActivityKind.trip,
    BalanceUpdatePhase() => CardActivityKind.balanceUpdate,
    IssuePhase() => CardActivityKind.issue,
    UnknownPhase() => CardActivityKind.unknown,
  };
}

CardActivityPhase _phaseFromServerTransactionType(TransactionType type) {
  return switch (type) {
    TransactionType.trip => CardActivityPhase.trip,
    TransactionType.issue => CardActivityPhase.issue,
    TransactionType.recharge => CardActivityPhase.recharge,
    TransactionType.fine => CardActivityPhase.fine,
    TransactionType.unknown => CardActivityPhase.unknown,
  };
}

CardActivityPhase _phaseFromNfcPhase(NfcEventPhase phase) {
  return switch (phase) {
    BoardingPhase() => CardActivityPhase.boarding,
    AlightingPhase() => CardActivityPhase.alighting,
    TripPhase() => CardActivityPhase.trip,
    BalanceUpdatePhase() => CardActivityPhase.balanceUpdate,
    IssuePhase() => CardActivityPhase.issue,
    UnknownPhase() => CardActivityPhase.unknown,
  };
}

CardActivityService? _serviceFromRouteIndex(int? routeIndex) {
  return switch (routeIndex) {
    5 => CardActivityService.dhakaMetroLine6,
    6 => CardActivityService.hatirjheelCircularBus,
    _ => null,
  };
}

CardActivityService _serviceFromNfcServiceName(NfcServiceName serviceName) {
  return switch (serviceName) {
    DhakaMetroLine6Service() => CardActivityService.dhakaMetroLine6,
    HatirjheelCircularBusService() => CardActivityService.hatirjheelCircularBus,
    RapidPassBalanceService() => CardActivityService.rapidPassBalanceSystem,
    RapidPassCardSystemService() => CardActivityService.rapidPassCardSystem,
    UnknownNfcService() => CardActivityService.unknown,
  };
}

/// Unified transaction model consumed by merged card views.
///
/// Both server transactions and NFC transactions are normalized into this
/// shape so the widgets can render a single list without caring about the
/// original transport source.
final class CardActivity {
  const CardActivity({
    required this.timestamp,
    required this.source,
    required this.kind,
    required this.balanceAfter,
    this.charge,
    this.origin,
    this.destination,
    this.routeIndex,
    this.originStationIndex,
    this.destinationStationIndex,
    this.service,
    required this.phase,
  });

  final DateTime timestamp;
  final CardActivitySource source;
  final CardActivityKind kind;
  final double? charge;
  final double balanceAfter;
  final String? origin;
  final String? destination;
  final int? routeIndex;
  final int? originStationIndex;
  final int? destinationStationIndex;
  final CardActivityService? service;
  final CardActivityPhase phase;

  String get title => kind.label;
  String? get serviceName => service?.label;
  String get eventPhase => phase.label;

  /// Builds a UI-facing activity from a server transaction.
  ///
  /// This also attempts to infer canonical route/station IDs from the server's
  /// localized station strings so server and NFC records can share icon,
  /// localization, and matching logic.
  factory CardActivity.fromServerTransaction(Transaction transaction) {
    final originReference = _resolveServerStationReference(
      transaction.originStation,
    );
    final destinationReference = _resolveServerStationReference(
      transaction.destinationStation,
    );
    final routeIndex =
        originReference?.routeIndex ?? destinationReference?.routeIndex;

    return CardActivity(
      timestamp: transaction.timeStamp,
      source: CardActivitySource.server,
      kind: _kindFromServerTransactionType(transaction.type),
      charge: transaction.charge,
      balanceAfter: transaction.balance,
      origin: transaction.originStation,
      destination: transaction.destinationStation,
      routeIndex: routeIndex,
      originStationIndex: originReference?.stationIndex,
      destinationStationIndex: destinationReference?.stationIndex,
      service: _serviceFromRouteIndex(routeIndex),
      phase: _phaseFromServerTransactionType(transaction.type),
    );
  }

  /// Builds a UI-facing activity from a parsed NFC transaction.
  ///
  /// [charge] is optional because many NFC events do not contain an explicit
  /// defensible fare amount. When absent, the UI should treat the value as
  /// informational rather than exact.
  factory CardActivity.fromNfcTransactionWithCharge(
    NfcTransaction transaction, {
    double? charge,
  }) {
    return CardActivity(
      timestamp: transaction.timestamp,
      source: CardActivitySource.nfc,
      kind: _kindFromNfcPhase(transaction.eventPhase),
      charge: charge,
      balanceAfter: transaction.balance.toDouble(),
      origin: _fallbackStationName(
        stationIndex: transaction.fromStationIndex,
        rawCode: transaction.fromStationRawCode,
      ),
      destination: _fallbackStationName(
        stationIndex: transaction.toStationIndex,
        rawCode: transaction.toStationRawCode,
      ),
      routeIndex: transaction.routeIndex,
      originStationIndex: transaction.fromStationIndex,
      destinationStationIndex: transaction.toStationIndex,
      service: _serviceFromNfcServiceName(transaction.serviceName),
      phase: _phaseFromNfcPhase(transaction.eventPhase),
    );
  }

  static String? _fallbackStationName({
    required int? stationIndex,
    required int rawCode,
  }) {
    if (stationIndex == null) {
      return 'Unknown ($rawCode)';
    }
    return null;
  }
}

/// UI-facing merged card state derived from server and NFC snapshots.
///
/// This is the main projection used by the cards screen. It keeps server card
/// identity fields, computes whether the server snapshot is stale relative to
/// the latest NFC scan, and appends only unmatched NFC activities to the
/// server-provided history.
final class MergedTransitCard {
  const MergedTransitCard({
    required this.accountId,
    required this.cardNumber,
    required this.name,
    required this.hexCardNo,
    required this.cardType,
    required this.serverStatus,
    required this.effectiveBalance,
    required this.effectiveActivities,
    required this.isLinked,
    required this.isServerStale,
    required this.nfcGapFillCount,
    this.linkedIdm,
  });

  final String accountId;
  final String cardNumber;
  final String name;
  final String hexCardNo;
  final String cardType;
  final String serverStatus;
  final double effectiveBalance;
  final List<CardActivity> effectiveActivities;
  final bool isLinked;
  final bool isServerStale;
  final int nfcGapFillCount;
  final String? linkedIdm;

  /// Whether any NFC-only activities were appended after server/NFC matching.
  bool get hasNfcGapFill => nfcGapFillCount > 0;

  factory MergedTransitCard.fromRecord(LinkedCardRecord record) {
    final serverCard = record.serverSnapshot?.card;
    final lastServerFetchAt = record.serverSnapshot?.fetchedAt;
    final lastNfcScanAt = record.nfcSnapshot?.scannedAt;
    final isServerStale = lastNfcScanAt != null &&
        (lastServerFetchAt == null || lastNfcScanAt.isAfter(lastServerFetchAt));
    final serverActivities =
        (serverCard?.getFormattedTransactions() ?? const <Transaction>[])
            .map(CardActivity.fromServerTransaction)
            .toList();
    final nfcActivities = record.nfcSnapshot == null
        ? <CardActivity>[]
        : _buildNfcActivities(record.nfcSnapshot!.transactions);
    final unmatchedNfcActivities = _buildUnmatchedNfcActivities(
      serverActivities: serverActivities,
      nfcActivities: nfcActivities,
    );

    final effectiveBalance = isServerStale && record.nfcSnapshot != null
        ? record.nfcSnapshot!.currentBalance.toDouble()
        : double.tryParse(serverCard?.balance ?? '') ??
            record.nfcSnapshot?.currentBalance.toDouble() ??
            0.0;

    final effectiveActivities = <CardActivity>[
      ...serverActivities,
      ...unmatchedNfcActivities,
    ];
    effectiveActivities.sort(
      (left, right) => right.timestamp.compareTo(left.timestamp),
    );

    return MergedTransitCard(
      accountId: record.accountId,
      cardNumber: record.cardNumber,
      name: serverCard?.name ?? record.cardNumber,
      hexCardNo: serverCard?.hexCardNo ?? '',
      cardType: serverCard?.cardType ?? '',
      serverStatus: serverCard?.serverStatus ?? '',
      effectiveBalance: effectiveBalance,
      effectiveActivities: effectiveActivities,
      isLinked: record.linkedIdm != null,
      isServerStale: isServerStale,
      nfcGapFillCount: unmatchedNfcActivities.length,
      linkedIdm: record.linkedIdm,
    );
  }
}

/// Aggregated merged cards for the full home/cards experience.
final class MergedCardCollection {
  const MergedCardCollection({
    required this.allCards,
    required this.allActivities,
    required this.totalBalance,
  });

  final List<MergedTransitCard> allCards;
  final List<CardActivity> allActivities;
  final double totalBalance;
}

/// Converts parsed NFC history into [CardActivity] entries and derives a
/// conservative amount when the adjacent-balance delta looks trustworthy.
List<CardActivity> _buildNfcActivities(List<NfcTransaction> transactions) {
  final activities = <CardActivity>[];

  for (var i = 0; i < transactions.length; i++) {
    final current = transactions[i];
    final older = i + 1 < transactions.length ? transactions[i + 1] : null;
    activities.add(
      CardActivity.fromNfcTransactionWithCharge(
        current,
        charge: _estimateNfcCharge(
          current: current,
          older: older,
        ),
      ),
    );
  }

  return activities;
}

/// Returns only the NFC activities that are safe to append on top of the
/// server history for a card.
///
/// This is intentionally server-first: if an NFC activity appears to match a
/// server transaction, the server copy wins and the NFC copy is dropped.
List<CardActivity> _buildUnmatchedNfcActivities({
  required List<CardActivity> serverActivities,
  required List<CardActivity> nfcActivities,
}) {
  final surfaceableNfcActivities =
      nfcActivities.where(_shouldSurfaceNfcActivity).toList();

  if (serverActivities.isEmpty) {
    return List<CardActivity>.from(surfaceableNfcActivities);
  }

  return surfaceableNfcActivities
      .where(
        (nfcActivity) => !serverActivities.any(
          (serverActivity) => _matchesServerActivity(
            serverActivity,
            nfcActivity,
          ),
        ),
      )
      .toList();
}

/// Fuzzy matcher used to decide whether an NFC record is already represented
/// by a server transaction.
///
/// Matching is conservative because NFC timestamps are only precise to the
/// hour. A candidate match must agree on hour, broad phase, station pair, and
/// ending balance.
bool _matchesServerActivity(
  CardActivity serverActivity,
  CardActivity nfcActivity,
) {
  if (!_sameCalendarHour(serverActivity.timestamp, nfcActivity.timestamp)) {
    return false;
  }

  if (!_phasesLookCompatible(serverActivity, nfcActivity)) {
    return false;
  }

  if (!_stationsLookCompatible(
    serverActivity.origin,
    nfcActivity.origin,
    routeIndex: nfcActivity.routeIndex,
    stationIndex: nfcActivity.originStationIndex,
  )) {
    return false;
  }

  if (!_stationsLookCompatible(
    serverActivity.destination,
    nfcActivity.destination,
    routeIndex: nfcActivity.routeIndex,
    stationIndex: nfcActivity.destinationStationIndex,
  )) {
    return false;
  }

  if (!_balancesLookCompatible(
    serverActivity.balanceAfter,
    nfcActivity.balanceAfter,
  )) {
    return false;
  }

  return true;
}

/// NFC timestamps currently resolve only to the hour, so hour-level comparison
/// is the strongest reliable time signal available for deduplication.
bool _sameCalendarHour(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day &&
      left.hour == right.hour;
}

/// Compares coarse event categories between server and NFC records.
///
/// Server and NFC do not use the same event model, so this intentionally maps
/// multiple NFC phases like boarding/alighting onto the broader server `trip`
/// concept.
bool _phasesLookCompatible(
  CardActivity serverActivity,
  CardActivity nfcActivity,
) {
  return switch (nfcActivity.phase) {
    CardActivityPhase.balanceUpdate =>
      serverActivity.kind == CardActivityKind.recharge ||
          serverActivity.charge == null,
    CardActivityPhase.issue => serverActivity.kind == CardActivityKind.issue,
    CardActivityPhase.trip ||
    CardActivityPhase.boarding ||
    CardActivityPhase.alighting =>
      serverActivity.kind == CardActivityKind.trip ||
          (serverActivity.charge != null && serverActivity.charge! < 0),
    _ => false,
  };
}

/// Compares station strings after normalizing them into a shared namespace.
///
/// If either side does not have a trustworthy station value, the location check
/// becomes permissive so it does not incorrectly reject a likely match.
bool _stationsLookCompatible(
  String? serverStation,
  String? nfcStation, {
  required int? routeIndex,
  required int? stationIndex,
}) {
  final canonicalNfcStation = routeIndex != null && stationIndex != null
      ? TransportRouteLocalizations.englishStationName(routeIndex, stationIndex)
      : nfcStation;

  if (!_isKnownLocation(serverStation) ||
      !_isKnownLocation(canonicalNfcStation)) {
    return true;
  }

  return _normalizeLocation(serverStation!) ==
      _normalizeLocation(canonicalNfcStation!);
}

/// Uses rounded balance-after values because both server and NFC are intended
/// to represent the same post-transaction stored balance.
bool _balancesLookCompatible(double serverBalance, double nfcBalance) {
  return serverBalance.round() == nfcBalance.round();
}

/// Tries to infer a fare or top-up amount from adjacent NFC balance snapshots.
///
/// This stays intentionally conservative:
/// - trip deltas must be negative and small enough to look like a fare
/// - balance updates must be positive and small enough to look like a top-up
/// - ambiguous events return `null`
double? _estimateNfcCharge({
  required NfcTransaction current,
  required NfcTransaction? older,
}) {
  if (older == null) {
    return null;
  }

  final delta = current.balance - older.balance;
  return switch (current.eventPhase) {
    TripPhase() when delta < 0 && delta.abs() <= 200 => delta.toDouble(),
    BalanceUpdatePhase() when delta > 0 && delta <= 5000 => delta.toDouble(),
    _ => null,
  };
}

/// Filters NFC activities to the subset that is meaningful in the main history
/// view. Start-only transport events are kept out to avoid noisy duplicates.
bool _shouldSurfaceNfcActivity(CardActivity activity) {
  if (activity.source != CardActivitySource.nfc) {
    return true;
  }

  return switch (activity.phase) {
    CardActivityPhase.trip ||
    CardActivityPhase.alighting ||
    CardActivityPhase.balanceUpdate ||
    CardActivityPhase.issue =>
      true,
    _ => false,
  };
}

bool _isKnownLocation(String? value) {
  return value != null &&
      value.isNotEmpty &&
      !value.toLowerCase().startsWith('unknown');
}

/// Best-effort lookup table for converting server station strings into route
/// and station IDs already used elsewhere in the app.
///
/// Server responses only expose strings, so this lookup allows the merge layer
/// to recover canonical route metadata for icons, localization, and matching.
StationReference? _resolveServerStationReference(String? stationName) {
  if (!_isKnownLocation(stationName)) {
    return null;
  }

  final normalizedStationName = _normalizeLocation(stationName!);

  for (final routeEntry in transportRoutes.entries) {
    final routeIndex = routeEntry.key;
    final stationIndices = routeEntry.value.stations;

    for (final stationIndex in stationIndices) {
      final englishName = TransportRouteLocalizations.englishStationName(
        routeIndex,
        stationIndex,
      );
      if (englishName == null) {
        continue;
      }

      if (_normalizeLocation(englishName) == normalizedStationName) {
        return StationReference(
          routeIndex: routeIndex,
          stationIndex: stationIndex,
        );
      }
    }
  }

  return null;
}

String _normalizeLocation(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s*\(hj\)$'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
  return normalized;
}

/// Localizes one activity endpoint using route/station IDs when available,
/// falling back to the stored raw English station string otherwise.
String localizeActivityStation(
  TransportRouteLocalizations localizations,
  CardActivity activity, {
  required bool destination,
}) {
  final stationIndex = destination
      ? activity.destinationStationIndex
      : activity.originStationIndex;
  final fallback = destination ? activity.destination : activity.origin;
  final localized = localizations.translateOptional(
    activity.routeIndex,
    stationIndex,
  );
  final translatedFallback = fallback == null
      ? null
      : localizations.translateFromLocale(fallback, 'en') ?? fallback;
  return localized ?? translatedFallback ?? 'Unknown';
}

/// Localizes the transport route/service name for an activity.
String? localizeActivityRouteName(
  TransportRouteLocalizations localizations,
  CardActivity activity,
) {
  if (activity.routeIndex == null) {
    return activity.serviceName;
  }
  return localizations.translateOptionalRouteName(activity.routeIndex) ??
      activity.serviceName;
}

/// Localizes higher-level service names that are not route-backed, such as
/// balance-system and card-system events.
String? localizeActivityServiceName(
  AppLocalizations appLocalizations,
  TransportRouteLocalizations routeLocalizations,
  CardActivity activity,
) {
  if (activity.routeIndex != null) {
    return localizeActivityRouteName(routeLocalizations, activity);
  }

  return switch (activity.service) {
    CardActivityService.rapidPassBalanceSystem =>
      appLocalizations.rapidPassBalanceSystem,
    CardActivityService.rapidPassCardSystem =>
      appLocalizations.rapidPassCardSystem,
    CardActivityService.unknown => appLocalizations.unknownService,
    CardActivityService.dhakaMetroLine6 ||
    CardActivityService.hatirjheelCircularBus =>
      activity.serviceName,
    null => null,
  };
}

/// Localizes coarse event phases for merged activities.
String? localizeActivityEventPhase(
  AppLocalizations appLocalizations,
  CardActivity activity,
) {
  return switch (activity.phase) {
    CardActivityPhase.boarding => appLocalizations.boarding,
    CardActivityPhase.alighting => appLocalizations.alighting,
    CardActivityPhase.trip => appLocalizations.trip,
    CardActivityPhase.balanceUpdate => appLocalizations.balanceUpdate,
    CardActivityPhase.issue => appLocalizations.issue,
    CardActivityPhase.recharge => appLocalizations.recharge,
    CardActivityPhase.fine => 'Fine',
    CardActivityPhase.unknown => appLocalizations.unknown,
  };
}

/// Decodes a space-separated uppercase hex string back into integer bytes.
List<int> _hexStringToIntList(String value) {
  if (value.isEmpty) {
    return const [];
  }

  return value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => int.parse(part, radix: 16))
      .toList(growable: false);
}

Uint8List _hexToBytes(String value) {
  return Uint8List.fromList(_hexStringToIntList(value));
}

/// Serializes linked card records for local persistence.
String encodeLinkedCardRecords(List<LinkedCardRecord> records) {
  return jsonEncode(records.map((record) => record.toJson()).toList());
}

/// Restores linked card records from the repository persistence payload.
List<LinkedCardRecord> decodeLinkedCardRecords(String value) {
  final decoded = jsonDecode(value) as List<dynamic>;
  return decoded
      .map((item) => LinkedCardRecord.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
}
