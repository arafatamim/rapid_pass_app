import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/services/account_service.dart';
import 'package:rapid_pass_info/widgets/card_list.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';
import 'package:rapid_pass_info/widgets/transactions_list.dart';
import "package:sliver_tools/sliver_tools.dart";

class CardsView extends StatelessWidget {
  final List<MergedTransitCard> cards;
  final int selectedCardIndex;
  final ValueChanged<int> onSelectedCardChanged;
  final ValueChanged<bool> onFabVisibilityChanged;

  const CardsView({
    super.key,
    required this.cards,
    required this.selectedCardIndex,
    required this.onSelectedCardChanged,
    required this.onFabVisibilityChanged,
  });

  Future<void> _showCardInfoSheet(
    BuildContext context,
    MergedTransitCard card,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final accountService = context.read<AccountService>();

    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.cardInfo,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    icon: Icons.credit_card_outlined,
                    label: localizations.cardNumberLabel,
                    value: card.cardNumber,
                  ),
                  _InfoRow(
                    icon: Icons.link,
                    label: localizations.nfcLinkStatus,
                    value: card.isLinked
                        ? localizations.linkedIdm(card.linkedIdm!)
                        : localizations.notLinkedYet,
                  ),
                  if (card.isLinked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            await accountService.unlinkNfcScanFromCard(
                              accountId: card.accountId,
                              cardNumber: card.cardNumber,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(Icons.link_off),
                          label: Text(localizations.unlinkPhysicalCard),
                        ),
                      ),
                    ),
                  _InfoRow(
                    icon: card.isServerStale
                        ? Icons.offline_bolt_outlined
                        : Icons.cloud_done_outlined,
                    label: localizations.syncStatus,
                    value: card.isServerStale
                        ? localizations.nfcScanNewerThanServer
                        : localizations.serverSnapshotCurrent,
                  ),
                  if (card.hasNfcGapFill)
                    _InfoRow(
                      icon: Icons.history_toggle_off,
                      label: localizations.nfcHistoryLabel,
                      value: localizations.nfcOnlyTransactionsCount(
                        card.nfcGapFillCount,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const EmptyMessage();
    }

    final safeSelectedCardIndex =
        selectedCardIndex >= 0 && selectedCardIndex < cards.length
            ? selectedCardIndex
            : 0;
    final selectedCard = cards[safeSelectedCardIndex];
    final activities = selectedCard.effectiveActivities;
    final isTablet = MediaQuery.sizeOf(context).width >= 900;

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        switch (notification.direction) {
          case ScrollDirection.reverse:
            onFabVisibilityChanged(false);
            return false;
          case ScrollDirection.forward:
            onFabVisibilityChanged(true);
            return false;
          case ScrollDirection.idle:
            return false;
        }
      },
      child: isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: CardList(
                          cards: cards,
                          selectedIndex: safeSelectedCardIndex,
                          onChange: onSelectedCardChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 7,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate.fixed(
                          [
                            Text(
                              AppLocalizations.of(context)!.transactions,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () =>
                                  _showCardInfoSheet(context, selectedCard),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedCard.cardNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context).hintColor,
                                        ),
                                  ),
                                  if (selectedCard.isLinked) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.contactless,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      SliverAnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: TransactionList(
                          key: ValueKey(activities.hashCode),
                          activities: activities,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      CardList(
                        cards: cards,
                        selectedIndex: safeSelectedCardIndex,
                        onChange: onSelectedCardChanged,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.transactions,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _showCardInfoSheet(context, selectedCard),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedCard.cardNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                            if (selectedCard.isLinked) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.contactless,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                SliverAnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: TransactionList(
                    key: ValueKey(activities.hashCode),
                    activities: activities,
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
