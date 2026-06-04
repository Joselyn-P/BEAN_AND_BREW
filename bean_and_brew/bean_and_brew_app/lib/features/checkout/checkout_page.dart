import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double tax;
  final double discount;
  final String? promoCodeId;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.discount = 0,
    this.promoCodeId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _fulfillmentType = 'pickup';
  String _paymentMethod = 'cash';
  bool _isPlacingOrder = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'google_pay',
      'label': 'Google Pay',
      'subtitle': 'FAST & SECURE',
      'icon': Icons.g_mobiledata,
      'color': Color(0xFF4285F4),
    },
    {
      'id': 'visa',
      'label': 'Visa •••• 4242',
      'subtitle': 'Exp 12/26',
      'icon': Icons.credit_card,
      'color': Color(0xFF1A1F71),
    },
    {
      'id': 'cash',
      'label': 'Cash at Counter',
      'subtitle': 'Pay when you pick up',
      'icon': Icons.payments_outlined,
      'color': Color(0xFF7A6652),
    },
  ];

  double get _deliveryFee =>
      _fulfillmentType == 'delivery' ? 2.00 : 0.00;

  double get _finalTotal =>
      widget.subtotal + widget.tax + _deliveryFee - widget.discount;

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      final token = await StorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiConstants.orders),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fulfillment_type': _fulfillmentType,
          'payment_method': _paymentMethod,
          'address_id': null,
          'promo_code_id': widget.promoCodeId,
        }),
      );

      if (res.statusCode == 201) {
        final data = json.decode(res.body);
        // Reset cart count
        Provider.of<CartProvider>(context, listen: false).reset();

        // Navigate to order tracking
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderConfirmedPage(
              orderId: data['order_id'],
              fulfillmentType: _fulfillmentType,
              total: _finalTotal,
            ),
          ),
          (route) => route.isFirst,
        );
      } else {
        final data = json.decode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to place order',
                style: GoogleFonts.lato()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isPlacingOrder = false);
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
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
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF2C1A0E), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Checkout',
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // ── Step 1: Order Summary ──────────────
                  _buildStepHeader('1', 'Order Summary'),
                  const SizedBox(height: 12),
                  Container(
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
                        ...widget.items.map((item) {
                          final price = double.parse(
                              item['item_price'].toString());
                          final qty = item['quantity'] as int;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['image_url'] ?? '',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                      width: 48,
                                      height: 48,
                                      color: const Color(0xFFF0E8D8),
                                      child: const Icon(Icons.coffee,
                                          color: Color(0xFF7A6652),
                                          size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2C1A0E),
                                        ),
                                      ),
                                      Text(
                                        'x$qty',
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: const Color(0xFF7A6652),
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
                                    color: const Color(0xFF2C1A0E),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(color: Color(0xFFE0D5C5)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal',
                                style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: const Color(0xFF7A6652))),
                            Text(
                              '\$${widget.subtotal.toStringAsFixed(2)}',
                              style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C1A0E)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Step 2: Delivery or Pickup ─────────
                  _buildStepHeader('2', 'Delivery or Pickup'),
                  const SizedBox(height: 12),
                  Container(
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
                        // Toggle
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F0E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: ['pickup', 'delivery'].map((type) {
                                final selected = _fulfillmentType == type;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _fulfillmentType = type),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.08),
                                                  blurRadius: 4,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        type == 'pickup'
                                            ? 'Pickup'
                                            : 'Delivery',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: selected
                                              ? const Color(0xFF2C1A0E)
                                              : const Color(0xFF7A6652),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Store / Address info
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0D6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _fulfillmentType == 'pickup'
                                      ? Icons.store
                                      : Icons.location_on,
                                  color: const Color(0xFFB87333),
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
                                      _fulfillmentType == 'pickup'
                                          ? 'Bean & Brew • Downtown'
                                          : 'Delivery Address',
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2C1A0E),
                                      ),
                                    ),
                                    Text(
                                      _fulfillmentType == 'pickup'
                                          ? 'Ready in 10–15 mins'
                                          : 'Add your delivery address',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: const Color(0xFF7A6652),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Change',
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: const Color(0xFFB87333),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Step 3: Payment Method ─────────────
                  _buildStepHeader('3', 'Payment Method'),
                  const SizedBox(height: 12),
                  Container(
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
                      children: _paymentMethods.map((method) {
                        final selected = _paymentMethod == method['id'];
                        final isLast = method == _paymentMethods.last;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                  () => _paymentMethod = method['id']),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F0E8),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        method['icon'] as IconData,
                                        color: method['color'] as Color,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            method['label'] as String,
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  const Color(0xFF2C1A0E),
                                            ),
                                          ),
                                          Text(
                                            method['subtitle'] as String,
                                            style: GoogleFonts.lato(
                                              fontSize: 11,
                                              color:
                                                  const Color(0xFF7A6652),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<String>(
                                      value: method['id'] as String,
                                      groupValue: _paymentMethod,
                                      onChanged: (val) => setState(
                                          () => _paymentMethod = val!),
                                      activeColor:
                                          const Color(0xFF2C1A0E),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                  height: 1,
                                  color: Color(0xFFE0D5C5),
                                  indent: 16,
                                  endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Fee Summary ────────────────────────
                  Container(
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
                        _feeRow('Subtotal',
                            '\$${widget.subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _feeRow('Taxes & Fees',
                            '\$${widget.tax.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _feeRow(
                          'Delivery Fee',
                          _fulfillmentType == 'delivery'
                              ? '\$${_deliveryFee.toStringAsFixed(2)}'
                              : 'FREE',
                          valueColor: const Color(0xFFB87333),
                        ),
                        if (widget.discount > 0) ...[
                          const SizedBox(height: 8),
                          _feeRow(
                            'Discount',
                            '-\$${widget.discount.toStringAsFixed(2)}',
                            valueColor: const Color(0xFF2E7D52),
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFE0D5C5)),
                        ),
                        _feeRow(
                          'Total',
                          '\$${_finalTotal.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Security note ──────────────────────
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 12, color: Color(0xFFB0A090)),
                        const SizedBox(width: 4),
                        Text(
                          'SECURED WITH 256-BIT SSL ENCRYPTION',
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: const Color(0xFFB0A090),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Place Order Button ─────────────────────
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
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C1A0E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Place Order — \$${_finalTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF2C1A0E),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C1A0E),
          ),
        ),
      ],
    );
  }

  Widget _feeRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF2C1A0E),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: valueColor ?? const Color(0xFF2C1A0E),
          ),
        ),
      ],
    );
  }
}

// ── Order Confirmed Page ─────────────────────────────
class OrderConfirmedPage extends StatelessWidget {
  final String orderId;
  final String fulfillmentType;
  final double total;

  const OrderConfirmedPage({
    super.key,
    required this.orderId,
    required this.fulfillmentType,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1A0E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Confirmed!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C1A0E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fulfillmentType == 'pickup'
                    ? 'Your order is being prepared.\nReady in 10–15 mins!'
                    : 'Your order is on its way!',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: const Color(0xFF7A6652),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Order #${orderId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C1A0E),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB87333),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C1A0E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // TODO: navigate to order tracking
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2C1A0E)),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Track My Order',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C1A0E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}