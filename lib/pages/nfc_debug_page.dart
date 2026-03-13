import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/services/nfc.dart';

/// Temporary startup screen for validating Android NFC reads with a real card.
///
/// This bypasses the normal app flow until the NFC transport layer is verified.
class NfcDebugPage extends StatefulWidget {
  const NfcDebugPage({super.key});

  @override
  State<NfcDebugPage> createState() => _NfcDebugPageState();
}

class _NfcDebugPageState extends State<NfcDebugPage> {
  final _nfcService = RapidPassNfcService.instance;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nfcService.startScan();
    });
  }

  @override
  void dispose() {
    _nfcService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _nfcService,
      builder: (context, child) {
        final state = _nfcService.cardState;
        final result = _nfcService.lastReadResult;

        return Scaffold(
          appBar: AppBar(
            title: const Text('NFC Debug'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(state, result),
              const SizedBox(height: 16),
              _buildActionRow(),
              const SizedBox(height: 16),
              _buildInstructionsCard(),
              const SizedBox(height: 16),
              if (result != null)
                _buildResultCard(result)
              else
                _buildEmptyCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(CardState state, CardReadResult? result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reader status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(_describeState(state)),
            if (state case ErrorState(:final message)) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (result?.currentBalance case final balance?) ...[
              const SizedBox(height: 12),
              Text(
                'Current balance: $balance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: _nfcService.startScan,
          icon: const Icon(Icons.nfc),
          label: const Text('Start scan'),
        ),
        OutlinedButton.icon(
          onPressed: _nfcService.stopScan,
          icon: const Icon(Icons.pause_circle_outline),
          label: const Text('Stop scan'),
        ),
        OutlinedButton.icon(
          onPressed: _nfcService.refreshAvailability,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh status'),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test notes'),
            SizedBox(height: 8),
            Text('1. NFC reader mode starts automatically on this screen.'),
            Text(
                '2. Keep a Rapid Pass or MRT card steady on the back of the phone.'),
            Text(
                '3. A successful read should show IDm, balance, and parsed history.'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('No card read yet.'),
      ),
    );
  }

  Widget _buildResultCard(CardReadResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last read',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SelectableText('IDm: ${result.idm}'),
            const SizedBox(height: 8),
            Text('Transactions: ${result.transactions.length}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => _copyReadDump(result),
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copy read dump'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Raw response 1',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            SelectableText(ByteParser.toHexString(result.rawResponse1)),
            const SizedBox(height: 12),
            Text(
              'Raw response 2',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            SelectableText(ByteParser.toHexString(result.rawResponse2)),
            const SizedBox(height: 16),
            for (var i = 0; i < result.transactions.length; i++) ...[
              _buildTransactionTile(i + 1, result.transactions[i]),
              const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(int index, NfcTransaction transaction) {
    final routeName = transaction.routeIndex == null
        ? null
        : TransportRouteLocalizations.englishRouteName(transaction.routeIndex!);
    final fromStationName =
        transaction.routeIndex == null || transaction.fromStationIndex == null
            ? null
            : TransportRouteLocalizations.englishStationName(
                transaction.routeIndex!,
                transaction.fromStationIndex!,
              );
    final toStationName =
        transaction.routeIndex == null || transaction.toStationIndex == null
            ? null
            : TransportRouteLocalizations.englishStationName(
                transaction.routeIndex!,
                transaction.toStationIndex!,
              );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction $index: ${_describeTransactionKind(transaction.transactionKind)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text('Service: ${transaction.serviceName.label}'),
        Text('Event phase: ${transaction.eventPhase.label}'),
        Text('Route: ${routeName ?? 'n/a'}'),
        SelectableText(
            'Raw block: ${ByteParser.toHexString(transaction.rawBlock)}'),
        Text('Timestamp: ${_dateFormat.format(transaction.timestamp)}'),
        Text('Header: ${transaction.fixedHeader}'),
        Text('Type bytes: ${transaction.transactionType}'),
        Text(
          'From: ${fromStationName ?? 'Unknown (${transaction.fromStationRawCode})'}',
        ),
        Text(
          'To: ${toStationName ?? 'Unknown (${transaction.toStationRawCode})'}',
        ),
        Text('From raw code: ${transaction.fromStationRawCode}'),
        Text('To raw code: ${transaction.toStationRawCode}'),
        Text('From station index: ${transaction.fromStationIndex ?? 'n/a'}'),
        Text('To station index: ${transaction.toStationIndex ?? 'n/a'}'),
        Text('Balance: ${transaction.balance}'),
        Text('Trailing: ${transaction.trailing}'),
      ],
    );
  }

  String _describeState(CardState state) {
    return switch (state) {
      Balance(:final amount) => 'Balance available: $amount',
      WaitingForTap() => 'Waiting for card tap',
      Reading() => 'Reading card',
      ErrorState() => 'Read failed',
      NoNfcSupport() => 'Device does not support NFC',
      NfcDisabled() => 'NFC is disabled',
    };
  }

  String _describeTransactionKind(NfcTransactionType kind) {
    return switch (kind) {
      CommuteHatirjheelBusStart() => 'Hatirjheel bus start',
      CommuteHatirjheelBusEnd() => 'Hatirjheel bus end',
      CommuteDhakaMetro() => 'Dhaka metro commute',
      CardIssueRecord() => 'Card issue',
      BalanceUpdate() => 'Balance update',
      CommuteUnknown() => 'Unknown commute',
    };
  }

  Future<void> _copyReadDump(CardReadResult result) async {
    final buffer = StringBuffer()
      ..writeln('IDm: ${result.idm}')
      ..writeln()
      ..writeln('Response 1:')
      ..writeln(ByteParser.toHexString(result.rawResponse1))
      ..writeln()
      ..writeln('Response 2:')
      ..writeln(ByteParser.toHexString(result.rawResponse2))
      ..writeln();

    for (var i = 0; i < result.transactions.length; i++) {
      final transaction = result.transactions[i];
      final routeName = transaction.routeIndex == null
          ? null
          : TransportRouteLocalizations.englishRouteName(
              transaction.routeIndex!,
            );
      final fromStationName =
          transaction.routeIndex == null || transaction.fromStationIndex == null
              ? null
              : TransportRouteLocalizations.englishStationName(
                  transaction.routeIndex!,
                  transaction.fromStationIndex!,
                );
      final toStationName =
          transaction.routeIndex == null || transaction.toStationIndex == null
              ? null
              : TransportRouteLocalizations.englishStationName(
                  transaction.routeIndex!,
                  transaction.toStationIndex!,
                );
      buffer
        ..writeln('Transaction ${i + 1}:')
        ..writeln('Raw block: ${ByteParser.toHexString(transaction.rawBlock)}')
        ..writeln('Header: ${transaction.fixedHeader}')
        ..writeln('Service: ${transaction.serviceName.label}')
        ..writeln('Event phase: ${transaction.eventPhase.label}')
        ..writeln('Route: ${routeName ?? 'n/a'}')
        ..writeln('Type bytes: ${transaction.transactionType}')
        ..writeln('Timestamp: ${_dateFormat.format(transaction.timestamp)}')
        ..writeln(
          'From: ${fromStationName ?? 'Unknown (${transaction.fromStationRawCode})'}',
        )
        ..writeln(
          'To: ${toStationName ?? 'Unknown (${transaction.toStationRawCode})'}',
        )
        ..writeln('From raw code: ${transaction.fromStationRawCode}')
        ..writeln('To raw code: ${transaction.toStationRawCode}')
        ..writeln(
            'From station index: ${transaction.fromStationIndex ?? 'n/a'}')
        ..writeln('To station index: ${transaction.toStationIndex ?? 'n/a'}')
        ..writeln('Balance: ${transaction.balance}')
        ..writeln('Trailing: ${transaction.trailing}')
        ..writeln();
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied read dump to clipboard'),
      ),
    );
  }
}
