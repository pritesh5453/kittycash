import 'package:flutter/material.dart';
import 'package:kittycash/portfolio/RequestWithdrawScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WithdrawScreen extends StatefulWidget {
  final double utilizedBalance; // 👈 new field

  const WithdrawScreen({super.key, required this.utilizedBalance});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  bool _isLoading = false;
  bool _kycCompleted = false;
  String? _kycMessage;

  @override
  void initState() {
    super.initState();
    _checkKycStatus();
  }

  Future<void> _checkKycStatus() async {
    setState(() {
      _isLoading = true;
      _kycMessage = null;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
          _kycMessage = 'Not authenticated. Please log in again.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://kittycash.co.in/api/kyc/details'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final data = json['data'];
          final aadhaarVerified = data['aadhaar_verified'] ?? '';
          final panVerified = data['pan_verified'] ?? '';
          final bankVerified = data['bank_verified'] ?? '';

          final completed =
              aadhaarVerified == 'verified' &&
              panVerified == 'verified' &&
              bankVerified == 'verified';

          setState(() {
            _kycCompleted = completed;
            _isLoading = false;
            if (!completed) {
              _kycMessage =
                  'KYC not completed. Please complete all verifications.';
            }
          });
        } else {
          setState(() {
            _isLoading = false;
            _kycMessage = json['message'] ?? 'Failed to load KYC details';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _kycMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _kycMessage = 'Network error: $e';
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _handleWithdrawPress() {
    if (_isLoading) return;
    if (_kycCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestWithdrawalScreen(
            utilizedBalance: widget.utilizedBalance, // 👈 pass it forward
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_kycMessage ?? 'KYC not completed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88FF),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Withdraw"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    title: "KYC Verification Requirements",
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        "KYC Verification Required :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _tick("Aadhar Verification"),
                      _tick("PAN card Verification"),
                      _tick("Bank Account Verification"),
                      const SizedBox(height: 12),
                      const Text(
                        "Withdrawal Rules :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _tick(
                        "Only Utilized Balance (Profits from coin sales can be withdrawn)",
                      ),
                      _tick("One active Withdrawal request allowed at a time"),
                      _tick("Minimum withdrawal : ₹ 100"),
                      _tick("All KYC verifications must be completed"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _card(
                    title: "Processing Information",
                    children: [
                      _dot(
                        "Withdrawal requests are processed within 1-3 business days",
                      ),
                      _dot("Funds will be transferred to your bank account"),
                      _dot("Admin approval is required for all withdrawals"),
                      _dot("Processing fees may apply based on your plan"),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _handleWithdrawPress,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Withdraw",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.logout,
                        size: 12,
                        color: Colors.white,
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

  // ---------- Widgets ----------
  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _tick(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _dot(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
