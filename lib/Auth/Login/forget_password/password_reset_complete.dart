import 'package:flutter/material.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              /// 🔝 BACK
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              /// 🔵 STEP INDICATOR (ALL COMPLETED)
              _stepIndicator(activeStep: 3),

              const SizedBox(height: 50),

              /// 🎉 ILLUSTRATION
              Image.asset(
                'assets/images/illustration.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              /// 🎊 TITLE
              const Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1B44),
                ),
              ),

              const SizedBox(height: 12),

              /// 📝 DESCRIPTION
              const Text(
                "You have successfully created a new password,\n"
                "click continue to enter the application",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              /// 🔵 CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Home / Dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔵 STEP INDICATOR (COMPLETED STYLE)
  Widget _stepIndicator({required int activeStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber <= activeStep;

        return Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: isCompleted
                  ? const Color(0xFF2F6BFF)
                  : Colors.grey.shade300,
              child: Text(
                "$stepNumber",
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
            if (index != 2)
              Container(
                width: 30,
                height: 2,
                color: isCompleted
                    ? const Color(0xFF2F6BFF)
                    : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }
}
