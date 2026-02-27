import 'package:flutter/material.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _inWishlist = false;
  String _selectedSize = 'M';
  String _selectedColor = 'Navy';
  int _qty = 1;

  final _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final _colors = ['Navy', 'Black', 'White', 'Beige'];

  void _addToCart() {
    for (int i = 0; i < _qty; i++) {
      cartProducts.add(widget.product);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} x$_qty ditambahkan ke keranjang'),
        backgroundColor: const Color(0xFF1E2D4E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
      ),
    );
  }

  void _toggleWishlist() {
    setState(() {
      _inWishlist = !_inWishlist;
      if (_inWishlist) {
        wishlistProducts.add(widget.product);
      } else {
        wishlistProducts.removeWhere((p) => p.id == widget.product.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_inWishlist
            ? '${widget.product.name} ditambahkan ke wishlist'
            : 'Dihapus dari wishlist'),
        backgroundColor: const Color(0xFF1E2D4E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _inWishlist =
        wishlistProducts.any((p) => p.id == widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: Colors.white,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF1E2D4E), size: 18),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _inWishlist
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _inWishlist
                            ? Colors.red
                            : const Color(0xFF1E2D4E),
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Color(0xFF1E2D4E), size: 20),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_outlined,
                          color: Colors.grey, size: 60),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2D4E),
                              ),
                            ),
                          ),
                          Text(
                            widget.product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2D4E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E2D4E),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('(128 ulasan)',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tersedia',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2D4E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Produk berkualitas tinggi dari bahan premium, nyaman dipakai sehari-hari. Desain modern yang cocok untuk berbagai kesempatan, mulai dari casual hingga semi-formal. Tersedia dalam berbagai pilihan ukuran dan warna.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Size
                      const Text(
                        'Ukuran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2D4E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: _sizes.map((s) {
                          final selected = s == _selectedSize;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSize = s),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1E2D4E)
                                    : Colors.white,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF1E2D4E)
                                      : Colors.grey.shade200,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF1E2D4E),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Color
                      const Text(
                        'Warna',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2D4E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((c) {
                          final selected = c == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1E2D4E)
                                    : Colors.white,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF1E2D4E)
                                      : Colors.grey.shade200,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF1E2D4E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Qty
                      Row(
                        children: [
                          const Text(
                            'Jumlah',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2D4E),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _qtyBtn(Icons.remove, () {
                                if (_qty > 1)
                                  setState(() => _qty--);
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Text(
                                  '$_qty',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2D4E),
                                  ),
                                ),
                              ),
                              _qtyBtn(Icons.add,
                                  () => setState(() => _qty++)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1E2D4E).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _inWishlist
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _inWishlist ? Colors.red : const Color(0xFF1E2D4E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2D4E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tambah ke Keranjang',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
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

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2D4E).withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1E2D4E)),
      ),
    );
  }
}