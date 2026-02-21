import 'package:flutter/material.dart';
import 'package:kittycash/portfolio/sell_coins.dart';
import 'package:kittycash/portfolio/wallet_screen.dart';
import 'package:kittycash/portfolio/wallet_model.dart';
import 'package:kittycash/services/portfolio_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late Future<PortfolioModel> portfolioFuture;

  @override
  void initState() {
    super.initState();
    portfolioFuture = PortfolioService().fetchPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: FutureBuilder<PortfolioModel>(
              future: portfolioFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final data = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _portfolioCard(data),

                      const SizedBox(height: 16),

                      /// ✅ MY WALLET BUTTON (BACK)
                      _myWalletButton(context),

                      const SizedBox(height: 24),

                      _myHoldingsHeader(),
                      const SizedBox(height: 12),

                      if (data.holdings.isEmpty)
                        const Center(
                          child: Text(
                            "No holdings found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...data.holdings.map(_holdingCard).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _topBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16, // status bar + spacing
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E7BFF), Color(0xFF4A9BFF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Row(
        children: [
          // Icon(Icons.arrow_back, color: Colors.white),
          SizedBox(width: 12),
          Text(
            "Portfolio",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PORTFOLIO CARD =================
  Widget _portfolioCard(PortfolioModel data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Portfolio Value",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),

          /// coin_holdings_value
          Row(
            children: [
              Text(
                "₹${data.coinHoldingsValue.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${data.profitLossPercent >= 0 ? '+' : ''}"
                "${data.profitLossPercent.toStringAsFixed(4)}%",
                style: TextStyle(
                  color: data.profitLossPercent >= 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountColumn(
                "Invested Amount",
                "₹${data.totalInvested.toStringAsFixed(2)}",
              ),
              _amountColumn(
                "Wallet Amount",
                "₹${data.totalBalance.toStringAsFixed(2)}",
              ),
            ],
          ),

          const SizedBox(height: 12),

          _amountColumn(
            "Profit / Loss",
            "₹${data.profitLoss.toStringAsFixed(2)}",
          ),
        ],
      ),
    );
  }

  // ================= MY WALLET BUTTON =================
  Widget _myWalletButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF3D6BFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletScreen()),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "My Wallet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HOLDINGS HEADER =================
  Widget _myHoldingsHeader() {
    return const Text(
      "My Holdings",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  // ================= HOLDING CARD =================
  Widget _holdingCard(HoldingModel h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// MAIN CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                /// LEFT - IMAGE + NAME
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(h.coin.image),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          h.coin.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qty: ${h.balance.toStringAsFixed(4)}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                /// RIGHT - VALUE & PNL
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${h.currentValue.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${h.pnl >= 0 ? '+' : ''}${h.pnl.toStringAsFixed(4)}",
                      style: TextStyle(
                        color: h.pnl >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔥 CENTER FLOATING SELL BUTTON
          /// 🔥 CENTER RIGHT SHIFTED SELL BUTTON
          Align(
            alignment: const Alignment(
              0.23,
              0,
            ), // 👈 increase value for more right
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellCoinScreen(coinId: h.coin.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Sell",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= AMOUNT COLUMN =================
class _amountColumn extends StatelessWidget {
  final String title;
  final String value;

  const _amountColumn(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
