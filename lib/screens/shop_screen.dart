import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'productdetail_screen.dart';

class ShopScreen extends StatefulWidget {
  final String? filterCategory;
  const ShopScreen({super.key, this.filterCategory});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedFilter = 'All';
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _pollingTimer;
  List<Product> _products = [];
  bool _isLoading = true;
  String? _loadError;

  final _filters = ['All', 'New', 'Popular', 'Price ↑'];

  @override
  void initState() {
    super.initState();
    // Default ke null (Semua) agar produk muncul
    _selectedCategory = widget.filterCategory;
    _loadProducts();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30), // Polling setiap 30 detik (lebih efisien)
      (_) => _loadProducts(showLoading: false),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final data = await ApiService.getProducts();
      print('[DEBUG] Raw data from API: ${data.length} products');
      
      final products = <Product>[];
      for (var p in data) {
        try {
          final imageUrl = (p['image_url'] ?? '').toString();
          final id = int.tryParse(p['id'].toString()) ?? 0;
          
          final product = Product(
            id: p['id'].toString(),
            name: (p['name'] ?? '').toString(),
            price: double.tryParse(p['price'].toString()) ?? 0.0,
            imageUrl: imageUrl.isEmpty
                ? 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'
                : ApiService.getImageUrl(imageUrl),
            category: (p['category'] ?? 'Other').toString(),
            rating: double.tryParse(p['rating'].toString()) ?? 0.0,
            isNew: id <= 30,
            isPopular: (double.tryParse(p['rating'].toString()) ?? 0.0) >= 4.5,
          );
          products.add(product);
        } catch (e) {
          print('[ERROR] Failed to parse product: $e');
          print('[ERROR] Product data: $p');
        }
      }
      
      print('[DEBUG] Successfully processed ${products.length} products');
      if (products.isNotEmpty) {
        print('[DEBUG] First product: ${products.first.name}');
      }

      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
        _loadError = null;
      });
      
      print('[DEBUG] Current filter: $_selectedFilter');
      print('[DEBUG] Filtered products: ${_filteredProducts.length}');
    } catch (e) {
      print('[ERROR] Load products failed: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Gagal memuat produk';
      });
    }
  }

  List<Product> get _filteredProducts {
    List<Product> list = _products;
    
    print('[FILTER] Total products: ${list.length}');
    print('[FILTER] Selected category: $_selectedCategory');
    print('[FILTER] Selected filter: $_selectedFilter');
    print('[FILTER] Search query: "$_searchQuery"');

    // Category filter
    if (_selectedCategory != null && _selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
      print('[FILTER] After category filter: ${list.length}');
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      print('[FILTER] After search filter: ${list.length}');
    }

    // Tab filter
    switch (_selectedFilter) {
      case 'New':
        list = list.where((p) => p.isNew).toList();
        print('[FILTER] After New filter: ${list.length}');
        break;
      case 'Popular':
        list = list.where((p) => p.isPopular).toList();
        print('[FILTER] After Popular filter: ${list.length}');
        break;
      case 'Price ↑':
        list = List<Product>.from(list)
          ..sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Shop',
          style: TextStyle(
            color: Color(0xFF1E2D4E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: widget.filterCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFF1E2D4E)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Color(0xFF1E2D4E)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const WishlistScreen()),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: Color(0xFF1E2D4E)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cartProducts.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProducts.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          _buildCategoryChips(),
          _buildFilterTabs(),
          Expanded(
            child: _isLoading && _products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(_loadError ?? 'Produk tidak ditemukan',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (ctx, i) {
                      final p = _filteredProducts[i];
                      return _ShopCard(
                        product: p,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: p)),
                        ),
                        onAddCart: () {
                          setState(() => cartProducts.add(p));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${p.name} ditambahkan'),
                              backgroundColor: const Color(0xFF1E2D4E),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onWishlist: () {
                          setState(() {
                            if (wishlistProducts
                                .any((wp) => wp.id == p.id)) {
                              wishlistProducts
                                  .removeWhere((wp) => wp.id == p.id);
                            } else {
                              wishlistProducts.add(p);
                            }
                          });
                        },
                        isWishlisted: wishlistProducts
                            .any((wp) => wp.id == p.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      null,
      'Dress',
      'Jacket',
      'T-Shirt',
      'Pants',
      'Shoes',
      'Accessories'
    ];
    final labels = ['Semua', 'Dress', 'Jacket', 'T-Shirt', 'Pants', 'Shoes', 'Accessories'];

    return Container(
      color: Colors.white,
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final selected = _selectedCategory == categories[i];
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedCategory = categories[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1E2D4E)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: _filters.map((f) {
          final selected = f == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1E2D4E)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddCart;
  final VoidCallback onWishlist;
  final bool isWishlisted;

  const _ShopCard({
    required this.product,
    required this.onTap,
    required this.onAddCart,
    required this.onWishlist,
    required this.isWishlisted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_outlined,
                            color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2D4E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('NEW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onWishlist,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: isWishlisted
                              ? Colors.red
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2D4E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2D4E),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddCart,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2D4E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}