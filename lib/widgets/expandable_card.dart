import 'dart:async';

import 'package:elegant_spring_animation/elegant_spring_animation.dart';
import 'package:flutter/material.dart';

class ColorProvider extends StatelessWidget {
  final Color surfaceColor;
  final Widget Function(
      BuildContext context, Color surfaceColor, Color onSurfaceColor) builder;
  final Color? _cachedOnSurfaceColor;

  ColorProvider({
    super.key,
    required this.surfaceColor,
    required this.builder,
  }) : _cachedOnSurfaceColor = _computeOnSurfaceColor(surfaceColor);

  static Color _computeOnSurfaceColor(Color surfaceColor) {
    return surfaceColor.computeLuminance() > 0.5
        ? HSLColor.fromColor(surfaceColor)
            .withLightness(0.25)
            .withSaturation(0.2)
            .toColor()
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, surfaceColor, _cachedOnSurfaceColor!);
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;
  const MeasureSize({required this.child, required this.onChange, super.key});

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? oldSize;
  bool _callbackScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleCallback();
  }

  @override
  void didUpdateWidget(MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _scheduleCallback();
    }
  }

  void _scheduleCallback() {
    if (!_callbackScheduled && mounted) {
      _callbackScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _callbackScheduled = false;
        if (mounted) {
          final renderObject = context.findRenderObject();
          if (renderObject is RenderBox && renderObject.hasSize) {
            final newSize = renderObject.size;
            if (oldSize != newSize) {
              oldSize = newSize;
              widget.onChange(newSize);
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ExpandableCardDescription {
  final String title;
  final TextStyle? titleStyle;
  final Widget Function(Color color)? leading;
  final Widget Function(Color color)? trailing;
  final Widget? floating;
  final Color? color;

  const ExpandableCardDescription({
    required this.title,
    required this.leading,
    this.trailing,
    this.floating,
    this.color,
    this.titleStyle,
  });
}

class ExpandableCardList extends StatefulWidget {
  final List<ExpandableCardDescription> cards;

  /// -1 means no card is initially expanded
  final int index;

  final bool allowCollapse;

  final bool allowInteraction;

  final void Function(int index)? onChange;

  const ExpandableCardList({
    super.key,
    required this.cards,
    this.index = -1,
    this.allowInteraction = true,
    this.allowCollapse = false,
    this.onChange,
  });

  @override
  State<ExpandableCardList> createState() => _ExpandableCardListState();
}

class _ExpandableCardListState extends State<ExpandableCardList> {
  int? expandedCardIndex;
  final Map<Color, Color> _colorCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.index != -1) {
      expandedCardIndex = widget.index;
    }
  }

  @override
  void didUpdateWidget(ExpandableCardList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      expandedCardIndex = widget.index;
    }
  }

  void _onCardTap(int index) {
    if (widget.allowInteraction) {
      if (!widget.allowCollapse && expandedCardIndex != index) {
        setState(() {
          expandedCardIndex = expandedCardIndex == index ? null : index;
        });
      }
      widget.onChange?.call(index);
    }
  }

  Widget _buildCard(ExpandableCardDescription card, int index) {
    return ExpandableCard(
      color: card.color,
      isExpanded: expandedCardIndex == index,
      isAboveCardExpanded:
          expandedCardIndex != null && (expandedCardIndex! - index) == -1,
      leading: card.leading?.call(_getOnSurfaceColor(card.color)) ??
          const SizedBox.shrink(),
      trailing: card.trailing?.call(_getOnSurfaceColor(card.color)) ??
          const SizedBox.shrink(),
      floating: card.floating,
      onTap: () {
        _onCardTap(index);
      },
      title: card.title,
      titleStyle: card.titleStyle,
    );
  }

  Color _getOnSurfaceColor(Color? cardColor) {
    final color = cardColor ?? Theme.of(context).colorScheme.surface;
    return _colorCache.putIfAbsent(color, () {
      return HSLColor.fromColor(color)
          .withLightness(0.25)
          .withSaturation(0.2)
          .toColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          for (int index = 0; index < widget.cards.length; index++) ...[
            RepaintBoundary(
              key: ValueKey('card_$index'),
              child: _buildCard(widget.cards[index], index),
            ),
            if (index < widget.cards.length - 1) const SizedBox(height: 8),
          ],
        ],
        // children: [
        // ExpandableCard(
        //   color: allowedColors[0],
        //   isExpanded: expandedCardIndex == 0,
        //   isAboveCardExpanded: false,
        //   leading: MaterialClippedShape(
        //     MaterialShapes.gem,
        //     MaterialShapes.pentagon,
        //     color: HSLColor.fromColor(allowedColors[0])
        //         .withLightness(0.25)
        //         .withSaturation(0.2)
        //         .toColor(),
        //   ),
        //   onTap: () => _onCardTap(0),
        //   title: "Verde Plus",
        //   titleStyle: GoogleFonts.merriweather(
        //     fontWeight: FontWeight.w800,
        //   ),
        //   trailing: Text(
        //     "\$10",
        //     style: TextStyle(
        //         fontFamily: 'Roboto Flex',
        //         fontSize: 20,
        //         fontVariations: const [
        //           FontVariation('wght', 600),
        //           FontVariation('wdth', 25),
        //         ],
        //         color: HSLColor.fromColor(allowedColors[0])
        //             .withLightness(0.25)
        //             .withSaturation(0.2)
        //             .toColor()),
        //   ),
        // ),
        // const SizedBox(height: 8),
        // ExpandableCard(
        //   color: allowedColors[1],
        //   isExpanded: expandedCardIndex == 1,
        //   isAboveCardExpanded: expandedCardIndex == 0,
        //   leading: MaterialClippedShape(
        //     MaterialShapes.puffyDiamond,
        //     MaterialShapes.diamond,
        //     color: HSLColor.fromColor(allowedColors[1])
        //         .withLightness(0.25)
        //         .withSaturation(0.2)
        //         .toColor(),
        //   ),
        //   onTap: () => _onCardTap(1),
        //   title: "Aquacoin",
        //   titleStyle: GoogleFonts.bungee(
        //       foreground: Paint()
        //         ..style = PaintingStyle.stroke
        //         ..strokeWidth = 1
        //         ..color = Colors.black),
        //   trailing: Text(
        //     "\$70",
        //     style: TextStyle(
        //       fontFamily: 'Roboto Flex',
        //       fontSize: 20,
        //       fontVariations: const [
        //         FontVariation('wght', 600),
        //         FontVariation('wdth', 25),
        //       ],
        //       color: HSLColor.fromColor(allowedColors[1])
        //           .withLightness(0.25)
        //           .withSaturation(0.2)
        //           .toColor(),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 8),
        // ExpandableCard(
        //   color: allowedColors[2],
        //   isExpanded: expandedCardIndex == 2,
        //   isAboveCardExpanded: expandedCardIndex == 1,
        //   leading: MaterialClippedShape(
        //     MaterialShapes.circle,
        //     MaterialShapes.softBoom,
        //     color: HSLColor.fromColor(allowedColors[2])
        //         .withLightness(0.25)
        //         .withSaturation(0.2)
        //         .toColor(),
        //   ),
        //   onTap: () => _onCardTap(2),
        //   title: "Royal Preferred",
        //   titleStyle: GoogleFonts.corinthia(),
        //   trailing: Text(
        //     "\$150",
        //     style: TextStyle(
        //       fontFamily: 'Roboto Flex',
        //       fontSize: 20,
        //       fontVariations: const [
        //         FontVariation('wght', 600),
        //         FontVariation('wdth', 25),
        //       ],
        //       color: HSLColor.fromColor(allowedColors[2])
        //           .withLightness(0.25)
        //           .withSaturation(0.2)
        //           .toColor(),
        //     ),
        //   ),
        // ),
        // ],
      ),
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final bool isExpanded;
  final bool isAboveCardExpanded;
  final Widget leading;
  final Widget? trailing;
  final Widget? floating;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final String title;
  final Color? color;
  final TextStyle? titleStyle;

  const ExpandableCard({
    super.key,
    required this.isExpanded,
    required this.isAboveCardExpanded,
    required this.leading,
    this.trailing,
    this.floating,
    required this.onTap,
    this.padding = const EdgeInsets.only(left: 16, top: 16),
    required this.title,
    this.color,
    this.titleStyle,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with TickerProviderStateMixin {
  final ElegantSpring _curve = ElegantSpring.mediumBounce;
  final Duration _duration = const Duration(seconds: 1);

  static const double _expandedHeight = 200.0;
  static const double _collapsedHeight = 60.0;
  static const double _sandwichedHeight = 50.0;

  Color? _color;
  Color? _titleColor;
  Timer? _floatingTimer;
  double? _cachedScreenWidth;
  double? _cachedAvailableWidth;

  static const _fontSizeCollapsed = 34.0;
  static const _fontSizeExpanded = 72.0;

  static const _leadingSizeCollapsed = 32.0;
  static const _leadingSizeExpanded = 64.0;

  static const _gap = 42.0;

  static const _overshootDp = 10;

  double _fontSize = _fontSizeCollapsed;
  double _leadingSize = _leadingSizeCollapsed;
  Size _trailingSize = Size.zero;

  bool _isPressed = false;
  bool _showFloating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isExpanded) {
      _fontSize = _fontSizeExpanded;
      _leadingSize = _leadingSizeExpanded;
      _scheduleFloatingShow();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _color ??= widget.color ?? Theme.of(context).colorScheme.secondary;
    _titleColor ??= HSLColor.fromColor(_color ?? Colors.grey)
        .withLightness(0.3)
        .withSaturation(0.5)
        .toColor();

    // Cache screen width to avoid repeated MediaQuery calls
    final newScreenWidth = MediaQuery.of(context).size.width;
    if (_cachedScreenWidth != newScreenWidth) {
      _cachedScreenWidth = newScreenWidth;
      _cachedAvailableWidth = null; // Reset cached available width
    }
  }

  @override
  void didUpdateWidget(ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _floatingTimer?.cancel(); // Cancel any existing timer
      _cachedAvailableWidth = null; // Reset cached width on state change
      if (widget.isExpanded) {
        _fontSize = _fontSizeExpanded;
        _leadingSize = _leadingSizeExpanded;
        _scheduleFloatingShow();
      } else {
        _fontSize = _fontSizeCollapsed;
        _leadingSize = _leadingSizeCollapsed;
        _showFloating = false;
      }
    }
  }

  void _scheduleFloatingShow() {
    if (widget.floating != null) {
      _floatingTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted && widget.isExpanded) {
          setState(() {
            _showFloating = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _floatingTimer?.cancel();
    super.dispose();
  }

  Widget _buildLeadingWidget({required double top}) {
    return AnimatedPositioned(
      duration: _duration,
      curve: _curve,
      top: top,
      left: widget.padding.horizontal,
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          duration: _duration,
          curve: _curve,
          tween: Tween<double>(end: _leadingSize),
          builder: (context, value, child) {
            return SizedBox(
              height: value,
              width: value,
              child: child,
            );
          },
          child: widget.leading,
        ),
      ),
    );
  }

  Widget _buildTrailingWidget({required double top}) {
    return AnimatedPositioned(
      duration: _duration,
      curve: _curve,
      top: top,
      right: widget.padding.horizontal,
      child: MeasureSize(
        onChange: (size) {
          if (mounted) {
            setState(() {
              _trailingSize = size;
              _cachedAvailableWidth =
                  null; // Reset cached width when trailing size changes
            });
          }
        },
        child: widget.trailing!,
      ),
    );
  }

  double _getAvailableWidth() {
    if (widget.isExpanded) {
      return double.infinity;
    }

    // Use cached value if available and trailing size hasn't changed
    if (_cachedAvailableWidth != null) {
      return _cachedAvailableWidth!;
    }

    // Calculate and cache the available width
    _cachedAvailableWidth = (_cachedScreenWidth ?? 0) -
        (widget.padding.horizontal * 2) -
        _gap -
        _trailingSize.width -
        40; // extra padding

    return _cachedAvailableWidth!;
  }

  Widget _buildTitleWidget() {
    return RepaintBoundary(
      child: AnimatedPadding(
        duration: _duration,
        curve: _curve,
        padding: widget.isExpanded
            ? EdgeInsets.only(left: widget.padding.horizontal)
            : EdgeInsets.only(left: widget.padding.horizontal + _gap),
        child: AnimatedAlign(
          curve: _curve,
          duration: _duration,
          alignment:
              widget.isExpanded ? Alignment.bottomLeft : Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            duration: _duration,
            tween: Tween<double>(end: _fontSize),
            curve: _curve,
            builder: (context, value, child) {
              return SizedBox(
                width: _getAvailableWidth(),
                child: Text(
                  widget.title,
                  softWrap: false,
                  overflow:
                      widget.isExpanded ? TextOverflow.clip : TextOverflow.fade,
                  style: (widget.titleStyle ?? const TextStyle()).copyWith(
                    fontSize: value,
                    color: _titleColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingWidget() {
    return Positioned(
      bottom: widget.padding.vertical,
      right: widget.padding.horizontal,
      child: RepaintBoundary(
        child: AnimatedOpacity(
          opacity: _showFloating ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: _color ?? Colors.grey,
                width: 5.0,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: widget.floating,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double currentHeight = (widget.isExpanded
            ? _expandedHeight
            : widget.isAboveCardExpanded
                ? _collapsedHeight
                : _sandwichedHeight) +
        // add subtle overshoot feedback on press
        (_isPressed ? (widget.isExpanded ? -_overshootDp : _overshootDp) : 0);

    final double currentLeadingSize =
        widget.isExpanded ? _leadingSizeExpanded : _leadingSizeCollapsed;

    final double leadingTop = widget.isExpanded
        ? widget.padding.vertical
        : (currentHeight - currentLeadingSize) / 2;

    final double trailingHeight = _trailingSize.height;
    final double trailingTop = widget.isExpanded
        ? (_leadingSizeExpanded / 2) // center of leading widget
        : _trailingSize == Size.zero
            ? (currentHeight / 2) // fallback center if not measured yet
            : (currentHeight - trailingHeight) / 2; // center of card

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (details) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (details) {
          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _color ?? Colors.grey,
            borderRadius: widget.isExpanded
                ? const BorderRadius.all(Radius.circular(16))
                : widget.isAboveCardExpanded
                    ? const BorderRadius.all(Radius.circular(24))
                    : const BorderRadius.all(Radius.circular(36)),
          ),
          duration: _duration,
          curve: _curve,
          height: currentHeight,
          child: Stack(
            children: [
              _buildLeadingWidget(
                top: leadingTop,
              ),

              _buildTitleWidget(),

              if (widget.trailing != null)
                _buildTrailingWidget(top: trailingTop),

              // floating widget
              if (widget.floating != null) _buildFloatingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
