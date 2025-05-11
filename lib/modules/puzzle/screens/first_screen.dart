import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:puzzle_test/modules/puzzle/screens/image_picker_screen.dart';

class HomePage extends StatelessWidget {
  Future<File?> _fixVideoRotation(File originalVideo) async {
    final info = await VideoCompress.compressVideo(
      originalVideo.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    return info?.file;
  }

  void _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);

      final extension = result.files.first.extension?.toLowerCase();
      final isVideo =
          extension == 'mp4' || extension == 'mov' || extension == 'avi';

      File finalFile = file;

      if (isVideo) {
        File? fixedVideo = await _fixVideoRotation(file);
        if (fixedVideo != null) {
          finalFile = fixedVideo;
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePuzzleApp(file: finalFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('انتخاب فایل')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickFile(context),
          child: Text('انتخاب عکس یا ویدیو'),
        ),
      ),
    );
  }
}
