import 'package:flutter/material.dart';
import 'package:kittycash/Onboarding%20Screens/welcome2.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// 🔹 App Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Logo.png", height: 28, width: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "KittyCash",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F6BFF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// 🔹 Illustration
              Expanded(
                child: Image.asset(
                  "assets/images/onboarding.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 Title
              const Text(
                "Take hold of your\nfinances",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Subtitle
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                "Ut eget mauris massa pharetra.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),

              const SizedBox(height: 24),

              /// 🔹 Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(isActive: true), _dot(), _dot()],
              ),

              const SizedBox(height: 30),

              /// 🔹 Next Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen2(),
                      ),
                    );
                  },

                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 👈 only this
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Dot Widget
  Widget _dot({bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 18 : 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2F6BFF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
