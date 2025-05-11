import 'package:flutter/material.dart';
import 'package:puzzle_test/modules/puzzle/bottom/clip_path.dart';
import 'dart:ui' as ui;

class PanelPieceWidget extends StatelessWidget {
  final ui.Image? loadedImage;
  final Rect? removedPiece;
  final String? userSelectedRawSvgPath;
  final void Function()? onPieceTap;

  const PanelPieceWidget({
    Key? key,
    required this.loadedImage,
    required this.removedPiece,
    required this.userSelectedRawSvgPath,
    this.onPieceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (removedPiece == null || loadedImage == null) {
      return const Center(child: Text('...در حال بارگذاری قطعه'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final panelSize = screenWidth * 0.3;

    return Center(
      child: GestureDetector(
        onTap: onPieceTap,
        child: Container(
          width: panelSize,
          height: panelSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: const ui.Color.fromARGB(255, 76, 175, 87),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: PuzzlePieceClipPathPainter(
              image: loadedImage!,
              rect: removedPiece!,
              rawSvgPath: userSelectedRawSvgPath,
            ),
          ),
        ),
      ),
    );
  }
}
