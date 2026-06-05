import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import 'order_tracking_page.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiConstants.orders),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(
            json.decode(res.body),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'placed':
        return const Color(0xFF7A6652);
      case 'confirmed':
        return const Color(0xFF4285F4);
      case 'preparing':
        return const Color(0xFFB87333);
      case 'delivery':
      case 'pickup':
        return const Color(0xFF9C27B0);
      case 'completed':
        return const Color(0xFF2E7D52);
      case 'cancelled':
        return Colors.red;
      default:
        return const Color(0xFF7A6652);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'placed':
        return 'Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'delivery':
        return 'Out for Delivery';
      case 'pickup':
        return 'Ready for Pickup';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'placed':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.coffee;
      case 'delivery':
        return Icons.delivery_dining;
      case 'pickup':
        return Icons.store;
      case 'completed':
        return Icons.favorite;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long;
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
      return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  void _onOrderTap(Map<String, dynamic> order) {
    final status = order['status'] ?? 'placed';
    if (status == 'completed' || status == 'cancelled') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailPage(orderId: order['id']),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingPage(orderId: order['id']),
        ),
      ).then((_) => _loadOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2C1A0E),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Orders',
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

            // ── Body ────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2C1A0E),
                      ),
                    )
                  : _orders.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          color: const Color(0xFF2C1A0E),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_orders[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation ──────────────────────────
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'placed';
    final total = double.parse(order['total'].toString());
    final itemCount = order['item_count'] ?? 0;
    final fulfillment = order['fulfillment_type'] ?? 'pickup';
    final placedAt = _formatDate(order['placed_at'] ?? '');
    final orderId =
        (order['id'] as String).substring(0, 8).toUpperCase();
    final isCompleted =
        status == 'completed' || status == 'cancelled';

    return GestureDetector(
      onTap: () => _onOrderTap(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            // Order header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$orderId',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C1A0E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        placedAt,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: const Color(0xFF7A6652),
                        ),
                      ),
                    ],
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 12,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(status),
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE0D5C5)),

            // Order details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Icon(
                    fulfillment == 'pickup'
                        ? Icons.store
                        : Icons.delivery_dining,
                    size: 16,
                    color: const Color(0xFF7A6652),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fulfillment == 'pickup' ? 'Pickup' : 'Delivery',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: const Color(0xFF7A6652),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.coffee_outlined,
                    size: 16,
                    color: Color(0xFF7A6652),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$itemCount item${itemCount > 1 ? 's' : ''}',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: const Color(0xFF7A6652),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB87333),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action button
            Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFE0D5C5))),
              ),
              child: TextButton(
                onPressed: () => _onOrderTap(order),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                ),
                child: Text(
                  isCompleted ? 'View Receipt →' : 'Track Order →',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB87333),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: const Color(0xFF7A6652),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
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
              'Order Something',
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