import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rapid_pass_info/constants/transport_routes/hatirjheel_bus.dart';
import 'package:rapid_pass_info/constants/transport_routes/line_6.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_felica/nfc_manager_felica.dart';

/// Domain-level classification for known Rapid Pass / MRT transaction headers.
///
/// The raw card data exposes a 4-byte fixed header per 16-byte block. This
/// maps the headers observed in the reference implementation to stable Dart
/// types so UI and persistence code do not need to compare hex strings.
sealed class NfcTransactionType {
  const NfcTransactionType();

  /// Maps a 4-byte fixed header rendered as uppercase hex to a known type.
  static NfcTransactionType fromHeader(String fixedHeader) {
    return switch (fixedHeader) {
      "42 D6 30 00" => const CommuteHatirjheelBusEnd(),
      "08 D2 20 00" => const CommuteHatirjheelBusStart(),
      "08 52 10 00" => const CommuteDhakaMetro(),
      "44 20 02 01" => const CardIssueRecord(),
      "1D 60 02 01" => const BalanceUpdate(),
      "42 60 02 00" => const BalanceUpdate(),
      _ => const CommuteUnknown(),
    };
  }
}

final class CommuteHatirjheelBusStart extends NfcTransactionType {
  const CommuteHatirjheelBusStart();
}

final class CommuteHatirjheelBusEnd extends NfcTransactionType {
  const CommuteHatirjheelBusEnd();
}

final class CommuteDhakaMetro extends NfcTransactionType {
  const CommuteDhakaMetro();
}

final class CommuteUnknown extends NfcTransactionType {
  const CommuteUnknown();
}

final class BalanceUpdate extends NfcTransactionType {
  const BalanceUpdate();
}

final class CardIssueRecord extends NfcTransactionType {
  const CardIssueRecord();
}

/// Inferred transport service derived from a known transaction header.
sealed class NfcServiceName {
  const NfcServiceName();

  String get label;

  static NfcServiceName fromTransactionType(NfcTransactionType type) {
    return switch (type) {
      CommuteDhakaMetro() => const DhakaMetroLine6Service(),
      CommuteHatirjheelBusStart() ||
      CommuteHatirjheelBusEnd() =>
        const HatirjheelCircularBusService(),
      CardIssueRecord() => const RapidPassCardSystemService(),
      BalanceUpdate() => const RapidPassBalanceService(),
      CommuteUnknown() => const UnknownNfcService(),
    };
  }
}

final class DhakaMetroLine6Service extends NfcServiceName {
  const DhakaMetroLine6Service();

  @override
  String get label => 'MRT Line 6';
}

final class HatirjheelCircularBusService extends NfcServiceName {
  const HatirjheelCircularBusService();

  @override
  String get label => 'Hatirjheel Circular Bus';
}

final class RapidPassBalanceService extends NfcServiceName {
  const RapidPassBalanceService();

  @override
  String get label => 'Rapid Pass Balance System';
}

final class RapidPassCardSystemService extends NfcServiceName {
  const RapidPassCardSystemService();

  @override
  String get label => 'Rapid Pass Card System';
}

final class UnknownNfcService extends NfcServiceName {
  const UnknownNfcService();

  @override
  String get label => 'Unknown Service';
}

/// Inferred event phase derived from a known transaction header.
sealed class NfcEventPhase {
  const NfcEventPhase();

  String get label;

  static NfcEventPhase fromTransactionType(NfcTransactionType type) {
    return switch (type) {
      CommuteHatirjheelBusStart() => const BoardingPhase(),
      CommuteHatirjheelBusEnd() => const AlightingPhase(),
      CommuteDhakaMetro() => const TripPhase(),
      CardIssueRecord() => const IssuePhase(),
      BalanceUpdate() => const BalanceUpdatePhase(),
      CommuteUnknown() => const UnknownPhase(),
    };
  }
}

final class BoardingPhase extends NfcEventPhase {
  const BoardingPhase();

  @override
  String get label => 'Boarding';
}

final class AlightingPhase extends NfcEventPhase {
  const AlightingPhase();

  @override
  String get label => 'Alighting';
}

final class TripPhase extends NfcEventPhase {
  const TripPhase();

  @override
  String get label => 'Trip';
}

final class BalanceUpdatePhase extends NfcEventPhase {
  const BalanceUpdatePhase();

  @override
  String get label => 'Balance Update';
}

final class IssuePhase extends NfcEventPhase {
  const IssuePhase();

  @override
  String get label => 'Issue';
}

final class UnknownPhase extends NfcEventPhase {
  const UnknownPhase();

  @override
  String get label => 'Unknown';
}

/// Public scan state emitted by [RapidPassNfcService].
///
/// This mirrors the state model from the original Android/KMP implementation:
/// unsupported, disabled, waiting, reading, success, and failure.
sealed class CardState {
  const CardState();
}

final class Balance extends CardState {
  const Balance(this.amount);

  final int amount;
}

final class WaitingForTap extends CardState {
  const WaitingForTap();
}

final class Reading extends CardState {
  const Reading();
}

final class ErrorState extends CardState {
  const ErrorState(this.message);

  final String message;
}

final class NoNfcSupport extends CardState {
  const NoNfcSupport();
}

final class NfcDisabled extends CardState {
  const NfcDisabled();
}

/// A parsed 16-byte history block from the card.
///
/// The parser keeps both the raw protocol-derived fields and a higher-level
/// [transactionKind] classification for downstream use.
final class NfcTransaction {
  const NfcTransaction({
    required this.fixedHeader,
    required this.timestamp,
    required this.transactionType,
    required this.transactionKind,
    required this.serviceName,
    required this.eventPhase,
    required this.routeIndex,
    required this.fromStationIndex,
    required this.toStationIndex,
    required this.fromStationRawCode,
    required this.toStationRawCode,
    required this.balance,
    required this.trailing,
    required this.rawBlock,
  });

  final String fixedHeader;
  final DateTime timestamp;
  final String transactionType;
  final NfcTransactionType transactionKind;
  final NfcServiceName serviceName;
  final NfcEventPhase eventPhase;
  final int? routeIndex;
  final int? fromStationIndex;
  final int? toStationIndex;
  final int fromStationRawCode;
  final int toStationRawCode;
  final int balance;
  final String trailing;
  final Uint8List rawBlock;
}

/// Convenience wrapper for history UIs that compute a per-row fare delta.
final class TransactionWithAmount {
  const TransactionWithAmount({
    required this.transaction,
    this.amount,
  });

  final NfcTransaction transaction;
  final int? amount;
}

/// Full result of a successful NFC read session.
///
/// [idm] is the FeliCa card identifier rendered as uppercase hex bytes.
/// [transactions] are returned newest-first, matching the existing parser flow.
final class CardReadResult {
  const CardReadResult({
    required this.idm,
    required this.transactions,
    required this.rawResponse1,
    required this.rawResponse2,
  });

  final String idm;
  final List<NfcTransaction> transactions;
  final Uint8List rawResponse1;
  final Uint8List rawResponse2;

  int? get currentBalance =>
      transactions.isEmpty ? null : transactions.first.balance;
}

/// Generates the exact FeliCa `Read Without Encryption` command packet used by
/// the prior native implementation.
///
/// The command targets service code `0x220F` by default and reads 10 blocks at a
/// time, which matches the two-batch Android strategy: blocks `0..9` then
/// `10..19`.
final class NfcCommandGenerator {
  const NfcCommandGenerator();

  /// Builds a raw FeliCa command including the leading packet-length byte.
  Uint8List generateReadCommand({
    required Uint8List idm,
    int serviceCode = 0x220F,
    int numberOfBlocksToRead = 10,
    int startBlockNumber = 0,
  }) {
    final serviceCodeList = [
      serviceCode & 0xFF,
      (serviceCode >> 8) & 0xFF,
    ];

    final blockListElements = List<int>.filled(numberOfBlocksToRead * 2, 0);
    for (var i = 0; i < numberOfBlocksToRead; i++) {
      blockListElements[i * 2] = 0x80;
      blockListElements[i * 2 + 1] = startBlockNumber + i;
    }

    final commandLength = 14 + blockListElements.length;
    final command = Uint8List(commandLength);
    var idx = 0;

    command[idx++] = commandLength;
    command[idx++] = 0x06;

    for (final byte in idm) {
      command[idx++] = byte;
    }

    command[idx++] = 0x01;
    command[idx++] = serviceCodeList[0];
    command[idx++] = serviceCodeList[1];
    command[idx++] = numberOfBlocksToRead;

    for (final byte in blockListElements) {
      command[idx++] = byte;
    }

    return command;
  }
}

/// Byte-level helpers ported from the original parser.
///
/// The card format mixes endian conventions, so these helpers keep the parsing
/// logic explicit and testable.
final class ByteParser {
  static const String _hexChars = "0123456789ABCDEF";

  static String toHexString(List<int> bytes) {
    return bytes.map((byte) {
      final unsigned = byte & 0xFF;
      final highNibble = _hexChars[unsigned >> 4];
      final lowNibble = _hexChars[unsigned & 0x0F];
      return "$highNibble$lowNibble";
    }).join(' ');
  }

  static int extractInt16(List<int> bytes, [int offset = 0]) {
    return ((bytes[offset + 1] & 0xFF) << 8) | (bytes[offset] & 0xFF);
  }

  static int extractInt24(List<int> bytes, [int offset = 0]) {
    return ((bytes[offset + 2] & 0xFF) << 16) |
        ((bytes[offset + 1] & 0xFF) << 8) |
        (bytes[offset] & 0xFF);
  }

  static int extractByte(List<int> bytes, int offset) {
    return bytes[offset] & 0xFF;
  }

  static int extractInt24BigEndian(List<int> bytes, [int offset = 0]) {
    return ((bytes[offset] & 0xFF) << 16) |
        ((bytes[offset + 1] & 0xFF) << 8) |
        (bytes[offset + 2] & 0xFF);
  }
}

/// Station-code lookup used by the card history parser.
///
/// Station codes are transport-specific. The same numeric code can refer to
/// different places on Dhaka Metro and Hatirjheel bus records, so lookup must
/// be done with the parsed [NfcTransactionType], not with a single global map.
final class StationReference {
  const StationReference({
    required this.routeIndex,
    required this.stationIndex,
  });

  final int routeIndex;
  final int stationIndex;
}

final class StationService {
  static const Map<int, StationReference> _dhakaMetroStationMap = {
    10: StationReference(routeIndex: 5, stationIndex: Line6Station.motijheel),
    20: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.bangladeshSecretariat,
    ),
    25: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.dhakaUniversity,
    ),
    30: StationReference(routeIndex: 5, stationIndex: Line6Station.shahbagh),
    35: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.karwanBazar,
    ),
    40: StationReference(routeIndex: 5, stationIndex: Line6Station.farmgate),
    45: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.bijoySarani,
    ),
    50: StationReference(routeIndex: 5, stationIndex: Line6Station.agargaon),
    55: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.shewrapara,
    ),
    60: StationReference(routeIndex: 5, stationIndex: Line6Station.kazipara),
    65: StationReference(routeIndex: 5, stationIndex: Line6Station.mirpur10),
    70: StationReference(routeIndex: 5, stationIndex: Line6Station.mirpur11),
    75: StationReference(routeIndex: 5, stationIndex: Line6Station.pallabi),
    80: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.uttaraSouth,
    ),
    85: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.uttaraCenter,
    ),
    90: StationReference(
      routeIndex: 5,
      stationIndex: Line6Station.uttaraNorth,
    ),
  };

  static const Map<int, StationReference> _hatirJheelBusStationMap = {
    10: StationReference(
      routeIndex: 6,
      stationIndex: HatirjheelBus.modhubag,
    ),
    13: StationReference(
      routeIndex: 6,
      stationIndex: HatirjheelBus.mohanagar,
    ),
    16: StationReference(
      routeIndex: 6,
      stationIndex: HatirjheelBus.rampura,
    ),
    17: StationReference(routeIndex: 6, stationIndex: HatirjheelBus.badda),
    19: StationReference(
      routeIndex: 6,
      stationIndex: HatirjheelBus.policePlaza,
    ),
    22: StationReference(
      routeIndex: 6,
      stationIndex: HatirjheelBus.kunipara,
    ),
    25: StationReference(
      routeIndex: 6,
      stationIndex: HatirjheelBus.bouBazar,
    ),
    28: StationReference(routeIndex: 6, stationIndex: HatirjheelBus.fdc),
  };

  static StationReference? getStationReference(
      int code, NfcTransactionType type) {
    return switch (type) {
      CommuteHatirjheelBusStart() ||
      CommuteHatirjheelBusEnd() =>
        _hatirJheelBusStationMap[code],
      CommuteDhakaMetro() => _dhakaMetroStationMap[code],
      BalanceUpdate() || CardIssueRecord() || CommuteUnknown() => null,
    };
  }
}

/// Decodes the packed timestamp format stored in Rapid Pass history blocks.
///
/// The card stores year, month, day, and hour in a compact 24-bit value.
/// Minutes are not present in the block format and are treated as zero.
final class TimestampService {
  /// Converts the 24-bit packed timestamp into a local [DateTime].
  static DateTime decodeTimestamp(int value) {
    final hour = (value >> 3) & 0x1F;
    final day = (value >> 8) & 0x1F;
    final month = (value >> 13) & 0x0F;
    final year = (value >> 17) & 0x1F;

    final fullYear = _baseYear() + year;
    final validMonth = month >= 1 && month <= 12 ? month : 1;
    final validDay = day >= 1 && day <= 31 ? day : 1;

    return DateTime(
      fullYear,
      validMonth,
      validDay,
      hour % 24,
    );
  }

  static int _baseYear() {
    final currentYear = DateTime.now().year;
    return currentYear - (currentYear % 100);
  }
}

/// Parses FeliCa read responses and 16-byte transaction blocks.
///
/// The parser follows the original implementation exactly:
/// - response status flags must both be `0x00`
/// - payload blocks are 16 bytes each
/// - transactions before 2020 are filtered out as invalid/noise
final class NfcTransactionParser {
  static final DateTime _cutoffDate = DateTime(2020, 1, 1);

  static bool _isValidTransaction(NfcTransaction transaction) {
    return transaction.timestamp.isAfter(_cutoffDate);
  }

  static List<NfcTransaction> parseTransactionResponse(List<int> response) {
    final transactions = <NfcTransaction>[];

    if (response.length < 13) {
      return transactions;
    }

    final statusFlag1 = response[10];
    final statusFlag2 = response[11];

    if (statusFlag1 != 0x00 || statusFlag2 != 0x00) {
      return transactions;
    }

    final numBlocks = response[12] & 0xFF;
    final blockData = response.sublist(13);
    const blockSize = 16;

    if (blockData.length < numBlocks * blockSize) {
      return transactions;
    }

    for (var i = 0; i < numBlocks; i++) {
      final offset = i * blockSize;
      final block = blockData.sublist(offset, offset + blockSize);
      final transaction = parseTransactionBlock(block);
      if (_isValidTransaction(transaction)) {
        transactions.add(transaction);
      }
    }

    return transactions;
  }

  /// Parses a single 16-byte history block into an [NfcTransaction].
  static NfcTransaction parseTransactionBlock(List<int> block) {
    if (block.length != 16) {
      throw ArgumentError('Invalid block size');
    }

    final fixedHeader = block.sublist(0, 4);
    final fixedHeaderStr = ByteParser.toHexString(fixedHeader);
    final transactionKind = NfcTransactionType.fromHeader(fixedHeaderStr);
    final serviceName = NfcServiceName.fromTransactionType(transactionKind);
    final eventPhase = NfcEventPhase.fromTransactionType(transactionKind);
    final timestampValue = ByteParser.extractInt24BigEndian(block, 4);
    final transactionTypeBytes = block.sublist(6, 8);
    final transactionType = ByteParser.toHexString(transactionTypeBytes);
    final fromStationCode = ByteParser.extractByte(block, 8);
    final toStationCode = ByteParser.extractByte(block, 10);
    final fromStationReference =
        StationService.getStationReference(fromStationCode, transactionKind);
    final toStationReference =
        StationService.getStationReference(toStationCode, transactionKind);
    final routeIndex =
        fromStationReference?.routeIndex ?? toStationReference?.routeIndex;
    final balance = ByteParser.extractInt24(block, 11);
    final trailingBytes = block.sublist(14, 16);

    return NfcTransaction(
      fixedHeader: fixedHeaderStr,
      timestamp: TimestampService.decodeTimestamp(timestampValue),
      transactionType: transactionType,
      transactionKind: transactionKind,
      serviceName: serviceName,
      eventPhase: eventPhase,
      routeIndex: routeIndex,
      fromStationIndex: fromStationReference?.stationIndex,
      toStationIndex: toStationReference?.stationIndex,
      fromStationRawCode: fromStationCode,
      toStationRawCode: toStationCode,
      balance: balance,
      trailing: ByteParser.toHexString(trailingBytes),
      rawBlock: Uint8List.fromList(block),
    );
  }
}

/// Android-only NFC transport/service for Rapid Pass card reads.
///
/// This service owns:
/// - NFC availability checks
/// - Android reader mode lifecycle
/// - adapter on/off monitoring
/// - FeliCa read execution
/// - mapping raw reads into [CardState] and [CardReadResult] streams
///
/// UI wiring is intentionally separate. Consumers can initialize the service
/// early, then call [startScan] when the relevant screen is ready to listen.
final class RapidPassNfcService extends ChangeNotifier
    with WidgetsBindingObserver {
  RapidPassNfcService._();

  /// Singleton instance used by the app.
  static final RapidPassNfcService instance = RapidPassNfcService._();

  static const _cardMovedTooFastMessage = "Card moved too fast";
  static const _failedToReadCardMessage = "Failed to read card";
  static const _unsupportedTagMessage = "Unsupported NFC-F tag";

  final _commandGenerator = const NfcCommandGenerator();
  final _cardStateController = StreamController<CardState>.broadcast();
  final _cardReadResultController =
      StreamController<CardReadResult?>.broadcast();

  StreamSubscription<NfcAdapterStateAndroid>? _adapterStateSubscription;
  CardState _cardState = const NoNfcSupport();
  CardReadResult? _lastReadResult;
  bool _initialized = false;
  bool _scanRequested = false;
  bool _readerModeEnabled = false;
  bool _isReading = false;

  /// Broadcast stream of high-level NFC state updates.
  Stream<CardState> get cardStateStream => _cardStateController.stream;

  /// Broadcast stream of successful card reads.
  Stream<CardReadResult?> get cardReadResultsStream =>
      _cardReadResultController.stream;

  /// Latest emitted NFC state.
  CardState get cardState => _cardState;

  /// Latest successful card read, if any.
  CardReadResult? get lastReadResult => _lastReadResult;

  /// Sets up lifecycle and adapter-state listeners without starting scanning.
  Future<void> initialize() async {
    await _ensureInitialized();
    await refreshAvailability();
  }

  /// Requests active scanning and enables Android NFC-F reader mode when
  /// available.
  Future<void> startScan() async {
    await _ensureInitialized();
    _scanRequested = true;
    await refreshAvailability();
  }

  /// Stops active scanning and disables reader mode.
  Future<void> stopScan() async {
    _scanRequested = false;
    await _disableReaderMode();
  }

  /// Returns whether this device supports NFC at all.
  Future<bool> isSupported() async {
    if (!_isAndroid) {
      return false;
    }

    final availability = await NfcManager.instance.checkAvailability();
    return availability != NfcAvailability.unsupported;
  }

  /// Returns whether NFC is currently enabled by the user/system.
  Future<bool> isEnabled() async {
    if (!_isAndroid) {
      return false;
    }

    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  /// Re-checks platform availability and emits the appropriate [CardState].
  Future<void> refreshAvailability() async {
    if (!_isAndroid) {
      _emitState(const NoNfcSupport());
      return;
    }

    final availability = await NfcManager.instance.checkAvailability();
    switch (availability) {
      case NfcAvailability.enabled:
        if (_scanRequested) {
          await _enableReaderMode();
        }
        if (_cardState is! Balance) {
          _emitState(const WaitingForTap());
        }
        return;
      case NfcAvailability.disabled:
        await _disableReaderMode();
        _emitState(const NfcDisabled());
        return;
      case NfcAvailability.unsupported:
        await _disableReaderMode();
        _emitState(const NoNfcSupport());
        return;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isAndroid) {
      return;
    }

    if (state == AppLifecycleState.resumed && _scanRequested) {
      unawaited(refreshAvailability());
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_disableReaderMode());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_adapterStateSubscription?.cancel());
    unawaited(_cardStateController.close());
    unawaited(_cardReadResultController.close());
    super.dispose();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    WidgetsBinding.instance.addObserver(this);

    if (_isAndroid) {
      _adapterStateSubscription =
          NfcManagerAndroid.instance.onStateChanged.listen(
        (state) {
          unawaited(_handleAdapterStateChanged(state));
        },
      );
    }
  }

  Future<void> _handleAdapterStateChanged(NfcAdapterStateAndroid state) async {
    switch (state) {
      case NfcAdapterStateAndroid.on:
        if (_scanRequested) {
          await _enableReaderMode();
        }
        if (_cardState is! Balance) {
          _emitState(const WaitingForTap());
        }
        return;
      case NfcAdapterStateAndroid.off:
        await _disableReaderMode();
        _emitState(const NfcDisabled());
        return;
      case NfcAdapterStateAndroid.turningOn:
      case NfcAdapterStateAndroid.turningOff:
        return;
    }
  }

  Future<void> _enableReaderMode() async {
    if (!_isAndroid || _readerModeEnabled) {
      return;
    }

    await NfcManagerAndroid.instance.enableReaderMode(
      flags: {
        NfcReaderFlagAndroid.nfcF,
        NfcReaderFlagAndroid.skipNdefCheck,
      },
      onTagDiscovered: (tag) {
        unawaited(_handleTagDiscovered(tag));
      },
    );
    _readerModeEnabled = true;
  }

  Future<void> _disableReaderMode() async {
    if (!_isAndroid || !_readerModeEnabled) {
      return;
    }

    await NfcManagerAndroid.instance.disableReaderMode();
    _readerModeEnabled = false;
  }

  Future<void> _handleTagDiscovered(NfcTag tag) async {
    if (_isReading) {
      return;
    }

    _isReading = true;
    _emitState(const Reading());

    try {
      final felica = FeliCa.from(tag);
      if (felica == null) {
        _emitState(const ErrorState(_unsupportedTagMessage));
        return;
      }

      final transactions = await _readTransactionHistory(felica);
      if (transactions.transactions.isEmpty) {
        _emitState(const ErrorState(_failedToReadCardMessage));
        return;
      }

      final result = CardReadResult(
        idm: ByteParser.toHexString(felica.idm),
        transactions: transactions.transactions,
        rawResponse1: transactions.response1,
        rawResponse2: transactions.response2,
      );
      _lastReadResult = result;
      _cardReadResultController.add(result);
      _emitState(Balance(result.currentBalance!));
    } on PlatformException catch (error) {
      _emitState(ErrorState(_mapPlatformError(error)));
    } catch (_) {
      _emitState(const ErrorState(_failedToReadCardMessage));
    } finally {
      _isReading = false;
    }
  }

  Future<RawCardReadResult> _readTransactionHistory(FeliCa felica) async {
    final transactions = <NfcTransaction>[];
    Uint8List? response1;
    Uint8List? response2;

    try {
      response1 = await _sendReadCommand(
        felica: felica,
        startBlockNumber: 0,
      );
      transactions.addAll(
        NfcTransactionParser.parseTransactionResponse(response1),
      );

      response2 = await _sendReadCommand(
        felica: felica,
        startBlockNumber: 10,
      );
      transactions.addAll(
        NfcTransactionParser.parseTransactionResponse(response2),
      );
    } on PlatformException {
      rethrow;
    } catch (_) {
      return RawCardReadResult(
        transactions: transactions,
        response1: response1 ?? Uint8List(0),
        response2: response2 ?? Uint8List(0),
      );
    }

    return RawCardReadResult(
      transactions: transactions,
      response1: response1,
      response2: response2,
    );
  }

  Future<Uint8List> _sendReadCommand({
    required FeliCa felica,
    required int startBlockNumber,
  }) async {
    final command = _commandGenerator.generateReadCommand(
      idm: felica.idm,
      startBlockNumber: startBlockNumber,
    );

    final response = await felica.sendFeliCaCommand(
      commandPacket: Uint8List.fromList(command.sublist(1)),
    );

    return Uint8List.fromList([response.length + 1, ...response]);
  }

  void _emitState(CardState state) {
    _cardState = state;
    _cardStateController.add(state);
    notifyListeners();
  }

  String _mapPlatformError(PlatformException error) {
    final message = error.message?.toLowerCase() ?? '';
    if (message.contains('lost') ||
        message.contains('timeout') ||
        message.contains('ioexception') ||
        message.contains('transceive')) {
      return _cardMovedTooFastMessage;
    }
    return _failedToReadCardMessage;
  }

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}

/// Combined result of raw transport bytes and parsed transactions.
final class RawCardReadResult {
  const RawCardReadResult({
    required this.transactions,
    required this.response1,
    required this.response2,
  });

  final List<NfcTransaction> transactions;
  final Uint8List response1;
  final Uint8List response2;
}
