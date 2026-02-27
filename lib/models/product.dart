class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final bool isNew;
  final bool isPopular;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 4.5,
    this.isNew = false,
    this.isPopular = false,
  });

  String get formattedPrice {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp$formatted';
  }
}

// Global state lists
List<Product> wishlistProducts = [];
List<Product> cartProducts = [];

final List<Product> dummyProducts = [
  Product(
    id: '1',
    name: 'Cozy Sweater',
    price: 180000,
    imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400',
    category: 'Women',
    rating: 4.7,
    isNew: true,
  ),
  Product(
    id: '2',
    name: 'Classic Blazer',
    price: 320000,
    imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400',
    category: 'Women',
    rating: 4.8,
    isPopular: true,
  ),
  Product(
    id: '3',
    name: 'Summer Chic Dress',
    price: 299000,
    imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400',
    category: 'Women',
    rating: 4.8,
    isPopular: true,
  ),
  Product(
    id: '4',
    name: 'Denim Jacket',
    price: 350000,
    imageUrl: 'https://images.unsplash.com/photo-1551537482-f2075a1d41f2?w=400',
    category: 'Men',
    rating: 4.6,
    isNew: true,
  ),
  Product(
    id: '5',
    name: 'Elegant Long Coat',
    price: 550000,
    imageUrl: 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400',
    category: 'Women',
    rating: 4.9,
    isPopular: true,
  ),
  Product(
    id: '6',
    name: 'Vintage Sneakers',
    price: 220000,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    category: 'Shoes',
    rating: 4.5,
  ),
  Product(
    id: '7',
    name: 'Leather Bag',
    price: 450000,
    imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400',
    category: 'Accessories',
    rating: 4.7,
    isNew: true,
  ),
  Product(
    id: '8',
    name: 'Floral Blouse',
    price: 185000,
    imageUrl: 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=400',
    category: 'Women',
    rating: 4.4,
  ),
  Product(
    id: '9',
    name: 'Slim Chino Pants',
    price: 270000,
    imageUrl: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400',
    category: 'Men',
    rating: 4.3,
    isNew: true,
  ),
  Product(
    id: '10',
    name: 'Running Shoes',
    price: 395000,
    imageUrl: 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=400',
    category: 'Shoes',
    rating: 4.6,
    isPopular: true,
  ),
];