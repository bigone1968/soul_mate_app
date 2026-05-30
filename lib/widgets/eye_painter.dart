import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class EyePainter extends CustomPainter {
  final double pupilX;
  final double pupilY;
  final double blinkProgress;
  final String expression;

  EyePainter({
    required this.pupilX,
    required this.pupilY,
    required this.blinkProgress,
    required this.expression,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (w < 10 || h < 10) return;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final idleBob = sin(time * 1.3) * 1.5;

    final baseEyeRX = w * 0.085;
    final baseEyeRY = w * 0.125;
    final eyeCenterY = h * 0.38 + idleBob;

    double eyeRX = baseEyeRX;
    double eyeRY = baseEyeRY;
    double eyelidLower = 0;
    double pupilDrop = 0;
    double bottomLift = 0;
    double browRaiseL = 0;
    double browRaiseR = 0;

    switch (expression) {
      case 'happy':
        eyelidLower = 0.18;
        bottomLift = 0.08;
        break;
      case 'sleepy':
        eyelidLower = 0.42;
        pupilDrop = 0.25;
        break;
      case 'curious':
        eyeRY = baseEyeRY * 1.15;
        browRaiseR = 1;
        break;
    }

    final pX = pupilX.clamp(-1.0, 1.0);
    final pY = pupilY.clamp(-1.0, 1.0);

    final leftEyeX = w * 0.35;
    final rightEyeX = w * 0.65;

    drawSingleEye(canvas, leftEyeX, eyeCenterY, eyeRX, eyeRY, pX, pY + pupilDrop, blinkProgress, eyelidLower, bottomLift, browRaiseL, time, w);
    drawSingleEye(canvas, rightEyeX, eyeCenterY, eyeRX, eyeRY, pX, pY + pupilDrop, blinkProgress, eyelidLower, bottomLift, browRaiseR, time, w);
  }

  void drawSingleEye(Canvas canvas, double cx, double cy, double rx, double ry, double pX, double pY, double blink, double eyelidLower, double bottomLift, double browRaise, double time, double w) {
    final irisR = rx * 0.72;
    final maxIrisDX = rx * 0.35;
    final maxIrisDY = ry * 0.2;
    final irisCX = cx + pX * maxIrisDX;
    final irisCY = cy + pY * maxIrisDY;

    final lidTopY = cy - ry * 1.15;
    final lidBottomY = cy - ry * 0.85;
    final eyelidRange = ry * 1.7;

    double lidY = lidBottomY + eyelidRange * blink + eyelidLower * eyelidRange;

    if (blink > 0.95) {
      lidY = cy + ry * 0.85;
    }

    canvas.save();

    final eyePath = Path();
    eyePath.moveTo(cx - rx, cy);
    eyePath.cubicTo(cx - rx, cy - ry * 1.2, cx + rx, cy - ry * 1.2, cx + rx, cy);
    final bottomRy = ry * (0.85 - bottomLift * 0.5);
    eyePath.cubicTo(cx + rx, cy + bottomRy, cx - rx, cy + bottomRy, cx - rx, cy);
    eyePath.close();

    final eyePaint = Paint()..color = const Color(0xFFfefefe);
    canvas.drawPath(eyePath, eyePaint);
    canvas.clipPath(eyePath);

    final colorShift = sin(time * 0.35) * 0.04;
    final hueBase = 32 + colorShift * 30;

    final irisPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(irisCX, irisCY),
        irisR,
        [
          HSLColor.fromAHSL(1.0, hueBase + 15, 0.58, 0.72).toColor(),
          HSLColor.fromAHSL(1.0, hueBase + 5, 0.52, 0.60).toColor(),
          HSLColor.fromAHSL(1.0, hueBase - 5, 0.55, 0.48).toColor(),
          HSLColor.fromAHSL(1.0, hueBase - 15, 0.58, 0.35).toColor(),
        ],
        [0.0, 0.4, 0.75, 1.0],
      );
    canvas.drawOval(Rect.fromCenter(center: Offset(irisCX, irisCY), width: irisR * 2, height: irisR * 2), irisPaint);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCenter(center: Offset(irisCX, irisCY), width: irisR * 2, height: irisR * 2)));

    final striaePaint = Paint()
      ..color = HSLColor.fromAHSL(0.12, hueBase - 10, 0.45, 0.40).toColor()
      ..strokeWidth = 1.2;
    for (int i = 0; i < 14; i++) {
      final angle = (i / 14) * pi * 2;
      canvas.drawLine(
        Offset(irisCX, irisCY),
        Offset(irisCX + cos(angle) * irisR, irisCY + sin(angle) * irisR),
        striaePaint,
      );
    }

    final ringPaint = Paint()
      ..color = HSLColor.fromAHSL(0.2, hueBase - 5, 0.50, 0.35).toColor()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final ringR = irisR * 0.6;
    canvas.drawOval(Rect.fromCenter(center: Offset(irisCX, irisCY), width: ringR * 2, height: ringR * 2), ringPaint);

    canvas.restore();

    final pupilPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(irisCX, irisCY),
        irisR * 0.45,
        [
          const Color(0xFF2a2a2a),
          const Color(0xFF111111),
          const Color(0xFF050505),
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawOval(Rect.fromCenter(center: Offset(irisCX, irisCY), width: irisR * 0.45 * 2, height: irisR * 0.52 * 2), pupilPaint);

    final hl1X = irisCX + irisR * 0.28;
    final hl1Y = irisCY - irisR * 0.32;
    final hl1R = irisR * 0.2;
    canvas.save();
    canvas.translate(hl1X, hl1Y);
    canvas.rotate(-0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: hl1R * 1.15 * 2, height: hl1R * 0.8 * 2), Paint()..color = const Color.fromRGBO(255, 255, 255, 0.92));
    canvas.restore();

    final hl2X = irisCX - irisR * 0.22;
    final hl2Y = irisCY + irisR * 0.18;
    final hl2R = irisR * 0.09;
    canvas.save();
    canvas.translate(hl2X, hl2Y);
    canvas.rotate(0.4);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: hl2R * 2, height: hl2R * 0.75 * 2), Paint()..color = const Color.fromRGBO(255, 255, 255, 0.55));
    canvas.restore();

    canvas.restore();

    if (lidY > lidTopY) {
      final lidPath = Path();
      lidPath.moveTo(cx - rx - 4, lidTopY - 4);
      lidPath.lineTo(cx + rx + 4, lidTopY - 4);
      lidPath.lineTo(cx + rx + 4, lidY);
      lidPath.quadraticBezierTo(cx, lidY + ry * 0.07, cx - rx - 4, lidY);
      lidPath.close();
      canvas.drawPath(lidPath, Paint()..color = const Color(0xFFf7d5b8));
    }

    if (lidY > lidBottomY - ry * 0.1) {
      final lidLinePath = Path();
      lidLinePath.moveTo(cx - rx, lidY);
      lidLinePath.quadraticBezierTo(cx, lidY - ry * 0.04, cx + rx, lidY);
      canvas.drawPath(lidLinePath, Paint()
        ..color = const Color(0xFF3d2b1f)
        ..strokeWidth = max(1.5, 2.5 - blink * 2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);

      if (blink < 0.85) {
        final lashCount = 8;
        for (int i = 0; i < lashCount; i++) {
          final t = i / (lashCount - 1);
          final lashX = cx - rx * 0.75 + t * rx * 1.5;
          final lashLen = (3 + (1 - (t - 0.5).abs() * 2) * 7) * (1 - blink * 0.4);
          final lashAngle = -0.35 + t * 0.7;
          canvas.drawLine(
            Offset(lashX, lidY),
            Offset(lashX + sin(lashAngle) * lashLen, lidY - cos(lashAngle) * lashLen),
            Paint()
              ..color = const Color(0xFF3d2b1f)
              ..strokeWidth = 1.8 - (t - 0.5).abs() * 1.2,
          );
        }
      }
    }

    final browBaseY = cy - ry * 1.35;
    final browY = browBaseY - (browRaise > 0.5 ? ry * 0.3 : 0);

    final browPath = Path();
    browPath.moveTo(cx - rx * 0.75, browY);
    browPath.quadraticBezierTo(
      cx,
      browY - ry * 0.18 - (browRaise > 0.5 ? ry * 0.18 : 0),
      cx + rx * 0.75,
      browY,
    );
    canvas.drawPath(browPath, Paint()
      ..color = const Color(0xFF3d2b1f)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    if (browRaise > 0.5) {
      final browInnerPath = Path();
      browInnerPath.moveTo(cx - rx * 0.75, browY);
      browInnerPath.quadraticBezierTo(cx, browY - ry * 0.08, cx + rx * 0.75, browY);
      canvas.drawPath(browInnerPath, Paint()
        ..color = const Color(0xFF3d2b1f)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant EyePainter oldDelegate) => true;
}