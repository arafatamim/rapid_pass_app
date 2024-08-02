import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/add_pass_page.dart';
import 'package:rapid_pass_info/state/state.dart';
import 'package:rapid_pass_info/widgets/card_layout.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPassPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      builder: (context, state, child) {
        return Scaffold(
          floatingActionButton: child,
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Center(
                  child: Text(
                    AppLocalizations.of(context)!.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                sliver: state.passes.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: EmptyMessage(),
                        ),
                      )
                    : CardList(passes: state.passes),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardList extends StatefulWidget {
  final List<RapidPass> passes;

  const CardList({
    super.key,
    required this.passes,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: widget.passes.length,
      onReorder: (oldIndex, newIndex) {
        context.read<AppState>().reorderPasses(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final pass = widget.passes[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(pass.id),
          index: index,
          child: AnimatedSwitcher(
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            duration: const Duration(milliseconds: 300),
            child: Material(
              child: CardItem(pass: pass),
            ),
          ),
        );
      },
    );
  }
}

class CardItem extends StatefulWidget {
  final RapidPass pass;

  const CardItem({
    super.key,
    required this.pass,
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: ValueKey(widget.pass.id),
      future: widget.pass.data,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.active) &&
            snapshot.hasError) {
          return CardLayoutError(
            message: switch (snapshot.error) {
              SocketException _ => AppLocalizations.of(context)!.noInternet,
              _ => snapshot.error,
            },
            passName: widget.pass.name,
            passNumber: widget.pass.number,
            onCopy: () => _onCopy(widget.pass),
            onDelete: () => _onDelete(widget.pass),
          );
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final passData = snapshot.data!;
          return CardLayoutSuccess(
            passName: widget.pass.name,
            passNumber: widget.pass.number,
            passData: passData,
            onCopy: () => _onCopy(widget.pass),
            onDelete: () => _onDelete(widget.pass),
          );
        }
        return CardLayoutLoading(
          passNumber: widget.pass.number,
          passName: widget.pass.name,
        );
      },
    );
  }

  void _onDelete(RapidPass pass) {
    context.read<AppState>().removePass(pass.id);
  }

  void _onCopy(RapidPass pass) async {
    await Clipboard.setData(
      ClipboardData(text: "RP${pass.number}"),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cardNumberCopied),
      ),
    );
  }
}
