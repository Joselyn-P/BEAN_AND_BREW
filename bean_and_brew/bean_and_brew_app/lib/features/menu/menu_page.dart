import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';

import 'product_page.dart';
import '../cart/cart_page.dart';
import '../orders/orders_page.dart';
import '../profile/profile_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategory = -1; // -1 = all
  bool _isLoading = true;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  final List<String> _categories = [
    'All', 'Hot Coffee', 'Cold Brew', 'Tea', 'Pastries'
  ];

  final List<String> _categorySlugs = [
    'all', 'hot-coffee', 'cold-brew', 'tea', 'pastries'
  ];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final name = (p['name'] ?? '').toLowerCase();
        final desc = (p['description'] ?? '').toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList();
    });
  }

  Future<void> _loadAllProducts() async {
    setState(() => _isLoading = true);
    try {
      final token = await StorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final res = await http.get(
        Uri.parse('${ApiConstants.products}?category=all'),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(
          json.decode(res.body),
        );
        setState(() {
          _allProducts = data;
          _filteredProducts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadByCategory(String slug) async {
    setState(() => _isLoading = true);
    _searchController.clear();
    try {
      final token = await StorageService.getToken();
      final url = slug == 'all'
          ? '${ApiConstants.products}?category=all'
          : '${ApiConstants.products}?category=$slug';

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(
          json.decode(res.body),
        );
        setState(() {
          _allProducts = data;
          _filteredProducts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      // Profile pic
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0D5C5),
                          border: Border.all(
                            color: const Color(0xFFD5C9B8),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF7A6652),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bean & Brew
                      Expanded(
                        child: Text(
                          'Bean & Brew',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF2C1A0E),
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Search Bar ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search your coffee...',
                      hintStyle: GoogleFonts.lato(
                        color: const Color(0xFFB0A090),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFB0A090),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Color(0xFFB0A090)),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF2C1A0E),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Category Tabs ────────────────────────────
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final selected = _selectedCategory == index - 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = index - 1);
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
                const SizedBox(height: 16),

                // ── Product Grid ─────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2C1A0E),
                          ),
                        )
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.coffee_outlined,
                                    size: 60,
                                    color: Color(0xFFD5C9B8),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No products found',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      color: const Color(0xFF7A6652),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try a different search or category',
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: const Color(0xFFB0A090),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 0, 20, 25),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final item = _filteredProducts[index];
                                return _ProductCard(product: item);
                              },
                            ),
                ),
              ],
            ),
          ),

          // ── Floating Cart Button ─────────────────────────
          Positioned(
              bottom: 16,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ).then((_) {
                    Provider.of<CartProvider>(context, listen: false).loadCart();
                  });
                },

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
                          child: Center(
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
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
            ),
        ],
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
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context); // back to Home
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            }
            // index == 1 is current page, do nothing
          },
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

// ── Product Card Widget ──────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {

    
    final price = double.parse(
      (product['base_price'] ?? '0').toString(),
    ).toStringAsFixed(2);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                product['image_url'] ?? '',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: const Color(0xFFF0E8D8),
                  child: const Center(
                    child: Icon(
                      Icons.coffee,
                      size: 40,
                      color: Color(0xFF7A6652),
                    ),
                  ),
                ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C1A0E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$$price',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A6652),
                        ),
                      ),
                      // Add to cart button
                      GestureDetector(
                        onTap: () {
                          // TODO: add to cart
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1A0E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}