import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kittycash/Main/Dashboard/dashboard_model.dart';

class DashboardService {
  static const String baseUrl = "https://kittycash.co.in/api";

  Future<DashboardModel> getOverview(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/overview"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      return DashboardModel.fromJson(data["data"]);
    } else {
      throw Exception("Failed to load dashboard");
    }
  }
}
