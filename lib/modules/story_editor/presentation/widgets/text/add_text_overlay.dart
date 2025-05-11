import 'package:flutter/material.dart';

class AddTextOverlay extends StatefulWidget {
  final Function(String text, Color color, String font, Color bgColor) onSubmit;
  final VoidCallback onCancel;

  const AddTextOverlay({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<AddTextOverlay> createState() => _AddTextOverlayState();
}

class _AddTextOverlayState extends State<AddTextOverlay> {
  final TextEditingController _controller = TextEditingController();
  Color selectedColor = Colors.white;
  Color selectedBackground = Colors.transparent;
  String selectedFont = 'Roboto';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            GestureDetector(
              onTap: widget.onCancel, // لمس خارج از پنل = لغو
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 100,
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                    fontSize: 28,
                    color: selectedColor,
                    fontFamily: selectedFont,
                    backgroundColor: selectedBackground,
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "نوشتن متن...",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),

            // ابزارهای تنظیم رنگ و فونت
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.color_lens, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          selectedColor = Colors.red;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.format_color_fill,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedBackground =
                              selectedBackground == Colors.transparent
                                  ? Colors.black45
                                  : Colors.transparent;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.font_download,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedFont =
                              selectedFont == 'Roboto' ? 'Lobster' : 'Roboto';
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.greenAccent),
                      onPressed: () {
                        widget.onSubmit(
                          _controller.text,
                          selectedColor,
                          selectedFont,
                          selectedBackground,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
