import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kittycash/portfolio/TransactionSuccessScreen.dart';

class DepositMoneyFormScreen extends StatefulWidget {
  const DepositMoneyFormScreen({super.key});

  @override
  State<DepositMoneyFormScreen> createState() => _DepositMoneyFormScreenState();
}

class _DepositMoneyFormScreenState extends State<DepositMoneyFormScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// 🔹 AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7BFF),
        elevation: 0,
        title: const Text(
          "Deposit",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
          SizedBox(width: 12),
        ],
      ),

      /// 🔹 Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _depositFormCard(),
            const SizedBox(height: 16),
            _depositHistoryCard(),
          ],
        ),
      ),
    );
  }

  // =================================================
  // 🔹 DEPOSIT FORM CARD
  // =================================================
  Widget _depositFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_wallet, color: Color(0xFF1E7BFF)),
              SizedBox(width: 8),
              Text(
                "Deposit Money",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Add funds to your KittyCash wallet securely",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          const Text(
            "₹ Deposit Amount (₹) *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _inputField("Enter amount in rupees"),
          const SizedBox(height: 4),
          const Text(
            "Minimum: ₹1 , Maximum: ₹50,000",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          const Text(
            "# UTR / Reference Number *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _inputField("Enter UTR number"),
          const SizedBox(height: 14),

          const Text(
            "# Payment Screenshot *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1ECFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Choose File",
                    style: TextStyle(
                      color: Color(0xFF6A5AE0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedImage == null
                      ? "No File chosen"
                      : _selectedImage!.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D6BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionSuccessScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text(
                "Submit Deposit Request",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================
  // 🔹 DEPOSIT HISTORY CARD
  // =================================================
  Widget _depositHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.history, color: Color(0xFF1E7BFF)),
              SizedBox(width: 8),
              Text(
                "Deposit History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                _TH("Date", flex: 2),
                _TH("Amount"),
                _TH("UTR", flex: 2),
                _TH("Verify"),
                _TH("Status"),
                _TH("Action"),
              ],
            ),
          ),
          const SizedBox(height: 8),

          _historyRow(),
          const SizedBox(height: 6),
          _historyRow(),
        ],
      ),
    );
  }

  Widget _historyRow() {
    return Row(
      children: [
        _cell("Jan 28, 2026\n13:59", flex: 2),
        _cell("₹100.00", color: Colors.blue),
        _cell("UTR00001", flex: 2),
        _cell("Approved", color: Colors.green),
        _cell("Completed", color: Colors.green),
        SizedBox(
          width: 60,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF9F2D)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "View",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFFF9F2D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Widget _inputField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

// ================= Helpers =================
class _TH extends StatelessWidget {
  final String text;
  final int flex;

  const _TH(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _cell(String text, {int flex = 1, Color? color}) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11, color: color),
    ),
  );
}
