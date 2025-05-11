import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final GlobalKey repaintKey;

  const VideoPlayerWidget({
    Key? key,
    required this.controller,
    required this.repaintKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenSize = MediaQuery.of(context).size;
    final videoAspectRatio = controller.value.aspectRatio;

    final maxHeight = screenSize.height - 100;
    final maxWidth = screenSize.width;

    double width = maxWidth;
    double height = width / videoAspectRatio;

    if (height > maxHeight) {
      height = maxHeight;
      width = height * videoAspectRatio;
    }

    return Center(
      child: RepaintBoundary(
        key: repaintKey,
        child: SizedBox(
          width: width,
          height: height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
