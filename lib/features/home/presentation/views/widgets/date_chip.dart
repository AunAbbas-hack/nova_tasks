//
// import 'package:flutter/material.dart';
//
// class DateChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//
//   const DateChip({
//     super.key,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         decoration: BoxDecoration(
//           color: selected ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: TextStyle(
//             color: selected ? Colors.white : Colors.white70,
//             fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }
