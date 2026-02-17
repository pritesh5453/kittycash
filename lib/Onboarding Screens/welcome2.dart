import 'package:flutter/material.dart';
import 'package:kittycash/Onboarding%20Screens/welcome3.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// 🔹 Logo + Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Logo.png", height: 26),
                  const SizedBox(width: 8),
                  const Text(
                    "KittyCash",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F6BFF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 🔹 Illustration with floating icons
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/images/onboarding2.png",
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 Title
              const Text(
                "Smart trading tools",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              /// 🔹 Subtitle
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                "Ut eget mauris massa pharetra.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),

              const SizedBox(height: 20),

              /// 🔹 Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(), _dot(isActive: true), _dot()],
              ),

              const SizedBox(height: 24),

              /// 🔹 Next Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen3(),
                      ),
                    );
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Small floating icon
  Widget _circleIcon(String path) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: Image.asset(path, height: 18),
    );
  }

  /// 🔹 Page dot
  Widget _dot({bool isActive = false}) {
    return Container(
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
