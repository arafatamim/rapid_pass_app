import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_pass_info/constants/transport_routes/hatirjheel_bus.dart';
import 'package:rapid_pass_info/constants/transport_routes/line_6.dart';
import 'package:rapid_pass_info/services/nfc.dart';

void main() {
  group('NfcCommandGenerator', () {
    test('builds the expected read command', () {
      final generator = const NfcCommandGenerator();
      final command = generator.generateReadCommand(
        idm: Uint8List.fromList([
          0x01,
          0x02,
          0x03,
          0x04,
          0x05,
          0x06,
          0x07,
          0x08,
        ]),
      );

      expect(
        command,
        Uint8List.fromList([
          0x22,
          0x06,
          0x01,
          0x02,
          0x03,
          0x04,
          0x05,
          0x06,
          0x07,
          0x08,
          0x01,
          0x0F,
          0x22,
          0x0A,
          0x80,
          0x00,
          0x80,
          0x01,
          0x80,
          0x02,
          0x80,
          0x03,
          0x80,
          0x04,
          0x80,
          0x05,
          0x80,
          0x06,
          0x80,
          0x07,
          0x80,
          0x08,
          0x80,
          0x09,
        ]),
      );
    });
  });

  group('TimestampService', () {
    test('decodes the packed Dhaka MRT timestamp format', () {
      final encoded = _encodeTimestamp(
        year: 2026,
        month: 3,
        day: 12,
        hour: 9,
      );

      final timestamp = TimestampService.decodeTimestamp(encoded);

      expect(timestamp.year, 2026);
      expect(timestamp.month, 3);
      expect(timestamp.day, 12);
      expect(timestamp.hour, 9);
      expect(timestamp.minute, 0);
    });
  });

  group('NfcTransactionParser', () {
    test('parses a valid FeliCa read response', () {
      final encodedTimestamp = _encodeTimestamp(
        year: 2026,
        month: 3,
        day: 12,
        hour: 9,
      );
      final timestampBytes = Uint8List.fromList([
        (encodedTimestamp >> 16) & 0xFF,
        (encodedTimestamp >> 8) & 0xFF,
        encodedTimestamp & 0xFF,
      ]);
      final block = Uint8List.fromList([
        0x08,
        0x52,
        0x10,
        0x00,
        ...timestampBytes,
        0x00,
        0x32,
        0x00,
        0x0A,
        0x39,
        0x30,
        0x00,
        0xAA,
        0xBB,
      ]);
      final response = Uint8List.fromList([
        29,
        0x07,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x00,
        0x00,
        0x01,
        ...block,
      ]);

      final transactions =
          NfcTransactionParser.parseTransactionResponse(response);

      expect(transactions, hasLength(1));
      expect(transactions.first.fixedHeader, "08 52 10 00");
      expect(transactions.first.routeIndex, 5);
      expect(transactions.first.fromStationIndex, Line6Station.agargaon);
      expect(transactions.first.toStationIndex, Line6Station.motijheel);
      expect(transactions.first.fromStationRawCode, 50);
      expect(transactions.first.toStationRawCode, 10);
      expect(transactions.first.balance, 12345);
      expect(transactions.first.transactionKind, isA<CommuteDhakaMetro>());
      expect(transactions.first.serviceName.label, 'MRT Line 6');
      expect(transactions.first.eventPhase.label, 'Trip');
    });

    test('uses Hatirjheel station mapping for bus records', () {
      final block = Uint8List.fromList([
        0x42,
        0xD6,
        0x30,
        0x00,
        0x32,
        0xFB,
        0x58,
        0x8C,
        0x16,
        0x8C,
        0x13,
        0x71,
        0x00,
        0x00,
        0x00,
        0x10,
      ]);

      final transaction = NfcTransactionParser.parseTransactionBlock(block);

      expect(transaction.transactionKind, isA<CommuteHatirjheelBusEnd>());
      expect(transaction.serviceName.label, 'Hatirjheel Circular Bus');
      expect(transaction.eventPhase.label, 'Alighting');
      expect(transaction.routeIndex, 6);
      expect(transaction.fromStationIndex, HatirjheelBus.kunipara);
      expect(transaction.toStationIndex, HatirjheelBus.policePlaza);
      expect(transaction.fromStationRawCode, 22);
      expect(transaction.toStationRawCode, 19);
    });

    test('does not pretend balance updates have station names', () {
      final block = Uint8List.fromList([
        0x1D,
        0x60,
        0x02,
        0x01,
        0x32,
        0xBC,
        0x78,
        0x01,
        0x23,
        0x00,
        0x00,
        0x29,
        0x01,
        0x00,
        0x00,
        0x08,
      ]);

      final transaction = NfcTransactionParser.parseTransactionBlock(block);

      expect(transaction.transactionKind, isA<BalanceUpdate>());
      expect(transaction.serviceName.label, 'Rapid Pass Balance System');
      expect(transaction.eventPhase.label, 'Balance Update');
      expect(transaction.routeIndex, isNull);
      expect(transaction.fromStationIndex, isNull);
      expect(transaction.toStationIndex, isNull);
      expect(transaction.fromStationRawCode, 35);
      expect(transaction.toStationRawCode, 0);
    });

    test('classifies card issue records instead of leaving them unknown', () {
      final block = Uint8List.fromList([
        0x44,
        0x20,
        0x02,
        0x01,
        0x30,
        0x4A,
        0xB0,
        0xFD,
        0xC1,
        0x00,
        0x00,
        0xC8,
        0x00,
        0x00,
        0x00,
        0x01,
      ]);

      final transaction = NfcTransactionParser.parseTransactionBlock(block);

      expect(transaction.transactionKind, isA<CardIssueRecord>());
      expect(transaction.serviceName.label, 'Rapid Pass Card System');
      expect(transaction.eventPhase.label, 'Issue');
      expect(transaction.routeIndex, isNull);
      expect(transaction.fromStationIndex, isNull);
      expect(transaction.toStationIndex, isNull);
      expect(transaction.fromStationRawCode, 193);
      expect(transaction.toStationRawCode, 0);
    });
  });
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
