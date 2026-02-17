import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//////////////////////////////////////////////////////////////
/// SERVICE CLASS (API ONLY)
//////////////////////////////////////////////////////////////
class DashboardService {
  static const String baseUrl = "https://kittycash.co.in/api";

  Future<Map<String, dynamic>> getDashboardProfile(String token) async {
    print("🔥 DASHBOARD API HIT");

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dashboard/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("🔥 STATUS => ${response.statusCode}");
      print("🔥 BODY => ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"status": true, "data": data};
      } else {
        return {"status": false};
      }
    } catch (e) {
      print("❌ API ERROR => $e");
      return {"status": false};
    }
  }
}

//////////////////////////////////////////////////////////////
/// UI SCREEN
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

  //////////////////////////////////////////////////////////////
  /// LOAD DASHBOARD
  //////////////////////////////////////////////////////////////
  Future<void> loadDashboard() async {
    try {
      const token = "16|luMBOYamB5XjCtIOYf48sHW9Tx3KFfPsCaNeRVs08d2689d4";

      print("🔥 DASHBOARD API CALL START");
      final res = await DashboardService().getDashboardProfile(token);
      print("🔥 DASHBOARD API RESPONSE => $res");

      if (res["status"] == true) {
        final responseData = res["data"];

        if (responseData is Map<String, dynamic>) {
          setState(() {
            profile = responseData.containsKey("data")
                ? responseData["data"]
                : responseData;
          });
        }
      }
    } catch (e) {
      print("❌ DASHBOARD ERROR: $e");
    } finally {
      if (mounted) {
        setState(() {
          loading = false; // ✅ VERY IMPORTANT
        });
      }
    }
  }

  //////////////////////////////////////////////////////////////
  /// UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              HomeHeader(),
              Padding(
                padding: EdgeInsets.all(23.0),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    ReferCard(),
                    SizedBox(height: 20),
                    TrendingSection(),
                    SizedBox(height: 20),
                    AllCoinsSection(),
                    SizedBox(height: 30),
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
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Welcome",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Stack(
                children: const [
                  Icon(Icons.notifications_none, color: Colors.white, size: 26),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/images/profile.png"),
              ),
            ],
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
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              "assets/images/refer_and_earn.jpg",
              width: MediaQuery.of(context).size.width * 0.85,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// TRENDING SECTION
//////////////////////////////////////////////////////////////

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Top Trending Coins",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: TrendingCard(
                  title: "KTC",
                  subtitlecolor: Colors.orange,
                  subtitleheading: "New",
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TrendingCard(
                  title: "KTCH",
                  subtitlecolor: Colors.green,
                  subtitleheading: "+12%",
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TrendingCard(
                  title: "KTCR",
                  subtitlecolor: Colors.red,
                  subtitleheading: "-8%",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TrendingCard extends StatelessWidget {
  final String title;
  final Color subtitlecolor;
  final String subtitleheading;
  const TrendingCard({
    super.key,
    required this.title,
    required this.subtitleheading,
    required this.subtitlecolor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 100,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orangeAccent),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                child: Image.asset("assets/images/kitty.png"),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: subtitlecolor,
                  fontSize: 10,
                ),
              ),
              Spacer(),
              Text(
                subtitleheading,
                style: TextStyle(
                  color: subtitlecolor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "10.59",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// ALL COINS SECTION
//////////////////////////////////////////////////////////////

class AllCoinsSection extends StatelessWidget {
  const AllCoinsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "All Coins",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CoinCard(),
          const SizedBox(height: 12),
          const CoinCard(),
        ],
      ),
    );
  }
}

class CoinCard extends StatelessWidget {
  const CoinCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/kitty.png"),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "KTCH",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text("₹10.95", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text(
                        "+5.9%",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "+125.25(24h)",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.info_outline, size: 18),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF356AE6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Buy Coin",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
