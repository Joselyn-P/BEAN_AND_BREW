import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> _options = [];
  bool _isLoading = true;

  String _selectedSize = 'Small';
  String _selectedTemp = 'Hot';
  String _selectedSugar = '50%';
  Map<String, int> _addons = {};
  int _quantity = 1;
  bool _oatMilk = false;
  bool _warmed = false;

  final List<String> _sizes = ['Small', 'Medium', 'Large'];
  final List<String> _temps = ['Hot', 'Iced'];
  final List<String> _sugarLevels = ['0%', '50%', '100%'];

  double get _basePrice =>
      double.parse(widget.product['base_price'].toString());

  double get _totalPrice {
    double total = _basePrice;

    if (_isDrink) {
      if (_selectedSize == 'Medium') total += 0.50;
      if (_selectedSize == 'Large') total += 1.00;
      if (_oatMilk) total += 0.75;
    }

    for (final option in _options) {
      if (option['option_type'] == 'addon') {
        final count = _addons[option['id']] ?? 0;
        if (count > 0) {
          total += double.parse(option['price_modifier'].toString()) * count;
        }
      }
    }

    return total * _quantity;
  }

  bool get _isDrink {
    const drinkCategories = {'Hot Coffee', 'Cold Brew', 'Tea'};
    final category = widget.product['category_name'] ?? '';
    return drinkCategories.contains(category);
  }

  @override
  void initState() {
    super.initState();
    _loadProductOptions();
    final tempType = widget.product['temperature_type'] ?? 'both';
    if (tempType == 'hot') _selectedTemp = 'Hot';
    if (tempType == 'cold') _selectedTemp = 'Iced';
  }

  Future<void> _loadProductOptions() async {
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse('${ApiConstants.products}/${widget.product['id']}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _options = List<Map<String, dynamic>>.from(data['options'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addToCart() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login first', style: GoogleFonts.lato()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final selectedOptions = {
        'size': _selectedSize,
        'temperature': _selectedTemp,
        'sugar': _selectedSugar,
        'oat_milk': _oatMilk,
        'addons': _addons,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.cart}/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'product_id': widget.product['id'],
          'quantity': _quantity,
          'selected_options': selectedOptions,
          'item_price': (_totalPrice / _quantity).toStringAsFixed(2),
        }),
      );

      if (response.statusCode == 201) {
        Provider.of<CartProvider>(context, listen: false).loadCart();
          // OR for instant local bump by quantity:
          for (int i = 0; i < _quantity; i++) {
            Provider.of<CartProvider>(context, listen: false).increment();
          }
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product['name']} added to cart!',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: const Color(0xFF2C1A0E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Failed to add to cart',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.lato()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final tempType = product['temperature_type'] ?? 'both';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Scrollable Content ───────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image ───────────────────────────────
                Stack(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Image.network(
                        product['image_url'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 300,
                          color: const Color(0xFFF0E8D8),
                          child: const Center(
                            child: Icon(
                              Icons.coffee,
                              size: 80,
                              color: Color(0xFF7A6652),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: SafeArea(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF2C1A0E),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: SafeArea(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: Color(0xFF2C1A0E),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Product Info ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? '',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C1A0E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product['description'] ?? '',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: const Color(0xFF7A6652),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_isDrink) ...[
                        // ── Size Selection ─────────────────────
                        Text(
                          'Size Selection',
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: _sizes.map((size) {
                            final selected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSize = size),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF2C1A0E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF2C1A0E)
                                        : const Color(0xFFE0D5C5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.coffee_outlined,
                                      size: size == 'Small'
                                          ? 16
                                          : size == 'Medium'
                                              ? 20
                                              : 24,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF7A6652),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      size,
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF7A6652),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // ── Temperature & Sugar ────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Temperature',
                                    style: GoogleFonts.lato(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2C1A0E),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: _temps.map((temp) {
                                      if (temp == 'Iced' &&
                                          tempType == 'hot') {
                                        return const SizedBox.shrink();
                                      }
                                      if (temp == 'Hot' &&
                                          tempType == 'cold') {
                                        return const SizedBox.shrink();
                                      }
                                      final selected = _selectedTemp == temp;
                                      return GestureDetector(
                                        onTap: () => setState(
                                            () => _selectedTemp = temp),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color(0xFF2C1A0E)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: selected
                                                  ? const Color(0xFF2C1A0E)
                                                  : const Color(0xFFE0D5C5),
                                            ),
                                          ),
                                          child: Text(
                                            temp,
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
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            // Sugar Level
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sugar Level',
                                    style: GoogleFonts.lato(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2C1A0E),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _sugarLevels.map((sugar) {
                                      final selected =
                                          _selectedSugar == sugar;
                                      return GestureDetector(
                                        onTap: () => setState(
                                            () => _selectedSugar = sugar),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color(0xFF2C1A0E)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: selected
                                                  ? const Color(0xFF2C1A0E)
                                                  : const Color(0xFFE0D5C5),
                                            ),
                                          ),
                                          child: Text(
                                            sugar,
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
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Add-ons ────────────────────────────
                        if (!_isLoading) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE0D5C5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0D6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.opacity,
                                    color: Color(0xFFB87333),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Oat Milk',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2C1A0E),
                                        ),
                                      ),
                                      Text(
                                        'ADD +\$0.75',
                                        style: GoogleFonts.lato(
                                          fontSize: 11,
                                          color: const Color(0xFF7A6652),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _oatMilk,
                                  onChanged: (val) =>
                                      setState(() => _oatMilk = val),
                                  activeColor: const Color(0xFF2C1A0E),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          ..._options
                              .where((o) => o['option_type'] == 'addon')
                              .map((option) {
                            final count = _addons[option['id']] ?? 0;
                            final price = double.parse(
                              option['price_modifier'].toString(),
                            );
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0D5C5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0D6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFFB87333),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option['label'] ?? '',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2C1A0E),
                                          ),
                                        ),
                                        Text(
                                          'ADD +\$${price.toStringAsFixed(2)}',
                                          style: GoogleFonts.lato(
                                            fontSize: 11,
                                            color: const Color(0xFF7A6652),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (count > 0) {
                                            setState(() => _addons[
                                                option['id']] = count - 1);
                                          }
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0E8D8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                            color: Color(0xFF2C1A0E),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          '$count',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2C1A0E),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _addons[
                                              option['id']] = count + 1);
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2C1A0E),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],

                      // Show warmed option for pastries
                      if (!_isDrink) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0D5C5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0D6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.whatshot,
                                  color: Color(0xFFB87333),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Warmed',
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2C1A0E),
                                      ),
                                    ),
                                    Text(
                                      'Heat it up for you',
                                      style: GoogleFonts.lato(
                                        fontSize: 11,
                                        color: const Color(0xFF7A6652),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _warmed,
                                onChanged: (val) => setState(() => _warmed = val),
                                activeColor: const Color(0xFF2C1A0E),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Bar (Price + Add to Cart) ─────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E8D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 16,
                            color: Color(0xFF2C1A0E),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E8D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Color(0xFF2C1A0E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Add to Cart button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C1A0E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Add to Cart — \$${_totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}