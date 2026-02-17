import 'package:flutter/material.dart';
import 'package:kittycash/Refferal_screen/how_it_works_screen.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  final String referralCode = "E48fsdsds53";

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6BFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Referrals"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _snack(context, "Notifications clicked"),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _referralCodeCard(context),
            const SizedBox(height: 16),
            _totalEarned(),
            const SizedBox(height: 16),
            _levelCards(),
            const SizedBox(height: 8),
            _learnMore(context),
            const SizedBox(height: 20),
            _userTile(context, "Annette Black", "1st", 200),
            _userTile(context, "John Doe", "2nd", 100),
            _userTile(context, "Arvin Kinney", "2nd", 0, reminder: true),
          ],
        ),
      ),
    );
  }

  // 🔹 Referral code + WhatsApp share
  Widget _referralCodeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Referral Code",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  referralCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Share.share(
                "Join using my referral code: $referralCode\nDownload the app now!",
              );
            },
            icon: const Icon(Icons.share),
            label: const Text("Share"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6BFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Total earned
  Widget _totalEarned() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Text("Total Earned", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 6),
          Text(
            "₹ 3250.75",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Level cards
  Widget _levelCards() {
    return Row(
      children: [
        Expanded(
          child: _levelCard("Level 1 (20%)", "₹ 2400.50", "9 Referrals"),
        ),
        const SizedBox(width: 12),
        Expanded(child: _levelCard("Level 2 (10%)", "₹ 850.50", "5 Referrals")),
      ],
    );
  }

  Widget _levelCard(String title, String amount, String ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(border: Colors.blue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(ref, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 🔹 Learn More navigation
  Widget _learnMore(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
          );
        },
        child: const Text(
          "Learn More",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 🔹 User tile
  Widget _userTile(
    BuildContext context,
    String name,
    String level,
    int amount, {
    bool reminder = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name   $level",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  children: const [
                    _StatusDot("Sign Up"),
                    _StatusDot("First Investment"),
                    _StatusDot("KYC"),
                  ],
                ),
              ],
            ),
          ),
          reminder
              ? OutlinedButton(
                  onPressed: () => _snack(context, "Reminder sent"),
                  child: const Text("Send Reminder"),
                )
              : Text(
                  "₹ $amount",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ],
      ),
    );
  }

  BoxDecoration _box({Color? border}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: border != null ? Border.all(color: border) : null,
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String text;
  const _StatusDot(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 8, color: Colors.green),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
