import 'dart:convert';
import '../../../../../core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = '${ApiConstants.baseUrl}/auth/login.php';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"status": false, "message": "Server error"};
    }
  }
}
