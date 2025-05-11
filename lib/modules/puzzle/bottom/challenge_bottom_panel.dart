import 'package:flutter/material.dart';
import 'package:puzzle_test/modules/puzzle/bottom/clip_path.dart';
import 'dart:ui' as ui;

class ChallengeBottomPanel extends StatelessWidget {
  final bool show;
  final ui.Image? image;
  final Rect? removedPiece;
  final String? selectedSvgPath;
  final Rect? svgTargetRect;
  final void Function(String path, int index) onSvgTap;
  final VoidCallback onComplete;

  const ChallengeBottomPanel({
    super.key,
    required this.show,
    required this.image,
    required this.removedPiece,
    required this.selectedSvgPath,
    required this.svgTargetRect,
    required this.onSvgTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      bottom: show ? 0 : -220,
      left: 0,
      right: 0,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          color: const Color.fromARGB(255, 19, 13, 41),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            const Center(
              child: Text(
                'چالش پازل',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 33, 31, 49),
                ),
                child: MyRow(
                  selectedSvgPath: selectedSvgPath,
                  removedPiece: removedPiece,
                  image: image,
                  onTap: onSvgTap,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 25,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: onComplete,
                    child: const Text(
                      'تمام',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'پازل مورد نظر را انتخاب کنید',
                    style: TextStyle(color: Color(0xfff43464B), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
