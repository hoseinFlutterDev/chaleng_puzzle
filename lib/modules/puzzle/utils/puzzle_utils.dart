import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class PuzzleUtils {
  /// تولید قطعات پازل
  static List<Rect> generatePuzzlePieces(
    ui.Image image, {
    int rows = 7,
    int cols = 7,
  }) {
    final pieceWidth = image.width / cols;
    final pieceHeight = image.height / rows;
    final List<Rect> pieces = [];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        pieces.add(
          Rect.fromLTWH(
            col * pieceWidth,
            row * pieceHeight,
            pieceWidth,
            pieceHeight,
          ),
        );
      }
    }
    return pieces;
  }

  /// پیدا کردن قطعه‌ای که کاربر روی آن کلیک کرده
  static Rect? findClickedPiece({
    required Offset position,
    required RenderBox renderBox,
    required ui.Image image,
    required List<Rect> pieces,
  }) {
    final localPosition = renderBox.globalToLocal(position);

    final scaleX = renderBox.size.width / image.width;
    final scaleY = renderBox.size.height / image.height;
    final scale = min(scaleX, scaleY);

    for (final piece in pieces) {
      final scaledPiece = Rect.fromLTWH(
        piece.left * scale,
        piece.top * scale,
        piece.width * scale,
        piece.height * scale,
      );

      if (scaledPiece.contains(localPosition)) {
        return piece;
      }
    }
    return null;
  }

  /// بارگزاری مسیر SVG
  static Future<String> loadRawSvgPathData(String assetPath) async {
    final svgString = await rootBundle.loadString(assetPath);
    final document = XmlDocument.parse(svgString);
    final pathElem = document.findAllElements('path').first;
    return pathElem.getAttribute('d') ?? '';
  }

  /// تولید قطعات جعلی برای انتخاب
  static List<Rect> generateFakePieces(Rect correct, List<Rect> allPieces) {
    final rnd = Random(), fake = <Rect>[];
    while (fake.length < 5) {
      final pick = allPieces[rnd.nextInt(allPieces.length)];
      if (pick != correct && !fake.contains(pick)) fake.add(pick);
    }
    return ([...fake, correct]..shuffle());
  }
}
