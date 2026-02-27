import 'package:flutter/material.dart';
import '../models/product.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0;
  int _selectedShipping = 0;

  final _payments = [
    {'name': 'Credit Card', 'icon': Icons.credit_card, 'desc': 'Visa / Mastercard'},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance, 'desc': 'BCA / BNI / Mandiri'},
    {'name': 'E-Wallet', 'icon': Icons.account_balance_wallet, 'desc': 'GoPay / OVO / Dana'},
    {'name': 'COD', 'icon': Icons.money, 'desc': 'Bayar di tempat'},
  ];

  final _shippings = [
    {'name': 'JNE Reguler', 'price': 20000.0, 'eta': '3-5 hari'},
    {'name': 'JNE Express', 'price': 35000.0, 'eta': '1-2 hari'},
    {'name': 'SiCepat', 'price': 25000.0, 'eta': '2-3 hari'},
  ];

  double get _subtotal =>
      cartProducts.fold<double>(0, (sum, p) => sum + p.price);
  double get _shipping =>
      (_shippings[_selectedShipping]['price'] as double);
  double get _total => _subtotal + _shipping;

  String _fmt(double v) {
    final s = v.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp$s';
  }

  // Get unique products with qty
  Map<String, int> get _qtys {
    final map = <String, int>{};
    for (final p in cartProducts) {
      map[p.id] = (map[p.id] ?? 0) + 1;
    }
    return map;
  }

  List<Product> get _uniqueProducts {
    final seen = <String>{};
    return cartProducts.where((p) => seen.add(p.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF1E2D4E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E2D4E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection('Alamat Pengiriman', _buildAddress()),
            const SizedBox(height: 8),
            _buildSection('Item Pesanan', _buildItems()),
            const SizedBox(height: 8),
            _buildSection('Pilih Pengiriman', _buildShipping()),
            const SizedBox(height: 8),
            _buildSection('Metode Pembayaran', _buildPaymentMethods()),
            const SizedBox(height: 8),
            _buildSection('Ringkasan Pesanan', _buildOrderSummary()),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2D4E),
            ),
          ),
        ),
        Container(color: Colors.white, child: child),
      ],
    );
  }

  Widget _buildAddress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D4E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: Color(0xFF1E2D4E), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amanda B.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2D4E),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Jl. Sudirman No. 123, Jakarta Pusat, 10220',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  '+62 812-3456-7890',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Ubah',
              style: TextStyle(
                color: Color(0xFF1E2D4E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    if (_uniqueProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Tidak ada produk', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      children: _uniqueProducts.map((p) {
        final qty = _qtys[p.id] ?? 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  p.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E2D4E),
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('x$qty',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                _fmt(p.price * qty),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2D4E),
                    fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShipping() {
    return Column(
      children: List.generate(_shippings.length, (i) {
        final s = _shippings[i];
        final selected = i == _selectedShipping;
        return GestureDetector(
          onTap: () => setState(() => _selectedShipping = i),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: i < _shippings.length - 1
                    ? BorderSide(color: Colors.grey.shade100)
                    : BorderSide.none,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1E2D4E)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E2D4E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E2D4E),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Estimasi: ${s['eta']}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  _fmt(s['price'] as double),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2D4E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: List.generate(_payments.length, (i) {
        final p = _payments[i];
        final selected = i == _selectedPayment;
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = i),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF1E2D4E).withOpacity(0.04)
                  : Colors.transparent,
              border: Border(
                bottom: i < _payments.length - 1
                    ? BorderSide(color: Colors.grey.shade100)
                    : BorderSide.none,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1E2D4E)
                        : const Color(0xFF1E2D4E).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    p['icon'] as IconData,
                    color: selected ? Colors.white : const Color(0xFF1E2D4E),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E2D4E),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        p['desc'] as String,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1E2D4E)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E2D4E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          _row('Subtotal (${cartProducts.length} item)', _fmt(_subtotal)),
          const SizedBox(height: 8),
          _row(
              'Ongkos kirim (${_shippings[_selectedShipping]['name']})',
              _fmt(_shipping)),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
          _row('Total Pembayaran', _fmt(_total), bold: true),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
              Text(
                _fmt(_total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E2D4E),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        paymentMethod:
                            _payments[_selectedPayment]['name'] as String,
                        paymentIcon:
                            _payments[_selectedPayment]['icon'] as IconData,
                        total: _total,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2D4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: bold ? const Color(0xFF1E2D4E) : Colors.grey.shade600,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF1E2D4E),
          ),
        ),
      ],
    );
  }
}