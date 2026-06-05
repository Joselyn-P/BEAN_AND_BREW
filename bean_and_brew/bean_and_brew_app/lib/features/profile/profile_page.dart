import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_page.dart';

import '../menu/menu_page.dart';
import '../orders/orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _favorites = [];
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userJson = await StorageService.getUser();
      if (userJson != null) {
        setState(() {
          _user = json.decode(userJson);
          _isLoading = false;
        });
      }
      // Also load favorites
      await _loadFavorites();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse('${ApiConstants.profile}/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          _favorites =
              List<Map<String, dynamic>>.from(json.decode(res.body));
        });
      }
    } catch (e) {
      // Favorites not yet implemented — show empty
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C1A0E),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.lato(color: const Color(0xFF7A6652)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: const Color(0xFF7A6652)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text('Logout', style: GoogleFonts.lato()),
          ),
        ],
      ),
    );
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
                  // ── Header ────────────────────────────
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
                          'Profile',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C1A0E),
                          ),
                        ),
                        const Spacer(),
                        // Settings icon
                        GestureDetector(
                          onTap: () {},
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
                              Icons.settings_outlined,
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
                    child: ListView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      children: [
                        // ── Profile Info ───────────────
                        Center(
                          child: Column(
                            children: [
                              // Profile photo
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE0D5C5),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: _user?['profile_photo_url'] !=
                                        null
                                    ? ClipOval(
                                        child: Image.network(
                                          _user!['profile_photo_url'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Color(0xFF7A6652),
                                      ),
                              ),
                              const SizedBox(height: 4),
                              // Camera icon
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2C1A0E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _user?['full_name'] ?? 'User',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C1A0E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user?['email'] ?? '',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: const Color(0xFF7A6652),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Recent Favorites ───────────
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Favorites',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C1A0E),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: GoogleFonts.lato(
                                  color: const Color(0xFFB87333),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _favorites.isEmpty
                            ? Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'No favorites yet — heart a product!',
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: const Color(0xFFB0A090),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _favorites.length,
                                  itemBuilder: (context, index) {
                                    final item = _favorites[index];
                                    return Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(
                                          right: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          item['image_url'] ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  const Icon(
                                            Icons.coffee,
                                            color: Color(0xFF7A6652),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 24),

                        // ── Account & Settings ─────────
                        Text(
                          'ACCOUNT & SETTINGS',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7A6652),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSettingsRow(
                                icon: Icons.location_on_outlined,
                                label: 'Saved Addresses',
                                subtitle: 'Manage delivery addresses',
                                onTap: () {},
                              ),
                              const Divider(
                                  height: 1,
                                  color: Color(0xFFE0D5C5),
                                  indent: 56),
                              _buildSettingsRow(
                                icon: Icons.payment_outlined,
                                label: 'Payment Methods',
                                subtitle: 'Manage cards & wallets',
                                onTap: () {},
                              ),
                              const Divider(
                                  height: 1,
                                  color: Color(0xFFE0D5C5),
                                  indent: 56),
                              _buildNotificationsRow(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Help & Support ─────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildSettingsRow(
                            icon: Icons.help_outline,
                            label: 'Help & Support',
                            subtitle: 'FAQs and contact us',
                            onTap: () {},
                            showChevron: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Logout ─────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: _logout,
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            title: Text(
                              'LOGOUT',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                                letterSpacing: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Version ────────────────────
                        Center(
                          child: Text(
                            'Version 1.0.0 (Build 1)',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: const Color(0xFFB0A090),
                            ),
                          ),
                        ),
                      ],
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
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MenuPage()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              );
            }
            // index == 3 is current page, do nothing
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

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0D6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFB87333), size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C1A0E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(
          fontSize: 12,
          color: const Color(0xFF7A6652),
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right,
              color: Color(0xFFB0A090))
          : null,
    );
  }

  Widget _buildNotificationsRow() {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0D6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.notifications_outlined,
            color: Color(0xFFB87333), size: 18),
      ),
      title: Text(
        'Notifications',
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C1A0E),
        ),
      ),
      subtitle: Text(
        'Order updates & offers',
        style: GoogleFonts.lato(
          fontSize: 12,
          color: const Color(0xFF7A6652),
        ),
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (val) =>
            setState(() => _notificationsEnabled = val),
        activeColor: const Color(0xFF2C1A0E),
      ),
    );
  }
}