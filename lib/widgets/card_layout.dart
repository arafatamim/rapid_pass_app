import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/widgets/flippable_card.dart';
import 'package:relative_time/relative_time.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CardLayoutBase extends StatefulWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final bool disableDropdownMenu;
  final List<Widget> children;
  final double? elevation;
  final ShapeBorder? shape;
  final Color? color;
  final Color? foregroundColor;

  const CardLayoutBase({
    super.key,
    this.onDelete,
    this.onCopy,
    this.elevation,
    this.shape,
    this.color,
    this.foregroundColor,
    this.disableDropdownMenu = false,
    required this.children,
  });

  @override
  State<CardLayoutBase> createState() => _CardLayoutBaseState();
}

class _CardLayoutBaseState extends State<CardLayoutBase> {
  final _controller = FlippableCardController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: GestureDetector(
        onLongPressStart: (details) async {
          if (widget.disableDropdownMenu) {
            return;
          }
          final offset = details.globalPosition;
          final value = await showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              MediaQuery.of(context).size.width - offset.dx,
              MediaQuery.of(context).size.height - offset.dy,
            ),
            items: [
              PopupMenuItem(
                value: "copy",
                child: Text(AppLocalizations.of(context)!.copyCardNumber),
              ),
              PopupMenuItem(
                value: "delete",
                child: Text(AppLocalizations.of(context)!.removeCard),
              ),
            ],
          );
          switch (value) {
            case "copy":
              widget.onCopy?.call();
              break;
            case "delete":
              widget.onDelete?.call();
              break;
          }
        },
        child: Card(
          color: widget.color,
          elevation: widget.elevation,
          shape: widget.shape,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

class CardLayoutLoading extends StatelessWidget {
  final int passNumber;
  final String passName;
  final int index;

  const CardLayoutLoading({
    super.key,
    required this.passNumber,
    required this.passName,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).hintColor;
    return CardLayoutBase(
      elevation: 0,
      disableDropdownMenu: true,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: hintColor,
          width: 1,
        ),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                [passName, "RP$passNumber"].join(" • "),
                style: TextStyle(color: hintColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: hintColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 100,
          height: 40,
          color: hintColor,
        ),
        const Spacer(),
        Container(
          width: 100,
          height: 20,
          color: hintColor,
        ),
      ],
    );
  }
}

class CardLayoutSuccess extends StatelessWidget {
  final int index;
  final String passName;
  final int passNumber;
  final RapidPassData passData;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const CardLayoutSuccess({
    super.key,
    required this.index,
    required this.passName,
    required this.passNumber,
    required this.passData,
    this.onDelete,
    this.onCopy,
  });

  Widget _buildTooltip(BuildContext context, Color foregroundColor) {
    final List<String> messages = [];

    if (!passData.isActive) {
      messages.add(AppLocalizations.of(context)!.inactive);
    }

    if (passData.balance < 100) {
      messages.add(AppLocalizations.of(context)!.lowBalance);
    }

    if (messages.isEmpty) return const SizedBox.shrink();

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: messages.join("; "),
      child: Icon(
        Icons.warning_amber_rounded,
        color: foregroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBackgroundColor = passData.isActive
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.surface;
    final activeForegroundColor = passData.isActive
        ? Theme.of(context).colorScheme.onSecondary
        : Theme.of(context).hintColor;

    return CardLayoutBase(
      color: activeBackgroundColor,
      foregroundColor: activeForegroundColor,
      elevation: passData.isActive ? 1 : 0,
      shape: passData.isActive
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).hintColor,
                width: 2,
              ),
            ),
      onCopy: onCopy,
      onDelete: onDelete,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                [passName, "RP$passNumber"].join(" • "),
                style: TextStyle(color: activeForegroundColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: activeForegroundColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              "৳${passData.balance}",
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: activeForegroundColor),
            ),
            const Padding(padding: EdgeInsets.only(right: 8)),
            _buildTooltip(context, activeForegroundColor),
          ],
        ),
        const Spacer(),
        Text(
          "${RelativeTime(context).format(passData.lastUpdated)}"
          "${!passData.isActive ? " • ${AppLocalizations.of(context)!.inactive}" : ""}",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: activeForegroundColor),
        ),
      ],
    );
  }
}

class CardLayoutError extends StatelessWidget {
  final int index;
  final Object? message;
  final int passNumber;
  final String passName;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const CardLayoutError({
    super.key,
    required this.index,
    this.message,
    this.onDelete,
    this.onCopy,
    required this.passName,
    required this.passNumber,
  });

  @override
  Widget build(BuildContext context) {
    return CardLayoutBase(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      onCopy: onCopy,
      onDelete: onDelete,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                [passName, "RP$passNumber"].join(" • "),
                style: const TextStyle(color: Colors.red),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          AppLocalizations.of(context)!.errorWhileLoading,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          "$message",
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
