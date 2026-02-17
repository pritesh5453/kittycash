import 'package:flutter/material.dart';
import 'package:kittycash/portfolio/RequestWithdrawScreen.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88FF),
        elevation: 0,

        // 🔥 THIS LINE FIXES EVERYTHING
        foregroundColor: Colors.white,

        title: const Text("Withdraw"),
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    title: "KYC Verification Requirements",
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        "KYC Verification Required :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _tick("Aadhar Verification"),
                      _tick("PAN card Verification"),
                      _tick("Bank Account Verification"),
                      const SizedBox(height: 12),
                      const Text(
                        "Withdrawal Rules :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _tick(
                        "Only Utilized Balance (Profits from coin sales can be withdrawn)",
                      ),
                      _tick("One active Withdrawal request allowed at a time"),
                      _tick("Minimum withdrawal : ₹ 100"),
                      _tick("All KYC verifications must be completed"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _card(
                    title: "Processing Information",
                    children: [
                      _dot(
                        "Withdrawal requests are processed within 1-3 business days",
                      ),
                      _dot("Funds will be transferred to your bank account"),
                      _dot("Admin approval is required for all withdrawals"),
                      _dot("Processing fees may apply based on your plan"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12), // ⬅️ outer spacing कमी
            child: SizedBox(
              width: double.infinity,
              height: 40, // ⬅️ आधी 50 होतं, आता छोटं
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.zero, // ⬅️ extra inner padding remove
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // थोडा छोटा radius
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestWithdrawScreen(),
                    ),
                  );
                },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Withdraw",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // ⬅️ text पण थोडं छोटं
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.logout,
                        size: 12, // ⬅️ icon छोटा
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _tick(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _dot(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
