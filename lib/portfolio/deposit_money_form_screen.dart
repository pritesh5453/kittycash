import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kittycash/portfolio/TransactionSuccessScreen.dart';
import 'package:intl/intl.dart';
import 'package:kittycash/services/auth_service.dart'; // Add this for date formatting
import 'package:kittycash/services/wallet_service.dart'; // Add this for wallet balance

class DepositMoneyFormScreen extends StatefulWidget {
  const DepositMoneyFormScreen({super.key});

  @override
  State<DepositMoneyFormScreen> createState() => _DepositMoneyFormScreenState();
}

class _DepositMoneyFormScreenState extends State<DepositMoneyFormScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _utrController = TextEditingController();

  // API Service
  final AuthService _authService = AuthService();
  final WalletDashboardService _walletService = WalletDashboardService();

  // State variables
  bool _isLoading = false;
  bool _isHistoryLoading = false;
  Map<String, dynamic> _depositHistory = {};
  List<dynamic> _deposits = [];
  Map<String, dynamic> _pagination = {};
  int _currentPage = 1;
  String? _selectedStatus;

  // Date formatter
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy\nHH:mm');

  @override
  void initState() {
    super.initState();
    _fetchDepositHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  // =================================================
  // 🔹 FETCH DEPOSIT HISTORY
  // =================================================
  Future<void> _fetchDepositHistory({int page = 1}) async {
    setState(() {
      _isHistoryLoading = true;
      _currentPage = page;
    });

    try {
      final result = await _authService.getDepositHistory(
        page: page,
        status: _selectedStatus,
      );

      // Debug: Print API response structure
      print("===== DEPOSIT HISTORY RESPONSE =====");
      print("Status: ${result['status']}");
      print("Data keys: ${result['data']?.keys.toList()}");
      print("Data: ${result['data']}");
      print("=====================================");

      if (result['status'] == true) {
        // Handle both possible API response structures
        // Laravel often wraps data in 'data' key with pagination
        final depositData = result['data'];
        List<dynamic> depositsList = [];
        Map<String, dynamic> paginationData = {};

        if (depositData != null) {
          // Check if deposits is directly in 'deposits' key
          if (depositData['deposits'] != null) {
            depositsList = depositData['deposits'] as List<dynamic>;
            paginationData = depositData['pagination'] ?? {};
          }
          // Check if it's Laravel paginated response (data key contains array)
          else if (depositData['data'] != null) {
            depositsList = depositData['data'] as List<dynamic>;
            // Extract pagination info from Laravel response
            paginationData = {
              'current_page': depositData['current_page'] ?? 1,
              'last_page': depositData['last_page'] ?? 1,
              'total': depositData['total'] ?? 0,
            };
          }
          // Fallback: check if data itself is a list
          else if (depositData is List) {
            depositsList = depositData;
          }
        }

        setState(() {
          _depositHistory = result;
          _deposits = depositsList;
          _pagination = paginationData;
        });
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      _showSnackBar('Error loading deposit history', isError: true);
    } finally {
      setState(() {
        _isHistoryLoading = false;
      });
    }
  }

  // =================================================
  // 🔹 SUBMIT DEPOSIT
  // =================================================
  Future<void> _submitDeposit() async {
    // Validation
    if (_amountController.text.isEmpty) {
      _showSnackBar('Please enter amount', isError: true);
      return;
    }

    if (_utrController.text.isEmpty) {
      _showSnackBar('Please enter UTR number', isError: true);
      return;
    }

    if (_selectedImage == null) {
      _showSnackBar('Please upload payment screenshot', isError: true);
      return;
    }

    // Amount validation
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 1 || amount > 50000) {
      _showSnackBar('Amount must be between ₹1 and ₹50,000', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.submitDeposit(
        amount: _amountController.text,
        utrNumber: _utrController.text,
        paymentScreenshot: File(_selectedImage!.path),
      );

      if (result['status'] == true) {
        _showSnackBar('Deposit request submitted successfully!');
        final amount = _amountController.text;
        final utr = _utrController.text;

        _amountController.clear();
        _utrController.clear();

        // Fetch wallet balance after successful deposit
        String? walletBalance;
        try {
          final walletResponse = await _walletService.fetchDashboardWallet();
          walletBalance = walletResponse.data.user.balances.inrBalance
              .toStringAsFixed(2);
          print("Wallet Balance fetched: ₹$walletBalance");
        } catch (e) {
          print("Error fetching wallet balance: $e");
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionSuccessScreen(
                amount: amount,
                utrNumber: utr,
                transactionId: result['data']?['id']?.toString() ?? 'N/A',
                walletBalance: walletBalance,
              ),
            ),
          );
        }
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      _showSnackBar('Error submitting deposit', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =================================================
  // 🔹 VIEW DEPOSIT DETAILS
  // =================================================
  Future<void> _viewDepositDetails(int depositId) async {
    try {
      final result = await _authService.getDepositDetails(depositId);

      if (result['status'] == true) {
        _showDepositDetailsDialog(result['data']);
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      _showSnackBar('Error loading deposit details', isError: true);
    }
  }

  // =================================================
  // 🔹 SHOW DEPOSIT DETAILS DIALOG
  // =================================================
  void _showDepositDetailsDialog(Map<String, dynamic>? deposit) {
    if (deposit == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deposit Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Amount:', '₹${deposit['amount'] ?? 'N/A'}'),
            _detailRow('UTR:', deposit['utr_number'] ?? 'N/A'),
            _detailRow('Status:', deposit['status'] ?? 'N/A'),
            _detailRow('Date:', _formatDate(deposit['created_at'])),
            if (deposit['remarks'] != null)
              _detailRow('Remarks:', deposit['remarks']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // =================================================
  // 🔹 HELPER METHODS
  // =================================================
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return _dateFormat.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'completed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'rejected':
      case 'failed':
        return 'red';
      default:
        return 'grey';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  // =================================================
  // 🔹 BUILD METHODS
  // =================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7BFF),
        elevation: 0,
        title: const Text(
          "Deposit",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("assets/images/profile.jpg"),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _depositFormCard(),
            const SizedBox(height: 16),
            _depositHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _depositFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_wallet, color: Color(0xFF1E7BFF)),
              SizedBox(width: 8),
              Text(
                "Deposit Money",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Add funds to your KittyCash wallet securely",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          const Text(
            "₹ Deposit Amount (₹) *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _inputField(
            "Enter amount in rupees",
            controller: _amountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 4),
          const Text(
            "Minimum: ₹1 , Maximum: ₹50,000",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          const Text(
            "# UTR / Reference Number *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _inputField("Enter UTR number", controller: _utrController),
          const SizedBox(height: 14),

          const Text(
            "# Payment Screenshot *",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1ECFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Choose File",
                    style: TextStyle(
                      color: Color(0xFF6A5AE0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedImage == null
                      ? "No File chosen"
                      : _selectedImage!.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D6BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _submitDeposit,
              icon: _isLoading
                  ? Container(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.open_in_new, color: Colors.white),
              label: Text(
                _isLoading ? "Submitting..." : "Submit Deposit Request",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _depositHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9F2D), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.history, color: Color(0xFF1E7BFF)),
              SizedBox(width: 8),
              Text(
                "Deposit History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                _TH("Date", flex: 2),
                _TH("Amount"),
                _TH("UTR", flex: 2),
                _TH("Status"),
                _TH("Action"),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // History List
          if (_isHistoryLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_deposits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  "No deposit history found",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _deposits.length,
              itemBuilder: (context, index) {
                final deposit = _deposits[index];
                return _historyRow(deposit);
              },
            ),

          // Pagination
          if (_pagination.isNotEmpty && (_pagination['last_page'] ?? 1) > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => _fetchDepositHistory(page: _currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Page $_currentPage of ${_pagination['last_page']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  IconButton(
                    onPressed: _currentPage < (_pagination['last_page'] ?? 1)
                        ? () => _fetchDepositHistory(page: _currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> deposit) {
    final status = deposit['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _cell(_formatDate(deposit['created_at']), flex: 2),
          _cell(
            "₹${deposit['amount']?.toStringAsFixed(2) ?? '0.00'}",
            color: Colors.blue,
          ),
          _cell(deposit['utr_number'] ?? '-', flex: 2),
          _cell(
            status.toUpperCase(),
            color: statusColor == 'green'
                ? Colors.green
                : statusColor == 'orange'
                ? Colors.orange
                : statusColor == 'red'
                ? Colors.red
                : Colors.grey,
          ),
          SizedBox(
            width: 60,
            child: GestureDetector(
              onTap: () => _viewDepositDetails(deposit['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF9F2D)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "View",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFF9F2D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

// ================= Helpers =================
class _TH extends StatelessWidget {
  final String text;
  final int flex;

  const _TH(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _cell(String text, {int flex = 1, Color? color}) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11, color: color),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
