import 'package:flutter/material.dart';
import 'dart:math';

class FlippableCardController extends ChangeNotifier {
  bool _isFront = true;

  bool get isFront => _isFront;
  set isFront(bool value) {
    _isFront = value;
    notifyListeners();
  }

  final ChangeNotifier _notifyFlip = ChangeNotifier();

  /// Flip the card
  void flipCard() {
    _notifyFlip.notifyListeners();
  }
}

/// [FlippableCard]  A component that provides a gsture flip card animation
class FlippableCard extends StatefulWidget {
  ///[frontWidget] The Front side widget of the card
  final Widget frontWidget;

  /// [controller] used to control the Gesture flip programmatically
  final FlippableCardController? controller;

  ///[backWidget] The Back side widget of the card
  final Widget backWidget;

  /// [axis] The flip axis [Horizontal] and [Vertical]
  final Axis axis;

  /// [primaryDuration] The amount of milliseconds a turn animation will take.
  final Duration primaryDuration;

  final Duration? secondaryDuration;

  final Curve primaryCurve;

  final Curve? secondaryCurve;

  const FlippableCard({
    super.key,
    required this.frontWidget,
    required this.backWidget,
    this.controller,
    this.axis = Axis.vertical,
    this.primaryDuration = const Duration(milliseconds: 800),
    this.secondaryDuration = const Duration(milliseconds: 300),
    this.primaryCurve = Curves.easeOut,
    this.secondaryCurve,
  });

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard>
    with SingleTickerProviderStateMixin {
  bool _isFrontStart = true;
  double _dragPosition = 0;

  late final AnimationController _animationController;
  late final Duration _secondaryDuration;
  Animation<double>? _animation;

  FlippableCardController? _flipCardController;
  FlippableCardController get _effectiveController =>
      widget.controller ?? _flipCardController!;

  void _createLocalController() {
    assert(_flipCardController == null);
    _flipCardController = FlippableCardController();
  }

  @override
  void initState() {
    super.initState();

    _createLocalController();

    _animationController = AnimationController(
      duration: widget.primaryDuration,
      vsync: this,
    );
    _animationController.addListener(() {
      if (_animation != null) {
        setState(() {
          _dragPosition = _animation!.value;
          setFacingDirection();
        });
      }
    });

    if (widget.secondaryDuration != null) {
      _secondaryDuration = widget.secondaryDuration!;
    } else {
      _secondaryDuration = widget.primaryDuration;
    }

    _effectiveController._notifyFlip.addListener(() {
      _flipCard();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flipCardController?.dispose();
    super.dispose();
  }

  void _flipCard() {
    double end = _isFrontStart ? (_dragPosition > 180 ? 360 : 0) : 180;
    _animation = Tween<double>(
      begin: _dragPosition,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _animationController..duration = _secondaryDuration,
        curve: widget.secondaryCurve ?? widget.primaryCurve,
      ),
    );
    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0);
    }
    _isFrontStart = !(_dragPosition <= 90 || _dragPosition >= 270);
  }

  void _onDragStart(DragStartDetails details) {
    _animationController.stop();
    _isFrontStart = _effectiveController._isFront;
  }

  void _onDragUpdate(DragUpdateDetails details, Axis direction) {
    setState(() {
      if (direction == Axis.horizontal) {
        _dragPosition += details.delta.dy;
      }
      if (direction == Axis.vertical) {
        _dragPosition -= details.delta.dx;
      }
      _dragPosition %= 360;
      setFacingDirection();
    });
  }

  void _onDragEnd(DragEndDetails details, Axis direction) {
    final double velocity;
    if (direction == Axis.horizontal) {
      velocity = details.velocity.pixelsPerSecond.dx.abs();
    } else {
      velocity = details.velocity.pixelsPerSecond.dy.abs();
    }
    if (velocity >= 100) {
      _effectiveController._isFront = !_isFrontStart;
    }
    double end =
        _effectiveController._isFront ? (_dragPosition > 180 ? 360 : 0) : 180;
    _animation = Tween<double>(
      begin: _dragPosition,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.primaryCurve,
      ),
    );
    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    double angle = _dragPosition / 180 * pi;
    late Matrix4 transform;
    late Matrix4 transformForBack;

    if (widget.axis == Axis.horizontal) {
      transform = Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(angle);
      transformForBack = Matrix4.identity()..rotateX(pi);
    } else {
      transform = Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angle);
      transformForBack = Matrix4.identity()..rotateY(pi);
    }

    final child = Transform(
      transform: transform,
      alignment: Alignment.center,
      child: _effectiveController._isFront
          ? widget.frontWidget
          : Transform(
              transform: transformForBack,
              alignment: Alignment.center,
              child: widget.backWidget,
            ),
    );

    GestureDetector horizontalRotate = GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: (details) =>
          _onDragUpdate(details, Axis.vertical),
      onHorizontalDragEnd: (details) => _onDragEnd(details, Axis.vertical),
      child: child,
    );

    GestureDetector verticalRotate = GestureDetector(
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: (details) =>
          _onDragUpdate(details, Axis.horizontal),
      onVerticalDragEnd: (details) => _onDragEnd(details, Axis.horizontal),
      child: child,
    );

    return widget.axis == Axis.vertical ? horizontalRotate : verticalRotate;
  }

  void setFacingDirection() {
    if (_dragPosition <= 90 || _dragPosition >= 270) {
      _effectiveController.isFront = true;
    } else {
      _effectiveController.isFront = false;
    }
  }
}
