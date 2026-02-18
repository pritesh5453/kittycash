import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kittycash/portfolio/wallet_model.dart';

class PortfolioService {
  static const String baseUrl = "https://kittycash.co.in/api";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<PortfolioModel> fetchPortfolio() async {
    final token = await storage.read(key: "auth_token");

    print("🔐 TOKEN = $token");

    if (token == null || token.isEmpty) {
      throw Exception("User not logged in");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/overview"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("📡 STATUS = ${response.statusCode}");
    print("📦 BODY = ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return PortfolioModel.fromJson(body["data"]["portfolio"]);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthenticated");
    } else {
      throw Exception("Server error ${response.statusCode}");
    }
  }
}
