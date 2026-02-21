import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "https://kittycash.co.in/api";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> getToken() async {
    final token = await _storage.read(key: 'token') ?? '';
    return token.trim(); // 🔥 VERY IMPORTANT
  }

  Future<Map<String, dynamic>> submitDeposit({
    required String amount,
    required String utr_Number,
    required File payment_Screenshot,
  }) async {
    print("===== SUBMIT DEPOSIT API CALLED =====");
    print("Amount: $amount");
    print("UTR: $utr_Number");
    print("IMAGE PATH: ${payment_Screenshot.path}");

    final uri = Uri.parse("$baseUrl/deposit");
    final token = await getToken();

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['amount'] = amount;
    request.fields['utr_number'] = utr_Number;

    // 🔥 ONLY THIS WORKS (Postman-like)
    final bytes = await payment_Screenshot.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'payment_screenshot',
        bytes,
        filename: payment_Screenshot.path.split('/').last,
      ),
    );

    print("FIELDS => ${request.fields}");
    print("FILES => ${request.files.map((f) => f.field).toList()}");

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print("STATUS => ${response.statusCode}");
    print("BODY => $body");

    return jsonDecode(body);
  }
}
