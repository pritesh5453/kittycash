import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kittycash/portfolio/portfolio_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyCoinScreen extends StatefulWidget {
  final int coinId;
  final String coinName;
  final double serviceCharge;
  final double gstCharges;
  final double coinPrice;

  const BuyCoinScreen({
    super.key,
    required this.coinId,
    required this.coinName,
    required this.serviceCharge,
    required this.gstCharges,
    required this.coinPrice,
  });

  @override
  State<BuyCoinScreen> createState() => _BuyCoinScreenState();
}

class _BuyCoinScreenState extends State<BuyCoinScreen> {
  final TextEditingController amountController = TextEditingController();

  bool loading = false;
  bool showCalculation = false;

  double coinAmount = 0;
  double serviceChargeAmount = 0;
  double gstAmount = 0;
  double totalCharge = 0;
  double totalDeduct = 0;
  double finalPayable = 0;

  ////////////////////////////////////////////////////////////
  /// CALCULATE API
  ////////////////////////////////////////////////////////////

  Future<void> calculateBuy() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("https://kittycash.co.in/api/trading/buy/calculate"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"coin_id": widget.coinId, "inr_amount": amount}),
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      final res = data["data"];

      setState(() {
        coinAmount = (res["input"]["coin_amount"] as num).toDouble();
        serviceChargeAmount = (res["charges"]["service_charge"] as num)
            .toDouble();
        gstAmount = (res["charges"]["gst_charge"] as num).toDouble();
        totalCharge = (res["charges"]["total_charge"] as num).toDouble();
        totalDeduct = (res["total_amount_to_deduct"] as num).toDouble();
        finalPayable = amount + totalCharge;
        showCalculation = true;
      });
    }

    setState(() => loading = false);
  }

  ////////////////////////////////////////////////////////////
  /// BUY API
  ////////////////////////////////////////////////////////////

  Future<void> buyCoin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final amount = double.tryParse(amountController.text);
    if (token == null || amount == null) return;

    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("https://kittycash.co.in/api/trading/buy"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"coin_id": widget.coinId, "inr_amount": amount}),
    );

    final data = jsonDecode(response.body);

    setState(() => loading = false);

    if (data["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PortfolioScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Buy Failed")));
    }
  }

  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F7),
      body: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Buy ${widget.coinName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage("assets/images/profile.jpg"),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Coin Price
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹ ${widget.coinPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "${widget.coinName}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          const Text("Current Price"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("INR Amount"),
                    const SizedBox(height: 8),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateBuy(),
                      decoration: InputDecoration(
                        hintText: "₹ 100",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Show only after amount entered
                    if (showCalculation) ...[
                      _orangeBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("You will Approximately receive"),
                            const SizedBox(height: 6),
                            Text(
                              "${coinAmount.toStringAsFixed(4)} ${widget.coinName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _orangeBox(
                        child: Column(
                          children: [
                            _rowItem(
                              "Service Charge (${widget.serviceCharge}%)",
                              "₹${serviceChargeAmount.toStringAsFixed(2)}",
                            ),
                            _rowItem(
                              "GST (${widget.gstCharges}%)",
                              "₹${gstAmount.toStringAsFixed(2)}",
                            ),
                            const Divider(),
                            _rowItem(
                              "Total Amount to Pay",
                              "₹${finalPayable.toStringAsFixed(2)}",
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Row(
                      children: [
                        Icon(Icons.list),
                        SizedBox(width: 8),
                        Text(
                          "Important Instructions",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    const Text("• A platform fee plus GST will be Applied"),
                    const SizedBox(height: 6),
                    const Text("• Funds will be debited from your INR wallet"),
                    const SizedBox(height: 6),
                    const Text("• Transaction may take 2-5 minutes to Process"),
                    const SizedBox(height: 6),
                    const Text("• All transactions are irreversible"),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: showCalculation ? buyCoin : null,
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("Buy Coin"),
                          ),
                        ),
                      ],
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

  static Widget _orangeBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange),
      ),
      child: child,
    );
  }
}

class _rowItem extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _rowItem(this.title, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
