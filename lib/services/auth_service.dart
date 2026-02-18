import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // Add this import

class AuthService {
  static const String baseUrl = "https://kittycash.co.in/api";
  
  // Helper method to get token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

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
        "Authorization":
            "Bearer rF09gA38E8OrXy85lPN91DAyZuyBzp6JGcinptUd8e947ee5",
      },
      body: {"email": email, "password": password},
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    try {
      final data = jsonDecode(response.body);
      
      // If login successful, save the token
      if (response.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
      }
      
      return data;
    } catch (e) {
      print("JSON Decode Error: $e");
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
      final url = Uri.parse("$baseUrl/verify-otp");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"session_id": sessionId, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "status": true,
          "message": data["message"] ?? "OTP verified",
          "data": data,
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
    required String dob,
    required String referral,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/register");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "status": true,
          "message": data["message"] ?? "Registration successful",
          "data": data,
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

  // ================= GET ACTIVE BANK DETAILS =================
  Future<Map<String, dynamic>> getActiveBankDetails() async {
    print("===== GET ACTIVE BANK DETAILS API CALLED =====");
    
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          "status": false,
          "message": "User not authenticated",
        };
      }

      final response = await http.get(
        Uri.parse("$baseUrl/bank-details/active"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return {
            "status": true,
            "message": "Bank details fetched successfully",
            "data": data['data'],
          };
        } else {
          return {
            "status": true,
            "message": "Bank details fetched successfully",
            "data": data,
          };
        }
      } else if (response.statusCode == 401) {
        return {
          "status": false,
          "message": "Authentication failed. Please login again.",
        };
      } else {
        return {
          "status": false,
          "message": data['message'] ?? "Failed to fetch bank details",
        };
      }
    } catch (e) {
      print("Error fetching bank details: $e");
      return {
        "status": false,
        "message": "Something went wrong. Please try again.",
      };
    }
  }

  // ================= DEPOSIT METHODS =================

  // Get deposit history with pagination
  Future<Map<String, dynamic>> getDepositHistory({
    int page = 1,
    String? status,
    String? startDate,
    String? endDate,
    String sort = 'desc',
    int perPage = 20,
  }) async {
    print("===== GET DEPOSIT HISTORY API CALLED =====");
    print("Page: $page");
    
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          "status": false,
          "message": "User not authenticated",
        };
      }

      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'sort': sort,
        'per_page': perPage.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final Uri uri = Uri.parse("$baseUrl/payments/deposits").replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          "status": true,
          "message": data['message'] ?? "Deposit history fetched successfully",
          "data": data['data'],
        };
      } else {
        return {
          "status": false,
          "message": data['message'] ?? "Failed to fetch deposit history",
        };
      }
    } catch (e) {
      print("Error fetching deposit history: $e");
      return {
        "status": false,
        "message": "Something went wrong. Please try again.",
      };
    }
  }

  // Submit deposit request
  Future<Map<String, dynamic>> submitDeposit({
    required String amount,
    required String utrNumber,
    required File paymentScreenshot,
  }) async {
    print("===== SUBMIT DEPOSIT API CALLED =====");
    print("Amount: $amount");
    print("UTR: $utrNumber");
    
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          "status": false,
          "message": "User not authenticated",
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/payments/deposits"),
      );

      // Add headers
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // Add text fields
      request.fields['amount'] = amount;
      request.fields['utr_number'] = utrNumber;

      // Add file with proper content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'screenshot',
          paymentScreenshot.path,
          contentType: MediaType('image', 'jpeg'), // Now this will work
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "status": true,
          "message": data['message'] ?? "Deposit request submitted successfully",
          "data": data['data'] ?? data,
        };
      } else {
        return {
          "status": false,
          "message": data['message'] ?? "Failed to submit deposit request",
        };
      }
    } catch (e) {
      print("Error submitting deposit: $e");
      return {
        "status": false,
        "message": "Something went wrong. Please try again.",
      };
    }
  }

  // View single deposit details
  Future<Map<String, dynamic>> getDepositDetails(int depositId) async {
    print("===== GET DEPOSIT DETAILS API CALLED =====");
    print("Deposit ID: $depositId");
    
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          "status": false,
          "message": "User not authenticated",
        };
      }

      final response = await http.get(
        Uri.parse("$baseUrl/payments/deposits/$depositId"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          "status": true,
          "message": data['message'] ?? "Deposit details fetched successfully",
          "data": data['data'],
        };
      } else {
        return {
          "status": false,
          "message": data['message'] ?? "Failed to fetch deposit details",
        };
      }
    } catch (e) {
      print("Error fetching deposit details: $e");
      return {
        "status": false,
        "message": "Something went wrong. Please try again.",
      };
    }
  }

  // Add this method to save token after login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Add this method to clear token on logout
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}