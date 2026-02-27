import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E2D4E),
          ),
        ),
      );
    }

    final fullName = _userData?['full_name'] ?? 'User';
    final email = _userData?['email'] ?? 'email@example.com';
    final phone = _userData?['phone'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E2D4E).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person,
                                    color: Colors.grey, size: 36),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2D4E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2D4E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Stats row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    _statItem('12', 'Pesanan'),
                    _divider(),
                    _statItem('5', 'Wishlist'),
                    _divider(),
                    _statItem('8', 'Ulasan'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Menu
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _menuItem(
                      context,
                      Icons.receipt_long_outlined,
                      'My Orders',
                      subtitle: 'Lihat riwayat pesanan',
                      onTap: () => _showOrders(context),
                    ),
                    _dividerLine(),
                    _menuItem(
                      context,
                      Icons.location_on_outlined,
                      'Alamat',
                      subtitle: 'Kelola alamat pengiriman',
                      onTap: () => _showAddress(context),
                    ),
                    _dividerLine(),
                    _menuItem(
                      context,
                      Icons.credit_card_outlined,
                      'Payment Method',
                      subtitle: 'Kartu & dompet digital',
                      onTap: () => _showPaymentMethods(context),
                    ),
                    _dividerLine(),
                    _menuItem(
                      context,
                      Icons.settings_outlined,
                      'Settings',
                      subtitle: 'Notifikasi, privasi & lainnya',
                      onTap: () => _showSettings(context),
                    ),
                    _dividerLine(),
                    _menuItem(
                      context,
                      Icons.help_outline,
                      'Help Center',
                      subtitle: 'FAQ & dukungan pelanggan',
                      onTap: () => _showHelp(context),
                    ),
                    _dividerLine(),
                    _menuItem(
                      context,
                      Icons.logout,
                      'Log Out',
                      subtitle: 'Keluar dari akun',
                      onTap: () => _showLogout(context),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Librae v1.0.0 · Own Your Style.',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2D4E),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.shade200,
    );
  }

  Widget _dividerLine() {
    return Divider(
        height: 1, indent: 72, color: Colors.grey.shade100);
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.08)
              : const Color(0xFF1E2D4E).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF1E2D4E),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : const Color(0xFF1E2D4E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 11))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: Colors.grey),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showOrders(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'My Orders',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2D4E)),
            ),
            const SizedBox(height: 16),
            _orderItem('LBR001', 'Cozy Sweater', 'Dikirim', '3 Jan 2025'),
            _orderItem('LBR002', 'Classic Blazer', 'Selesai', '1 Jan 2025'),
            _orderItem('LBR003', 'Denim Jacket', 'Selesai', '28 Des 2024'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _orderItem(
      String no, String name, String status, String date) {
    final isDelivered = status == 'Dikirim';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  no,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11),
                ),
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2D4E)),
                ),
                Text(date,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDelivered
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color:
                    isDelivered ? Colors.orange : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Alamat Pengiriman',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2D4E))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D4E).withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF1E2D4E).withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on,
                      color: Color(0xFF1E2D4E), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rumah',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2D4E))),
                        Text(
                          'Jl. Sudirman No. 123, Jakarta Pusat, 10220',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Metode Pembayaran',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2D4E))),
            const SizedBox(height: 16),
            _payMethod(Icons.credit_card, 'Visa ****1234', 'Credit Card'),
            const SizedBox(height: 10),
            _payMethod(Icons.account_balance_wallet, 'GoPay Aktif',
                'E-Wallet'),
            const SizedBox(height: 10),
            _payMethod(Icons.add_circle_outline, 'Tambah Metode Baru',
                ''),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _payMethod(IconData icon, String name, String type) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D4E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2D4E))),
          ),
          if (type.isNotEmpty)
            Text(type,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Settings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2D4E))),
            const SizedBox(height: 16),
            _settingToggle('Push Notification', true),
            _settingToggle('Email Promo', false),
            _settingToggle('Dark Mode', false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _settingToggle(String label, bool value) {
    return StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E2D4E))),
            ),
            Switch(
              value: value,
              onChanged: (v) => setState(() => value = v),
              activeColor: const Color(0xFF1E2D4E),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Help Center',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2D4E))),
            const SizedBox(height: 16),
            _helpItem('Cara melacak pesanan?'),
            _helpItem('Kebijakan pengembalian barang'),
            _helpItem('Cara menggunakan voucher'),
            _helpItem('Hubungi Customer Service'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _helpItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF1E2D4E), fontSize: 14)),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 13, color: Colors.grey),
        ],
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
              color: Color(0xFF1E2D4E), fontWeight: FontWeight.bold),
        ),
        content: const Text(
            'Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () async {
              // Clear user data and token
              await ApiService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Log Out',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}