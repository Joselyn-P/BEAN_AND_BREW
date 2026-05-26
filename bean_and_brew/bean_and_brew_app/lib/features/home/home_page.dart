import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _weatherLoading = true;
  bool _productsLoading = true;
  int _selectedCategory = 0;
  int _currentNavIndex = 0;

  final List<String> _categories = [
    'HOT COFFEE', 'COLD BREW', 'TEA', 'PASTRIES'
  ];

  final List<String> _categorySlugs = [
    'hot-coffee', 'cold-brew', 'tea', 'pastries'
  ];

  List<Map<String, dynamic>> _recommended = [];
  List<Map<String, dynamic>> _featured = [];

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadProducts();
  }

  Future<void> _loadWeather() async {
    try {
      final data = await _weatherService.getWeatherRecommendation();
      setState(() {
        _weatherData = data;
        _weatherLoading = false;

        if (data['products'] != null &&
            (data['products'] as List).isNotEmpty) {
              _recommended = List<Map<String, dynamic>>.from(data['products']);
              _productsLoading = false;
            }
      });
    } catch (e) {
      setState(() {
        _weatherData = {
          'condition': 'Clear',
          'temp': 28,
          'city': 'Your City',
          'recommendationType': 'cold',
          'bannerText': "It's a sunny day! ☀️",
          'bannerColor': 'orange',
        };
        _weatherLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final token = await StorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final featuredRes = await http.get(
        Uri.parse('${ApiConstants.products}/featured'),
        headers: headers,
      );

      final recommendedRes = await http.get(
        Uri.parse(ApiConstants.products),
        headers: headers,
      );

      if (featuredRes.statusCode == 200 && recommendedRes.statusCode == 200) {
        setState(() {
          _featured = List<Map<String, dynamic>>.from(
            json.decode(featuredRes.body),
          );
          _recommended = List<Map<String, dynamic>>.from(
            json.decode(recommendedRes.body),
          ).take(5).toList();
          _productsLoading = false;
        });
      } else {
        setState(() => _productsLoading = false);
      }
    } catch (e) {
      setState(() => _productsLoading = false);
    }
  }

  Future<void> _loadByCategory(String slug) async {
    setState(() => _productsLoading = true);
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse('${ApiConstants.products}/category/$slug'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          _recommended = List<Map<String, dynamic>>.from(
            json.decode(res.body),
          ).take(5).toList();
          _productsLoading = false;
        });
      }
    } catch (e) {
      setState(() => _productsLoading = false);
    }
  }

  Color _getBannerBgColor() {
    final color = _weatherData?['bannerColor'] ?? 'orange';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE0D5C5),
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://i.pravatar.cc/150?img=8',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _weatherData?['city'] ?? 'Loading...',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: const Color(0xFF7A6652),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Bean & Brew',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C1A0E),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(0xFF2C1A0E),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Weather Banner ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _weatherLoading
                        ? Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0D6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2C1A0E),
                              ),
                            ),
                          )
                        : Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _weatherData?['bannerText'] ?? '',
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          color: const Color(0xFF7A6652),
                                        ),
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
                                        _weatherData?['recommendationType'] ==
                                                'hot'
                                            ? 'Honey Lavender Latte'
                                            : 'Iced Caramel Macchiato',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: const Color(0xFF7A6652),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2C1A0E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                  child: const Icon(
                                    Icons.coffee,
                                    size: 80,
                                    color: Color(0xFF2C1A0E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // ── Category Tabs ────────────────────────
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final selected = _selectedCategory == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = index);
                            _loadByCategory(_categorySlugs[index]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF2C1A0E)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF2C1A0E)
                                    : const Color(0xFFD5C9B8),
                              ),
                            ),
                            child: Text(
                              _categories[index],
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF7A6652),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Recommended (Carousel) ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: GoogleFonts.lato(
                              color: const Color(0xFFB87333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: _productsLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2C1A0E),
                            ),
                          )
                        : _recommended.isEmpty
                            ? Center(
                                child: Text(
                                  'No products found',
                                  style: GoogleFonts.lato(
                                    color: const Color(0xFF7A6652),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _recommended.length,
                                itemBuilder: (context, index) {
                                  final item = _recommended[index];
                                  return Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            item['image_url'] ?? '',
                                            height: 130,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              height: 130,
                                              color: const Color(0xFFF0E8D8),
                                              child: const Icon(
                                                Icons.coffee,
                                                size: 40,
                                                color: Color(0xFF7A6652),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'] ?? '',
                                                style: GoogleFonts.lato(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF2C1A0E),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${double.parse(item['base_price'].toString()).toStringAsFixed(2)}',
                                                style: GoogleFonts.lato(
                                                  fontSize: 13,
                                                  color:
                                                      const Color(0xFF7A6652),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 24),

                  // ── Featured Today ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Featured Today',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C1A0E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _featured.isEmpty && !_productsLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'No featured items today',
                            style: GoogleFonts.lato(
                              color: const Color(0xFF7A6652),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _featured.length,
                          itemBuilder: (context, index) {
                            final item = _featured[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item['image_url'] ?? '',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: const Color(0xFFF0E8D8),
                                        child: const Icon(
                                          Icons.coffee,
                                          color: Color(0xFF7A6652),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['name'] ?? '',
                                                style: GoogleFonts.lato(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF2C1A0E),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '\$${double.parse(item['base_price'].toString()).toStringAsFixed(2)}',
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    const Color(0xFFB87333),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['description'] ?? '',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            color: const Color(0xFF7A6652),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item['temperature_type'] ==
                                                    'cold'
                                                ? const Color(0xFFE0F5E9)
                                                : const Color(0xFFFFF0E0),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            item['temperature_type'] == 'cold'
                                                ? 'HEALTHY CHOICE'
                                                : 'FRESHLY BAKED',
                                            style: GoogleFonts.lato(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: item['temperature_type'] ==
                                                      'cold'
                                                  ? const Color(0xFF2E7D52)
                                                  : const Color(0xFFD4703A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Floating Cart Button ─────────────────────
            Positioned(
              bottom: 16,
              right: 20,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1A0E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB87333),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation ────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          selectedItemColor: const Color(0xFFB87333),
          unselectedItemColor: const Color(0xFF7A6652),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.lato(),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.coffee_outlined),
              activeIcon: Icon(Icons.coffee),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}