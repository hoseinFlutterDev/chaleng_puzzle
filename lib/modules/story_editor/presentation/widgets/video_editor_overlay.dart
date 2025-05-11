import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoEditorOverlay extends StatelessWidget {
  final VideoPlayerController? controller;
  final VoidCallback onDone;

  const VideoEditorOverlay({
    super.key,
    required this.controller,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.95),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text("ویرایش ویدیو"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: onDone,
                ),
              ],
            ),
            Expanded(
              child:
                  controller != null && controller!.value.isInitialized
                      ? AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: VideoPlayer(controller!),
                      )
                      : const Center(child: CircularProgressIndicator()),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.pause_circle, color: Colors.white, size: 30),
                  Icon(Icons.text_fields, color: Colors.white, size: 30),
                  Icon(Icons.photo_filter, color: Colors.white, size: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
