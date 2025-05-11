import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:puzzle_test/modules/puzzle/bottom/clip_path.dart';
import 'package:video_player/video_player.dart';

class PuzzleWidget extends StatelessWidget {
  final ui.Image? loadedImage;
  final List<Rect> pieces;
  final Rect? removedPiece;
  final Offset? removedPieceOffset;
  final List<Rect> fakePieces;
  final AnimationController? animationController;
  final Animation<Offset>? animation;
  final GlobalKey puzzleKey;
  final String? selectedSvgPath;
  final Rect? svgTargetRect;
  final List<Rect> panelPieces;
  final String? userSelectedRawSvgPath;
  final VideoPlayerController? videoController;
  final bool isVideo;
  final GlobalKey videoGlobalKey;
  final bool showSvgOnImage;
  final void Function(Offset)? onCanvasClick;

  const PuzzleWidget({
    Key? key,
    required this.loadedImage,
    required this.pieces,
    required this.removedPiece,
    required this.removedPieceOffset,
    required this.fakePieces,
    required this.animationController,
    required this.animation,
    required this.puzzleKey,
    required this.selectedSvgPath,
    required this.svgTargetRect,
    required this.panelPieces,
    required this.userSelectedRawSvgPath,
    required this.videoController,
    required this.isVideo,
    required this.videoGlobalKey,
    required this.showSvgOnImage,
    this.onCanvasClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loadedImage == null && !isVideo) {
      return const Center(child: Text('هیچ عکسی انتخاب نشده است.'));
    }

    if (isVideo && videoController != null) {
      return Center(
        child: RepaintBoundary(
          key: videoGlobalKey,
          child: AspectRatio(
            aspectRatio: videoController!.value.aspectRatio,
            child: VideoPlayer(videoController!),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (details) {
        if (selectedSvgPath != null && onCanvasClick != null) {
          onCanvasClick!(details.globalPosition);
        }
      },
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              key: puzzleKey,
              decoration: BoxDecoration(
                color: const ui.Color.fromARGB(208, 0, 0, 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: loadedImage!.width.toDouble(),
                  height: loadedImage!.height.toDouble(),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(
                          loadedImage!.width.toDouble(),
                          loadedImage!.height.toDouble(),
                        ),
                        painter: PuzzlePainter(
                          image: loadedImage!,
                          pieces: pieces,
                        ),
                      ),
                      if (svgTargetRect != null && showSvgOnImage)
                        Positioned(
                          left: svgTargetRect!.left,
                          top: svgTargetRect!.top,
                          width: svgTargetRect!.width + 30,
                          height: svgTargetRect!.height,
                          child: SvgPicture.asset(
                            selectedSvgPath!,
                            fit: BoxFit.fill,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
