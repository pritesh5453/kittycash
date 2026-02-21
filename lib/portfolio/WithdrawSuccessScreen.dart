// import 'package:flutter/material.dart';
// import 'package:kittycash/portfolio/RequestWithdrawScreen.dart';

// class WithdrawSuccessScreen extends StatelessWidget {
//   const WithdrawSuccessScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFFFFB347), Color(0xFFFF9800)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // 🔙 Back Arrow
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),

//               const Spacer(),

//               // ✅ Success Icon
//               Container(
//                 width: 130,
//                 height: 130,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.25),
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 90,
//                     height: 90,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                     ),
//                     child: const Icon(
//                       Icons.check,
//                       size: 40,
//                       color: Color(0xFFFF9800),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // ✅ Title
//               const Text(
//                 "Withdraw Request Sent\nSuccessfully !",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // ✅ Subtitle
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 30),
//                 child: Text(
//                   "We've received your withdraw request.\nYour transaction will be processed shortly.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ),

//               const Spacer(),

//               // 🏠 GO TO HOME BUTTON
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 44,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {
//                       //   onPressed: () {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const RequestWithdrawalScreen(),
//                         ),
//                         (route) => false,
//                       );
//                     },

//                     child: const Text(
//                       "GO TO HOME",
//                       style: TextStyle(
//                         color: Color(0xFFFF9800),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
