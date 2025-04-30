// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:puzzle_test/bottom/my_elevat.dart';
// import 'package:puzzle_test/bottom/my_row.dart';
// import 'package:video_player/video_player.dart';

// class PreviewPage extends StatefulWidget {
//   final File file;

//   const PreviewPage({required this.file});

//   @override
//   State<PreviewPage> createState() => _PreviewPageState();
// }

// class _PreviewPageState extends State<PreviewPage> {
//   String? selectedSvgPath;
//   double svgX = 100;
//   double svgY = 100;

//   VideoPlayerController? _controller;
//   bool get isVideo {
//     final ext = widget.file.path.toLowerCase();
//     return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
//   }

//   @override
//   void initState() {
//     super.initState();
//     if (isVideo) {
//       _controller = VideoPlayerController.file(widget.file)
//         ..initialize().then((_) {
//           setState(() {});
//           _controller!.play();
//         });
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 // تصویر یا ویدیو
//                 isVideo
//                     ? AspectRatio(
//                       aspectRatio: _controller!.value.aspectRatio,
//                       child: VideoPlayer(_controller!),
//                     )
//                     : ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Image.file(widget.file),
//                     ),

//                 // اگر SVG انتخاب شده، اونم نشون بده
//                 if (selectedSvgPath != null)
//                   Positioned(
//                     left: svgX,
//                     top: svgY,
//                     child: GestureDetector(
//                       onPanUpdate: (details) {
//                         setState(() {
//                           svgX += details.delta.dx;
//                           svgY += details.delta.dy;
//                         });
//                       },
//                       child: SvgPicture.asset(
//                         selectedSvgPath!,
//                         width: 70,
//                         height: 70,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           firstContainer(isVideo: isVideo, controller: _controller),
//         ],
//       ),
//     );
//   }
// }

// class firstContainer extends StatefulWidget {
//   final bool isVideo;
//   final VideoPlayerController? controller;

//   const firstContainer({
//     Key? key,
//     required this.isVideo,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   State<firstContainer> createState() => _firstContainerState();
// }

// class _firstContainerState extends State<firstContainer> {
//   Duration current = Duration.zero;
//   Duration total = Duration(seconds: 1);
//   late final VoidCallback listener;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.controller != null) {
//       listener = () {
//         final pos = widget.controller!.value.position;
//         final dur = widget.controller!.value.duration;

//         if (mounted) {
//           setState(() {
//             current = pos;
//             total = dur;
//           });
//         }
//       };
//       widget.controller!.addListener(listener);
//     }
//   }

//   @override
//   void dispose() {
//     widget.controller?.removeListener(listener);
//     super.dispose();
//   }

//   String format(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(d.inMinutes.remainder(60));
//     final seconds = twoDigits(d.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final progress =
//         total.inMilliseconds > 0
//             ? current.inMilliseconds / total.inMilliseconds
//             : 0.0;

//     return Container(
//       height: 160,
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         border: Border.symmetric(horizontal: BorderSide(color: Colors.white)),
//         color: const Color.fromARGB(255, 18, 11, 60),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(15),
//           topRight: Radius.circular(15),
//         ),
//       ),
//       child: Expanded(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (widget.isVideo &&
//                   widget.controller != null &&
//                   widget.controller!.value.isInitialized) ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       ' ${format(current)}',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     Text(
//                       ' ${format(total)}',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 15),
//                 LinearProgressIndicator(
//                   value: progress,
//                   backgroundColor: const Color.fromARGB(60, 70, 67, 67),
//                   color: const Color.fromARGB(255, 242, 243, 245),
//                   minHeight: 5,
//                 ),
//                 SizedBox(height: 20),
//               ] else
//                 Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(
//                         const Color.fromARGB(255, 41, 38, 38),
//                       ),
//                     ),
//                     onPressed: () {
//                       // رفتن به صفحه بعد
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 45),
//                       child: Text(
//                         'بعدی',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         backgroundColor: Colors.transparent,
//                         isScrollControlled: true,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(25),
//                           ),
//                         ),
//                         builder: (context) {
//                           return Container(
//                             height: 150,
//                             padding: EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 18, 11, 60),
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(15),
//                                 topRight: Radius.circular(15),
//                               ),
//                               border: Border.symmetric(
//                                 horizontal: BorderSide(color: Colors.white),
//                               ),
//                             ),
//                             child: Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     'انتخاب چالش',
//                                     style: TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         MyElevated(
//                                           onPressed: () {
//                                             // انتخاب چالش
//                                           },
//                                           label: 'چهار گزینه ای',
//                                           icon: Icon(Icons.date_range_outlined),
//                                         ),
//                                         SizedBox(width: 10),
//                                         MyElevated(
//                                           onPressed: () {
//                                             // انتخاب چالش
//                                           },
//                                           label: 'ترک بار',
//                                           icon: Icon(Icons.date_range_outlined),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         MyElevated(
//                                           onPressed: () {
//                                             String?
//                                             selectedSvgPath; // ✅ اینو اضافه کن
//                                             Future<String> loadRawSvgPathData(
//                                               String selectedPath,
//                                             ) async {
//                                               return MyRow
//                                                   .rawPaths[selectedPath]!;
//                                             }

//                                             showModalBottomSheet(
//                                               context: context,
//                                               isScrollControlled: true,
//                                               backgroundColor:
//                                                   Colors.transparent,
//                                               builder: (_) {
//                                                 return StatefulBuilder(
//                                                   // ✅ اضافه‌ش کن تا بتونی مقدار رو تغییر بدی
//                                                   builder: (context, setState) {
//                                                     return Container(
//                                                       height: 260,
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                             10,
//                                                           ),
//                                                       decoration: BoxDecoration(
//                                                         border: Border.all(
//                                                           color: Colors.white70,
//                                                         ),
//                                                         color:
//                                                             const Color.fromARGB(
//                                                               255,
//                                                               19,
//                                                               13,
//                                                               41,
//                                                             ),
//                                                         borderRadius:
//                                                             const BorderRadius.only(
//                                                               topLeft:
//                                                                   Radius.circular(
//                                                                     15,
//                                                                   ),
//                                                               topRight:
//                                                                   Radius.circular(
//                                                                     15,
//                                                                   ),
//                                                             ),
//                                                       ),
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .stretch,
//                                                         children: [
//                                                           const Center(
//                                                             child: Text(
//                                                               'چالش پازل',
//                                                               style: TextStyle(
//                                                                 fontFamily:
//                                                                     'Inter',
//                                                                 fontSize: 17,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w800,
//                                                                 color:
//                                                                     Colors
//                                                                         .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 10,
//                                                           ),
//                                                           Expanded(
//                                                             child: Container(
//                                                               padding:
//                                                                   const EdgeInsets.symmetric(
//                                                                     horizontal:
//                                                                         10,
//                                                                   ),
//                                                               decoration: BoxDecoration(
//                                                                 border: Border.all(
//                                                                   color:
//                                                                       Colors
//                                                                           .white24,
//                                                                 ),
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       10,
//                                                                     ),
//                                                                 color:
//                                                                     const Color.fromARGB(
//                                                                       255,
//                                                                       33,
//                                                                       31,
//                                                                       49,
//                                                                     ),
//                                                               ),
//                                                               child: SingleChildScrollView(
//                                                                 child: MyRow(
//                                                                   onTap: (
//                                                                     selectedPath,
//                                                                   ) {
//                                                                     setState(() {
//                                                                       String?
//                                                                       selectedSvgPath;
//                                                                       double
//                                                                       svgX =
//                                                                           100;
//                                                                       double
//                                                                       svgY =
//                                                                           100;

//                                                                       selectedSvgPath =
//                                                                           selectedPath;
//                                                                       svgX =
//                                                                           100; // یا مثلاً MediaQuery.of(context).size.width / 2
//                                                                       svgY =
//                                                                           100;
//                                                                     });
//                                                                   },
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 10,
//                                                           ),
//                                                           Row(
//                                                             children: [
//                                                               ElevatedButton(
//                                                                 onPressed: () async {
//                                                                   if (selectedSvgPath !=
//                                                                       null) {
//                                                                     final rawD =
//                                                                         await loadRawSvgPathData(
//                                                                           selectedSvgPath!,
//                                                                         );
//                                                                     Navigator.pop(
//                                                                       context,
//                                                                       rawD,
//                                                                     );
//                                                                   } else {
//                                                                     ScaffoldMessenger.of(
//                                                                       context,
//                                                                     ).showSnackBar(
//                                                                       const SnackBar(
//                                                                         content:
//                                                                             Text(
//                                                                               'لطفاً یک پازل انتخاب کنید',
//                                                                             ),
//                                                                       ),
//                                                                     );
//                                                                   }
//                                                                 },
//                                                                 child: const Text(
//                                                                   'تمام',
//                                                                   style: TextStyle(
//                                                                     color:
//                                                                         Colors
//                                                                             .black,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               const Spacer(),
//                                                               const Text(
//                                                                 'پازل مورد نظر را انتخاب کنید',
//                                                                 style: TextStyle(
//                                                                   color: Color(
//                                                                     0xfff43464B,
//                                                                   ),
//                                                                   fontSize: 12,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                             );
//                                           },

//                                           label: 'پازل',
//                                           icon: Icon(Icons.date_range_outlined),
//                                         ),
//                                         SizedBox(width: 12),
//                                         MyElevated(
//                                           onPressed: () {
//                                             // انتخاب چالش
//                                           },
//                                           label: 'ادامه موزیک بخون',
//                                           icon: Icon(Icons.date_range_outlined),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },

//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 25),
//                       child: Text('انتخاب چالش'),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PuzzlePage extends StatefulWidget {
//   const PuzzlePage({super.key});

//   @override
//   State<PuzzlePage> createState() => _PuzzlePageState();
// }

// class _PuzzlePageState extends State<PuzzlePage> {
//   String? selectedSvgPath; // مسیر انتخاب‌شده فعلی
//   List<String?> puzzleGrid = List.generate(
//     25,
//     (index) => null,
//   ); // جدول پازل 5x5

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("پازل SVG")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             MyRow(
//               onTap: (path) {
//                 setState(() {
//                   selectedSvgPath = path;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: GridView.builder(
//                 itemCount: 25,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 5,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                 ),
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       if (selectedSvgPath != null) {
//                         setState(() {
//                           puzzleGrid[index] = selectedSvgPath;
//                         });
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         border: Border.all(color: Colors.black12),
//                       ),
//                       child:
//                           puzzleGrid[index] != null
//                               ? SvgPicture.asset(
//                                 puzzleGrid[index]!,
//                                 fit: BoxFit.contain,
//                               )
//                               : const Center(child: Text('')),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
