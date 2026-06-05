import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  Timer? _refreshTimer;

  final List<Map<String, dynamic>> _steps = [
    {
      'status': 'placed',
      'label': 'Order Placed',
      'sublabel': 'Waiting for store confirmation',
      'icon': Icons.access_time,
    },
    {
      'status': 'confirmed',
      'label': 'Order Confirmed',
      'sublabel': 'Store accepted your order',
      'icon': Icons.check_circle_outline,
    },
    {
      'status': 'preparing',
      'label': 'Preparing',
      'sublabel': 'Barista is crafting your drink',
      'icon': Icons.coffee,
    },
    {
      'status': 'delivery',
      'label': 'On the Way',
      'sublabel': 'Your order is out for delivery',
      'icon': Icons.delivery_dining,
    },
    {
      'status': 'pickup',
      'label': 'Ready for Pickup',
      'sublabel': 'Your order is ready at the counter',
      'icon': Icons.store,
    },
    {
      'status': 'completed',
      'label': 'Completed',
      'sublabel': 'Enjoy your order!',
      'icon': Icons.favorite,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadOrder(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse('${ApiConstants.orders}/${widget.orderId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _order = data;
          _items =
              List<Map<String, dynamic>>.from(data['items'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Get relevant steps based on fulfillment type
  List<Map<String, dynamic>> get _relevantSteps {
    final fulfillment = _order?['fulfillment_type'] ?? 'pickup';
    return _steps.where((step) {
      // Skip delivery step for pickup orders
      if (step['status'] == 'delivery' && fulfillment == 'pickup') {
        return false;
      }
      // Skip pickup step for delivery orders
      if (step['status'] == 'pickup' && fulfillment == 'delivery') {
        return false;
      }
      return true;
    }).toList();
  }

  int get _currentStepIndex {
    final status = _order?['status'] ?? 'placed';
    final steps = _relevantSteps;
    final index = steps.indexWhere((s) => s['status'] == status);
    return index == -1 ? 0 : index;
  }

  String get _headerText {
    final status = _order?['status'] ?? 'placed';
    switch (status) {
      case 'placed':
        return 'Waiting for confirmation...';
      case 'confirmed':
        return 'Order confirmed!';
      case 'preparing':
        return 'Preparing your coffee...';
      case 'delivery':
        return 'On the way!';
      case 'pickup':
        return 'Ready for pickup!';
      case 'completed':
        return 'Enjoy your coffee!';
      default:
        return 'Processing your order...';
    }
  }

  String get _estimatedTimeText {
    final status = _order?['status'] ?? 'placed';
    switch (status) {
      case 'placed':
        return 'Waiting for store to confirm';
      case 'confirmed':
        return 'Estimated ready in 15–20 mins';
      case 'preparing':
        return 'Ready in 10–15 mins';
      case 'delivery':
        return 'Estimated delivery in 20–30 mins';
      case 'pickup':
        return 'Ready at the counter now!';
      default:
        return '';
    }
  }

  String _buildOptionsSubtitle(dynamic selectedOptions) {
    if (selectedOptions == null) return '';
    Map<String, dynamic> opts = {};
    if (selectedOptions is String) {
      try {
        opts = json.decode(selectedOptions);
      } catch (_) {
        return '';
      }
    } else if (selectedOptions is Map) {
      opts = Map<String, dynamic>.from(selectedOptions);
    }
    final parts = <String>[];
    if (opts['size'] != null) parts.add(opts['size']);
    if (opts['temperature'] != null) parts.add(opts['temperature']);
    if (opts['oat_milk'] == true) parts.add('Oat Milk');
    if (opts['warmed'] == true) parts.add('Warmed');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2C1A0E),
                ),
              )
            : Column(
                children: [
                  // ── Header ──────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                                  color: Colors.black
                                      .withValues(alpha: 0.08),
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
                          'Bean & Brew',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _loadOrder,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF2C1A0E),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadOrder,
                      color: const Color(0xFF2C1A0E),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                            20, 0, 20, 20),
                        children: [
                          // ── Status Header ────────────
                          Text(
                            _headerText,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C1A0E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_estimatedTimeText.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: Color(0xFF7A6652),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _estimatedTimeText,
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: const Color(0xFF7A6652),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),

                          // ── Status Stepper ───────────
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: List.generate(
                                _relevantSteps.length,
                                (index) => _buildStepItem(index),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Order Summary ────────────
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ORDER SUMMARY',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF7A6652),
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: const Color(0xFF7A6652),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ..._items.map((item) {
                                  final price = double.parse(
                                      item['item_price'].toString());
                                  final qty = item['quantity'] as int;
                                  final subtitle =
                                      _buildOptionsSubtitle(
                                          item['selected_options']);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFFF0E8D8),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                          ),
                                          child: const Icon(
                                            Icons.coffee,
                                            color: Color(0xFF7A6652),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                item['name'] ?? '',
                                                style:
                                                    GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: const Color(
                                                      0xFF2C1A0E),
                                                ),
                                              ),
                                              if (subtitle.isNotEmpty)
                                                Text(
                                                  subtitle,
                                                  style:
                                                      GoogleFonts.lato(
                                                    fontSize: 11,
                                                    color: const Color(
                                                        0xFF7A6652),
                                                  ),
                                                ),
                                              Text(
                                                'x$qty',
                                                style:
                                                    GoogleFonts.lato(
                                                  fontSize: 11,
                                                  color: const Color(
                                                      0xFF7A6652),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(price * qty).toStringAsFixed(2)}',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                const Color(0xFF2C1A0E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(
                                    color: Color(0xFFE0D5C5)),
                                const SizedBox(height: 8),
                                _summaryRow(
                                  'Subtotal',
                                  '\$${double.parse(_order?['subtotal'].toString() ?? '0').toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 6),
                                _summaryRow(
                                  'Tax',
                                  '\$${double.parse(_order?['tax'].toString() ?? '0').toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 6),
                                _summaryRow(
                                  'Total',
                                  '\$${double.parse(_order?['total'].toString() ?? '0').toStringAsFixed(2)}',
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Help Button ──────────────
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFE0D5C5)),
                              minimumSize:
                                  const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Need help with your order?',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: const Color(0xFF2C1A0E),
                                fontWeight: FontWeight.w600,
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

      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            if (index != 2) Navigator.pop(context);
          },
          selectedItemColor: const Color(0xFFB87333),
          unselectedItemColor: const Color(0xFF7A6652),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.lato(fontWeight: FontWeight.w600),
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

  Widget _buildStepItem(int index) {
    final steps = _relevantSteps;
    final step = steps[index];
    final currentIndex = _currentStepIndex;
    final isCompleted = index < currentIndex;
    final isActive = index == currentIndex;
    final isLast = index == steps.length - 1;

    Color dotColor;
    if (isCompleted) {
      dotColor = const Color(0xFF2E7D52);
    } else if (isActive) {
      dotColor = const Color(0xFF2C1A0E);
    } else {
      dotColor = const Color(0xFFE0D5C5);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot + line
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? dotColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check,
                        size: 14, color: Colors.white)
                    : isActive
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? const Color(0xFF2E7D52)
                    : const Color(0xFFE0D5C5),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Step text
        Padding(
          padding:
              EdgeInsets.only(top: 4, bottom: isLast ? 0 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['label'] as String,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isCompleted
                      ? const Color(0xFFB0A090)
                      : isActive
                          ? const Color(0xFF2C1A0E)
                          : const Color(0xFFB0A090),
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: const Color(0xFFB0A090),
                ),
              ),
              if (isActive)
                Text(
                  step['sublabel'] as String,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: const Color(0xFF7A6652),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: isBold ? 15 : 13,
            fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF2C1A0E),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: isBold ? 15 : 13,
            fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF2C1A0E),
          ),
        ),
      ],
    );
  }
}