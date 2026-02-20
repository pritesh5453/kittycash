import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'portfolio_screen.dart'; // adjust import as needed

class SellCoinScreen extends StatefulWidget {
  final int coinId;

  const SellCoinScreen({super.key, required this.coinId});

  @override
  State<SellCoinScreen> createState() => _SellCoinScreenState();
}

class _SellCoinScreenState extends State<SellCoinScreen> {
  // Controllers
  final TextEditingController _coinAmountController = TextEditingController();
  final TextEditingController _inrAmountController = TextEditingController();

  // Data from API
  Map<String, dynamic>? _coinData;
  Map<String, dynamic>? _holdingsData;
  bool _isLoading = true;
  String? _errorMessage;

  // Sell loading
  bool _isSelling = false;

  // Flag to prevent recursive updates
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _fetchHoldingData();
    _coinAmountController.addListener(_onCoinAmountChanged);
    _inrAmountController.addListener(_onInrAmountChanged);
  }

  @override
  void dispose() {
    _coinAmountController.removeListener(_onCoinAmountChanged);
    _inrAmountController.removeListener(_onInrAmountChanged);
    _coinAmountController.dispose();
    _inrAmountController.dispose();
    super.dispose();
  }

  Future<void> _fetchHoldingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('https://kittycash.co.in/api/trading/coin-holding'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'coin_id': widget.coinId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          setState(() {
            _coinData = json['data']['coin'];
            _holdingsData = json['data']['holdings'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = json['message'] ?? 'Failed to load data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // adjust key as needed
  }

  void _onCoinAmountChanged() {
    if (_updating) return;
    _updating = true;
    final coinAmount = double.tryParse(_coinAmountController.text) ?? 0.0;
    final price = _coinData?['price'] ?? 0.0;
    final inrAmount = coinAmount * price;
    _inrAmountController.text = inrAmount.toStringAsFixed(2);
    _updating = false;
  }

  void _onInrAmountChanged() {
    if (_updating) return;
    _updating = true;
    final inrAmount = double.tryParse(_inrAmountController.text) ?? 0.0;
    final price = _coinData?['price'] ?? 0.0;
    if (price > 0) {
      final coinAmount = inrAmount / price;
      _coinAmountController.text = coinAmount.toStringAsFixed(4);
    }
    _updating = false;
  }

  bool get _exceedsBalance {
    final coinAmount = double.tryParse(_coinAmountController.text) ?? 0.0;
    final balance = _holdingsData?['balance'] ?? 0.0;
    return coinAmount > balance;
  }

  Future<void> _sell() async {
    // Validation is done here, not by disabling the button
    if (_exceedsBalance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    final coinAmount = double.tryParse(_coinAmountController.text) ?? 0.0;
    if (coinAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _isSelling = true);

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('https://kittycash.co.in/api/trading/sell'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'coin_id': widget.coinId, 'coin_amount': coinAmount}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Navigate to PortfolioScreen on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PortfolioScreen(),
            ), // adjust
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json['message'] ?? 'Sell failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _isSelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF2F7),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF2F7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              ElevatedButton(
                onPressed: _fetchHoldingData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final coinName = _coinData?['name'] ?? 'Coin';
    final coinSymbol = _coinData?['symbol'] ?? '';
    final currentPrice = (_coinData?['price'] as num?)?.toDouble() ?? 0.0;
    final balance = (_holdingsData?['balance'] as num?)?.toDouble() ?? 0.0;
    final investedValue =
        (_holdingsData?['invested_value'] as num?)?.toDouble() ?? 0.0;
    final currentValue =
        (_holdingsData?['current_value'] as num?)?.toDouble() ?? 0.0;
    final pnl = (_holdingsData?['pnl'] as num?)?.toDouble() ?? 0.0;
    final pnlPercentage =
        (_holdingsData?['pnl_percentage'] as num?)?.toDouble() ?? 0.0;

    final inrAmount = double.tryParse(_inrAmountController.text) ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F7),
      body: Column(
        children: [
          /// 🔵 HEADER
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Sell $coinName",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white),
                    const SizedBox(width: 15),
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🟦 BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Coin title and "Ready to Sell"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          coinName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Ready to Sell",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Stats grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        _statCard(
                          "YOUR BALANCE",
                          "${balance.toStringAsFixed(4)} $coinSymbol",
                        ),
                        _statCard(
                          "INVESTED AMOUNT",
                          "₹ ${investedValue.toStringAsFixed(2)}",
                        ),
                        _statCard(
                          "CURRENT VALUE",
                          "₹ ${currentValue.toStringAsFixed(2)}",
                        ),
                        _statCard(
                          "PROFIT & LOSS",
                          "${pnl >= 0 ? '+' : ''}${pnl.toStringAsFixed(2)} (${pnlPercentage.toStringAsFixed(2)}%)",
                          textColor: pnl >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Sell Transaction Heading
                    const Text(
                      "Sell Transaction",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Coin to Sell (editable)
                    const Text(
                      "Coin to Sell",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _coinAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "0.0",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _exceedsBalance
                                  ? 'Exceeds balance'
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7ECF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            coinSymbol,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Amount (INR) - editable
                    const Text(
                      "Amount (INR)",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inrAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "0.0",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Available balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Available",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "${balance.toStringAsFixed(4)} $coinSymbol",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Transaction Details
                    const Row(
                      children: [
                        Icon(Icons.list, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Transaction Details",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "• Funds will be credited to your INR wallet",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "• Transaction may take 2-5 minutes to process",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "• All transactions are irreversible",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSelling ? null : _sell,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSelling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "SELL $coinName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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

  Widget _statCard(
    String label,
    String value, {
    Color textColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
