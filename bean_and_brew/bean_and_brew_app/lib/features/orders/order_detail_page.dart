import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadOrder();
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = date.hour > 12
          ? date.hour - 12
          : date.hour == 0
              ? 12
              : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $period';
    } catch (e) {
      return dateStr;
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

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'google_pay':
        return 'Google Pay';
      case 'visa':
        return 'Visa •••• 4242';
      case 'cash':
        return 'Cash at Counter';
      default:
        return method;
    }
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
                          'Order Receipt',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, 20),
                      children: [
                        // ── Completed Badge ──────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Color(0xFF2E7D52),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _order?['status'] == 'cancelled'
                                      ? 'Order Cancelled'
                                      : 'Order Completed',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E7D52),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            _formatDate(
                                _order?['placed_at'] ?? ''),
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: const Color(0xFF7A6652),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Order Info ───────────────
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              _infoRow(
                                'Order ID',
                                '#${widget.orderId.substring(0, 8).toUpperCase()}',
                              ),
                              const Divider(
                                  color: Color(0xFFE0D5C5),
                                  height: 20),
                              _infoRow(
                                'Fulfillment',
                                _order?['fulfillment_type'] ==
                                        'pickup'
                                    ? 'Pickup'
                                    : 'Delivery',
                              ),
                              const Divider(
                                  color: Color(0xFFE0D5C5),
                                  height: 20),
                              _infoRow(
                                'Payment',
                                _getPaymentLabel(
                                    _order?['payment_method'] ??
                                        ''),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Items ────────────────────
                        Text(
                          'ITEMS',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7A6652),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                            children: _items.map((item) {
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
                                        color:
                                            const Color(0xFFF0E8D8),
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
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['name']} x$qty',
                                            style: GoogleFonts.lato(
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
                                              style: GoogleFonts.lato(
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
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Price Summary ────────────
                        Text(
                          'PRICE SUMMARY',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7A6652),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              _summaryRow(
                                'Subtotal',
                                '\$${double.parse(_order?['subtotal'].toString() ?? '0').toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 8),
                              _summaryRow(
                                'Tax',
                                '\$${double.parse(_order?['tax'].toString() ?? '0').toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 8),
                              _summaryRow(
                                'Delivery Fee',
                                double.parse(_order?['delivery_fee']
                                                .toString() ??
                                            '0') ==
                                        0
                                    ? 'FREE'
                                    : '\$${double.parse(_order?['delivery_fee'].toString() ?? '0').toStringAsFixed(2)}',
                                valueColor:
                                    const Color(0xFFB87333),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Divider(
                                    color: Color(0xFFE0D5C5)),
                              ),
                              _summaryRow(
                                'Total',
                                '\$${double.parse(_order?['total'].toString() ?? '0').toStringAsFixed(2)}',
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 13,
            color: const Color(0xFF7A6652),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C1A0E),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
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
            color: valueColor ?? const Color(0xFF2C1A0E),
          ),
        ),
      ],
    );
  }
}