import 'dart:convert';
import 'package:http/http.dart' as http;

class KYCService {
  static const String baseUrl = "https://kittycash.co.in/api";

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/kyc/update-profile"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("KYC STATUS => ${response.statusCode}");
    print("KYC BODY => ${response.body}");

    // Safely decode response body; some endpoints may return plain text.
    try {
      final data = jsonDecode(response.body);
      return {
        "status": response.statusCode >= 200 && response.statusCode < 300,
        "message": data["message"] ?? "",
        "data": data,
      };
    } catch (e) {
      return {
        "status": response.statusCode >= 200 && response.statusCode < 300,
        "message": response.body.isNotEmpty ? response.body : 'Unexpected response',
        "data": {"raw": response.body},
      };
    }
  }

  Future<Map<String, dynamic>> submitPersonalDetails({
    required String token,
    required String name,
    required String phone,
    required String dob,
    required String gender,
    required String address,
    required String city,
    required String pincode,
    required String state,
  }) async {
    final body = {
      "name": name,
      "phone": phone,
      "date_of_birth": dob, // ✅ FIX
      "gender": gender,
      "address": address,
      "city": city,
      "postal_code": pincode, // ✅ FIX
      "state": state,
    };

    return await updateProfile(token: token, body: body);
  }
}