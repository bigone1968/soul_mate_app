import 'dart:math';
import 'package:flutter/material.dart';

class FlowerSpiritEyes extends StatelessWidget {
  final double pupilX;
  final double pupilY;
  final double blinkProgress;
  final Expression expression;
  final double width;
  final double height;

  const FlowerSpiritEyes({
    super.key,
    this.pupilX = 0,
    this.pupilY = 0,
    this.blinkProgress = 0,
    this.expression = Expression.neutral,
    this.width = double.infinity,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EyePainter(
          pupilX: pupilX,
          pupilY: pupilY,
          blinkProgress: blinkProgress,
          expression: expression,
        ),
      ),
    );
  }
}

enum Expression { neutral, happy, sleepy, curious }

class _EyePainter extends CustomPainter {
  final double pupilX;
  final double pupilY;
  final double blinkProgress;
  final Expression expression;

  _EyePainter({
    required this.pupilX,
    required this.pupilY,
    required this.blinkProgress,
    required this.expression,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 400;

    final blinkFactor = _getBlinkFactor();

    _drawLeftEye(canvas, centerX - 60 * scale, centerY, scale, blinkFactor);
    _drawRightEye(canvas, centerX + 60 * scale, centerY, scale, blinkFactor);
    _drawEyebrows(canvas, centerX, centerY, scale, blinkFactor);
  }

  double _getBlinkFactor() {
    if (blinkProgress <= 0 || blinkProgress >= 1) return 0;
    if (blinkProgress < 0.5) return blinkProgress * 2;
    return (1 - blinkProgress) * 2;
  }

  void _drawLeftEye(Canvas canvas, double cx, double cy, double scale, double blink) {
    _drawEye(canvas, cx, cy, scale, blink, -1);
  }

  void _drawRightEye(Canvas canvas, double cx, double cy, double scale, double blink) {
    _drawEye(canvas, cx, cy, scale, blink, 1);
  }

  void _drawEye(Canvas canvas, double cx, double cy, double scale, double blink, int direction) {
    final eyeWidth = 50 * scale;
    final eyeHeight = 30 * scale;
    final openHeight = eyeHeight * (1 - blink);

    final whitePaint = Paint()
      ..color = const Color(0xFFF0E8E0)
      ..style = PaintingStyle.fill;

    final eyePath = Path();
    eyePath.moveTo(cx - eyeWidth, cy);
    eyePath.cubicTo(
      cx - eyeWidth,
      cy - openHeight,
      cx + eyeWidth,
      cy - openHeight,
      cx + eyeWidth,
      cy,
    );
    eyePath.cubicTo(
      cx + eyeWidth,
      cy + openHeight,
      cx - eyeWidth,
      cy + openHeight,
      cx - eyeWidth,
      cy,
    );
    canvas.drawPath(eyePath, whitePaint);

    final strokePaint = Paint()
      ..color = const Color(0xFFD4C4B5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(eyePath, strokePaint);

    if (blink < 0.9) {
      _drawIris(canvas, cx, cy, scale, direction);
    }
  }

  void _drawIris(Canvas canvas, double cx, double cy, double scale, int direction) {
    final irisRadius = 16 * scale;
    final pupilRadius = 7 * scale;

    final px = cx + pupilX * 15 * scale;
    final py = cy + pupilY * 10 * scale;

    final irisPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFF8B4513),
          Color(0xFF5C2E0A),
          Color(0xFF3A1A05),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(px, py), radius: irisRadius));
    canvas.drawCircle(Offset(px, py), irisRadius, irisPaint);

    final pupilPaint = Paint()..color = const Color(0xFF0A050E);
    canvas.drawCircle(Offset(px, py), pupilRadius, pupilPaint);

    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(px + 4 * scale, py - 4 * scale), 3 * scale, highlightPaint);

    final smallHighlight = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(px - 3 * scale, py + 3 * scale), 1.5 * scale, smallHighlight);
  }

  void _drawEyebrows(Canvas canvas, double cx, double cy, double scale, double blink) {
    final paint = Paint()
      ..color = const Color(0xFF5C4A3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;

    final browY = cy - 35 * scale;
    final browWidth = 30 * scale;

    double leftBrowY = browY;
    double rightBrowY = browY;

    if (expression == Expression.happy) {
      leftBrowY += 3 * scale;
      rightBrowY += 3 * scale;
    } else if (expression == Expression.sleepy) {
      leftBrowY += 5 * scale;
      rightBrowY += 5 * scale;
    } else if (expression == Expression.curious) {
      leftBrowY -= 3 * scale;
      rightBrowY -= 3 * scale;
    }

    final leftPath = Path();
    leftPath.moveTo(cx - 60 * scale - browWidth, leftBrowY);
    leftPath.cubicTo(
      cx - 60 * scale - browWidth * 0.5, leftBrowY - 3 * scale,
      cx - 60 * scale + browWidth * 0.5, leftBrowY + 3 * scale,
      cx - 60 * scale + browWidth, leftBrowY,
    );
    canvas.drawPath(leftPath, paint);

    final rightPath = Path();
    rightPath.moveTo(cx + 60 * scale - browWidth, rightBrowY);
    rightPath.cubicTo(
      cx + 60 * scale - browWidth * 0.5, rightBrowY + 3 * scale,
      cx + 60 * scale + browWidth * 0.5, rightBrowY - 3 * scale,
      cx + 60 * scale + browWidth, rightBrowY,
    );
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant _EyePainter oldDelegate) =>
      oldDelegate.pupilX != pupilX ||
      oldDelegate.pupilY != pupilY ||
      oldDelegate.blinkProgress != blinkProgress ||
      oldDelegate.expression != expression;
}