// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:video_player/video_player.dart';
// import 'package:xml/xml.dart';

// class MyBottom extends StatelessWidget {
//   const MyBottom({super.key, required bool showBottomPanel})
//     : _showBottomPanel = showBottomPanel;

//   final bool _showBottomPanel;

//   @override
//   Widget build(BuildContext context) {
//     //پنل مرحله دوم انخاب نوع چالش
//     return AnimatedPositioned(
//       duration: Duration(milliseconds: 600),
//       curve: Curves.easeInOut,
//       bottom: _showBottomPanel ? 0 : -160, // می‌تونه بسته به ارتفاع تغییر کنه
//       left: 0,
//       right: 0,
//       child: Container(
//         height: 152,
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 18, 11, 60),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(15),
//             topRight: Radius.circular(15),
//           ),
//           border: Border.symmetric(horizontal: BorderSide(color: Colors.white)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // دکمه‌ها
//             Text(
//               'انتخاب چالش',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   MyElevated(
//                     onPressed: () {},
//                     label: 'چهار گزینه ای',
//                     icon: Icon(Icons.date_range_outlined),
//                   ),
//                   SizedBox(width: 12),
//                   MyElevated(
//                     onPressed: () {},
//                     label: 'ترک بار',
//                     icon: Icon(Icons.date_range_outlined),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   MyElevated(
//                     onPressed: () {},
//                     label: 'پازل',
//                     icon: Icon(Icons.date_range_outlined),
//                   ),

//                   SizedBox(width: 12),
//                   MyElevated(
//                     onPressed: () {},
//                     label: 'ادامه موزیک بخون',
//                     icon: Icon(Icons.date_range_outlined),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ignore: must_be_immutable
// //دکمه ها
// class MyElevated extends StatelessWidget {
//   void Function()? onPressed;

//   String label;
//   Widget? icon;
//   MyElevated({Key? key, this.onPressed, required this.label, this.icon})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: icon,
//       label: Text(
//         label,
//         style: TextStyle(
//           color: const Color.fromARGB(179, 13, 13, 13),
//           fontSize: 17,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }
// }

// //  مرحله 3 پنل شیت انتخاب شکل پازل
// Future<String?> _showPuzzleSheet(BuildContext context) async {
//   String? selectedSvgPath;

//   Future<String> loadRawSvgPathData(String assetPath) async {
//     final svgString = await rootBundle.loadString(assetPath);
//     final document = XmlDocument.parse(svgString);
//     final pathElem = document.findAllElements('path').first;
//     return pathElem.getAttribute('d') ?? '';
//   }

//   final rawD = await showModalBottomSheet<String>(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return Container(
//             height: 240,
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.white70),
//               color: const Color.fromARGB(255, 19, 13, 41),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 topRight: Radius.circular(15),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Center(
//                   child: Text(
//                     'چالش پازل',
//                     style: TextStyle(
//                       fontFamily: 'Inter',
//                       fontSize: 17,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   child: Container(
//                     height: 150,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.white24),
//                       borderRadius: BorderRadius.circular(10),
//                       color: const Color.fromARGB(255, 33, 31, 49),
//                     ),
//                     child: Column(children: [

//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (selectedSvgPath != null) {
//                             final rawD = await loadRawSvgPathData(
//                               selectedSvgPath!,
//                             );
//                             Navigator.pop(context, rawD); // بازگشت rawD
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('لطفاً یک پازل انتخاب کنید'),
//                               ),
//                             );
//                           }
//                         },
//                         child: Text(
//                           'تمام',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       ),
//                       Spacer(),
//                       Text(
//                         'پازل مورد نظر را انتخاب کنید',
//                         style: TextStyle(
//                           color: Color(0xfff43464B),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );

//   return rawD;
// }

// // مرحله اول انتخاب چالش
// class MyPanel extends StatelessWidget {
//   void Function()? onPressed;
//   MyPanel({required this.onPressed, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPositioned(
//       duration: Duration(milliseconds: 500),
//       child: Container(
//         height: 152,
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           border: Border.symmetric(horizontal: BorderSide(color: Colors.white)),
//           color: const Color.fromARGB(255, 18, 11, 60),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(15),
//             topRight: Radius.circular(15),
//           ),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 30),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {},
//                     label: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40),
//                       child: Text('بعدی'),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white24,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: onPressed,
//                     child: Text('انتخاب چالش'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
