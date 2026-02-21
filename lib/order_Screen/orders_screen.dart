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

  List allTransactions = [];
  List filteredTransactions = [];
  bool isLoading = true;
  String? token;
  final TextEditingController searchController = TextEditingController();

  final String baseUrl =
      "https://kittycash.co.in/api/dashboard/transactions?page=1";

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
    searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterTransactions);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadTokenAndFetch() async {
    token = await storage.read(key: "auth_token");
    if (token != null && token!.isNotEmpty) {
      await fetchTransactions();
    } else {
      setState(() => isLoading = false);
    }
  }

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
          allTransactions = response.data["data"]["transactions"] ?? [];
          filteredTransactions = allTransactions;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } on DioException catch (e) {
      setState(() => isLoading = false);
      if (e.response?.statusCode == 401) {
        await storage.delete(key: "auth_token");
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterTransactions() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => filteredTransactions = allTransactions);
    } else {
      setState(() {
        filteredTransactions = allTransactions.where((tx) {
          final type = (tx['type'] ?? '').toString().toLowerCase();
          final coinName = tx['coin'] != null
              ? (tx['coin']['name'] ?? '').toString().toLowerCase()
              : '';
          final amount = tx['amount_inr']?.toString() ?? '';
          return type.contains(query) ||
              coinName.contains(query) ||
              amount.contains(query);
        }).toList();
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) {
        return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day} ${_getMonth(date.month)}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Colors.blue;
      case 'sell':
        return Colors.green;
      case 'deposit':
        return Colors.purple;
      case 'withdraw':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Icons.shopping_cart;
      case 'sell':
        return Icons.attach_money;
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdraw':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getCoinName(Map<String, dynamic>? coin) {
    if (coin == null) return '';
    return coin['name'] ?? coin['symbol'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          /// 🔵 HEADER
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2F6BFF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transaction History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search by type, coin, amount...",
                      border: InputBorder.none,
                    ),
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
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        final type = (tx['type'] ?? '').toString();
                        final coin = tx['coin'] as Map<String, dynamic>?;
                        final coinName = _getCoinName(coin);
                        final amount = (tx['actual_amount'] ?? 0).toDouble();
                        final date = _formatDate(tx['created_at'] ?? '');
                        final status = tx['status'] ?? 'completed';
                        final isCredit =
                            type.toLowerCase() == 'sell' ||
                            type.toLowerCase() == 'deposit';
                        final sign = isCredit ? '+' : '-';
                        final color = _getTypeColor(type);

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                /// Icon with background
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getTypeIcon(type),
                                    color: color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                /// Middle column: type, coin, date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            type.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                          if (coinName.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '• $coinName',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Right column: amount and status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$sign₹${amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isCredit
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == 'completed'
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: status == 'completed'
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
