class ApiConstants {
  // For web (Chrome), use localhost directly
  static const String baseUrl = 'http://localhost:3000/api';

  static const String login    = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String google   = '$baseUrl/auth/google';
  static const String products = '$baseUrl/products';
  static const String cart     = '$baseUrl/cart';
  static const String orders   = '$baseUrl/orders';
  static const String weather  = '$baseUrl/weather/recommend';
  static const String profile  = '$baseUrl/profile';
}