import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'storage_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      await StorageService.saveToken(data['token']);
      await StorageService.saveUser(json.encode(data['user']));
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> register(
      String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      await StorageService.saveToken(data['token']);
      await StorageService.saveUser(json.encode(data['user']));
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<void> logout() async {
    await StorageService.clearAll();
  }
}