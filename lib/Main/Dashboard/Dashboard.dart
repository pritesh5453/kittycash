import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kittycash/Profile_Screen/profile_Screen.dart';

//////////////////////////////////////////////////////////////
/// SERVICE
//////////////////////////////////////////////////////////////
class DashboardService {
  static const String baseUrl = "https://kittycash.co.in/api";

  Future<Map<String, dynamic>> getDashboardProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/profile"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"status": true, "data": data};
    }
    return {"status": false};
  }
}

//////////////////////////////////////////////////////////////
/// DASHBOARD SCREEN
//////////////////////////////////////////////////////////////
class CryptoHomeScreen extends StatefulWidget {
  const CryptoHomeScreen({super.key});

  @override
  State<CryptoHomeScreen> createState() => _CryptoHomeScreenState();
}

class _CryptoHomeScreenState extends State<CryptoHomeScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    final res = await DashboardService().getDashboardProfile(token);

    if (res["status"] == true) {
      final responseData = res["data"];
      profile = responseData["data"] ?? responseData;
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(profile: profile),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ReferCard(),
                    SizedBox(height: 20),
                    TrendingSection(),
                    SizedBox(height: 20),
                    AllCoinsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// HEADER
//////////////////////////////////////////////////////////////
class HomeHeader extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const HomeHeader({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final name =
        profile?['name'] ?? profile?['full_name'] ?? profile?['username'] ?? "";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Welcome $name",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(profile: profile),
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: profile?['profile_image'] != null
                  ? NetworkImage(profile!['profile_image'])
                  : const AssetImage("assets/images/profile.png")
                        as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// REFER CARD
//////////////////////////////////////////////////////////////
class ReferCard extends StatelessWidget {
  const ReferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        "assets/images/refer_and_earn.jpg",
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// TRENDING
//////////////////////////////////////////////////////////////
class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Text(
            "Top Trending Coins",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TrendingCard("KTC", "+5%")),
              SizedBox(width: 10),
              Expanded(child: TrendingCard("KTCH", "+12%")),
              SizedBox(width: 10),
              Expanded(child: TrendingCard("KTCR", "-8%")),
            ],
          ),
        ],
      ),
    );
  }
}

class TrendingCard extends StatelessWidget {
  final String title;
  final String change;
  const TrendingCard(this.title, this.change, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyle(
              color: change.startsWith("-") ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// ALL COINS
//////////////////////////////////////////////////////////////
class AllCoinsSection extends StatelessWidget {
  const AllCoinsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [CoinTile(), SizedBox(height: 12), CoinTile()],
      ),
    );
  }
}

class CoinTile extends StatelessWidget {
  const CoinTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: const [
          CircleAvatar(backgroundImage: AssetImage("assets/images/kitty.png")),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "KTCH  ₹10.95",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text("+5.9%", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}
