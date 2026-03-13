import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';
import 'package:rapid_pass_info/widgets/expandable_card.dart';
import 'package:rapid_pass_info/widgets/expressive_styles.dart';
import 'package:rapid_pass_info/widgets/material_shape.dart';

class CardList extends StatelessWidget {
  final List<MergedTransitCard> cards;
  final int selectedIndex;
  final void Function(int index) onChange;

  const CardList({
    super.key,
    required this.cards,
    required this.selectedIndex,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(
        child: Text('No cards available'),
      );
    }

    final safeSelectedIndex =
        selectedIndex >= 0 && selectedIndex < cards.length ? selectedIndex : 0;

    return ExpandableCardList(
      index: safeSelectedIndex,
      allowInteraction: cards.length > 1,
      allowCollapse: false,
      onChange: onChange,
      cards: cards.map((card) {
        final expressiveStyle = getExpressiveStyleFromString(card.hexCardNo);
        final balance = card.effectiveBalance;

        return ExpandableCardDescription(
          color: expressiveStyle.color,
          leading: (color) => MaterialClippedShape(
            expressiveStyle.backgroundShape,
            expressiveStyle.foregroundShape,
            color: color,
          ),
          trailing: (color) => CurrencyLabel(
            amount: balance,
            symbolColor: color,
            amountTextStyle: TextStyle(
              // fontFamily: 'Roboto Flex',
              color: color,
              fontSize: 28,
              letterSpacing: 0.1,
              fontVariations: const [
                FontVariation('wght', 700),
                FontVariation('wdth', 25),
              ],
            ),
          ),
          title: card.name,
          titleStyle: expressiveStyle.textStyle,
        );
      }).toList(),
    );
  }
}
