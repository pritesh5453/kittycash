import 'package:flutter/material.dart';
import 'package:kittycash/portfolio/deposit_money_form_screen.dart';

class TransactionSuccessScreen extends StatefulWidget {
  final String amount;
  final String utrNumber;
  final String transactionId;
  final String? walletBalance; // Optional - can be fetched or passed

  const TransactionSuccessScreen({
    super.key,
    required this.amount,
    required this.utrNumber,
    required this.transactionId,
    this.walletBalance,
  });

  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6EEB83), Color(0xFF3CB371)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Icon
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const Spacer(),

              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF3CB371),
                      size: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                "Transaction Successful !",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Dynamic Amount
              Text(
                "₹${widget.amount} Added to your wallet",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 25),

              // Divider
              Container(width: 200, height: 1, color: Colors.white30),

              const SizedBox(height: 20),

              const Text(
                "CURRENT WALLET BALANCE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              // Dynamic Wallet Balance
              Text(
                widget.walletBalance != null
                    ? "₹ ${widget.walletBalance}"
                    : "₹ ${widget.amount}", // Show deposited amount as fallback
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Transaction Details Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _detailRow("Amount", "₹${widget.amount}"),
                      const SizedBox(height: 8),
                      _detailRow("UTR Number", widget.utrNumber),
                      const SizedBox(height: 8),
                      _detailRow("Transaction ID", widget.transactionId),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DepositMoneyFormScreen(),
                        ),
                        (route) => false, // removes all previous screens
                      );
                    },
                    child: const Text(
                      "GO TO HOME",
                      style: TextStyle(
                        color: Color(0xFF3CB371),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
