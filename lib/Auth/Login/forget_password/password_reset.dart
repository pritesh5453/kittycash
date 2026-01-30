import 'package:flutter/material.dart';
import 'package:kittycash/Auth/Login/forget_password/otp_screen.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              /// STEP INDICATOR
              _stepIndicator(activeStep: 1),

              const SizedBox(height: 30),

              const Text(
                "Password reset",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1B44),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Please enter your registered email address to reset your password",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              /// EMAIL
              TextField(
                decoration: InputDecoration(
                  hintText: "Email address",
                  prefixIcon: const Icon(Icons.mail_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// CONTINUE
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnterCodeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              const Text(
                "By registering you accept our Terms & Conditions and Privacy Policy. "
                "Your data will be security encrypted with TLS",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  _stepIndicator({required int activeStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index + 1 == activeStep;

        return Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: isActive
                  ? const Color(0xFF2F6BFF)
                  : Colors.grey.shade300,
              child: Text(
                "${index + 1}",
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
            if (index != 2)
              Container(width: 30, height: 2, color: Colors.grey.shade300),
          ],
        );
      }),
    );
  }
}
