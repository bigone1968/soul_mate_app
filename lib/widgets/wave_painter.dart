import 'dart:math';
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double amplitude;
  final double phase;

  WavePainter({required this.amplitude, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 10 || size.height < 10) return;

    final barCount = 31;
    final gap = 1.0;
    final totalGap = (barCount - 1) * gap;
    final barWidth = (size.width - totalGap) / barCount;
    final centerY = size.height / 2;
    final maxBarHeight = size.height * 0.8;

    final paint = Paint()
      ..color = Color(0xFFC0392B).withOpacity(0.2 + amplitude * 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final normalizedIndex = i / (barCount - 1);
      final wave = sin(phase + normalizedIndex * pi * 2) * 0.5 +
          sin(phase * 2 + normalizedIndex * pi * 4) * 0.3 +
          sin(phase * 0.5 + normalizedIndex * pi * 8) * 0.2;
      final barHeight = ((wave + 1) / 2) * amplitude * maxBarHeight;
      final x = i * (barWidth + gap);

      if (barHeight > 0) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, centerY - barHeight / 2, barWidth, barHeight),
          Radius.circular(barWidth / 2),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return true;
  }
}