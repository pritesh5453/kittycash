import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kittycash/Refferal_screen/how_it_works_screen.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool loading = true;

  Map<String, dynamic>? user;
  Map<String, dynamic>? commissions;
  Map<String, dynamic>? referrals;

  @override
  void initState() {
    super.initState();
    loadReferralData();
  }

  Future<void> loadReferralData() async {
    try {
      final token = await storage.read(key: "auth_token");

      if (token == null) {
        setState(() => loading = false);
        return;
      }

      final response = await dio.get(
        "https://kittycash.co.in/api/trading/referral-history",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("REFERRAL RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data["success"] == true) {
        setState(() {
          user = response.data["data"]["user"];
          commissions = response.data["data"]["commissions"];
          referrals = response.data["data"]["referrals"];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Referral Error: $e");
      setState(() => loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6BFF),
        title: const Text("Referrals", style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _referralCodeCard(),
                  const SizedBox(height: 16),
                  _totalEarned(),
                  const SizedBox(height: 16),
                  _levelCards(),
                  const SizedBox(height: 16),
                  // _learnMore(),
                  // const SizedBox(height: 16),
                  _referralUsers(),
                ],
              ),
            ),
    );
  }

  /// 🔹 Referral Code Card
  Widget _referralCodeCard() {
    final code = user?["referral_code"] ?? "";
    final link = user?["referral_link"] ?? "";

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
                  code,
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
              Share.share("Join using my referral link:\n$link");
            },
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text("Share", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6BFF),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Total Earned
  Widget _totalEarned() {
    final total = commissions?["total_earned"] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("Total Earned", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            "₹ $total",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Level Cards
  Widget _levelCards() {
    final level1 = commissions?["level_1"] ?? {};
    final level2 = commissions?["level_2"] ?? {};

    return Row(
      children: [
        Expanded(
          child: _levelCard(
            "Level 1",
            "₹ ${level1["earned"] ?? 0}",
            "${level1["count"] ?? 0} Referrals",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _levelCard(
            "Level 2",
            "₹ ${level2["earned"] ?? 0}",
            "${level2["count"] ?? 0} Referrals",
          ),
        ),
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

  /// 🔹 Referral Users List
  Widget _referralUsers() {
    final level1Users = referrals?["level_1"]?["users"] ?? [];

    if (level1Users.isEmpty) {
      return const Text("No referrals yet");
    }

    return Column(
      children: level1Users.map<Widget>((user) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: _box(),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user["name"] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget _learnMore() {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
  //         );
  //       },
  //       child: const Text(
  //         "Learn More",
  //         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  BoxDecoration _box({Color? border}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: border != null ? Border.all(color: border) : null,
    );
  }
}
