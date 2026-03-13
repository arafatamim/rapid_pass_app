import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/services/account_service.dart';
import 'package:rapid_pass_info/services/card_link_repository.dart';
import 'package:rapid_pass_info/services/nfc.dart';

/// Focused bottom-sheet flow for scanning and linking a physical card.
///
/// The sheet keeps the interaction deliberately simple:
/// - start scanning automatically
/// - present one clear instruction/error state at a time
/// - after a successful scan, ask the user which saved card to link
/// - close itself on success and return a short status message
final class CardScanSheet extends StatefulWidget {
  const CardScanSheet({
    super.key,
    required this.cards,
  });

  final List<MergedTransitCard> cards;

  @override
  State<CardScanSheet> createState() => _CardScanSheetState();
}

final class _CardScanSheetState extends State<CardScanSheet> {
  final _nfcService = RapidPassNfcService.instance;

  StreamSubscription<CardReadResult?>? _readSubscription;
  _CardScanStep _step = _CardScanStep.scan;
  bool _isSaving = false;
  bool _slideFromRight = true;
  String? _errorMessage;
  CardReadResult? _pendingReadResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startScanning());
    });
  }

  @override
  void dispose() {
    unawaited(_readSubscription?.cancel());
    unawaited(_nfcService.stopScan());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _nfcService,
      builder: (context, child) {
        final content = _buildStepContent(context);
        final localizations = AppLocalizations.of(context)!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _step == _CardScanStep.scan
                      ? localizations.scanYourCard
                      : localizations.chooseMatchingCard,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 8),
                // Text(
                //   _step == _CardScanStep.scan
                //       ? localizations.scanCardInstructions
                //       : localizations.chooseMatchingCardInstructions,
                //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                //         color: Theme.of(context).hintColor,
                //       ),
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(_slideFromRight ? 0.18 : -0.18, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );

                    return ClipRect(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: content,
                ),
                const SizedBox(height: 24),
                _buildActionRow(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context) {
    if (_step == _CardScanStep.pickCard && !_isSaving) {
      return _buildCardPickerContent(context);
    }

    return _buildStatusContent(context);
  }

  Widget _buildActionRow() {
    if (_step == _CardScanStep.pickCard && !_isSaving) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.nfc),
              label: Text(AppLocalizations.of(context)!.scanAgain),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _startScanning,
            icon: const Icon(Icons.nfc),
            label: Text(AppLocalizations.of(context)!.tryAgain),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusContent(BuildContext context) {
    final theme = Theme.of(context);

    if (_isSaving) {
      return _StatusBlock(
        key: const ValueKey('saving'),
        icon: const CircularProgressIndicator(),
        title: AppLocalizations.of(context)!.savingCardScan,
        message: AppLocalizations.of(context)!.savingCardScanMessage,
      );
    }

    if (_errorMessage case final message?) {
      return _StatusBlock(
        key: const ValueKey('error'),
        icon: Icon(
          Icons.error_outline,
          size: 72,
          color: theme.colorScheme.error,
        ),
        title: AppLocalizations.of(context)!.couldNotScanCard,
        message: message,
      );
    }

    return switch (_nfcService.cardState) {
      WaitingForTap() => _StatusBlock(
          key: const ValueKey('waiting'),
          icon: Icon(
            Icons.nfc,
            size: 88,
            color: theme.colorScheme.primary,
          ),
          title: AppLocalizations.of(context)!.holdCardToBackOfPhone,
          message: AppLocalizations.of(context)!.keepStillUntilPhoneReads,
        ),
      Reading() => _StatusBlock(
          key: const ValueKey('reading'),
          icon: const CircularProgressIndicator(),
          title: AppLocalizations.of(context)!.readingCard,
          message: AppLocalizations.of(context)!.keepCardInPlace,
        ),
      Balance(:final amount) => _StatusBlock(
          key: const ValueKey('balance'),
          icon: Icon(
            Icons.check_circle_outline,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          title: AppLocalizations.of(context)!.cardReadSuccessfully,
          message: AppLocalizations.of(context)!.currentBalanceValue('$amount'),
        ),
      NfcDisabled() => _StatusBlock(
          key: const ValueKey('disabled'),
          icon: Icon(
            Icons.settings_input_antenna,
            size: 72,
            color: theme.colorScheme.error,
          ),
          title: AppLocalizations.of(context)!.turnOnNfcFirst,
          message: AppLocalizations.of(context)!.enableNfcThenTryAgain,
        ),
      NoNfcSupport() => _StatusBlock(
          key: const ValueKey('unsupported'),
          icon: Icon(
            Icons.block_outlined,
            size: 72,
            color: theme.colorScheme.error,
          ),
          title: AppLocalizations.of(context)!.phoneDoesNotSupportNfc,
          message: AppLocalizations.of(context)!.usePhoneWithNfc,
        ),
      ErrorState(:final message) => _StatusBlock(
          key: const ValueKey('read-failed'),
          icon: Icon(
            Icons.error_outline,
            size: 72,
            color: theme.colorScheme.error,
          ),
          title: AppLocalizations.of(context)!.readFailed,
          message: message,
        ),
    };
  }

  Widget _buildCardPickerContent(BuildContext context) {
    final readResult = _pendingReadResult;
    if (readResult == null) {
      return const SizedBox.shrink();
    }

    return Column(
      key: const ValueKey('pick-card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).colorScheme.secondaryContainer,
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        //   child: Column(
        //     children: [
        //       Text(
        //         AppLocalizations.of(context)!.cardReadSuccessfully,
        //         style: Theme.of(context).textTheme.titleMedium,
        //         textAlign: TextAlign.center,
        //       ),
        //       const SizedBox(height: 6),
        //       Text(
        //         AppLocalizations.of(context)!
        //             .currentBalanceValue('${readResult.currentBalance ?? 0}'),
        //         style: Theme.of(context).textTheme.bodyLarge,
        //         textAlign: TextAlign.center,
        //       ),
        //       const SizedBox(height: 4),
        //       Text(
        //         readResult.idm,
        //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //               color: Theme.of(context).hintColor,
        //             ),
        //         textAlign: TextAlign.center,
        //       ),
        //     ],
        //   ),
        // ),
        if (_errorMessage case final message?) ...[
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        // const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: ListView.separated(
            key: const ValueKey('card-list'),
            shrinkWrap: true,
            itemCount: widget.cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              final isAlreadyLinked = card.linkedIdm == readResult.idm;

              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.secondaryContainer,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: _isSaving ? null : () => _saveSelectedCard(card),
                  title: Text(card.name),
                  subtitle: Text(card.cardNumber),
                  trailing: isAlreadyLinked
                      ? const Icon(Icons.check_circle_outline)
                      : const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _startScanning() async {
    setState(() {
      _step = _CardScanStep.scan;
      _slideFromRight = false;
      _pendingReadResult = null;
      _isSaving = false;
      _errorMessage = null;
    });

    await _readSubscription?.cancel();
    _readSubscription = _nfcService.cardReadResultsStream.listen((result) {
      if (result == null) {
        return;
      }
      unawaited(_handleReadResult(result));
    });

    try {
      await _nfcService.stopScan();
      await _nfcService.startScan();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.failedToStartNfcScanning('$error');
      });
    }
  }

  Future<void> _handleReadResult(CardReadResult readResult) async {
    if (_isSaving || !mounted || _step != _CardScanStep.scan) {
      return;
    }

    setState(() {
      _slideFromRight = true;
      _step = _CardScanStep.pickCard;
      _pendingReadResult = readResult;
      _errorMessage = null;
    });

    try {
      await _nfcService.stopScan();
    } on CardLinkConflictException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context)!
            .physicalCardAlreadyLinked(error.existingCardNumber);
        _isSaving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.failedToSaveScan('$error');
        _isSaving = false;
      });
    }
  }

  Future<void> _saveSelectedCard(MergedTransitCard selectedCard) async {
    final readResult = _pendingReadResult;
    if (readResult == null || _isSaving || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await context.read<AccountService>().attachNfcScanToCard(
            accountId: selectedCard.accountId,
            cardNumber: selectedCard.cardNumber,
            readResult: readResult,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        AppLocalizations.of(context)!
            .linkedCardToIdm(selectedCard.cardNumber, readResult.idm),
      );
    } on CardLinkConflictException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context)!
            .physicalCardAlreadyLinked(error.existingCardNumber);
        _isSaving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.failedToSaveScan('$error');
        _isSaving = false;
      });
    }
  }
}

enum _CardScanStep { scan, pickCard }

final class _StatusBlock extends StatelessWidget {
  const _StatusBlock({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final Widget icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Center(child: icon),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).hintColor,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
