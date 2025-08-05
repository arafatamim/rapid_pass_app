import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';
import 'package:rapid_pass_info/widgets/expandable_card.dart';
import 'package:rapid_pass_info/widgets/expressive_styles.dart';
import 'package:rapid_pass_info/widgets/material_shape.dart';

class CardList extends StatefulWidget {
  final List<TransitCard> cards;
  final void Function(int index) onChange;

  const CardList({
    super.key,
    required this.cards,
    required this.onChange,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const Center(
        child: Text('No cards available'),
      );
    }

    // Ensure selected index is valid
    if (_selectedIndex >= widget.cards.length) {
      _selectedIndex = 0;
    }

    return ExpandableCardList(
      index: _selectedIndex,
      allowInteraction: widget.cards.length > 1,
      allowCollapse: false,
      onChange: (selectedIndex) {
        setState(() {
          _selectedIndex = selectedIndex;
        });
        widget.onChange(selectedIndex);
      },
      cards: widget.cards.map((card) {
        final expressiveStyle = getExpressiveStyleFromString(card.hexCardNo);
        final balance = double.tryParse(card.balance);

        return ExpandableCardDescription(
          color: expressiveStyle.color,
          leading: (color) => MaterialClippedShape(
            expressiveStyle.backgroundShape,
            expressiveStyle.foregroundShape,
            color: color,
          ),
          trailing: (color) => balance != null
              ? CurrencyLabel(
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
                )
              : Container(),
          title: card.name,
          titleStyle: expressiveStyle.textStyle,
        );
      }).toList(),
    );
  }
}
