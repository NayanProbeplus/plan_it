// import 'dart:async';
// import 'package:flutter/material.dart';

// // This is the main widget you'll add to your app.
// class ChecklistAnimation extends StatefulWidget {
//   const ChecklistAnimation({super.key});

//   @override
//   ChecklistAnimationState createState() => ChecklistAnimationState();
// }

// class ChecklistAnimationState extends State<ChecklistAnimation> {
//   // We use these booleans to trigger the animations in sequence
//   bool _showList = false;
//   bool _checkItem1 = false;
//   bool _checkItem2 = false;
//   bool _checkItem3 = false;
//   bool _showPlanIt = false;
//   bool _hideList = false;

//   @override
//   void initState() {
//     super.initState();
//     // Start the animation sequence when the widget is first built
//     _startAnimationSequence();
//   }

//   void _startAnimationSequence() async {
//     // 1. Show the list items
//     await Future.delayed(const Duration(milliseconds: 300));
//     setState(() => _showList = true);

//     // 2. Check the first item
//     await Future.delayed(const Duration(milliseconds: 500));
//     setState(() => _checkItem1 = true);

//     // 3. Check the second item
//     await Future.delayed(const Duration(milliseconds: 500));
//     setState(() => _checkItem2 = true);

//     // 4. Check the third item
//     await Future.delayed(const Duration(milliseconds: 500));
//     setState(() => _checkItem3 = true);

//     // 5. Hide the list
//     await Future.delayed(const Duration(milliseconds: 1000));
//     setState(() => _hideList = true);

//     // 6. Show the "PlanIt" text
//     await Future.delayed(const Duration(milliseconds: 400));
//     setState(() => _showPlanIt = true);

//     // You could add a navigator push here to move to your home screen
//     // e.g., await Future.delayed(const Duration(milliseconds: 2000));
//     // Navigator.of(context).pushReplacement(...);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Stack(
//         // We use a Stack to fade the list out and the text in
//         // in the same spot.
//         alignment: Alignment.center,
//         children: [
//           // The "PlanIt" text
//           AnimatedOpacity(
//             opacity: _showPlanIt ? 1.0 : 0.0,
//             duration: const Duration(milliseconds: 500),
//             child: Text(
//               'PlanIt',
//               style: TextStyle(
//                 fontSize: 48,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ),

//           // The Checklist
//           AnimatedOpacity(
//             // When _hideList is true, this fades out
//             opacity: _hideList ? 0.0 : 1.0,
//             duration: const Duration(milliseconds: 300),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AnimatedChecklistItem(
//                     show: _showList,
//                     isChecked: _checkItem1,
//                     delay: const Duration(milliseconds: 0)),
//                 AnimatedChecklistItem(
//                     show: _showList,
//                     isChecked: _checkItem2,
//                     delay: const Duration(milliseconds: 150)),
//                 AnimatedChecklistItem(
//                     show: _showList,
//                     isChecked: _checkItem3,
//                     delay: const Duration(milliseconds: 300)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // This is a helper widget for the animated list item
// class AnimatedChecklistItem extends StatelessWidget {
//   final bool show;
//   final bool isChecked;
//   final Duration delay;

//   const AnimatedChecklistItem({
//     super.key,
//     required this.show,
//     required this.isChecked,
//     required this.delay,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedOpacity(
//       // Fades the whole item in
//       opacity: show ? 1.0 : 0.0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // The Checkbox
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOutBack, // Gives a nice "pop"
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: isChecked
//                     ? Theme.of(context).primaryColor
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: isChecked
//                       ? Theme.of(context).primaryColor
//                       : Colors.grey.shade400,
//                   width: 2.5,
//                 ),
//               ),
//               child: isChecked
//                   ? const Icon(Icons.check, color: Colors.white, size: 20)
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             // The placeholder line
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOut,
//               width: 150,
//               height: 16,
//               decoration: BoxDecoration(
//                 color: isChecked ? Colors.grey.shade400 : Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
