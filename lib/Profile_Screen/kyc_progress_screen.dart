import 'package:flutter/material.dart';
import 'package:kittycash/Profile_Screen/profile_Screen.dart';

class KycProgressScreen extends StatelessWidget {
  const KycProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("KYC", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔵 CIRCULAR PROGRESS
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: CircularProgressIndicator(
                      value: 0.5, // 50%
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF2F6AF7),
                      ),
                    ),
                  ),
                  const Text(
                    "50%",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F6AF7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 STEPS
            _stepItem(
              title: "1. Personal Details",
              isDone: true,
              isActive: false,
            ),
            _stepItem(
              title: "2. PAN Verification",
              isDone: true,
              isActive: false,
            ),
            _stepItem(
              title: "3. Aadhaar Verification",
              isDone: false,
              isActive: true,
            ),
            _stepItem(
              title: "4. Identity Verification",
              isDone: false,
              isActive: false,
              showLine: false,
            ),

            const Spacer(),

            /// 🔘 FINISH BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6AF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(profile: null),
                    ),
                  );
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  "Finish",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// STEP ITEM WIDGET
  /// =======================
  Widget _stepItem({
    required String title,
    required bool isDone,
    required bool isActive,
    bool showLine = true,
  }) {
    Color dotColor;
    if (isDone) {
      dotColor = Colors.green;
    } else if (isActive) {
      dotColor = const Color(0xFF2F6AF7);
    } else {
      dotColor = Colors.grey.shade400;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT INDICATOR
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (showLine)
              Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),

        const SizedBox(width: 14),

        /// TITLE
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
