import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:puzzle_test/modules/puzzle/model/puzzle.dart';

class PuzzleHelper {
  static List<Rect> generatePieces(ui.Image image, int rows, int cols) {
    final List<Rect> pieces = [];
    final pieceWidth = image.width / cols;
    final pieceHeight = image.height / rows;

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

  static List<Rect> generateFakePieces(Rect correct, List<Rect> allPieces) {
    final rnd = Random();
    final fake = <Rect>[];

    while (fake.length < 5) {
      final pick = allPieces[rnd.nextInt(allPieces.length)];
      if (pick != correct && !fake.contains(pick)) fake.add(pick);
    }

    return [...fake, correct]..shuffle();
  }

  static CorrectPieceRect toCorrectPieceRect(Rect rect) {
    return CorrectPieceRect(
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );
  }

  static FakePieces toFakePieceRect(Rect rect) {
    return FakePieces(
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );
  }

  static Rect getCenterSvgRect(
    ui.Image image,
    RenderBox renderBox,
    double scaleRatio,
  ) {
    final boxSize = renderBox.size;
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    final scaleX = boxSize.width / imageWidth;
    final scaleY = boxSize.height / imageHeight;
    final scale = min(scaleX, scaleY);

    final svgDisplayWidth = boxSize.width * scaleRatio;
    final svgDisplayHeight = boxSize.height * scaleRatio;

    final offsetX = (boxSize.width - imageWidth * scale) / 2;
    final offsetY = (boxSize.height - imageHeight * scale) / 2;
    final centerX = offsetX + (imageWidth * scale) / 2;
    final centerY = offsetY + (imageHeight * scale) / 2;

    final svgLeft = (centerX - svgDisplayWidth / 2 - offsetX) / scale;
    final svgTop = (centerY - svgDisplayHeight / 2 - offsetY) / scale;

    return Rect.fromLTWH(
      svgLeft,
      svgTop,
      svgDisplayWidth / scale,
      svgDisplayHeight / scale,
    );
  }
}
