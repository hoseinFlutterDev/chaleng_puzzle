// ignore_for_file: unused_local_variable, unused_field

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:puzzle_test/modules/puzzle/bottom/challenge_bottom_panel.dart';
import 'package:puzzle_test/modules/puzzle/bottom/challenge_selector_panel.dart';
import 'package:puzzle_test/modules/puzzle/helpers/puzzle_helper.dart';
import 'package:puzzle_test/modules/puzzle/helpers/video_helper.dart';
import 'package:puzzle_test/modules/puzzle/model/puzzle.dart';
import 'package:puzzle_test/modules/puzzle/widget/editable_video_widget.dart';
import 'package:puzzle_test/modules/puzzle/widget/puzzle_widget.dart';
import 'package:puzzle_test/modules/puzzle/utils/network.dart';
import 'package:puzzle_test/modules/story_editor/presentation/pages/add_music_page.dart';
import 'package:puzzle_test/modules/story_editor/presentation/widgets/edit_toolbar.dart';
import 'package:puzzle_test/modules/story_editor/presentation/widgets/text/add_text_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:xml/xml.dart';

// اپلیکیشن پازل تصویری
class ImagePuzzleApp extends StatefulWidget {
  final File file; // فایل عکس ورودی

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
  bool _showPuzzleContainer = false;
  bool _showSvgOnImage = true;
  bool _showEditOverlay = false;
  bool _isEditingImage = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

  OverlayEntry? _textOverlayEntry;

  void _showTextEditorOverlay() {
    _textOverlayEntry = OverlayEntry(
      builder:
          (context) => AddTextOverlay(
            onSubmit: (text, color, font, bgColor) {
              _textOverlayEntry?.remove(); // بستن overlay
              _textOverlayEntry = null;

              // اضافه کردن متن نهایی روی تصویر یا ویدیو
              print("متن: $text | رنگ: $color | فونت: $font");
              // اینجا می‌تونی یک ویجت درگ‌پذیر متن بسازی
            },
            onCancel: () {
              _textOverlayEntry?.remove(); // لغو
              _textOverlayEntry = null;
            },
          ),
    );

    Overlay.of(context).insert(_textOverlayEntry!);
  }

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

  void _generatePuzzlePieces(ui.Image image) {
    _pieces = PuzzleHelper.generatePieces(image, 7, 7);
  }

  Future<void> _initVideo(File file) async {
    _videoController = await VideoHelper.initializeController(file);
    setState(() {});
  }

  List<Rect> _generateFakePieces(Rect correct) {
    return PuzzleHelper.generateFakePieces(correct, _pieces);
  }

  CorrectPieceRect _toCorrectRect(Rect rect) {
    return PuzzleHelper.toCorrectPieceRect(rect);
  }

  FakePieces _toFakePiece(Rect rect) {
    return PuzzleHelper.toFakePieceRect(rect);
  }

  void _generatePuzzleAtCenter() {
    if (_loadedImage == null) return;

    final renderBox =
        _puzzleKey.currentContext!.findRenderObject() as RenderBox;
    final centerRect = PuzzleHelper.getCenterSvgRect(
      _loadedImage!,
      renderBox,
      0.15,
    );

    setState(() {
      _removedPiece = centerRect;
      _svgTargetRect = centerRect;
      _panelPieces = _generateFakePieces(centerRect);
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

  //*ّبیلد
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 4, 14, 23),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child:
                      _isVideo
                          ? VideoPlayerWidget(
                            controller: _videoController!,
                            repaintKey: _videoGlobalKey,
                          )
                          : PuzzleWidget(
                            loadedImage: _loadedImage,
                            pieces: _pieces,
                            removedPiece: _removedPiece,
                            removedPieceOffset: _removedPieceOffset,
                            fakePieces: _fakePieces,
                            animationController: _animationController,
                            animation: _animation,
                            puzzleKey: _puzzleKey,
                            selectedSvgPath: selectedSvgPath,
                            svgTargetRect: _svgTargetRect,
                            panelPieces: _panelPieces,
                            userSelectedRawSvgPath: _userSelectedRawSvgPath,
                            videoController: _videoController,
                            isVideo: _isVideo,
                            videoGlobalKey: _videoGlobalKey,
                            showSvgOnImage: _showSvgOnImage,
                            onCanvasClick: (offset) {
                              if (selectedSvgPath != null) {
                                _handleCanvasClick(offset);
                              }
                            },
                          ),
                ),
                const SizedBox(height: 195), // فضای خالی برای پنل پایین
              ],
            ),
            if (!_showPuzzleContainer && (_loadedImage != null || _isVideo))
              EditToolbar(
                onMusic: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder:
                        (context) => MusicPickerBottomSheet(
                          onMusicSelected: (audioFile) {
                            // موزیک انتخاب شد
                            print("موزیک انتخاب شده: ${audioFile.path}");
                            // مثلا اینجا به ادیتور بفرست یا ذخیره کن
                          },
                        ),
                  );
                },
                onText: () {
                  _showTextEditorOverlay();
                },

                onVoice: () {
                  // نمایش ابزار برش یا زوم
                },
                onFilter: () {
                  // نمایش لیست فیلترها
                },
              ),

            // پنل انتخاب چالش (ویجت جداشده)
            ChallengeSelectorPanel(
              isVideo: _isVideo,
              videoController: _videoController,
              videoGlobalKey: _videoGlobalKey,
              onConvertToPuzzle: (ui.Image capturedFrame) {
                setState(() {
                  _isVideo = false;
                  _imageFile = null;
                  _videoController?.dispose();
                  _videoController = null;
                  _loadedImage = capturedFrame; // ذخیره‌ی تصویر گرفته شده
                });
                _generatePuzzlePieces(
                  capturedFrame,
                ); // ارسال مستقیم تصویر گرفته‌شده
              },
              onSelectPuzzleChallenge: () {
                setState(() {
                  _showPuzzleContainer = true;
                  _showSvgOnImage = true;
                  _svgTargetRect = null;
                  selectedSvgPath = null;
                  _removedPiece = null;
                });
              },
            ), // دکمه ادیت در بالا سمت راست
            // پنل پازل پایینی (MyRow و دکمه تمام)
            if (_showPuzzleContainer)
              ChallengeBottomPanel(
                show: _showPuzzleContainer,
                image: _loadedImage,
                removedPiece: _removedPiece,
                selectedSvgPath: selectedSvgPath,
                svgTargetRect: _svgTargetRect,
                onSvgTap: (path, index) {
                  setState(() {
                    selectedSvgPath = path;
                  });
                  _generatePuzzleAtCenter();
                },
                onComplete: () {
                  if (_svgTargetRect == null) return;

                  final correct = _toCorrectRect(_svgTargetRect!);

                  final all = _generateFakePieces(_svgTargetRect!);
                  final fakes =
                      all
                          .where((r) => r != _svgTargetRect!)
                          .map(_toFakePiece)
                          .toList();

                  Network.postData(
                    correctPieceRect: correct,
                    fakePieces: fakes,
                  );

                  setState(() {
                    _showPuzzleContainer = false;
                    _showSvgOnImage = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<String> loadRawSvgPathData(String assetPath) async {
    final svgString = await rootBundle.loadString(assetPath);
    final document = XmlDocument.parse(svgString);
    final pathElem = document.findAllElements('path').first;
    return pathElem.getAttribute('d') ?? '';
  }
}
