import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

import '../checkout/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;
  int _itemCount = 0;

  final _promoController = TextEditingController();
  bool _applyingPromo = false;
  Map<String, dynamic>? _appliedPromo;
  double _discount = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiConstants.cart),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _items = List<Map<String, dynamic>>.from(data['items']);
          _subtotal = double.parse(data['subtotal'].toString());
          _tax = double.parse(data['tax'].toString());
          _total = double.parse(data['total'].toString());
          _itemCount = data['item_count'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(String itemId, int newQty) async {
    try {
      final token = await StorageService.getToken();
      if (newQty <= 0) {
        await _removeItem(itemId);
        return;
      }
      await http.put(
        Uri.parse('${ApiConstants.cart}/items/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'quantity': newQty}),
      );
      await _loadCart();
    } catch (e) {}
  }

  Future<void> _removeItem(String itemId) async {
    try {
      final token = await StorageService.getToken();
      await http.delete(
        Uri.parse('${ApiConstants.cart}/items/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await _loadCart();
    } catch (e) {}
  }

  Future<void> _applyPromo() async {
    if (_promoController.text.isEmpty) return;
    setState(() => _applyingPromo = true);
    try {
      final token = await StorageService.getToken();
      final res = await http.post(
        Uri.parse('${ApiConstants.cart}/promo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'code': _promoController.text.trim()}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final discountValue =
            double.parse(data['discount_value'].toString());
        setState(() {
          _appliedPromo = data;
          _discount = data['discount_type'] == 'percent'
              ? _subtotal * (discountValue / 100)
              : discountValue;
          _applyingPromo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Promo applied!', style: GoogleFonts.lato()),
            backgroundColor: const Color(0xFF2C1A0E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        setState(() => _applyingPromo = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(data['message'] ?? 'Invalid code',
                    style: GoogleFonts.lato()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _applyingPromo = false);
    }
  }

  String _buildOptionsSubtitle(dynamic selectedOptions) {
    if (selectedOptions == null) return '';
    Map<String, dynamic> opts = {};
    if (selectedOptions is String) {
      opts = json.decode(selectedOptions);
    } else if (selectedOptions is Map) {
      opts = Map<String, dynamic>.from(selectedOptions);
    }
    final parts = <String>[];
    if (opts['size'] != null) parts.add(opts['size']);
    if (opts['temperature'] != null) parts.add(opts['temperature']);
    if (opts['sugar'] != null) parts.add('${opts['sugar']} Sugar');
    if (opts['oat_milk'] == true) parts.add('Oat Milk');
    if (opts['warmed'] == true) parts.add('Warmed');
    return parts.join(', ');
  }

  double get _finalTotal => _total - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                  const SizedBox(width: 12),
                  Text(
                    'My Cart',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C1A0E),
                    ),
                  ),
                  const Spacer(),
                  if (_itemCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1A0E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_itemCount item${_itemCount > 1 ? 's' : ''}',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body ──────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2C1A0E)))
                  : _items.isEmpty
                      ? _buildEmptyCart()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          children: [
                            // Cart items
                            ..._items.map((item) => _buildCartItem(item)),
                            const SizedBox(height: 20),

                            // Promo code
                            _buildPromoSection(),
                            const SizedBox(height: 20),

                            // Order summary
                            _buildOrderSummary(),
                          ],
                        ),
            ),

            // ── Checkout Button ───────────────────────────
            if (!_isLoading && _items.isNotEmpty)
              Container(
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutPage(
                          items: _items,
                          subtotal: _subtotal,
                          tax: _tax,
                          discount: _discount,
                          promoCodeId: _appliedPromo?['id'],
                        ),
                      ),
                    ).then((_) => _loadCart()); // reload cart when coming back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C1A0E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Checkout',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final price = double.parse(item['item_price'].toString());
    final qty = item['quantity'] as int;
    final subtitle = _buildOptionsSubtitle(item['selected_options']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item['image_url'] ?? '',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFF0E8D8),
                child: const Icon(Icons.coffee,
                    color: Color(0xFF7A6652)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['product_name'] ?? item['name'] ?? '',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C1A0E),
                        ),
                      ),
                    ),
                    // Remove button
                    GestureDetector(
                      onTap: () => _removeItem(item['id']),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFB0A090),
                      ),
                    ),
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: const Color(0xFF7A6652),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB87333),
                      ),
                    ),
                    // Quantity stepper
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _updateQuantity(item['id'], qty - 1),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E8D8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.remove,
                                size: 14,
                                color: Color(0xFF2C1A0E)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          child: Text(
                            '$qty',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C1A0E),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _updateQuantity(item['id'], qty + 1),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C1A0E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promo Code',
          style: GoogleFonts.lato(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C1A0E),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                enabled: _appliedPromo == null,
                decoration: InputDecoration(
                  hintText: 'Enter code',
                  hintStyle: GoogleFonts.lato(
                      color: const Color(0xFFB0A090)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0D5C5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0D5C5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF2C1A0E), width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0D5C5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  suffixIcon: _appliedPromo != null
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF2E7D52))
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _appliedPromo != null
                  ? () {
                      setState(() {
                        _appliedPromo = null;
                        _discount = 0;
                        _promoController.clear();
                      });
                    }
                  : _applyingPromo
                      ? null
                      : _applyPromo,
              style: ElevatedButton.styleFrom(
                backgroundColor: _appliedPromo != null
                    ? const Color(0xFFF0E8D8)
                    : const Color(0xFF2C1A0E),
                foregroundColor: _appliedPromo != null
                    ? const Color(0xFF7A6652)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _applyingPromo
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _appliedPromo != null ? 'Remove' : 'Apply',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal',
              '\$${_subtotal.toStringAsFixed(2)}', false),
          const SizedBox(height: 10),
          _summaryRow(
              'Taxes & Fees', '\$${_tax.toStringAsFixed(2)}', false),
          if (_discount > 0) ...[
            const SizedBox(height: 10),
            _summaryRow(
              'Discount (${_appliedPromo?['code']})',
              '-\$${_discount.toStringAsFixed(2)}',
              false,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 10),
          _summaryRow('Delivery Fee', 'FREE', false,
              isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE0D5C5)),
          ),
          _summaryRow(
            'Total',
            '\$${_finalTotal.toStringAsFixed(2)}',
            true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isBold,
      {bool isFree = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: isBold ? 16 : 14,
            fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF2C1A0E),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: isBold ? 16 : 14,
            fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w400,
            color: isFree
                ? const Color(0xFFB87333)
                : isDiscount
                    ? const Color(0xFF2E7D52)
                    : const Color(0xFF2C1A0E),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: const Color(0xFF7A6652),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some drinks to get started!',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: const Color(0xFFB0A090),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C1A0E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Browse Menu',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}