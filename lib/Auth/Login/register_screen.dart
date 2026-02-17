import 'package:flutter/material.dart';
import 'package:kittycash/Auth/Login/Otp_Page.dart';
import 'package:kittycash/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dobController = TextEditingController();
  final referralController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    referralController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    final response = await AuthService().register(
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(), // ✅ important
      dob: dobController.text.trim(),
      referral: referralController.text.trim(),
    );

    setState(() => isLoading = false);

    if (response["status"] == true) {
      if (response["status"] == true) {
        final sessionId = response["data"]["session_id"];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpRegisterPage(
              email: emailController.text.trim(),
              mobile: mobileController.text.trim(),
              sessionId: sessionId, // 🔥 MUST
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Hello",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F6BFF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Register Here",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A1B44),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              _field("Name", nameController),
              const SizedBox(height: 14),

              _field("Mobile No", mobileController),
              const SizedBox(height: 20),
              _field("Email", emailController),
              const SizedBox(height: 14),

              _passwordField(
                "Create Password",
                passwordController,
                obscurePassword,
                () => setState(() => obscurePassword = !obscurePassword),
              ),
              const SizedBox(height: 14),

              _passwordField(
                "Re-Enter Password",
                confirmPasswordController,
                obscureConfirmPassword,
                () => setState(
                  () => obscureConfirmPassword = !obscureConfirmPassword,
                ),
              ),
              const SizedBox(height: 14),

              _field("DD-MM-YYYY", dobController),
              const SizedBox(height: 14),

              _field("Referral Code (Optional)", referralController),

              const SizedBox(height: 28),

              SizedBox(
                width: width,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register"),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _passwordField(
    String hint,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
