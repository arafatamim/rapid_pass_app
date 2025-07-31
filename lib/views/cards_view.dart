import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/card_list.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';

const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 470,
  childAspectRatio: 1.8,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
);

class CardsView extends StatelessWidget {
  final List<TransitCard> cards;
  // final Object? error;

  const CardsView({
    super.key,
    required this.cards,
    // required this.error,
  });

  @override
  Widget build(context) {
    if (cards.isEmpty) {
      return SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const EmptyMessage(key: ValueKey('empty_message'));
          },
          childCount: 1,
        ),
      );
    }
    // success state
    return CardList(
      cards: cards,
      gridDelegate: gridDelegate,
    );
  }
}
