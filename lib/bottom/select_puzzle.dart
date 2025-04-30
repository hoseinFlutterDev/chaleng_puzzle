// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'my_row.dart'; // فایل MyRow رو که ساختی، وارد کن

// class PuzzleBoard extends StatefulWidget {
//   const PuzzleBoard({super.key});

//   @override
//   State<PuzzleBoard> createState() => _PuzzleBoardState();
// }

// class _PuzzleBoardState extends State<PuzzleBoard> {
//   String? selectedPuzzle;
//   Offset position = const Offset(150, 150); // موقعیت پیش‌فرض پازل

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // صفحه‌ای که پازل روش نمایش داده میشه
//         Expanded(
//           child: GestureDetector(
//             onTapDown: (details) {
//               if (selectedPuzzle != null) {
//                 setState(() {
//                   position = details.localPosition; // موقعیت کلیک کاربر
//                 });
//               }
//             },
//             child: Stack(
//               children: [
//                 // بک‌گراند تصویر اصلی
//                 Positioned.fill(
//                   child: Image.asset(
//                     'assets/your_background_image.jpg', // عکس زمینه‌ات رو بذار اینجا
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 // پازل انتخاب‌شده
//                 if (selectedPuzzle != null)
//                   Positioned(
//                     left:
//                         position.dx -
//                         35, // -35 برای وسط‌چین کردن (نصف اندازه پازل)
//                     top: position.dy - 35,
//                     child: SvgPicture.asset(
//                       selectedPuzzle!,
//                       width: 70,
//                       height: 70,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 10),

//         // ردیف پازل‌ها
//         MyRow(
//           onTap: (path) {
//             setState(() {
//               selectedPuzzle = path;
//               position = const Offset(150, 150); // پازل جدید بیفته وسط
//             });
//           },
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }
