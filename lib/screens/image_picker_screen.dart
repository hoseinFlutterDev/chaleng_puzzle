import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:puzzle_test/bottom/clip_path.dart';
import 'package:puzzle_test/class/PuzzlePiecePainter.dart';
import 'package:puzzle_test/model/puzzle.dart';
import 'package:puzzle_test/screens/first_screen.dart';
import 'package:puzzle_test/utils/network.dart';
import 'package:video_player/video_player.dart';
import 'package:xml/xml.dart';
import 'package:video_compress/video_compress.dart';

// اپلیکیشن پازل تصویری
class ImagePuzzleApp extends StatefulWidget {
  final File file; // ✅ فایل عکس ورودی

  final String? rawSvgPath; // مسیر SVG ورودی (اختیاری)

  ImagePuzzleApp({Key? key, required this.file, this.rawSvgPath})
    : super(key: key);

  @override
  _ImagePuzzleAppState createState() => _ImagePuzzleAppState();
}

class _ImagePuzzleAppState extends State<ImagePuzzleApp>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  ui.Image? _loadedImage;
  List<Rect> _pieces = []; // لیست قطعات پازل
  Rect? _removedPiece; // قطعه حذف شده
  Offset? _removedPieceOffset; // مکان قطعه حذف شده
  List<Rect> _fakePieces = []; // قطعات جعلی برای انتخاب
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final GlobalKey _puzzleKey = GlobalKey(); // برای اندازه گیری محل دقیق قطعات
  String? selectedSvgPath; // مسیر SVG انتخاب شده توسط کاربر
  Rect? _svgTargetRect; // محلی که SVG قرار داده می‌شود
  List<Rect> _panelPieces = []; // قطعات موجود در پنل انتخاب
  String? _userSelectedRawSvgPath; // داده خام SVG انتخاب شده توسط کاربر
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  final GlobalKey _videoGlobalKey = GlobalKey();
  List<Rect> _storedFakePieces = []; // قطعات فیک فقط ذخیره می‌شن، نه نمایش

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _imageFile = widget.file;
    _checkFileType();
  }

  void _checkFileType() {
    final path = _imageFile!.path.toLowerCase();
    if (path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv')) {
      // فایل ویدیویی
      _isVideo = true;
      _videoController = VideoPlayerController.file(_imageFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    } else {
      // فایل تصویری
      _isVideo = false;
      _loadImageFromFile();
    }
  }

  final List<String> svgPaths = [
    '''M109 40.7513C109 43.0112 111.472 44.5175 113.706 44.1745C114.454 44.0596 115.22 44 116 44C124.284 44 131 50.7157 131 59C131 67.2843 124.284 74 116 74C115.22 74 114.453 73.9403 113.705 73.8253C111.472 73.482 109 74.988 109 77.2479V106C109 107.657 107.657 109 106 109L77.2479 109C74.988 109 73.482 111.472 73.8253 113.705C73.9403 114.453 74 115.22 74 116C74 124.284 67.2843 131 59 131C50.7157 131 44 124.284 44 116C44 115.22 44.0597 114.453 44.1747 113.705C44.518 111.472 43.012 109 40.7521 109H12C10.3431 109 9 107.657 9 106L9 12C9 10.3431 10.3431 9 12 9L106 9C107.657 9 109 10.3431 109 12V40.7513Z
''',
    '''M109 40.7513C109 43.0112 106.528 44.5175 104.294 44.1745C103.546 44.0596 102.78 44 102 44C93.7157 44 87 50.7157 87 59C87 67.2843 93.7157 74 102 74C102.78 74 103.547 73.9403 104.295 73.8253C106.528 73.482 109 74.988 109 77.2479V106C109 107.657 107.657 109 106 109L77.2479 109C74.988 109 73.482 111.472 73.8253 113.705C73.9403 114.453 74 115.22 74 116C74 124.284 67.2843 131 59 131C50.7157 131 44 124.284 44 116C44 115.22 44.0597 114.453 44.1747 113.705C44.518 111.472 43.012 109 40.7521 109H12C10.3431 109 9 107.657 9 106L9 77.2479C9 74.988 11.4717 73.482 13.7054 73.8253C14.4535 73.9403 15.2198 74 16 74C24.2843 74 31 67.2843 31 59C31 50.7157 24.2843 44 16 44C15.2198 44 14.4535 44.0596 13.7055 44.1745C11.4718 44.5175 9 43.0112 9 40.7513L9 12C9 10.3431 10.3431 9 12 9L106 9C107.657 9 109 10.3431 109 12V40.7513Z''',
    '''M122 40.7513C122 43.0112 119.528 44.5175 117.294 44.1745C116.546 44.0596 115.78 44 115 44C106.716 44 100 50.7157 100 59C100 67.2843 106.716 74 115 74C115.78 74 116.547 73.9403 117.295 73.8253C119.528 73.482 122 74.988 122 77.2479L122 106C122 107.657 120.657 109 119 109L90.2479 109C87.988 109 86.482 106.528 86.8253 104.295C86.9403 103.547 87 102.78 87 102C87 93.7157 80.2843 87 72 87C63.7157 87 57 93.7157 57 102C57 102.78 57.0597 103.547 57.1747 104.295C57.518 106.528 56.012 109 53.7521 109H25C23.3431 109 22 107.657 22 106L22 77.2479C22 74.988 19.5283 73.482 17.2946 73.8253C16.5465 73.9403 15.7802 74 15 74C6.71573 74 5.26656e-07 67.2843 0 59C-5.26656e-07 50.7157 6.71573 44 15 44C15.7802 44 16.5465 44.0596 17.2945 44.1745C19.5282 44.5175 22 43.0112 22 40.7513L22 12C22 10.3431 23.3431 9 25 9L119 9C120.657 9 122 10.3431 122 12V40.7513Z''',
    '''M122 40.7513C122 43.0112 124.472 44.5175 126.706 44.1745C127.454 44.0596 128.22 44 129 44C137.284 44 144 50.7157 144 59C144 67.2843 137.284 74 129 74C128.22 74 127.453 73.9403 126.705 73.8253C124.472 73.482 122 74.988 122 77.2479V106C122 107.657 120.657 109 119 109H90.2479C87.988 109 86.482 111.472 86.8253 113.705C86.9403 114.453 87 115.22 87 116C87 124.284 80.2843 131 72 131C63.7157 131 57 124.284 57 116C57 115.22 57.0597 114.453 57.1747 113.705C57.518 111.472 56.012 109 53.7521 109H25C23.3431 109 22 107.657 22 106L22 77.2479C22 74.988 19.5283 73.482 17.2946 73.8253C16.5465 73.9403 15.7802 74 15 74C6.71573 74 5.26656e-07 67.2843 0 59C-5.26656e-07 50.7157 6.71573 44 15 44C15.7802 44 16.5465 44.0596 17.2945 44.1745C19.5282 44.5175 22 43.0112 22 40.7513L22 12C22 10.3431 23.3431 9 25 9L119 9C120.657 9 122 10.3431 122 12V40.7513Z''',
    '''M109.17 106.829C109.17 108.486 107.827 109.829 106.17 109.829H77.4181C75.1582 109.829 73.6522 112.301 73.9955 114.535C74.1105 115.283 74.1702 116.049 74.1702 116.829C74.1702 125.114 67.4544 131.829 59.1702 131.829C50.8859 131.829 44.1702 125.114 44.1702 116.829C44.1702 116.049 44.2298 115.283 44.3448 114.535C44.6882 112.301 43.1822 109.829 40.9222 109.829H12.1702C10.5133 109.829 9.17017 108.486 9.17017 106.829V78.0773C9.17017 75.8173 11.6419 74.3113 13.8756 74.6547C14.6236 74.7697 15.3899 74.8293 16.1702 74.8293C24.4544 74.8293 31.1702 68.1136 31.1702 59.8293C31.1702 51.5451 24.4544 44.8293 16.1702 44.8293C15.39 44.8293 14.6237 44.8889 13.8757 45.0038C11.6419 45.3468 9.17017 43.8405 9.17017 41.5806V12.8293C9.17017 11.1725 10.5133 9.82935 12.1702 9.82935H106.17C107.827 9.82935 109.17 11.1725 109.17 12.8293V106.829Z''',
    '''M109 40.7513C109 43.0112 111.472 44.5175 113.706 44.1745C114.454 44.0596 115.22 44 116 44C124.284 44 131 50.7157 131 59C131 67.2843 124.284 74 116 74C115.22 74 114.453 73.9403 113.705 73.8253C111.472 73.482 109 74.988 109 77.2479V106C109 107.657 107.657 109 106 109L77.2479 109C74.988 109 73.482 111.472 73.8253 113.705C73.9403 114.453 74 115.22 74 116C74 124.284 67.2843 131 59 131C50.7157 131 44 124.284 44 116C44 115.22 44.0597 114.453 44.1747 113.705C44.518 111.472 43.012 109 40.7521 109H12C10.3431 109 9 107.657 9 106L9 12C9 10.3431 10.3431 9 12 9L40.7521 9C43.012 9 44.518 11.4717 44.1747 13.7054C44.0597 14.4535 44 15.2198 44 16C44 24.2843 50.7157 31 59 31C67.2843 31 74 24.2843 74 16C74 15.2198 73.9403 14.4535 73.8253 13.7054C73.482 11.4717 74.988 9 77.2479 9L106 9C107.657 9 109 10.3431 109 12V40.7513Z''',
  ];
  // لود تصویر از فایل انتخاب شده
  Future<void> _loadImageFromFile() async {
    if (_imageFile != null) {
      final data = await _imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();

      setState(() {
        _loadedImage = frame.image;
        _generatePuzzlePieces(frame.image);
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose(); // از بین بردن انیمیشن کنترلر
    super.dispose();
  }

  //! ریست کردن وضعیت بازی
  void _resetState() {
    setState(() {
      _pieces.clear();
      _removedPiece = null;
      _removedPieceOffset = null;
      _fakePieces.clear();
      _loadedImage = null;
    });
  }

  Future<File?> _fixVideoRotation(File originalVideo) async {
    final info = await VideoCompress.compressVideo(
      originalVideo.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    return info?.file;
  }

  //! ساخت قطعات پازل براساس تعداد سطر و ستون
  void _generatePuzzlePieces(ui.Image image) {
    const int rows = 7;
    const int cols = 7;

    final pieceWidth = image.width / cols;
    final pieceHeight = image.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        _pieces.add(
          Rect.fromLTWH(
            col * pieceWidth,
            row * pieceHeight,
            pieceWidth,
            pieceHeight,
          ),
        );
      }
    }
  }

  String _getRandomDifferentPath() {
    // حذف مسیر کاربر از لیست

    final filteredPaths =
        svgPaths.where((path) => path != _userSelectedRawSvgPath).toList();

    if (filteredPaths.isEmpty) {
      // اگر به هر دلیلی لیست خالی شد، fallback
      return svgPaths.first;
    }

    final random = Random();
    return filteredPaths[random.nextInt(filteredPaths.length)];
  }

  //! اضافه کردن وری وسط تصویر
  void _setSvgToCenter() {
    if (_loadedImage == null) return;

    final imgWidth = _loadedImage!.width.toDouble();
    final imgHeight = _loadedImage!.height.toDouble();

    // اندازه فرضی برای SVG
    const double svgWidth = 90;
    const double svgHeight = 100;

    setState(() {
      _svgTargetRect = Rect.fromLTWH(
        (imgWidth - svgWidth) / 2,
        (imgHeight - svgHeight) / 2,
        svgWidth,
        svgHeight,
      );
    });
  }

  //! وقتی روی یک قطعه کلیک شود (برای حذف دستی)
  void _handleCanvasClick(Offset position) {
    final renderBox =
        _puzzleKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(position);

    // مقیاس بندی متناسب با اندازه تصویر
    final scaleX = renderBox.size.width / _loadedImage!.width;
    final scaleY = renderBox.size.height / _loadedImage!.height;
    final scale = min(scaleX, scaleY);

    for (final piece in _pieces) {
      final scaledPiece = Rect.fromLTWH(
        piece.left * scale,
        piece.top * scale,
        piece.width * scale,
        piece.height * scale,
      );

      if (scaledPiece.contains(localPosition)) {
        setState(() {
          _removedPiece = piece; // ذخیره قطعه حذف شده
          _removedPieceOffset = renderBox.localToGlobal(piece.topLeft * scale);
          _svgTargetRect = piece; // محل قرارگیری SVG
          _panelPieces = _generateFakePieces(piece); // تولید گزینه‌های جعلی

          // اگر کاربر قبلاً SVG انتخاب نکرده بود، پیشفرض بگذار
          if (selectedSvgPath == null) {
            selectedSvgPath = 'assets/svg/puzzle-2.svg';
          }

          // ساخت انیمیشن حرکت قطعه حذف شده
          _animation = Tween<Offset>(
            begin: _removedPieceOffset!,
            end: Offset(
              _removedPieceOffset!.dx,
              MediaQuery.of(context).size.height - 150,
            ),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
          _animationController.reset();
          _animationController.forward();
        });
        break;
      }
    }
  }

  //! تولید قطعات جعلی همراه با قطعه صحیح
  List<Rect> _generateFakePieces(Rect correct) {
    final rnd = Random(), fake = <Rect>[];
    while (fake.length < 5) {
      final pick = _pieces[rnd.nextInt(_pieces.length)];
      if (pick != correct && !fake.contains(pick)) fake.add(pick);
    }
    return ([...fake, correct]..shuffle());
  }

  //! قطعه درست
  CorrectPieceRect _toCorrectRect(Rect rect) {
    return CorrectPieceRect(
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );
  }

  //! قطعه های فیک
  FakePieces _toFakePiece(Rect rect) {
    return FakePieces(
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );
  }

  //! مدیریت کلیک روی قطعه انتخابی در پنل
  void _handlePieceClick(Rect piece) {
    if (piece == _removedPiece) {
      setState(() {
        _pieces.add(_removedPiece!);
        _removedPiece = null;
        _removedPieceOffset = null;
        _fakePieces.clear();
        _svgTargetRect = null;
        selectedSvgPath = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  //! محل پیش فرض قرار گیری اس وی جی
  void _generatePuzzleAtCenter() {
    if (_loadedImage == null) return;

    final renderBox =
        _puzzleKey.currentContext!.findRenderObject() as RenderBox;
    final boxSize = renderBox.size;

    final imageWidth = _loadedImage!.width.toDouble();
    final imageHeight = _loadedImage!.height.toDouble();

    // محاسبه نسبت مقیاس برای تطبیق تصویر در نمایش
    final scaleX = boxSize.width / imageWidth;
    final scaleY = boxSize.height / imageHeight;
    final scale = min(scaleX, scaleY);

    // اندازه SVG به صورت درصدی از تصویر نمایشی
    final svgDisplayWidth = boxSize.width * 0.15;
    final svgDisplayHeight = boxSize.height * 0.15;

    // محاسبه موقعیت وسط تصویر روی صفحه
    final offsetX = (boxSize.width - imageWidth * scale) / 2;
    final offsetY = (boxSize.height - imageHeight * scale) / 2;
    final centerX = offsetX + (imageWidth * scale) / 2;
    final centerY = offsetY + (imageHeight * scale) / 2;

    // تبدیل مختصات به نسبت تصویر واقعی
    final svgLeft = (centerX - svgDisplayWidth / 2 - offsetX) / scale;
    final svgTop = (centerY - svgDisplayHeight / 2 - offsetY) / scale;

    final centerRect = Rect.fromLTWH(
      svgLeft,
      svgTop,
      svgDisplayWidth / scale,
      svgDisplayHeight / scale,
    );

    setState(() {
      _removedPiece = centerRect;
      _svgTargetRect = centerRect;
      _panelPieces = _generateFakePieces(centerRect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: const ui.Color.fromARGB(255, 4, 14, 23),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _isVideo ? _buildVideoPlayer() : _buildPuzzle(),
                ),

                const SizedBox(height: 220), // جای خالی برای پنل پایین
              ],
            ),

            // پنل انتخاب پایین صفحه
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _isVideo ? 200 : 152, // ارتفاع کمی بیشتر اگر ویدیو باشه
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
                    SizedBox(height: 20),
                    if (_isVideo &&
                        _videoController != null &&
                        _videoController!.value.isInitialized) ...[
                      VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
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
                            _formatDuration(_videoController!.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_videoController!.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            label: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text('بعدی'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_isVideo && _videoController != null) {
                                await _videoController!.pause();
                                RenderRepaintBoundary boundary =
                                    _videoGlobalKey.currentContext!
                                            .findRenderObject()
                                        as RenderRepaintBoundary;
                                ui.Image image = await boundary.toImage(
                                  pixelRatio: 1.5,
                                );
                                setState(() {
                                  _isVideo = false;
                                  _loadedImage = image; // این درست هست
                                  _imageFile =
                                      null; // چون دیگه فایل ویدیویی نداریم
                                  _videoController?.dispose();
                                  _videoController = null;
                                });
                                _generatePuzzlePieces(
                                  image,
                                ); // ✅✅✅ ساختن قطعات پازل
                              }

                              // حالا بعد از ثبت فریم، چالش رو انتخاب کن

                              showModalBottomSheet(
                                isScrollControlled:
                                    true, // برای گرفتن تمام ارتفاع لازم
                                context: context,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  18,
                                  11,
                                  60,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 152,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        18,
                                        11,
                                        60,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      border: const Border.symmetric(
                                        horizontal: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {},
                                                label: const Text(
                                                  'چهار گزینه ای',
                                                ),
                                                icon: const Icon(
                                                  Icons.date_range_outlined,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              ElevatedButton.icon(
                                                onPressed: () {},
                                                label: const Text('ترک بار'),
                                                icon: const Icon(
                                                  Icons.date_range_outlined,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              newMethod(context),
                                              const SizedBox(width: 12),
                                              ElevatedButton.icon(
                                                onPressed: () {},
                                                label: const Text(
                                                  'ادامه موزیک بخون',
                                                ),
                                                icon: const Icon(
                                                  Icons.date_range_outlined,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
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
            ),

            // پایین‌تر قرار می‌گیرند
            if (_removedPiece != null) ...[
              _buildBottomPanel(),
              _buildMovingPiece(),
            ],

            // ✅ اینجا دیگر نمایش SVG دوتایی نمی‌شود، فقط از داخل _buildPuzzle() می‌آید
          ],
        ),
      ),
    );
  }

  //! MY Elevate
  ElevatedButton newMethod(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        showModalBottomSheet(
          isScrollControlled: true, // برای گرفتن تمام ارتفاع لازم
          context: context,
          backgroundColor: const Color.fromARGB(255, 18, 11, 60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          builder: (BuildContext context) {
            return Container(
              height: 240,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'چالش پازل',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 33, 31, 49),
                      ),
                      child: Column(
                        children: [
                          MyRow(
                            onTap: (assetPath) async {
                              final rawD = await loadRawSvgPathData(assetPath);

                              setState(() {
                                _userSelectedRawSvgPath = rawD;
                              });

                              _setSvgToCenter(); // بلافاصله بعد انتخاب، وسط قرار می‌گیره
                              _generatePuzzleAtCenter(); // این تابع رو اضافه می‌کنیم
                              Navigator.pop(context, rawD);

                              _setSelectedSvg(assetPath);
                              print('✅ SVG انتخاب‌شده: $assetPath');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedSvgPath != null) {
                              final rawD = await loadRawSvgPathData(
                                selectedSvgPath!,
                              );
                              //      Navigator.pop(context, rawD);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('لطفاً یک پازل انتخاب کنید'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'تمام',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'پازل مورد نظر را انتخاب کنید',
                          style: TextStyle(
                            color: Color(0xfff43464B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Text('پازل'),
    );
  }

  void _setSelectedSvg(String svgPath) {
    setState(() {
      selectedSvgPath = svgPath;
    });
  }

  Future<String> loadRawSvgPathData(String assetPath) async {
    final svgString = await rootBundle.loadString(assetPath);
    final document = XmlDocument.parse(svgString);
    final pathElem = document.findAllElements('path').first;
    return pathElem.getAttribute('d') ?? '';
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenSize = MediaQuery.of(context).size;
    final videoAspectRatio = _videoController!.value.aspectRatio;

    // محدودیت‌ها (مثلاً پایین دکمه داری، پس 100 پیکسل کم کنیم)
    final maxHeight = screenSize.height - 100;
    final maxWidth = screenSize.width;

    // حالا سایز ایده‌آل را بر اساس نسبت تصویر بساز
    double width = maxWidth;
    double height = width / videoAspectRatio;

    // اگر ارتفاع بیشتر از فضای قابل استفاده بود، برعکس محاسبه کن
    if (height > maxHeight) {
      height = maxHeight;
      width = height * videoAspectRatio;
    }

    return Center(
      child: RepaintBoundary(
        key: _videoGlobalKey,
        child: SizedBox(
          width: width,
          height: height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  //! ویجت ساخت پازل
  Widget _buildPuzzle() {
    if (_loadedImage == null && _isVideo == false) {
      return const Center(child: Text('هیچ عکسی انتخاب نشده است.'));
    }
    if (_isVideo && _videoController != null) {
      return Center(
        child: RepaintBoundary(
          key: _videoGlobalKey,
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }
    return GestureDetector(
      onTapDown: (details) {
        if (selectedSvgPath != null) {
          _handleCanvasClick(details.globalPosition);
        }
      },
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              key: _puzzleKey,
              decoration: BoxDecoration(
                color: const ui.Color.fromARGB(208, 0, 0, 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: _loadedImage!.width.toDouble(),
                  height: _loadedImage!.height.toDouble(),
                  child: Stack(
                    children: [
                      // تصویر اصلی پازل
                      CustomPaint(
                        size: Size(
                          _loadedImage!.width.toDouble(),
                          _loadedImage!.height.toDouble(),
                        ),
                        painter: PuzzlePainter(
                          image: _loadedImage!,
                          pieces: _pieces,
                        ),
                      ),

                      // نمایش SVG در نقطه‌ای که کاربر کلیک کرده است
                      if (_svgTargetRect != null)
                        Positioned(
                          left: _svgTargetRect!.left,
                          top: _svgTargetRect!.top,
                          width: _svgTargetRect!.width + 30,
                          height: _svgTargetRect!.height,
                          child: SvgPicture.asset(
                            selectedSvgPath!,
                            fit: BoxFit.fill,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //! ساخت پنل پایین
  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            height: 240,
            width: 400,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 19, 13, 41),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border.all(color: Color(0xfff43464B)),
            ),
            child: Column(
              children: [
                Text(
                  'چالش پازل',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    height: 160,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white70, width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildPanelPieces(),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPanelPieces() {
    if (_panelPieces.isEmpty) {
      return Center(child: Text('...هنوز هیچ قطعه‌ای انتخاب نشده'));
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: _panelPieces.length,
      itemBuilder: (_, i) {
        final piece = _panelPieces[i];
        final isCorrect = piece == _removedPiece; // قطعه درست

        return GestureDetector(
          onTap: () => _handlePieceClick(piece),
          child: Container(
            decoration: BoxDecoration(
              border:
                  isCorrect
                      ? Border.all(
                        color: const ui.Color.fromARGB(255, 76, 175, 87),
                        width: 3,
                      ) // ✅ حاشیه سبز برای درست
                      : null, // ❌ هیچ چیزی برای بقیه
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: piece.width,
              height: piece.height,
              child: CustomPaint(
                painter: PuzzlePieceClipPathPainter(
                  image: _loadedImage!,
                  rect: piece,
                  rawSvgPath:
                      isCorrect
                          ? _userSelectedRawSvgPath
                          : _getRandomDifferentPath(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //! ساخت قطعه متحرک
  Widget _buildMovingPiece() {
    if (_removedPiece == null || _removedPieceOffset == null) {
      return SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value.dy,
          left: _animation.value.dx,
          child: CustomPaint(
            painter: PuzzlePiecePainter(
              image: _loadedImage!,
              rect: _removedPiece!,
            ),
          ),
        );
      },
    );
  }

  //! فوتر پایین صفحه
  Widget _buildFooter() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              if (_svgTargetRect == null) return;

              final correct = _toCorrectRect(_svgTargetRect!);

              // فرض بر اینکه از همین تابع برای درست + جعلی استفاده می‌کنی
              final all = _generateFakePieces(_svgTargetRect!);
              final fakes =
                  all
                      .where((r) => r != _svgTargetRect!)
                      .map(_toFakePiece)
                      .toList();

              Network.postData(correctPieceRect: correct, fakePieces: fakes);
              print('send!!!!!!!!!!!!!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: const Text("تمام "),
          ),

          const SizedBox(width: 50),
          const Text(
            'پازل درست را انتخاب کنید',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}
