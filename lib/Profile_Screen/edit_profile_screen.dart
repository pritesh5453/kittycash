import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final String? name; // 👈 ADD THIS

  const EditProfileScreen({super.key, this.name});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();

  String? gender;
  DateTime? selectedDob;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name ?? "";
    fetchKycDetails();
  }

  // ================= GET KYC DETAILS =================
  Future<void> fetchKycDetails() async {
    try {
      final token = await storage.read(key: "auth_token");
      if (token == null) return;

      final response = await http.get(
        Uri.parse("https://kittycash.co.in/api/kyc/details"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final kyc = data["data"];

        nameController.text =
            kyc["name"] != null && kyc["name"].toString().isNotEmpty
            ? kyc["name"]
            : (widget.name ?? "");
        phoneController.text = kyc["phone"] ?? "";
        addressController.text = kyc["address"] ?? "";
        cityController.text = kyc["city"] ?? "";
        stateController.text = kyc["state"] ?? "";
        pincodeController.text = kyc["postal_code"] ?? "";
        gender = kyc["gender"];

        // Date formatting
        if (kyc["date_of_birth"] != null &&
            kyc["date_of_birth"].toString().isNotEmpty) {
          final date = DateTime.parse(kyc["date_of_birth"]);
          selectedDob = date;
          dobController.text =
              "${date.day.toString().padLeft(2, '0')}/"
              "${date.month.toString().padLeft(2, '0')}/"
              "${date.year}";
        }
      }
    } catch (e) {
      debugPrint("KYC Fetch Error: $e");
    }

    setState(() => isLoading = false);
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final token = await storage.read(key: "auth_token");
      if (token == null) return;

      final response = await http.post(
        Uri.parse("https://kittycash.co.in/api/kyc/update-profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "date_of_birth": selectedDob != null
              ? "${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}"
              : "",
          "gender": gender ?? "",
          "address": addressController.text.trim(),
          "city": cityController.text.trim(),
          "state": stateController.text.trim(),
          "postal_code": pincodeController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["message"])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _formCard(),
                  const SizedBox(height: 20),
                  _saveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D6EFD), Color(0xFF4D8BFF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Row(
        children: [
          BackButton(color: Colors.white),
          SizedBox(width: 6),
          Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field("Full Name", nameController),
            _field("Phone", phoneController, keyboard: TextInputType.phone),
            _dateField(),
            _genderField(),
            _field("Address", addressController),
            _field("City", cityController),
            _field("State", stateController),
            _field(
              "Postal Code",
              pincodeController,
              keyboard: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            initialDate: selectedDob ?? DateTime(2000),
          );

          if (date != null) {
            selectedDob = date;
            dobController.text = "${date.day}/${date.month}/${date.year}";
          }
        },
        decoration: const InputDecoration(
          labelText: "Date of Birth",
          filled: true,
          fillColor: Color(0xFFF6F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: gender,
        hint: const Text("Select Gender"),
        validator: (v) => v == null ? "Required" : null,
        items: const [
          DropdownMenuItem(value: "male", child: Text("Male")),
          DropdownMenuItem(value: "female", child: Text("Female")),
          DropdownMenuItem(value: "other", child: Text("Other")),
        ],
        onChanged: (v) => setState(() => gender = v),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFFF6F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSaving ? null : updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F6BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
