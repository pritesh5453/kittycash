import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestWithdrawalScreen extends StatefulWidget {
  final double utilizedBalance;

  const RequestWithdrawalScreen({super.key, required this.utilizedBalance});

  @override
  State<RequestWithdrawalScreen> createState() =>
      _RequestWithdrawalScreenState();
}

class _RequestWithdrawalScreenState extends State<RequestWithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedWithdrawalType;
  final List<Map<String, String>> _withdrawalTypes = [
    {'display': 'Instant Withdrawal (24h, dynamic charge)', 'value': 'instant'},
    {'display': 'Manual Withdrawal (2-3 days, no charge)', 'value': 'manual'},
  ];

  double minWithdrawal = 100;
  double _instantChargePercent = 0.0;
  bool _isLoadingCharge = true;
  String? _chargeErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInstantCharge();
  }

  Future<void> _fetchInstantCharge() async {
    setState(() {
      _isLoadingCharge = true;
      _chargeErrorMessage = null;
    });
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
          'https://kittycash.co.in/api/instant-withdrawal-service-charge',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          setState(() {
            _instantChargePercent = (json['data']['percentage'] as num)
                .toDouble();
            _isLoadingCharge = false;
          });
        } else {
          throw Exception(json['message'] ?? 'Failed to load charge');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingCharge = false;
        _chargeErrorMessage = 'Could not load service charge: $e';
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  double get requestedAmount {
    final text = _amountController.text;
    if (text.isEmpty) return 0;
    try {
      return double.parse(text);
    } catch (_) {
      return 0;
    }
  }

  double get serviceChargePercent {
    if (_selectedWithdrawalType == null) return 0;
    final typeValue = _withdrawalTypes.firstWhere(
      (e) => e['display'] == _selectedWithdrawalType,
    )['value'];
    return typeValue == 'instant' ? _instantChargePercent : 0.0;
  }

  double get serviceCharge => requestedAmount * serviceChargePercent / 100;
  double get receiveAmount => requestedAmount - serviceCharge;

  bool get isValidAmount {
    if (requestedAmount < minWithdrawal) return false;
    if (requestedAmount > widget.utilizedBalance) return false;
    return true;
  }

  Future<void> _submitWithdrawal() async {
    if (!isValidAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Amount must be between ₹$minWithdrawal and ₹${widget.utilizedBalance.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedWithdrawalType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a withdrawal type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {}); // show loading indicator (optional)

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final typeValue = _withdrawalTypes.firstWhere(
        (e) => e['display'] == _selectedWithdrawalType,
      )['value']!;

      final response = await http.post(
        Uri.parse('https://kittycash.co.in/api/payments/withdrawals'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': requestedAmount, // original amount, not after deduction
          'withdrawal_type': typeValue,
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201 && json['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message'] ?? 'Withdrawal request submitted'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally pop back to previous screen after a delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // go back to WithdrawScreen
        });
      } else {
        throw Exception(json['message'] ?? 'Withdrawal failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Withdrawal',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card (using dynamic utilizedBalance)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${widget.utilizedBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Utilized Balance (Profits from coin sales)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Withdrawal Amount
            const Text(
              'Withdrawal Amount (₹)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefix: const Text('₹ '),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 4),
            Text(
              'Minimum: ₹$minWithdrawal, Maximum: ₹${widget.utilizedBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Withdrawal Type Dropdown
            const Text(
              'Withdrawal Type *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedWithdrawalType,
                hint: const Text('-- Select Withdrawal Type --'),
                items: _withdrawalTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['display'],
                    child: Text(type['display']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWithdrawalType = value;
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedWithdrawalType != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _selectedWithdrawalType == _withdrawalTypes[0]['display']
                      ? 'Instant: Transfer within 24 hours (${_instantChargePercent.toStringAsFixed(1)}% service charge will be deducted)'
                      : 'Manual: Regular processing within 2-3 business days (no charge)',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Loading indicator for charge
            if (_isLoadingCharge)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_chargeErrorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _chargeErrorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // Calculation Card (only if amount > 0 and type selected)
            if (requestedAmount > 0 && _selectedWithdrawalType != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCalculationRow(
                      'Requested Amount:',
                      '₹${requestedAmount.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 16),
                    _buildCalculationRow(
                      'Service Charge (${serviceChargePercent.toStringAsFixed(1)}%):',
                      '₹${serviceCharge.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 16),
                    _buildCalculationRow(
                      'You Will Receive:',
                      '₹${receiveAmount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Orange info box for Instant Withdrawal (like screenshot)
            if (_selectedWithdrawalType == _withdrawalTypes[0]['display'] &&
                requestedAmount > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Instant Withdrawal Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Service Charge: ${_instantChargePercent.toStringAsFixed(1)}% (₹${serviceCharge.toStringAsFixed(2)}) will be deducted.\n'
                      '• You will receive: ₹${receiveAmount.toStringAsFixed(2)}\n'
                      '• Funds will be credited within 24 hours after admin approval.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // KYC & Verification Requirements (unchanged)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildSection(
                title: 'KYC & Verification Requirements',
                items: const [
                  'Aadhaar Verification',
                  'PAN Card Verification',
                  'Bank Account Verification',
                ],
                icon: Icons.verified_user,
              ),
            ),
            const SizedBox(height: 16),

            // Combined Withdrawal Rules & Processing Information Card (unchanged)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Withdrawal Rules & Processing Info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Withdrawal Rules',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._buildBulletList(const [
                              'Only Utilized Balance (profits from coin sales) can be withdrawn',
                              'One active withdrawal request allowed at a time',
                              'Minimum withdrawal: ₹100',
                              'All KYC verifications must be completed',
                              'Withdrawals are only available after full KYC verification',
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Processing Information',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._buildBulletList(const [
                              'Instant Withdrawal: Processed within 24 hours (dynamic service charge applies)',
                              'Manual Withdrawal: Processed within 2–3 business days (no charge)',
                              'Funds will be transferred to your registered bank account',
                              'Admin approval is required for all withdrawals',
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'SUBMIT WITHDRAWAL REQUEST',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBulletList(List<String> items) {
    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.blue : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
