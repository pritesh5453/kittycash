import 'package:flutter/material.dart';
import 'package:kittycash/Main/Portfolio/Buy/confirmcoins.dart';
import 'package:kittycash/util/commonappbar.dart';

class BuyKittyCashScreen extends StatefulWidget {
  const BuyKittyCashScreen({super.key});

  @override
  State<BuyKittyCashScreen> createState() => _BuyKittyCashScreenState();
}

class _BuyKittyCashScreenState extends State<BuyKittyCashScreen> {
  final TextEditingController amountCtrl = TextEditingController(text: "100");

  final double pricePerCoin = 61.11;
  final double serviceChargePercent = 2.0;
  final double gstPercent = 18.0;

  double get amount => double.tryParse(amountCtrl.text) ?? 0;

  double get serviceCharge => amount * serviceChargePercent / 100;

  double get gst => serviceCharge * gstPercent / 100;

  double get totalPayable => amount + serviceCharge + gst;

  double get coins => amount > 0 ? amount / pricePerCoin : 0;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CommonAppHeader(title: "Portfolio"),
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

                const SizedBox(height: 14),

                // ---------------- PRICE BOX ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "₹ 61.11",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Current Price (₹)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ---------------- INR INPUT ----------------
                const Text(
                  "INR Amount",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    hintText: "Enter amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ---------------- COINS BOX ----------------
                _infoBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You will Approximately receive",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${coins.toStringAsFixed(8)} KTCH",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ---------------- CHARGES BOX ----------------
                _infoBox(
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
                        "Total Amount to Pay",
                        "₹ ${totalPayable.toStringAsFixed(2)}",
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

                _bullet("Platform fee plus GST will be applied"),
                _bullet("Funds will be debited from your INR wallet"),
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
                                  const ConfirmTransactionScreen(),
                            ),
                          );
                        },
                        child: const Text("Buy Coin"),
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

  // ---------------- SMALL WIDGETS ----------------

  Widget _infoBox({required Widget child}) {
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
          const Text("• "),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
