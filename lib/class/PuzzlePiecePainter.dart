import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PuzzlePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect rect;

  PuzzlePiecePainter({required this.image, required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(
      image,
      rect,
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
