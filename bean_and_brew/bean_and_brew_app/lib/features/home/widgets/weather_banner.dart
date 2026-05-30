import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherBanner extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherBanner({super.key, required this.weatherData});

  Color _getBannerBgColor() {
    final color = weatherData['bannerColor'] ?? 'orange';
    switch (color) {
      case 'blue':
        return const Color(0xFFDDE8F5);
      case 'lightblue':
        return const Color(0xFFE0F0FF);
      case 'grey':
        return const Color(0xFFEEEEEE);
      default:
        return const Color(0xFFFFF0D6);
    }
  }

  IconData _getWeatherIcon() {
    final condition = weatherData['condition'] ?? 'Clear';
    switch (condition) {
      case 'Rain':
      case 'Drizzle':
        return Icons.umbrella;
      case 'Thunderstorm':
        return Icons.thunderstorm;
      case 'Snow':
        return Icons.ac_unit;
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Haze':
      case 'Mist':
      case 'Fog':
      case 'Smoke':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _getBannerText() {
    final condition = weatherData['condition'] ?? 'Clear';
    switch (condition) {
      case 'Rain':
      case 'Drizzle':
        return "It's rainy! Warm up with a hot drink";
      case 'Thunderstorm':
        return "Stormy outside! Stay cozy";
      case 'Snow':
        return "It's snowing! Perfect for something hot";
      case 'Clear':
        return "It's a sunny day!";
      case 'Clouds':
        return "Cloudy skies today";
      case 'Haze':
      case 'Mist':
      case 'Fog':
      case 'Smoke':
        return "Hazy day outside";
      default:
        return "Today's Pick for you";
    }
  }

  String _getRecommendedDrink() {
    return weatherData['recommendationType'] == 'hot'
        ? 'Honey Lavender Latte'
        : 'Iced Caramel Macchiato';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBannerBgColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getWeatherIcon(),
                      size: 16,
                      color: const Color(0xFF7A6652),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getBannerText(),
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: const Color(0xFF7A6652),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Today's Pick",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C1A0E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getRecommendedDrink(),
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: const Color(0xFF7A6652),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C1A0E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Order Now',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.15,
            child: Icon(
              _getWeatherIcon(),
              size: 80,
              color: const Color(0xFF2C1A0E),
            ),
          ),
        ],
      ),
    );
  }
}