import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kittycash/Auth/Login/login_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  List transactions = [];
  bool isLoading = true;
  int selectedTab = 0;

  String? token;

  final String baseUrl =
      "https://kittycash.co.in/api/dashboard/transactions?page=1";

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
  }

  /// ================= LOAD TOKEN =================

  Future<void> loadTokenAndFetch() async {
    token = await storage.read(key: "auth_token");

    if (token != null && token!.isNotEmpty) {
      await fetchTransactions();
    } else {
      debugPrint("Token not found");
      setState(() => isLoading = false);
    }
  }

  /// ================= FETCH TRANSACTIONS =================

  Future<void> fetchTransactions() async {
    if (token == null) return;

    try {
      setState(() => isLoading = true);

      final response = await dio.get(
        baseUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        setState(() {
          transactions = response.data["data"]["transactions"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } on DioException catch (e) {
      setState(() => isLoading = false);

      /// 🔴 AUTO LOGOUT ON 401
      if (e.response?.statusCode == 401) {
        await storage.delete(key: "auth_token");

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }

      debugPrint("Dio Error: ${e.message}");
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Unknown Error: $e");
    }
  }

  /// ================= FILTER =================

  List get filteredTransactions {
    if (selectedTab == 1) {
      return transactions
          .where(
            (e) => (e["status"] ?? "").toString().toLowerCase() == "pending",
          )
          .toList();
    } else if (selectedTab == 2) {
      return transactions
          .where(
            (e) => (e["status"] ?? "").toString().toLowerCase() != "pending",
          )
          .toList();
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          /// 🔵 HEADER
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2F6BFF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Orders",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                /// TABS
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _tabButton("All", 0),
                      _tabButton("Open", 1),
                      _tabButton("Closed", 2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      "No Transactions Found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchTransactions,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final item = filteredTransactions[index];

                        return OrderCard(
                          status: item["status"] ?? "Pending",
                          isBuy:
                              (item["type"] ?? "").toString().toLowerCase() ==
                              "buy",
                          symbol: item["coin"]?["symbol"] ?? "KTCH",
                          qty: item["quantity"]?.toString() ?? "0",
                          price: item["price"]?.toString() ?? "0",
                          total: item["total"]?.toString() ?? "0",
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2F6BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= ORDER CARD =================

class OrderCard extends StatelessWidget {
  final String status;
  final bool isBuy;
  final String symbol;
  final String qty;
  final String price;
  final String total;

  const OrderCard({
    super.key,
    required this.status,
    required this.isBuy,
    required this.symbol,
    required this.qty,
    required this.price,
    required this.total,
  });

  Color get statusColor {
    if (status.toLowerCase() == "pending") {
      return Colors.blue;
    } else if (status.toLowerCase() == "completed") {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange.shade50,
            child: Text(symbol),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text("Qty: $qty", style: const TextStyle(color: Colors.grey)),
                Text(
                  "Price: ₹$price",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Total: ₹$total",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                isBuy ? "BUY" : "SELL",
                style: TextStyle(
                  color: isBuy ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 110,
                child: Text(
                  status,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
