import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_pass_info/helpers/exceptions.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:rapid_pass_info/widgets/card_layout.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class CardList extends StatefulWidget {
  final List<RapidPass> passes;

  const CardList({
    super.key,
    required this.passes,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SliverReorderableGrid(
      itemCount: widget.passes.length,
      onReorderStart: (index) {
        HapticFeedback.heavyImpact();
      },
      onReorder: (oldIndex, newIndex) async {
        final box = Hive.box<RapidPass>(RapidPass.boxName);
        final oldItem = widget.passes[oldIndex];
        final newItem = widget.passes[newIndex];
        box.putAt(oldIndex, newItem.copyWith());
        box.putAt(newIndex, oldItem.copyWith());
      },
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.8,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final pass = widget.passes[index];
        return CardItem(
          key: ValueKey(pass.id),
          pass: pass,
          index: index,
        );
      },
    );
  }
}

class CardItem extends StatefulWidget {
  final RapidPass pass;
  final int index;

  const CardItem({
    super.key,
    required this.pass,
    required this.index,
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  final Box<RapidPassData> _cacheBox =
      Hive.box<RapidPassData>(RapidPassData.boxName);
  RapidPassData? _data;
  Object? _error;
  bool _isCached = false;

  @override
  void initState() {
    super.initState();
    // fetch from cache first if available
    final cached = _cacheBox.get(widget.pass.id);
    if (cached != null) {
      _isCached = true;
      _data = cached;
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _fetchRemoteData();
        }
      },
    );
  }

  void _fetchRemoteData() {
    if (!mounted) return;

    RapidPassService.instance.getRapidPass(widget.pass.id).then(
      (value) {
        if (!mounted) return;
        setState(() {
          _isCached = false;
          _data = value;
          // populate cache
          _cacheBox.put(widget.pass.id, value);
        });
      },
    ).catchError((e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          if (_error != null && _data == null) {
            return CardLayoutError(
              index: widget.index,
              message: switch (_error) {
                AppException(code: AppExceptionType.network) =>
                  AppLocalizations.of(context)!.networkException,
                AppException(code: AppExceptionType.server) =>
                  AppLocalizations.of(context)!.serverException,
                AppException(code: AppExceptionType.notFound) =>
                  AppLocalizations.of(context)!.notFoundException,
                _ => _error?.toString().replaceAll("Exception: ", ""),
              },
              name: widget.pass.name,
              id: widget.pass.id,
              onCopy: onCopy,
              onDelete: onDelete,
            );
          }
          if (_data != null) {
            return CardLayoutSuccess(
              index: widget.index,
              name: widget.pass.name,
              id: widget.pass.id,
              passData: _data!,
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
      ),
    );
  }

  void onCopy() {
    _onCopy(widget.pass);
  }

  void onDelete() {
    _onDelete(widget.pass);
  }

  void _onCopy(RapidPass pass) async {
    await Clipboard.setData(
      ClipboardData(text: pass.id),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cardNumberCopied(pass.id)),
      ),
    );
  }

  void _onDelete(RapidPass pass) {
    Hive.box<RapidPass>(RapidPass.boxName).deleteAt(widget.index);
    Hive.box<RapidPassData>(RapidPassData.boxName).delete(pass.id);
  }
}
