import 'package:flutter/material.dart';
import 'package:kittycash/util/commonappbar.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppHeader(title: "Dashboard"),
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _balanceBreakdown(),
                  const SizedBox(height: 16),
                  _portfolioCards(),
                  const SizedBox(height: 16),
                  _myHoldings(),
                  const SizedBox(height: 16),
                  _recentTransactions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 BALANCE BREAKDOWN
  Widget _balanceBreakdown() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance Breakdown",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _balanceItem("₹ 61.11", "Utilized Balance"),
              _balanceItem("₹ 4283.13", "Unutilized Balance"),
              _balanceItem("₹ 4549.59", "Total INR Balance"),
            ],
          ),
        ],
      ),
    );
  }

  /// 📊 PORTFOLIO STATS
  Widget _portfolioCards() {
    return Row(
      children: const [
        Expanded(
          child: _smallCard(
            icon: Icons.wallet,
            title: "₹ 61.11",
            subtitle: "Total Portfolio Value",
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _smallCard(
            icon: Icons.currency_bitcoin,
            title: "₹ 4283.13",
            subtitle: "Total Invested Amount",
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _smallCard(
            icon: Icons.pie_chart,
            title: "₹ 4549.59",
            subtitle: "Profit/Loss",
          ),
        ),
      ],
    );
  }

  /// 📦 MY HOLDINGS
  Widget _myHoldings() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("My Holdings"),
          const SizedBox(height: 12),
          _row("Asset", "KittyCash (KTCH)"),
          _row("Balance", "4713.9513"),
          _row("Invested Amt.", "₹ 591.82"),
          _row("Current Price", "₹ 0.12"),
          _row("Market Value", "₹ 559.13"),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(80, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Sell"),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧾 RECENT TRANSACTIONS
  Widget _recentTransactions() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Recent Transactions"),
          const SizedBox(height: 12),
          _transactionRow("Buy", "₹100.00", true),
          _transactionRow("Withdraw", "₹100.00", true),
          _transactionRow("Withdraw", "₹100.00", true),
        ],
      ),
    );
  }

  /// ⬇️ BOTTOM NAV

  /// 🔹 HELPERS
  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }

  static Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  static Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.black54)),
          Text(right, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _transactionRow(String type, String amount, bool success) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type),
          Text(amount),
          Text(
            success ? "COMPLETED" : "FAILED",
            style: TextStyle(
              color: success ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔸 SMALL CARD
class _smallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _smallCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// 🔹 BALANCE ITEM
class _balanceItem extends StatelessWidget {
  final String value;
  final String label;

  const _balanceItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
