import 'package:flutter/material.dart';
import 'package:kittycash/portfolio/WithdrawSuccessScreen.dart';

class RequestWithdrawScreen extends StatelessWidget {
  const RequestWithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88FF),
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _requestWithdrawCard(context),
            const SizedBox(height: 16),
            _withdrawHistoryCard(),
          ],
        ),
      ),
    );
  }

  // 🔹 REQUEST WITHDRAW CARD
  Widget _requestWithdrawCard(BuildContext context) {
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
            children: const [
              Icon(Icons.arrow_back_ios, size: 16),
              SizedBox(width: 6),
              Icon(Icons.access_time, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                "Request Withdrawal",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Available Balance",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              "₹ 61.11",
              style: TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              "Utilized Balance (Profits from coin sales)",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Withdrawal Amount (₹) *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          TextField(
            decoration: InputDecoration(
              prefixText: "₹ ",
              hintText: "50",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Minimum: ₹100 , Maximum: ₹50,000",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6AF7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WithdrawSuccessScreen(),
                  ),
                  (route) => false,
                );
              },

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Withdraw",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Icon(
                      Icons.logout,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 WITHDRAW HISTORY CARD
  Widget _withdrawHistoryCard() {
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
            children: const [
              Icon(Icons.access_time, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                "Withdrawal History",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const _historyHeader(),
          const Divider(),

          _historyRow("Jan 28, 2026\n13:59", "₹ 100.00", "Completed"),
          const Divider(),
          _historyRow("Jan 28, 2026\n13:59", "₹ 100.00", "Completed"),
        ],
      ),
    );
  }

  static Widget _historyRow(String date, String amount, String status) {
    return Row(
      children: [
        Expanded(child: Text(date, style: const TextStyle(fontSize: 11))),
        Expanded(
          child: Text(
            amount,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            status,
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// 🔹 HISTORY HEADER
class _historyHeader extends StatelessWidget {
  const _historyHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text("Amount", style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text("Status", style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
