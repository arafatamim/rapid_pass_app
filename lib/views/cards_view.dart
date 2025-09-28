import 'package:flutter/material.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/card_list.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';
import 'package:rapid_pass_info/widgets/transactions_list.dart';
import "package:sliver_tools/sliver_tools.dart";

class CardsView extends StatefulWidget {
  final List<TransitCard> cards;

  const CardsView({
    super.key,
    required this.cards,
  });

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  late int _selectedCardIndex = 0;

  @override
  Widget build(context) {
    if (widget.cards.isEmpty) {
      return const EmptyMessage();
    }
    final transactions =
        widget.cards[_selectedCardIndex].getFormattedTransactions();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            [
              CardList(
                cards: widget.cards,
                onChange: (index) {
                  setState(() {
                    _selectedCardIndex = index;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Text(
                    AppLocalizations.of(context)!.transactions,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Text(
                    widget.cards[_selectedCardIndex].cardNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  )
                ],
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
            key: ValueKey(transactions.hashCode),
            transactions: transactions,
          ),
        ),
      ],
    );
  }
}
