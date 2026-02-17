import 'package:flutter/material.dart';
import 'package:kittycash/Profile_Screen/KycPanVerificationScreen.dart';

class KycPersonalDetailsScreen extends StatelessWidget {
  const KycPersonalDetailsScreen({super.key});

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
        title: const Text("KYC", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // STEP INDICATOR
            const Center(
              child: Text(
                "STEP 1 OF 4",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // PROGRESS BAR
            Center(
              child: Container(
                width: 140,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 35,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F6AF7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            const Text(
              "Personal Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Fill in your details below and then\ncontinue to the next step.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 24),

            _inputLabel("Full Name"),
            _textField("Michael Mitc"),

            const SizedBox(height: 16),

            _inputLabel("Date of Birth"),
            _textField("15-05-1992"),

            const SizedBox(height: 16),

            _inputLabel("Email"),
            _textField("michael.mitc@example.com"),

            const SizedBox(height: 16),

            _inputLabel("PAN Number"),
            _textField("6844 - 5548 - 1214 - 8998"),

            const SizedBox(height: 30),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6AF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KycPanVerificationScreen(),
                    ),
                  );
                },

                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🔹 LABEL
  Widget _inputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  // 🔹 TEXT FIELD
  Widget _textField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2F6AF7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2F6AF7), width: 1.5),
        ),
      ),
    );
  }
}
