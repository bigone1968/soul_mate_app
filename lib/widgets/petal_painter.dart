import 'dart:math';
import 'package:flutter/material.dart';

class FallingPetal {
  double x;
  double y;
  double size;
  double rotation;
  double rotationSpeed;
  double fallSpeed;
  double swayAmplitude;
  double swaySpeed;
  double swayOffset;
  double opacity;
  int type;

  FallingPetal({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.fallSpeed,
    required this.swayAmplitude,
    required this.swaySpeed,
    required this.swayOffset,
    required this.opacity,
    required this.type,
  });
}

class PetalPainter extends CustomPainter {
  final List<FallingPetal> petals;
  final double time;

  PetalPainter({required this.petals, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final petal in petals) {
      canvas.save();
      canvas.translate(
        petal.x + sin(time * petal.swaySpeed + petal.swayOffset) * petal.swayAmplitude,
        petal.y + time * petal.fallSpeed * 60 % (size.height + 100) - 50,
      );
      canvas.rotate(petal.rotation + time * petal.rotationSpeed);

      final paint = Paint()
        ..color = Color(0xFFC0392B).withOpacity(petal.opacity * 0.35)
        ..style = PaintingStyle.fill;

      if (petal.type == 0) {
        _drawSpiderLilyPetal(canvas, petal.size, paint);
      } else if (petal.type == 1) {
        _drawRoundPetal(canvas, petal.size * 0.7, paint);
      } else {
        _drawLongPetal(canvas, petal.size * 0.6, paint);
      }

      canvas.restore();
    }
  }

  void _drawSpiderLilyPetal(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final w = size;
    final h = size * 3.5;
    path.moveTo(0, -h / 2);
    path.cubicTo(w * 0.4, -h * 0.35, w * 0.3, h * 0.2, 0, h / 2);
    path.cubicTo(-w * 0.3, h * 0.2, -w * 0.4, -h * 0.35, 0, -h / 2);
    path.close();

    paint.style = PaintingStyle.fill;
    final subPaint = Paint()
      ..color = Color(0xFFA93226).withOpacity(paint.color.opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(path, subPaint);
    canvas.drawPath(path, paint);
  }

  void _drawRoundPetal(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size / 2);
    path.quadraticBezierTo(size * 0.5, -size * 0.25, size * 0.4, 0);
    path.quadraticBezierTo(size * 0.3, size * 0.4, 0, size / 2);
    path.quadraticBezierTo(-size * 0.3, size * 0.2, -size * 0.4, 0);
    path.quadraticBezierTo(-size * 0.5, -size * 0.25, 0, -size / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLongPetal(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size);
    path.cubicTo(size * 0.15, -size * 0.5, size * 0.1, size * 0.3, 0, size);
    path.cubicTo(-size * 0.1, size * 0.3, -size * 0.15, -size * 0.5, 0, -size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PetalPainter oldDelegate) => true;
}

List<FallingPetal> generatePetals(int count, double width, double height) {
  final random = Random(42);
  return List.generate(count, (i) {
    return FallingPetal(
      x: random.nextDouble() * (width + 60) - 30,
      y: random.nextDouble() * height,
      size: 4 + random.nextDouble() * 8,
      rotation: random.nextDouble() * pi * 2,
      rotationSpeed: -0.3 + random.nextDouble() * 0.6,
      fallSpeed: 0.15 + random.nextDouble() * 0.35,
      swayAmplitude: 10 + random.nextDouble() * 25,
      swaySpeed: 0.3 + random.nextDouble() * 0.5,
      swayOffset: random.nextDouble() * pi * 2,
      opacity: 0.3 + random.nextDouble() * 0.7,
      type: random.nextInt(3),
    );
  });
}