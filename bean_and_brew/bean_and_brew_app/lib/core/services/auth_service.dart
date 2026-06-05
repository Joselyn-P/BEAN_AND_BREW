import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/api_constants.dart';
import 'storage_service.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '127644867232-ubajoq54sj3ut8qu82kilq06a6alb5i6.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // Existing login
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

  // Existing register
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

  // NEW Google login
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print(_googleSignIn.runtimeType);
      final account = await _googleSignIn.signIn();
      await _googleSignIn.signInSilently();

      if (account == null) {
        return {
          'success': false,
          'message': 'Sign in cancelled',
        };
      }

      final auth = await account.authentication;

      print('Access Token: ${auth.accessToken}');
      print('ID Token: ${auth.idToken}');

      final idToken = auth.idToken;
            

      final accessToken = auth.accessToken;

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Failed to get access token',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConstants.googleLogin),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'access_token': accessToken,
        }),
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await StorageService.saveToken(data['token']);
        await StorageService.saveUser(json.encode(data['user']));

        return {
          'success': true,
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Google login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await StorageService.clearAll();
  }
}