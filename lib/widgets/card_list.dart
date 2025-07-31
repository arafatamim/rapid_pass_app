import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/card_layout.dart';
import 'package:rapid_pass_info/pages/card_details.dart';

class CardList extends StatefulWidget {
  final List<TransitCard> cards;
  final SliverGridDelegate gridDelegate;

  const CardList({
    super.key,
    required this.cards,
    required this.gridDelegate,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final card = widget.cards[index];
          return CardItem(
            key: ValueKey(card.id),
            card: card,
            index: index,
          );
        },
        childCount: widget.cards.length,
      ),
    );
  }
}

class CardItem extends StatefulWidget {
  final TransitCard card;
  final int index;

  const CardItem({
    super.key,
    required this.card,
    required this.index,
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(builder: (context) {
        return CardLayoutSuccess(
          index: widget.index,
          data: widget.card,
          onCopy: onCopy,
          onTap: onTap,
          heroTag: "card_hero_${widget.card.cardNumber}",
        );
      }),
    );
  }

  void onTap() {
    _navigateToDetails();
  }

  void onCopy() {
    _onCopy(widget.card);
  }

  void _onCopy(TransitCard card) async {
    await Clipboard.setData(
      ClipboardData(text: card.cardNumber),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            AppLocalizations.of(context)!.cardNumberCopied(card.cardNumber)),
      ),
    );
  }

  void _navigateToDetails() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CardDetailsPage(
          card: widget.card,
          index: widget.index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Elastic slide up
          final slideTween = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut));

          // Fade in
          final fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.ease));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
