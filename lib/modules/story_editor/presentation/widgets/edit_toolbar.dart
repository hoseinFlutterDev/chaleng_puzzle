import 'package:flutter/material.dart';

class EditToolbar extends StatelessWidget {
  final VoidCallback onMusic;
  final VoidCallback onText;
  final VoidCallback onVoice;
  final VoidCallback onFilter;

  const EditToolbar({
    Key? key,
    required this.onMusic,
    required this.onText,
    required this.onFilter,
    required this.onVoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 380,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageButton("assets/images/Vector.png", onMusic),
            const SizedBox(height: 18),
            _buildImageButton("assets/images/Aa.png", onText),
            const SizedBox(height: 18),
            _buildImageButton("assets/images/Vector (Stroke).png", onFilter),
            const SizedBox(height: 18),
            _buildImageButton("assets/images/Vector2.png", onVoice),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(assetPath, width: 25, height: 25, fit: BoxFit.contain),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
