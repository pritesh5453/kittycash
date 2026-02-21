import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kittycash/portfolio/wallet_model.dart';

class WalletDashboardService {
  static const String baseUrl = "https://kittycash.co.in/api";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<DashboardWalletResponse> fetchDashboardWallet() async {
    final token = await storage.read(key: "auth_token");

    print("🔐 TOKEN = $token");

    if (token == null || token.isEmpty) {
      throw Exception("User not logged in");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/wallet/details"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("📡 STATUS = ${response.statusCode}");
    print("📦 BODY = ${response.body}");

    if (response.statusCode == 200) {
      return DashboardWalletResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception("Session expired");
    } else {
      throw Exception("Server error ${response.statusCode}");
    }
  }
}
