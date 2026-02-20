import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  // Controllers for user‑fillable fields
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  // Selected image files
  File? _aadharFrontImage;
  File? _aadharBackImage;
  File? _panImage;

  // Personal details fetched from API
  String? _phone;
  String? _dob;
  String? _gender;
  String? _address;
  String? _city;
  String? _state;
  String? _postalCode;

  // Loading states
  bool _isLoadingDetails = true;
  String? _detailsError;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchKycDetails();
  }

  Future<void> _fetchKycDetails() async {
    setState(() {
      _isLoadingDetails = true;
      _detailsError = null;
    });

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('https://kittycash.co.in/api/kyc/details'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final data = json['data'];
          setState(() {
            // Parse date_of_birth (format: "1998-06-14T18:30:00.000000Z")
            String rawDob = data['date_of_birth'] ?? '';
            if (rawDob.isNotEmpty) {
              // Extract date part (assuming ISO format)
              _dob = rawDob.split('T')[0];
            }
            _phone = data['phone']?.toString();
            _gender = data['gender'];
            _address = data['address'];
            _city = data['city'];
            _state = data['state'];
            _postalCode = data['postal_code']?.toString();
            _isLoadingDetails = false;
          });
        } else {
          setState(() {
            _detailsError = json['message'] ?? 'Failed to load KYC details';
            _isLoadingDetails = false;
          });
        }
      } else {
        setState(() {
          _detailsError = 'Server error: ${response.statusCode}';
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      setState(() {
        _detailsError = 'Network error: $e';
        _isLoadingDetails = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Image picking methods (unchanged)
  Future<void> _pickImage(
    ImageSource source,
    Function(File?) onImagePicked,
  ) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceDialog(Function(File?) onImagePicked) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, onImagePicked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, onImagePicked);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitKyc() async {
    print("=== Starting KYC submission ===");

    // Collect user‑entered data
    final aadharNumber = _aadharController.text.trim();
    final panNumber = _panController.text.trim().toUpperCase();
    final bankName = _bankNameController.text.trim();
    final accountHolder = _accountHolderController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final ifsc = _ifscController.text.trim().toUpperCase();
    final branch = _branchController.text.trim();

    print("User inputs:");
    print("Aadhar: $aadharNumber");
    print("PAN: $panNumber");
    print("Bank Name: $bankName");
    print("Account Holder: $accountHolder");
    print("Account Number: $accountNumber");
    print("IFSC: $ifsc");
    print("Branch: $branch");

    // Validate user inputs
    if (aadharNumber.length != 12) {
      print("Validation failed: Aadhar length ${aadharNumber.length}");
      _showError("Enter a valid 12-digit Aadhar number");
      return;
    }
    if (panNumber.length != 10) {
      print("Validation failed: PAN length ${panNumber.length}");
      _showError("Enter a valid 10-character PAN");
      return;
    }
    if (_aadharFrontImage == null ||
        _aadharBackImage == null ||
        _panImage == null) {
      print("Validation failed: Missing images");
      print("Aadhar front: ${_aadharFrontImage?.path}");
      print("Aadhar back: ${_aadharBackImage?.path}");
      print("PAN: ${_panImage?.path}");
      _showError("Please upload all required images");
      return;
    }
    if (bankName.isEmpty ||
        accountHolder.isEmpty ||
        accountNumber.isEmpty ||
        ifsc.isEmpty ||
        branch.isEmpty) {
      print("Validation failed: Empty bank fields");
      _showError("Please fill all bank details");
      return;
    }

    // Ensure personal details are loaded
    if (_phone == null ||
        _dob == null ||
        _gender == null ||
        _address == null ||
        _city == null ||
        _state == null ||
        _postalCode == null) {
      print("Personal details missing:");
      print("phone: $_phone");
      print("dob: $_dob");
      print("gender: $_gender");
      print("address: $_address");
      print("city: $_city");
      print("state: $_state");
      print("postalCode: $_postalCode");
      _showError("Personal details not loaded. Please try again.");
      return;
    }

    print("Personal details loaded:");
    print("phone: $_phone");
    print("dob: $_dob");
    print("gender: $_gender");
    print("address: $_address");
    print("city: $_city");
    print("state: $_state");
    print("postalCode: $_postalCode");

    setState(() => _isSubmitting = true);

    try {
      final token = await _getToken();
      if (token == null) {
        print("Token is null");
        throw Exception('Not authenticated');
      }
      print("Token obtained: $token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://kittycash.co.in/api/kyc/submit'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Add personal details (from fetched data)
      request.fields['phone'] = _phone!;
      request.fields['date_of_birth'] = _dob!;
      request.fields['gender'] = _gender!;
      request.fields['address'] = _address!;
      request.fields['city'] = _city!;
      request.fields['state'] = _state!;
      request.fields['postal_code'] = _postalCode!;
      // Add Aadhar, PAN, bank details
      request.fields['aadhaar_number'] = aadharNumber;
      request.fields['pan_number'] = panNumber;
      request.fields['bank_name'] = bankName;
      request.fields['account_holder_name'] = accountHolder;
      request.fields['account_number'] = accountNumber;
      request.fields['ifsc_code'] = ifsc;
      request.fields['bank_branch'] = branch;

      print("Request fields:");
      request.fields.forEach((key, value) {
        print("  $key: $value");
      });

      // Add images
      print("Adding image files:");
      print("aadhaar_front_image: ${_aadharFrontImage!.path}");
      request.files.add(
        await http.MultipartFile.fromPath(
          'aadhaar_front_image',
          _aadharFrontImage!.path,
        ),
      );
      print("aadhaar_back_image: ${_aadharBackImage!.path}");
      request.files.add(
        await http.MultipartFile.fromPath(
          'aadhaar_back_image',
          _aadharBackImage!.path,
        ),
      );
      print("pan_card_image: ${_panImage!.path}");
      request.files.add(
        await http.MultipartFile.fromPath('pan_card_image', _panImage!.path),
      );

      print("Sending request...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        print("Decoded JSON: $json");
        if (json['success'] == true) {
          print("KYC submission successful");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KYC submitted successfully!')),
          );
          Navigator.pop(context);
        } else {
          String message = json['message'] ?? 'KYC submission failed';
          if (json['data'] != null && json['data']['status'] != null) {
            message += ' (Status: ${json['data']['status']})';
          }
          print("KYC submission failed: $message");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } else {
        print("Server error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Exception caught: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
      print("=== KYC submission finished ===");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while fetching personal details
    if (_isLoadingDetails) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF2F7),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if details failed to load
    if (_detailsError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF2F7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_detailsError!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchKycDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Main UI with Aadhar, PAN, and Bank sections
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
                    const Text(
                      "KYC Verification",
                      style: TextStyle(
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
                    // Aadhar Details
                    const Text(
                      "Aadhar Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      "Aadhar Number",
                      "12-digit Aadhar number",
                      _aadharController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadBox(
                            label: "Aadhar Front",
                            icon: Icons.credit_card,
                            image: _aadharFrontImage,
                            onTap: () => _showImageSourceDialog(
                              (file) =>
                                  setState(() => _aadharFrontImage = file),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadBox(
                            label: "Aadhar Back",
                            icon: Icons.credit_card,
                            image: _aadharBackImage,
                            onTap: () => _showImageSourceDialog(
                              (file) => setState(() => _aadharBackImage = file),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Divider(thickness: 1),
                    const SizedBox(height: 16),

                    // PAN Details
                    const Text(
                      "PAN Card Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      "PAN Number",
                      "10-character PAN",
                      _panController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 16),

                    _buildUploadBox(
                      label: "Upload PAN Card",
                      icon: Icons.image,
                      fullWidth: true,
                      image: _panImage,
                      onTap: () => _showImageSourceDialog(
                        (file) => setState(() => _panImage = file),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Divider(thickness: 1),
                    const SizedBox(height: 16),

                    // Bank Details
                    const Text(
                      "Bank Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      "Bank Name",
                      "e.g., State Bank of India",
                      _bankNameController,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Account Holder Name",
                      "As per bank records",
                      _accountHolderController,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Account Number",
                      "Enter account number",
                      _accountNumberController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "IFSC Code",
                      "e.g., SBIN0001234",
                      _ifscController,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Bank Branch",
                      "e.g., Connaught Place",
                      _branchController,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitKyc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6BFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Submit KYC",
                                style: TextStyle(
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: maxLength != null ? "" : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox({
    required String label,
    required IconData icon,
    bool fullWidth = false,
    File? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.blue.shade300),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tap to upload",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
