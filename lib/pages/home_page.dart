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
import 'package:rapid_pass_info/pages/settings.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import '../helpers/cache.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildAppBar() {
    return SliverAppBar.large(
      title: Text(
        AppLocalizations.of(context)!.title,
        textAlign: TextAlign.center,
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "settings") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'settings',
              child: Text(AppLocalizations.of(context)!.settings),
            ),
          ],
        )
      ],
    );
  }

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
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
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
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SliverReorderableGrid(
          itemCount: widget.passes.length,
          onReorder: (oldIndex, newIndex) {
            context.read<AppState>().reorderPasses(oldIndex, newIndex);
          },
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 1.8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final pass = widget.passes[index];
            return AnimatedSwitcher(
              key: ValueKey(pass.id),
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
              child: CardItem(
                key: ValueKey(pass.id),
                pass: pass,
                index: index,
                cache: state.cache,
              ),
            );
          },
        );
      },
    );
  }
}

class CardItem extends StatefulWidget {
  final RapidPass pass;
  final int index;
  final Cache? cache;

  const CardItem({
    super.key,
    required this.pass,
    required this.index,
    required this.cache,
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  bool _isCached = false;

  Stream<RapidPassData> get data async* {
    final cache = widget.cache;
    final cachedData = await cache?.get(widget.pass.id);
    if (cachedData != null) {
      _isCached = true;
      yield cachedData;
    }

    try {
      final remoteData = await widget.pass.data;
      _isCached = false;
      yield remoteData;
      cache?.set(widget.pass.id, remoteData);
    } catch (e) {
      if (cachedData == null) {
        yield* Stream.error(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RapidPassData>(
      key: ValueKey(widget.pass.id),
      stream: data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CardLayoutError(
            index: widget.index,
            message: switch (snapshot.error) {
              SocketException _ => AppLocalizations.of(context)!.noInternet,
              _ => snapshot.error?.toString().replaceAll("Exception: ", ""),
            },
            name: widget.pass.name,
            id: widget.pass.id,
            onCopy: onCopy,
            onDelete: onDelete,
          );
        }
        if (snapshot.hasData) {
          final passData = snapshot.data!;
          return CardLayoutSuccess(
            index: widget.index,
            name: widget.pass.name,
            id: widget.pass.id,
            passData: passData,
            isCached: _isCached,
            onCopy: onCopy,
            onDelete: onDelete,
          );
        }
        return CardLayoutLoading(
          index: widget.index,
          id: widget.pass.id,
          name: widget.pass.name,
        );
      },
    );
  }

  void _onDelete(RapidPass pass) {
    context.read<AppState>().removePass(pass.id);
  }

  void _onCopy(RapidPass pass) async {
    await Clipboard.setData(
      ClipboardData(text: pass.id),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cardNumberCopied),
      ),
    );
  }

  void onDelete() {
    _onDelete(widget.pass);
  }

  void onCopy() {
    _onCopy(widget.pass);
  }
}
