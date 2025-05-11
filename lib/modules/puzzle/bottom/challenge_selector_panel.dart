import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:video_player/video_player.dart';

class ChallengeSelectorPanel extends StatelessWidget {
  final bool isVideo;
  final VideoPlayerController? videoController;
  final GlobalKey? videoGlobalKey;
  final void Function(ui.Image capturedFrame) onConvertToPuzzle;
  final VoidCallback onSelectPuzzleChallenge;

  const ChallengeSelectorPanel({
    super.key,
    required this.isVideo,
    required this.videoController,
    required this.videoGlobalKey,
    required this.onConvertToPuzzle,
    required this.onSelectPuzzleChallenge,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isVideo ? 190 : 152,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: const Border.symmetric(
            horizontal: BorderSide(color: Colors.white),
          ),
          color: const Color.fromARGB(255, 18, 11, 60),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (isVideo &&
                videoController != null &&
                videoController!.value.isInitialized) ...[
              VideoProgressIndicator(
                videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.blueAccent,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(videoController!.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    _formatDuration(videoController!.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // عملکرد دکمه "بعدی" در آینده اضافه شود
                    },
                    label: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text('بعدی'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () async {
                      if (isVideo &&
                          videoController != null &&
                          videoGlobalKey != null) {
                        await videoController!.pause();

                        RenderRepaintBoundary boundary =
                            videoGlobalKey!.currentContext!.findRenderObject()
                                as RenderRepaintBoundary;

                        ui.Image image = await boundary.toImage(
                          pixelRatio: 1.5,
                        );

                        onConvertToPuzzle(image);
                      }

                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        backgroundColor: const Color.fromARGB(255, 18, 11, 60),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return _buildBottomSheet(context);
                        },
                      );
                    },
                    child: const Text('انتخاب چالش'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      height: 152,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 18, 11, 60),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        border: const Border.symmetric(
          horizontal: BorderSide(color: Colors.white),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'انتخاب چالش',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // عملکرد چهار گزینه‌ای اضافه شود
                  },
                  label: const Text('چهار گزینه ای'),
                  icon: const Icon(Icons.question_answer),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // عملکرد ترک بار اضافه شود
                  },
                  label: const Text('ترک بار'),
                  icon: const Icon(Icons.drag_handle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      onSelectPuzzleChallenge,
                    );
                  },
                  icon: const Icon(Icons.extension),
                  label: const Text('پازل'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // عملکرد ادامه موزیک اضافه شود
                  },
                  label: const Text('ادامه موزیک بخون'),
                  icon: const Icon(Icons.music_note),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
