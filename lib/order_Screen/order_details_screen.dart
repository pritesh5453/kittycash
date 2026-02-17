import 'package:flutter/material.dart';

class OrderDetailsBottomSheet extends StatelessWidget {
  const OrderDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// DRAG HANDLE
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 16),

          /// HEADER
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
                backgroundImage: const AssetImage("assets/images/kitty.png"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ORDER INFO
          Row(
            children: const [
              Expanded(
                child: Text(
                  "Order ID: 0253366548096",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Text(
                "Status : Pending",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Order Type : SELL", style: TextStyle(fontSize: 12)),
          ),

          const SizedBox(height: 16),

          /// PRICE DETAILS
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Price Details",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _priceRow("Quantity", "10"),
          _priceRow("Price", "₹ 24.39"),
          _priceRow("Sub Total", "₹ 243.9"),
          _priceRow("Service Charge", "₹ 4.87"),
          _priceRow("GST", "₹ 0.87"),

          const Divider(height: 22),

          _priceRow("Grand Total", "₹ 249.64", isBold: true),

          const SizedBox(height: 20),

          /// ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "CANCEL ORDER",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("EDIT ORDER"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// PRICE ROW WIDGET
  static Widget _priceRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
