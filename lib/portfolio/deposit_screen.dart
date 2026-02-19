import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittycash/portfolio/deposit_money_form_screen.dart';
import 'package:kittycash/services/auth_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final AuthService _authService = AuthService();

  // Static data as fallback
  final Map<String, String> _staticBankDetails = {
    'account_holder_name': 'kittycash',
    'bank_name': 'state bank of india',
    'account_number': '41136293247',
    'ifsc_code': 'SBIN0061400',
  };

  Map<String, dynamic>? _bankDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBankDetails();
  }

  Future<void> _fetchBankDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.getActiveBankDetails();

    setState(() {
      _isLoading = false;
      if (result['status'] == true) {
        _bankDetails = result['data'];
      } else {
        _errorMessage = result['message'];
        // Use static data as fallback
        _bankDetails = _staticBankDetails;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF194EEE),
        elevation: 0,
        title: const Text(
          "Deposit",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _bankDetailsCard(),
                  const SizedBox(height: 16),
                  _instructionsCard(),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _depositButton(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _bankDetailsCard() {
    if (_bankDetails == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: Color(0xFFFF9F2D)),
              SizedBox(width: 8),
              Text(
                "KittyCash Bank Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(
            "Account Holder",
            _bankDetails!['account_holder_name']?.toString().toUpperCase() ??
                _staticBankDetails['account_holder_name']!.toUpperCase(),
          ),
          _detailRow(
            "Bank Name",
            _bankDetails!['bank_name']?.toString().toUpperCase() ??
                _staticBankDetails['bank_name']!.toUpperCase(),
          ),
          _copyRow(
            "Account Number",
            _bankDetails!['account_number']?.toString() ??
                _staticBankDetails['account_number']!,
          ),
          _copyRow(
            "IFSC Code",
            _bankDetails!['ifsc_code']?.toString().toUpperCase() ??
                _staticBankDetails['ifsc_code']!,
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Note: Using default data. $_errorMessage",
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _instructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.list_alt, color: Color(0xFFFF9F2D)),
              SizedBox(width: 8),
              Text(
                "Deposit Instructions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          _InstructionItem(
            "Choose your deposit amount from the options below.",
          ),
          _InstructionItem(
            "Transfer the exact amount to the bank account details shown above.",
          ),
          _InstructionItem(
            "After payment, enter the UTR/Reference number & proof in the next step.",
          ),
          _InstructionItem(
            "Your deposit will be verified manually by our team within 24 hrs.",
          ),
          _InstructionItem(
            "Once approved, the amount will be credited to your wallet.",
          ),
        ],
      ),
    );
  }

  Widget _depositButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DepositMoneyFormScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9F2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Deposit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.open_in_new, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title :", style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _copyRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title :", style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Copied to clipboard"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Copy",
                    style: TextStyle(fontSize: 12, color: Colors.blue),
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

class _InstructionItem extends StatelessWidget {
  final String text;
  const _InstructionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
