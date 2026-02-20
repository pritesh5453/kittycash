import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kittycash/Main/Buy/buy.dart';
import 'package:kittycash/Main/Dashboard/dashboard_model.dart';
import 'package:kittycash/Main/Dashboard/dashboard_services.dart';

class CryptoHomeScreen extends StatefulWidget {
  const CryptoHomeScreen({super.key});

  @override
  State<CryptoHomeScreen> createState() => _CryptoHomeScreenState();
}

class _CryptoHomeScreenState extends State<CryptoHomeScreen> {
  UserModel? user;
  List<CoinModel> coins = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        setState(() => loading = false);
        return;
      }

      final dashboard = await DashboardService().getOverview(token);

      setState(() {
        user = dashboard.user;
        coins = dashboard.coins;
        loading = false;
      });
    } catch (e) {
      print("Dashboard Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeader(user: user),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  ReferCard(),
                  SizedBox(height: 20),
                  TrendingSection(),
                  SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AllCoinsSection(coins: coins),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// HEADER
//////////////////////////////////////////////////////////////

class HomeHeader extends StatelessWidget {
  final UserModel? user;
  const HomeHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? "";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
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
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// REFER CARD
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
// TRENDING SECTION
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
      child: const Column(
        children: [
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
// COINS SECTION
//////////////////////////////////////////////////////////////

class AllCoinsSection extends StatelessWidget {
  final List<CoinModel> coins;
  const AllCoinsSection({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const Text("No coins available");
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: coins.map((coin) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CoinTile(coin: coin),
          );
        }).toList(),
      ),
    );
  }
}

class CoinTile extends StatelessWidget {
  final CoinModel coin;
  const CoinTile({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuyCoinScreen(
              coinId: coin.id,
              coinName: coin.name,
              serviceCharge: coin.serviceCharge,
              gstCharges: coin.gstCharges,
              coinPrice: coin.price,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(coin.image)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${coin.symbol}  ₹${coin.price.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
