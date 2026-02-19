import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {



  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://kittycash.co.in/api",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      validateStatus: (status) {
        return status != null && status < 500; // 🔥 IMPORTANT
      },
    ),
  );

  static Future<void> attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token != null && token.isNotEmpty) {
      dio.options.headers["Authorization"] = "Bearer ${token.trim()}";
      print("TOKEN ATTACHED: $token");
    }
  }



  
}
