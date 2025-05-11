import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:ui';

class ImageEditorOverlay extends StatelessWidget {
  final ui.Image? image;
  final VoidCallback onDone;

  const ImageEditorOverlay({
    super.key,
    required this.image,
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
              title: const Text("ویرایش تصویر"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: onDone,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child:
                    image != null
                        ? RawImage(image: image!)
                        : const CircularProgressIndicator(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.crop, color: Colors.white, size: 30),
                  Icon(Icons.filter, color: Colors.white, size: 30),
                  Icon(Icons.text_fields, color: Colors.white, size: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
