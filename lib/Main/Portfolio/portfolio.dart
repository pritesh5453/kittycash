import 'package:flutter/material.dart';
import 'package:kittycash/Main/Portfolio/Buy/buyCoins.dart';
import 'package:kittycash/Main/Portfolio/sell/sellCoins.dart';
import 'package:kittycash/util/commonappbar.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      /// ✅ FIXED APPBAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonAppHeader(title: "Portfolio"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            _topButtons(),
            const SizedBox(height: 16),

            /// CARD 1
            _kittyCashCard(context),
            const SizedBox(height: 16),

            /// CARD 2
            _holdingsCard(context),
            const SizedBox(height: 16),

            /// CARD 3
            _historyCard(),
          ],
        ),
      ),
    );
  }

  // ---------------- TOP BUTTONS ----------------
  Widget _topButtons() {
    return Row(
      children: [
        Expanded(child: _actionBtn("Deposit", Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _actionBtn("Withdraw", Colors.blue)),
      ],
    );
  }

  Widget _actionBtn(String text, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      child: Text(text),
    );
  }

  // ---------------- COMMON CARD ----------------
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2F80ED), width: 1.2),
      ),
      child: child,
    );
  }

  // ---------------- CARD 1 : KITTY CASH ----------------
  Widget _kittyCashCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.currency_exchange, "KittyCash (KTCH)"),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: const [
                Text(
                  "₹ 0.12",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text("Current Price (₹)", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _row("Service Fee", "2.00%"),
          _row("GST", "18.00%"),
          const SizedBox(height: 12),

          _primaryBtn(
            context,
            "Buy Coins",
            bgColor: Colors.blue,
            textColor: Colors.white,
            navigateTo: const BuyKittyCashScreen(),
          ),
        ],
      ),
    );
  }

  // ---------------- CARD 2 : HOLDINGS ----------------
  Widget _holdingsCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.account_balance_wallet, "Your Coin Holdings"),
          const SizedBox(height: 10),

          _tableHeader(["Coin", "Qty", "Invested", "Price", "Value"]),
          const SizedBox(height: 6),

          _tableRow(["KTCH", "951.4097", "₹113.26", "₹0.12", "₹113.26"]),
          const SizedBox(height: 6),
          _tableRow(["KTCH", "951.4097", "₹113.26", "₹0.12", "₹113.26"]),

          const SizedBox(height: 12),
          _primaryBtn(
            context,
            "Sell Coins",
            bgColor: Colors.blue,
            textColor: Colors.white,
            navigateTo: const SellCoinsScreen(),
          ),
        ],
      ),
    );
  }

  // ---------------- CARD 3 : HISTORY ----------------
  Widget _historyCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.history, "Purchase History"),
          const SizedBox(height: 10),

          _tableHeader(["Date", "Coin", "Qty", "Amount", "Price", "Status"]),
          const SizedBox(height: 6),

          _historyRow([
            "12 Jan",
            "KTCH",
            "100000",
            "₹114450",
            "₹0.12",
            "Completed",
          ]),
          _historyRow([
            "13 Jan",
            "KTCH",
            "50000",
            "₹56420",
            "₹0.12",
            "Completed",
          ]),
        ],
      ),
    );
  }

  // ---------------- SMALL WIDGETS ----------------
  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.grey)),
          Text(right, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _primaryBtn(
    BuildContext context,
    String text, {
    required Widget navigateTo,
    Color bgColor = Colors.blue,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => navigateTo),
          );
        },
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _tableHeader(List<String> titles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: titles
          .map(
            (e) => Text(
              e,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _tableRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((e) => Text(e)).toList(),
    );
  }

  Widget _historyRow(List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: values.map((e) {
          if (e == "Completed") {
            return Text(e, style: const TextStyle(color: Colors.green));
          }
          return Text(e);
        }).toList(),
      ),
    );
  }
}

//
// ---------------- DUMMY SCREENS (to avoid errors)
//
