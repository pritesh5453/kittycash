import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittycash/portfolio/deposit_money_form_screen.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB), // ✅ same soft bg
      /// 🔹 AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF194EEE),
        elevation: 0,
        title: const Text(
          "Deposit",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            // fontSize: 18,
          ),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _bankDetailsCard(),
            const SizedBox(height: 16),
            _instructionsCard(),
            const Spacer(),

            /// 🔥 Right aligned Deposit button
            Align(
              alignment: Alignment.centerRight,
              child: _depositButton(context),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= BANK DETAILS =================
  Widget _bankDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance, color: Color(0xFFFF9F2D)),
              SizedBox(width: 8),
              Text(
                "KittyCash Bank Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow("Account Holder", "kittycash"),
          _detailRow("Bank Name", "State Bank of India"),
          _copyRow("Account Number", "41136293295"),
          _copyRow("IFSC Code", "SBIN0061395"),
        ],
      ),
    );
  }

  /// ================= INSTRUCTIONS =================
  Widget _instructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.list_alt, color: Color(0xFFFF9F2D)),
              SizedBox(width: 8),
              Text(
                "Deposit Instructions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          _InstructionItem(
            "Choose your deposit amount from the options below.",
          ),
          _InstructionItem(
            "Transfer the exact amount to the bank account details shown above.",
          ),
          _InstructionItem(
            "After payment, enter the UTR/Reference number & proof in the next step.",
          ),
          _InstructionItem(
            "Your deposit will be verified manually by our team within 24 hrs.",
          ),
          _InstructionItem(
            "Once approved, the amount will be credited to your wallet.",
          ),
        ],
      ),
    );
  }

  /// ================= DEPOSIT BUTTON =================
  Widget _depositButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DepositMoneyFormScreen(), // 👈 navigate here
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9F2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Deposit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.open_in_new, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  /// ================= HELPERS =================
  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title :", style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _copyRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title :", style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Copy",
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget depositHistoryCard() {
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
        // Header
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

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              _TH("Date", flex: 2),
              _TH("Amount"),
              _TH("UTR No.", flex: 2),
              _TH("Verification"),
              _TH("Status"),
              _TH("Actions"),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Rows
        _historyRow(
          date: "Jan 28, 2026\n13:59",
          amount: "₹ 100.00",
          utr: "UTR00001",
          verification: "Approved",
          status: "Completed",
        ),
        const SizedBox(height: 6),
        _historyRow(
          date: "Jan 28, 2026\n13:59",
          amount: "₹ 100.00",
          utr: "UTR00001",
          verification: "Approved",
          status: "Completed",
        ),
      ],
    ),
  );
}

// ===== Table Header Cell
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
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ===== One History Row
Widget _historyRow({
  required String date,
  required String amount,
  required String utr,
  required String verification,
  required String status,
}) {
  return Row(
    children: [
      Expanded(
        flex: 2,
        child: Text(date, style: const TextStyle(fontSize: 11)),
      ),
      Expanded(
        child: Text(
          amount,
          style: const TextStyle(fontSize: 11, color: Colors.blue),
        ),
      ),
      Expanded(flex: 2, child: Text(utr, style: const TextStyle(fontSize: 11))),
      Expanded(
        child: Text(
          verification,
          style: const TextStyle(fontSize: 11, color: Colors.green),
        ),
      ),
      Expanded(
        child: Text(
          status,
          style: const TextStyle(fontSize: 11, color: Colors.green),
        ),
      ),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9F2D)),
            ),
            child: const Text(
              "View",
              style: TextStyle(fontSize: 11, color: Color(0xFFFF9F2D)),
            ),
          ),
        ),
      ),
    ],
  );
}

/// ================= INSTRUCTION ITEM =================
class _InstructionItem extends StatelessWidget {
  final String text;
  const _InstructionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
