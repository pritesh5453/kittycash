import 'package:flutter/material.dart';
import 'package:kittycash/Auth/Login/forget_password/password_reset_complete.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  bool obscure1 = true;
  bool obscure2 = true;
  bool touchId = false;

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

              _stepIndicator(activeStep: 3),

              const SizedBox(height: 30),

              const Text(
                "Create a password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              const Text(
                "The password must be 8 characters, including 1 uppercase letter, "
                "1 number and 1 special character.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              _passwordField("Password", obscure1, () {
                setState(() => obscure1 = !obscure1);
              }),

              const SizedBox(height: 14),

              _passwordField("Confirm password", obscure2, () {
                setState(() => obscure2 = !obscure2);
              }),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Unlock with Touch ID?"),
                  Switch(
                    value: touchId,
                    onChanged: (v) => setState(() => touchId = v),
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
                        builder: (_) => const CongratulationsScreen(),
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

  Widget _passwordField(String hint, bool obscure, VoidCallback toggle) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
