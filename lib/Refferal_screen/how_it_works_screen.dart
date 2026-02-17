import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "How it works?",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _singleReferral(),
            const SizedBox(height: 24),
            _bulletText("You referred to Deepak"),
            _bulletText(
              "When Deepak invests some amount, You will get 40% amount of Service charge paid by Deepak",
            ),
            const SizedBox(height: 40),
            _multiReferral(),
            const SizedBox(height: 24),
            _bulletText("Deepak refers to Vijay"),
            _bulletText(
              "When Vijay invests some amount, Deepak will get 40% and You will get 20% amount of Service charge paid by Vijay",
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 First Diagram (You → Deepak 40%)
  Widget _singleReferral() {
    return Column(
      children: [
        const _PercentBadge("40%"),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _UserAvatar(name: "You"),
            Icon(Icons.arrow_forward, color: Colors.teal),
            _UserAvatar(name: "Deepak"),
          ],
        ),
      ],
    );
  }

  // 🔹 Second Diagram (You → Deepak → Vijay)
  Widget _multiReferral() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [_PercentBadge("20%"), _PercentBadge("40%")],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _UserAvatar(name: "You"),
            Icon(Icons.arrow_forward, color: Colors.teal),
            _UserAvatar(name: "Deepak"),
            Icon(Icons.arrow_forward, color: Colors.teal),
            _UserAvatar(name: "Vijay"),
          ],
        ),
      ],
    );
  }

  // 🔹 Bullet text
  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18, height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 User Avatar Widget
class _UserAvatar extends StatelessWidget {
  final String name;
  const _UserAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.teal.shade100,
          child: const Icon(Icons.person, size: 32, color: Colors.teal),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// 🔹 Percentage Badge
class _PercentBadge extends StatelessWidget {
  final String text;
  const _PercentBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.teal,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
