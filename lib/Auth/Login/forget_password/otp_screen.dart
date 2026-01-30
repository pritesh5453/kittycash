import 'package:flutter/material.dart';
import 'package:kittycash/Auth/Login/forget_password/create_password.dart';

class EnterCodeScreen extends StatelessWidget {
  const EnterCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              _stepIndicator(activeStep: 2),

              const SizedBox(height: 30),

              const Text(
                "Please enter the code",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              const Text(
                "We sent email to tomashuk.dima.1992@gmail.com",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              const Icon(Icons.email_outlined, size: 64),

              const SizedBox(height: 20),

              /// OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (_) => _otpBox()),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Didn't get a mail? "),
                  Text(
                    "Send again",
                    style: TextStyle(
                      color: Color(0xFF2F6BFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePasswordScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Entered",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 12),

              const Text("or continue with"),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.facebook, size: 30),
                  Icon(Icons.apple, size: 30),
                  Icon(Icons.g_mobiledata, size: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox() {
    return Container(
      width: 46,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  _stepIndicator({required int activeStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final stepNumber = index + 1;

        final bool isCompletedOrActive = stepNumber <= activeStep;

        return Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: isCompletedOrActive
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
                color: isCompletedOrActive
                    ? const Color(0xFF2F6BFF)
                    : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }
}
