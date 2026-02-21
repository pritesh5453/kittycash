import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kittycash/Refferal_screen/ReferralScreen.dart';
import 'package:kittycash/order_Screen/orders_screen.dart';
import 'package:kittycash/portfolio/WithdrawScreen.dart';
import 'package:kittycash/portfolio/deposit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  // Function to fetch overview data
  Future<Map<String, dynamic>> _fetchOverview() async {
    final token = await getToken();
    print('🔐 TOKEN = $token');

    final response = await http.get(
      Uri.parse('https://kittycash.co.in/api/dashboard/overview'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('📡 STATUS = ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return json['data'];
      } else {
        throw Exception(json['message'] ?? 'API returned success=false');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized – check your token');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Placeholder for token retrieval - replace with actual implementation
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _topBar(context),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchOverview(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }

                final data = snapshot.data!;
                final user = data['user'] as Map<String, dynamic>;
                final balances = user['balances'] as Map<String, dynamic>;
                final portfolio = data['portfolio'] as Map<String, dynamic>;
                final recentTransactions = data['recent_transactions'] as List;
                final referralStats =
                    data['referral_stats'] as Map<String, dynamic>;

                // Format numbers
                final utilized = double.parse(
                  balances['utilized_balance'].toString(),
                ).toStringAsFixed(2);
                final unutilized = double.parse(
                  balances['unutilized_balance'].toString(),
                ).toStringAsFixed(2);
                final totalInr = double.parse(
                  balances['inr_balance'].toString(),
                ).toStringAsFixed(2);
                final totalPortfolioValue = double.parse(
                  portfolio['coin_holdings_value'].toString(),
                ).toStringAsFixed(2);
                final totalInvested = double.parse(
                  portfolio['total_invested'].toString(),
                ).toStringAsFixed(2);
                final profitLoss = double.parse(
                  portfolio['total_profit_loss'].toString(),
                );
                final profitLossStr = profitLoss.toStringAsFixed(2);
                final profitLossColor = profitLoss >= 0
                    ? Colors.green
                    : Colors.red;
                final profitLossSign = profitLoss >= 0 ? '+' : '';

                final utilizedRaw = balances['utilized_balance'] is double
                    ? balances['utilized_balance']
                    : double.parse(balances['utilized_balance'].toString());
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _balanceCard(
                        context,
                        utilized: utilized,
                        unutilized: unutilized,
                        totalInr: totalInr,
                        totalPortfolioValue: totalPortfolioValue,
                        totalInvested: totalInvested,
                        profitLoss: profitLossStr,
                        profitLossColor: profitLossColor,
                        profitLossSign: profitLossSign,
                      ),
                      const SizedBox(height: 20),
                      _quickActions(context, utilizedRaw),
                      const SizedBox(height: 24),
                      _recentTransactions(context, recentTransactions),
                      const SizedBox(height: 20),
                      _referTile(context),
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

  // 🔹 TOP BAR (unchanged)
  Widget _topBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E7BFF), Color(0xFF4A9BFF)],
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
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

  // 🔹 BALANCE CARD (now accepts data)
  Widget _balanceCard(
    BuildContext context, {
    required String utilized,
    required String unutilized,
    required String totalInr,
    required String totalPortfolioValue,
    required String totalInvested,
    required String profitLoss,
    required Color profitLossColor,
    required String profitLossSign,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _balanceItem(value: "₹ $utilized", label: "Utilized Balance"),
                const SizedBox(width: 50),
                _balanceItem(
                  value: "₹ $unutilized",
                  label: "Unutilized Balance",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: _balanceItem(
              value: "₹ $totalInr",
              label: "Total INR Balance",
            ),
          ),
          const SizedBox(height: 20),
          // Important note (static)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Text(
              "Only utilized balance (profits from coin sales) can be withdrawn. Unutilized balance must be used for trading first.",
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          // Three portfolio metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricItem(
                value: "₹ $totalPortfolioValue",
                label: "Total Portfolio Value",
              ),
              _metricItem(value: "₹ $totalInvested", label: "Total Invested"),
              _metricItem(
                value: "$profitLossSign ₹ $profitLoss",
                label: "Profit/Loss",
                valueColor: profitLossColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for balance items
  Widget _balanceItem({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Helper for metric items
  Widget _metricItem({
    required String value,
    required String label,
    Color valueColor = Colors.black,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // 🔹 QUICK ACTIONS (unchanged)
  Widget _quickActions(BuildContext context, double utilizedBalance) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DepositScreen()),
              );
            },
            child: _actionButton(
              "Deposit",
              const Color(0xFFFF9F2D),
              Icons.open_in_new,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WithdrawScreen(utilizedBalance: utilizedBalance),
                ),
              );
            },
            child: _actionButton(
              "Withdraw",
              const Color(0xFF3D6BFF),
              Icons.arrow_outward,
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 RECENT TRANSACTIONS (now uses API data)
  Widget _recentTransactions(BuildContext context, List transactions) {
    // Take only first 4 transactions
    final recent = transactions.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full transactions screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
              child: const Text(
                "Transaction Page >>",
                style: TextStyle(fontSize: 12, color: Color(0xFF1E7BFF)),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: recent.map((tx) {
              final type = tx['type'] as String;
              final coinName = tx['coin'] != null ? tx['coin']['name'] : 'N/A';
              final amountInr = double.parse(
                tx['amount_inr'].toString(),
              ).toStringAsFixed(2);
              final date = DateTime.parse(tx['created_at']);
              final formattedDate = _formatDate(date);
              IconData icon;
              Color color;
              String title;

              if (type == 'deposit') {
                icon = Icons.arrow_downward;
                color = Colors.green;
                title = 'Deposit';
              } else if (type == 'withdraw') {
                icon = Icons.arrow_upward;
                color = Colors.red;
                title = 'Withdraw';
              } else if (type == 'buy') {
                icon = Icons.shopping_cart;
                color = Colors.blue;
                title = 'Buy $coinName';
              } else if (type == 'sell') {
                icon = Icons.attach_money;
                color = Colors.orange;
                title = 'Sell $coinName';
              } else {
                icon = Icons.swap_horiz;
                color = Colors.grey;
                title = type;
              }

              return _transactionItem(
                title,
                '₹ $amountInr',
                formattedDate,
                icon,
                color,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Helper to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hr ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _transactionItem(
    String title,
    String amount,
    String date,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  // 🔹 REFER & EARN TILE (now navigates to ReferralScreen)
  Widget _referTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReferralScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Refer & Earn",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Invite friends and earn Virajpa coins",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E7BFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.share,
                color: Color(0xFF1E7BFF),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 🔹 ACTION BUTTON (unchanged)
  static Widget _actionButton(String text, Color color, IconData icon) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}
