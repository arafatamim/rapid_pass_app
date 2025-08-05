import 'package:flutter/material.dart';
import 'package:material_shapes/material_shapes.dart';

import 'dart:typed_data';

class MaterialShapePainter extends CustomPainter {
  final RoundedPolygon roundedPolygon;
  final Color color;

  const MaterialShapePainter({
    required this.roundedPolygon,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas
      ..scale(size.width)
      ..drawPath(roundedPolygon.toPath(), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MaterialShape extends StatelessWidget {
  final RoundedPolygon roundedPolygon;
  final Color? color;
  final double? size;

  const MaterialShape(
    this.roundedPolygon, {
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MaterialShapePainter(
        roundedPolygon: roundedPolygon,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
      // size: Size.square(size),
    );
  }
}

/// A painter that clips a background shape with a foreground shape.
class MaterialClippedShapePainter extends CustomPainter {
  final RoundedPolygon background;
  final RoundedPolygon foreground;
  final Color color;

  const MaterialClippedShapePainter({
    required this.background,
    required this.foreground,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.scale(size.width);
    final bgPath = background.toPath();
    canvas.drawPath(bgPath, paint);
    const s = 0.7;
    final dx = (1 - s) / 2;
    final dy = (1 - s) / 2;
    var fgPath = foreground.toPath();
    fgPath = fgPath.transform(Float64List.fromList([
      s,
      0,
      0,
      0,
      0,
      s,
      0,
      0,
      0,
      0,
      1,
      0,
      dx,
      dy,
      0,
      1,
    ]));
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    canvas.drawPath(fgPath, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// A widget that draws a clipped material shape.
class MaterialClippedShape extends StatelessWidget {
  final RoundedPolygon background;
  final RoundedPolygon foreground;
  final Color? color;
  final double? size;

  const MaterialClippedShape(
    this.background,
    this.foreground, {
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // If a size is provided, wrap in SizedBox to enforce dimensions.
    if (size != null) {
      return SizedBox.square(
        dimension: size!,
        child: CustomPaint(
          painter: MaterialClippedShapePainter(
            background: background,
            foreground: foreground,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    return CustomPaint(
      painter: MaterialClippedShapePainter(
        background: background,
        foreground: foreground,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
