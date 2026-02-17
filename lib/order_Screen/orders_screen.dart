import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> orders = [
    {"status": "Pending", "isBuy": false},
    {"status": "Failed", "isBuy": false},
    {"status": "Successfully Completed", "isBuy": true},
    {"status": "Failed", "isBuy": false},
  ];

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedTab == 1) {
      return orders.where((e) => e["status"] == "Pending").toList();
    } else if (selectedTab == 2) {
      return orders.where((e) => e["status"] != "Pending").toList();
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          /// 🔵 TOP BLUE AREA
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2F6BFF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Orders",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.notifications_none, color: Colors.white),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(
                          "assets/images/profile.png",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// TABS
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _tabButton("All", 0),
                      _tabButton("Open", 1),
                      _tabButton("Closed", 2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🧾 ORDER LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => OrderDetailsBottomSheet(
                        status: order["status"] as String,
                        isBuy: order["isBuy"] as bool,
                      ),
                    );
                  },
                  child: OrderCard(
                    status: order["status"] as String,
                    isBuy: order["isBuy"] as bool,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2F6BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= ORDER CARD =================

class OrderCard extends StatelessWidget {
  final String status;
  final bool isBuy;

  const OrderCard({super.key, required this.status, required this.isBuy});

  Color get statusColor {
    if (status == "Pending") return Colors.blue;
    if (status == "Successfully Completed") return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange.shade50,
            backgroundImage: const AssetImage("assets/images/kitty.png"),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "KTCH / KittyCash",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Text("Qty: 5", style: TextStyle(color: Colors.grey)),
                Text("Price: ₹24.39", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Total: ₹133.316",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                isBuy ? "BUY" : "SELL",
                style: TextStyle(
                  color: isBuy ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 110,
                child: Text(
                  status,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ================= BOTTOM SHEET =================

class OrderDetailsBottomSheet extends StatelessWidget {
  final String status;
  final bool isBuy;

  const OrderDetailsBottomSheet({
    super.key,
    required this.status,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text(
                  "KTCH",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.orange.shade50,
                backgroundImage: const AssetImage("assets/images/cat.png"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Expanded(
                child: Text(
                  "Order ID: 0253366548096",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Text(
                "Status : $status",
                style: TextStyle(
                  fontSize: 12,
                  color: status == "Pending"
                      ? Colors.blue
                      : status == "Successfully Completed"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order Type : ${isBuy ? "BUY" : "SELL"}",
              style: const TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),
          _priceRow("Quantity", "10"),
          _priceRow("Price", "₹24.39"),
          _priceRow("Sub Total", "₹243.90"),
          _priceRow("Service Charge", "₹4.87"),
          _priceRow("GST", "₹0.87"),
          const Divider(),
          _priceRow("Grand Total", "₹249.64", bold: true),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    "CANCEL ORDER",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("EDIT ORDER"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
