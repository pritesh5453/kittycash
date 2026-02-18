import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://kittycash.co.in/api";

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print("===== LOGIN API CALLED =====");
    print("Email: $email");
    print("Password: $password");

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    print("📡 Status Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");

    try {
      final decoded = jsonDecode(response.body);

      // ✅ Success response
      if (response.statusCode == 200 && decoded["status"] == true) {
        return decoded;
      }

      // ❌ Login failed
      return {"status": false, "message": decoded["message"] ?? "Login failed"};
    } catch (e) {
      print("❌ JSON Decode Error: $e");
      return {"status": false, "message": "Invalid server response"};
    }
  }

  // ================= VERIFY OTP =================
  Future<Map<String, dynamic>> verifyOtp({
    required String sessionId,
    required String otp,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"session_id": sessionId, "otp": otp}),
      );

      print("📡 OTP STATUS: ${response.statusCode}");
      print("📦 OTP BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        return {
          "status": true,
          "message": data["message"] ?? "OTP verified",
          "data": data["data"],
        };
      } else {
        return {"status": false, "message": data["message"] ?? "Invalid OTP"};
      }
    } catch (e) {
      return {"status": false, "message": "OTP verification failed"};
    }
  }

  // ================= REGISTER =================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String confirmPassword,
    required String referral,
    required String dob,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": mobile,
          "password": password,
          "password_confirmation": confirmPassword,
          if (referral.isNotEmpty) "referral_code": referral,
        }),
      );

      print("📡 REGISTER STATUS: ${response.statusCode}");
      print("📦 REGISTER BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "status": true,
          "message": data["message"] ?? "Registration successful",
          "data": data["data"],
        };
      } else {
        return {
          "status": false,
          "message": data["message"] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {
        "status": false,
        "message": "Something went wrong. Please try again.",
      };
    }
  }
}
