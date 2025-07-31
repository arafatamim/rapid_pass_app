import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  static final List<RoundedPolygon> _indicatorPolygons = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.verySunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
  ];

  late final List<Morph> _morphSequence;
  late final AnimationController _morphController;
  late final AnimationController _globalRotationController;

  int _currentMorphIndex = 0;
  double _morphRotationTargetAngle = _quarterRotation;
  Timer? _morphTimer;

  static const int _globalRotationDurationMs = 4666;
  static const int _morphIntervalMs = 650;
  static const double _fullRotation = 360.0;
  static const double _quarterRotation = _fullRotation / 4;

  static const double _activeIndicatorScale = 0.5;

  final _morphAnimationSpec = SpringSimulation(
    SpringDescription.withDampingRatio(
      ratio: 0.5,
      stiffness: 400.0,
      mass: 1.0,
    ),
    0.0,
    1.0,
    5.0,
    snapToEnd: true,
  );

  @override
  void initState() {
    super.initState();

    _morphSequence =
        _createMorphSequence(_indicatorPolygons, circularSequence: true);

    _morphController = AnimationController.unbounded(vsync: this);

    // continuous linear rotation
    _globalRotationController = AnimationController(
      duration: const Duration(milliseconds: _globalRotationDurationMs),
      vsync: this,
    );

    _startAnimations();
  }

  @override
  void dispose() {
    _morphTimer?.cancel();
    _morphController.dispose();
    _globalRotationController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    // Start global rotation (infinite linear rotation)
    _globalRotationController.repeat();

    // Start periodic morph cycle
    _morphTimer = Timer.periodic(
      const Duration(milliseconds: _morphIntervalMs),
      (_) => _startMorphCycle(),
    );

    // Start first morph immediately
    _startMorphCycle();
  }

  void _startMorphCycle() {
    if (!mounted) return;

    // Move to next morph in sequence
    _currentMorphIndex = (_currentMorphIndex + 1) % _morphSequence.length;

    // Accumulate rotation target
    _morphRotationTargetAngle =
        (_morphRotationTargetAngle + _quarterRotation) % _fullRotation;

    // Reset and start morph animation
    _morphController
      ..value = 0.0
      ..animateWith(_morphAnimationSpec);
  }

  List<Morph> _createMorphSequence(List<RoundedPolygon> polygons,
      {required bool circularSequence}) {
    final morphs = <Morph>[];

    for (int i = 0; i < polygons.length; i++) {
      if (i + 1 < polygons.length) {
        morphs.add(Morph(polygons[i], polygons[i + 1]));
      } else if (circularSequence) {
        // Create morph from last shape back to first shape
        morphs.add(Morph(polygons[i], polygons[0]));
      }
    }

    return morphs;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: AnimatedBuilder(
          animation:
              Listenable.merge([_morphController, _globalRotationController]),
          builder: (context, child) {
            final morphProgress = _morphController.value.clamp(0.0, 1.0);
            final globalRotationDegrees =
                _globalRotationController.value * _fullRotation;

            // Calculate total rotation (clockwise, matching Kotlin implementation)
            final totalRotationDegrees = morphProgress * _quarterRotation +
                _morphRotationTargetAngle +
                globalRotationDegrees;

            final totalRotationRadians =
                totalRotationDegrees * (math.pi / 180.0);

            return Transform.rotate(
              angle: totalRotationRadians,
              child: CustomPaint(
                painter: _MorphPainter(
                  morph: _morphSequence[_currentMorphIndex],
                  progress: morphProgress,
                  color: Theme.of(context).colorScheme.primary,
                  scaleFactor: _activeIndicatorScale,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  const _MorphPainter({
    required this.morph,
    required this.progress,
    required this.color,
    this.scaleFactor = 1.0,
  });

  final Morph morph;
  final double progress;
  final Color color;
  final double scaleFactor;

  Path _processPath(Path path, Size size) {
    final pathBounds = path.getBounds();
    if (pathBounds.isEmpty) {
      return path;
    }

    final scaleX = (size.width / pathBounds.width) * scaleFactor;
    final scaleY = (size.height / pathBounds.height) * scaleFactor;
    final scale = math.min(scaleX, scaleY);

    if (scale == 0.0) {
      return path;
    }

    final matrix = Matrix4.identity();
    matrix.scale(scale, scale);
    matrix.translate(
      (size.width / 2) / scale - pathBounds.center.dx,
      (size.height / 2) / scale - pathBounds.center.dy,
    );

    return path.transform(matrix.storage);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = morph.toPath(progress: progress);
    final processedPath = _processPath(path, size);
    canvas.drawPath(
      processedPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_MorphPainter oldDelegate) {
    return oldDelegate.morph != morph ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
