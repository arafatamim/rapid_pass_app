import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';
import 'package:rapid_pass_info/widgets/shimmer.dart';
import 'package:relative_time/relative_time.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';

// TODO: refactor to prevent code duplication

class CardLayoutBase extends StatefulWidget {
  final VoidCallback? onCopy;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool disableDropdownMenu;
  final List<Widget> children;
  final double? elevation;
  final ShapeBorder? shape;
  final Color? color;
  final Color? foregroundColor;

  const CardLayoutBase({
    super.key,
    this.onCopy,
    this.onTap,
    this.heroTag,
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
  @override
  Widget build(BuildContext context) {
    final cardWidget = AspectRatio(
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
            ],
          );
          switch (value) {
            case "copy":
              widget.onCopy?.call();
              break;
          }
        },
        child: Material(
          color: widget.color,
          elevation: widget.elevation ?? 1.0,
          shape: widget.shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
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
      ),
    );

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        flightShuttleBuilder: _buildHeroFlightShuttle,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

Widget _buildHeroFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero fromHero = fromHeroContext.widget as Hero;
  final Hero toHero = toHeroContext.widget as Hero;

  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final fadeOutAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 1, curve: Curves.easeOut),
      ));

      final fadeInAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 1.0, curve: Curves.easeIn),
      ));

      return Stack(
        children: [
          Opacity(
            opacity: flightDirection == HeroFlightDirection.push
                ? fadeOutAnimation.value
                : fadeInAnimation.value,
            child: fromHero.child,
          ),
          Opacity(
            opacity: flightDirection == HeroFlightDirection.push
                ? fadeInAnimation.value
                : fadeOutAnimation.value,
            child: toHero.child,
          ),
        ],
      );
    },
  );
}

List<Widget> _buildHeader(
  BuildContext context, {
  required int index,
  required String name,
  required String id,
  required Color activeForegroundColor,
  required Color activeForegroundColorDimmed,
}) {
  return [
    Text(
      name,
      style: TextStyle(
        color: activeForegroundColor,
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    Text(
      id,
      style: TextStyle(
        color: activeForegroundColorDimmed,
      ),
    )
  ];
}

class CardLayoutLoading extends StatelessWidget {
  final String id;
  final String name;
  final int index;

  const CardLayoutLoading({
    super.key,
    required this.id,
    required this.name,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).hintColor;
    return CardLayoutBase(
      elevation: 0,
      disableDropdownMenu: true,
      // color: Theme.of(context).scaffoldBackgroundColor,
      color: Theme.of(context).colorScheme.onInverseSurface,
      children: [
        ..._buildHeader(
          context,
          id: id,
          name: name,
          index: index,
          activeForegroundColor: hintColor,
          activeForegroundColorDimmed: hintColor,
        ),
        const Spacer(),
        Shimmer(
          height: 40,
          width: 100,
          color: hintColor,
        ),
        const Spacer(),
        Shimmer(
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
  final TransitCard data;
  final VoidCallback? onCopy;
  final VoidCallback? onTap;
  final String? heroTag;

  const CardLayoutSuccess({
    super.key,
    required this.index,
    required this.data,
    this.onCopy,
    this.onTap,
    this.heroTag,
  });

  Widget _buildTooltip(BuildContext context, Color foregroundColor) {
    final List<String> messages = [];

    if (data.status != "Active") {
      messages.add(AppLocalizations.of(context)!.inactive);
    }

    final balance = double.tryParse(data.balance);

    if (balance != null && balance < 100) {
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
    final isActive = data.status == "Active";
    final balance = double.tryParse(data.balance);
    final lastUpdated = DateTime.tryParse(data.transactionEndDate);

    final activeBackgroundColor = isActive
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.surface;
    final activeForegroundColor = isActive
        ? Theme.of(context).colorScheme.onSecondary
        : Theme.of(context).hintColor;
    final activeForegroundColorDimmed =
        activeForegroundColor.withValues(alpha: 0.8);

    return CardLayoutBase(
      color: activeBackgroundColor,
      foregroundColor: activeForegroundColor,
      elevation: isActive ? 1 : 0,
      shape: isActive
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).hintColor,
                width: 2,
              ),
            ),
      onCopy: onCopy,
      onTap: onTap,
      heroTag: heroTag,
      children: [
        ..._buildHeader(
          context,
          id: data.cardNumber,
          name: data.name,
          index: index,
          activeForegroundColor: activeForegroundColor,
          activeForegroundColorDimmed: activeForegroundColorDimmed,
        ),
        const Spacer(),
        Expanded(
          flex: 6,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 100,
              minWidth: 50,
            ),
            child: FittedBox(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  CurrencyLabel(
                    amount: balance ?? 0,
                    amountColor: activeForegroundColor,
                    symbolColor: activeForegroundColorDimmed,
                  ),
                  const Padding(padding: EdgeInsets.only(right: 8)),
                  Align(
                    alignment: Alignment.center,
                    child: _buildTooltip(context, activeForegroundColorDimmed),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          "${lastUpdated != null ? RelativeTime(context).format(lastUpdated) : 'N/A'}"
          "${!isActive ? " • ${AppLocalizations.of(context)!.inactive}" : ""}",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: activeForegroundColorDimmed),
        ),
      ],
    );
  }
}

class CollapsedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceDim,
    );
  }
}

class HeroCardLayout extends StatelessWidget {
  final TransitCard data;
  final String heroTag;
  final int index;

  const HeroCardLayout({
    super.key,
    required this.data,
    required this.heroTag,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = data.status == "Active";
    final balance = double.tryParse(data.balance);
    final lastUpdated = DateTime.tryParse(data.transactionEndDate);

    final activeBackgroundColor = isActive
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.surface;
    final activeForegroundColor = isActive
        ? Theme.of(context).colorScheme.onSecondary
        : Theme.of(context).hintColor;
    final activeForegroundColorDimmed =
        activeForegroundColor.withValues(alpha: 0.8);

    return Hero(
      tag: heroTag,
      flightShuttleBuilder: _buildHeroFlightShuttle,
      child: Material(
        color: activeBackgroundColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButton(
                    color: activeForegroundColor,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      ..._buildHeader(
                        context,
                        id: data.cardNumber,
                        name: data.name,
                        index: index,
                        activeForegroundColor: activeForegroundColor,
                        activeForegroundColorDimmed:
                            activeForegroundColorDimmed,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: balance != null
                    ? CurrencyLabel(
                        amount: balance,
                        amountColor: activeForegroundColor,
                        symbolColor: activeForegroundColorDimmed,
                      )
                    : Icon(Icons.error, color: activeForegroundColor),
              ),
              const Spacer(),
              if (lastUpdated != null)
                Text(
                  "${AppLocalizations.of(context)!.lastUpdated}: ${DateFormat.yMMMd(Platform.localeName).format(lastUpdated)}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: activeForegroundColorDimmed),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, Color foregroundColor) {
    final List<String> messages = [];

    if (data.status != "Active") {
      messages.add(AppLocalizations.of(context)!.inactive);
    }

    final balance = double.tryParse(data.balance);

    if (balance != null && balance < 100) {
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
}
