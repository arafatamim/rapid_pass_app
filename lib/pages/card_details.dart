import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/card_layout.dart';
import 'package:rapid_pass_info/widgets/transactions_list.dart';

class CardHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TransitCard card;

  CardHeaderDelegate({
    required this.card,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return HeroCardLayout(
      data: card,
      index: 0,
      heroTag: "card_hero_${card.cardNumber}",
    );
  }

  @override
  double get maxExtent => 210.0;

  @override
  double get minExtent => 210.0;

  @override
  bool shouldRebuild(CardHeaderDelegate oldDelegate) => false;
}

class CardDetailsPage extends StatefulWidget {
  final TransitCard card;
  final int index;

  const CardDetailsPage({
    super.key,
    required this.card,
    required this.index,
  });

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: CardHeaderDelegate(
                card: widget.card,
              ),
            ),
            TransactionList(
              transactions: widget.card.getFormattedTransactions(),
            ),
          ],
        ),
      ),
    );
  }
}
