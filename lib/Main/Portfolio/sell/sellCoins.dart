import 'package:flutter/material.dart';
import 'package:kittycash/Main/Portfolio/sell/confirmsell.dart';
import 'package:kittycash/util/commonappbar.dart';

class SellCoinsScreen extends StatefulWidget {
  const SellCoinsScreen({super.key});

  @override
  State<SellCoinsScreen> createState() => _SellCoinsScreenState();
}

class _SellCoinsScreenState extends State<SellCoinsScreen> {
  final TextEditingController sellCtrl = TextEditingController(text: "10");

  final double totalBalance = 5913.44951;
  final double pricePerCoin = 0.12;

  final double serviceChargePercent = 2.0;
  final double gstPercent = 18.0;

  double get sellCoins => double.tryParse(sellCtrl.text) ?? 0;

  double get grossAmount => sellCoins * pricePerCoin;

  double get serviceCharge => grossAmount * serviceChargePercent / 100;

  double get gst => serviceCharge * gstPercent / 100;

  double get netAmount => grossAmount - serviceCharge - gst;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CommonAppHeader(title: "Sell Coins"),
      backgroundColor: const Color(0xFFF3F6FB),
      body: Center(
        child: Container(
          width: w * 0.94,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2F80ED)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Buy KittyCash",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------------- STATS ----------------
                _statsGrid(),

                const SizedBox(height: 16),

                // ---------------- COINS INPUT ----------------
                const Text(
                  "Coins to Sell",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: sellCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Enter Number",
                    suffixText: "KTCH",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Available : ${totalBalance.toStringAsFixed(5)} KTCH",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 14),

                // ---------------- RECEIVE BOX ----------------
                _orangeBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You will Approximately receive",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${netAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ---------------- CHARGES BOX ----------------
                _orangeBox(
                  child: Column(
                    children: [
                      _chargeRow(
                        "Service Charge (2.00%)",
                        "₹ ${serviceCharge.toStringAsFixed(2)}",
                      ),
                      _chargeRow(
                        "GST (18.00%) on service charge",
                        "₹ ${gst.toStringAsFixed(2)}",
                      ),
                      const Divider(),
                      _chargeRow(
                        "Total Amount to Receive",
                        "₹ ${netAmount.toStringAsFixed(2)}",
                        highlight: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ---------------- INSTRUCTIONS ----------------
                Row(
                  children: const [
                    Icon(Icons.list_alt, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Important Instructions",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _bullet("A platform fee plus GST will be applied"),
                _bullet("Funds will be credited to your INR wallet"),
                _bullet("Transaction may take 2–5 minutes to process"),
                _bullet("All transactions are irreversible"),

                const SizedBox(height: 18),

                // ---------------- BUTTONS ----------------
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ConfirmSellTransactionScreen(),
                            ),
                          );
                        },
                        child: const Text("Sell Coin"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- STATS GRID ----------------
  Widget _statsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Total Balance",
                totalBalance.toStringAsFixed(5),
                Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard("Current Value", "₹ 591.13", Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard("Invested Amount", "₹ 513.95", Colors.blue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard("Profit & Loss", "+ ₹ 13.59", Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- SMALL WIDGETS ----------------
  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _orangeBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _chargeRow(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.green : Colors.black,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• "),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
