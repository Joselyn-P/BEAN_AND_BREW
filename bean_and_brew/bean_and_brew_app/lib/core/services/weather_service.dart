// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class WeatherService {
  Future<Map<String, dynamic>> getWeatherRecommendation() async {
    try {
      // Get location from browser
      final position =
          await html.window.navigator.geolocation.getCurrentPosition();
      final lat = position.coords!.latitude!.toDouble();
      final lon = position.coords!.longitude!.toDouble();

      // Call YOUR backend (which calls OpenWeather using the .env key)
      final response = await http.get(
        Uri.parse('${ApiConstants.weather}?lat=$lat&lon=$lon'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'condition': data['condition'],
          'temp': data['temp'],
          'city': data['city'],
          'recommendationType': data['recommendationType'],
          'bannerText': _getBannerText(data['condition']),
          'bannerColor': _getBannerColor(data['condition']),
          'products': data['products'], // recommended products from DB
        };
      } else {
        return _fallback();
      }
    } catch (e) {
      return _fallback();
    }
  }

  Map<String, dynamic> _fallback() {
    return {
      'condition': 'Clear',
      'temp': 28,
      'city': 'Your City',
      'recommendationType': 'cold',
      'bannerText': "It's a sunny day! ☀️",
      'bannerColor': 'orange',
      'products': [],
    };
  }

  String _getBannerText(String weatherMain) {
    switch (weatherMain) {
      case 'Rain':
      case 'Drizzle':
        return "It's rainy! ☔ Warm up with a hot drink";
      case 'Thunderstorm':
        return "Stormy outside! ⛈️ Stay cozy";
      case 'Snow':
        return "It's snowing! ❄️ Perfect for something hot";
      case 'Clear':
        return "It's a sunny day! ☀️";
      case 'Clouds':
        return "Cloudy skies today ☁️";
      default:
        return "Today's Pick for you ☕";
    }
  }

  String _getBannerColor(String weatherMain) {
    switch (weatherMain) {
      case 'Rain':
      case 'Drizzle':
      case 'Thunderstorm':
        return 'blue';
      case 'Snow':
        return 'lightblue';
      case 'Clear':
        return 'orange';
      default:
        return 'grey';
    }
  }
}