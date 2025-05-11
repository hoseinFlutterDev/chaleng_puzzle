import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';

class VideoHelper {
  static Future<VideoPlayerController> initializeController(File file) async {
    var controller = VideoPlayerController.file(file);
    await controller.initialize();

    final aspect = controller.value.aspectRatio;
    if (aspect < 0.5 || aspect > 2.2) {
      File? fixedFile = await _fixVideoRotation(file);
      if (fixedFile != null && fixedFile.path != file.path) {
        controller = VideoPlayerController.file(fixedFile);
        await controller.initialize();
      }
    }

    return controller;
  }

  static Future<File?> _fixVideoRotation(File originalVideo) async {
    try {
      final info = await VideoCompress.compressVideo(
        originalVideo.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return info?.file;
    } catch (_) {
      return null;
    }
  }
}
