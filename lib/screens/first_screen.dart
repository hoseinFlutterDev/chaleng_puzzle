import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:puzzle_test/screens/image_picker_screen.dart'; // فرض کردم اینجا همون ImagePuzzleApp باشه

class HomePage extends StatelessWidget {
  void _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImagePuzzleApp(file: file)),
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
