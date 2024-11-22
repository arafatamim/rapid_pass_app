import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/widgets/card_list.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 400,
  childAspectRatio: 1.8,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
);

class CardsView extends StatelessWidget {
  final List<RapidPass> passes;

  const CardsView({
    super.key,
    required this.passes,
  });

  @override
  Widget build(context) {
    if (passes.isEmpty) {
      return SliverReorderableGrid(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) {
          return const EmptyMessage(key: ValueKey('empty_message'));
        },
        itemCount: 1,
        onReorder: (oldIndex, newIndex) {},
      );
    } else {
      return CardList(
        passes: passes,
        gridDelegate: gridDelegate,
      );
    }
  }
}
