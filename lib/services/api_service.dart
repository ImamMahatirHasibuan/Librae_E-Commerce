import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/server_config.dart';

/// API Service untuk integrasi dengan Backend FashionHub
/// 
/// Konfigurasi Server di: lib/config/server_config.dart
/// Ubah SERVER_IP sesuai IP address laptop Anda untuk akses network lain

class ApiService {
  // Gunakan konfigurasi dari ServerConfig
  static String get baseUrl => ServerConfig.baseUrl;
  
  // Get token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Save token ke SharedPreferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Save user data ke SharedPreferences
  static Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }
  
  // Get user data dari SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
  
  // Delete token dan user data (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
  
  // ==================== AUTHENTICATION ====================
  
  /// Register user baru
  /// Returns: {token, user}
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone ?? '',
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // Save token and user data
        await _saveToken(data['token']);
        await _saveUserData(data['user']);
        return data;
      } else {
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Login user
  /// Returns: {token, user}
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save token and user data
        await _saveToken(data['token']);
        await _saveUserData(data['user']);
        return data;
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // ==================== PRODUCTS ====================
  
  /// Get semua products
  /// Optional: category, search query
  static Future<List<dynamic>> getProducts({
    String? category,
    String? search,
  }) async {
    try {
      String url = '$baseUrl/products';
      
      // Add query parameters
      List<String> queryParams = [];
      if (category != null) queryParams.add('category=$category');
      if (search != null) queryParams.add('search=$search');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      print('[API] Fetching products from: $url');
      final response = await http.get(Uri.parse(url));
      print('[API] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[API] Received ${data.length} products');
        return data;
      } else {
        print('[API] Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Exception: $e');
      throw Exception('Network error: $e');
    }
  }
  
  /// Get single product by ID
  static Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Create product (Admin only)
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    required String category,
    String? description,
    int stock = 0,
    String? imageUrl,
    double rating = 0,
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'price': price,
          'category': category,
          'description': description ?? '',
          'stock': stock,
          'image_url': imageUrl ?? '',
          'rating': rating,
        }),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Update product (Admin only)
  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    String? name,
    double? price,
    String? category,
    String? description,
    int? stock,
    String? imageUrl,
    double? rating,
  }) async {
    try {
      final token = await _getToken();
      
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (price != null) body['price'] = price;
      if (category != null) body['category'] = category;
      if (description != null) body['description'] = description;
      if (stock != null) body['stock'] = stock;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (rating != null) body['rating'] = rating;
      
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Delete product (Admin only)
  static Future<void> deleteProduct(int productId) async {
    try {
      final token = await _getToken();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // ==================== IMAGE UPLOAD ====================
  
  /// Upload image file
  /// Returns: image_url yang bisa disimpan ke database
  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = jsonDecode(String.fromCharCodes(responseData));
      
      if (response.statusCode == 201) {
        return result['image_url'];
      } else {
        throw Exception(result['error'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }
  
  /// Get full image URL
  static String getImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400';
    }
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    // Gunakan ServerConfig untuk build image URL
    return ServerConfig.getImageUrl(imageUrl);
  }
  
  // ==================== ORDERS ====================
  
  /// Create new order
  /// items: [{"product_id": 1, "quantity": 2}, ...]
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required List<Map<String, int>> items,
    String paymentMethod = 'midtrans',
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'items': items,
          'payment_method': paymentMethod,
        }),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Get order details
  static Future<Map<String, dynamic>> getOrder(int orderId) async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // ==================== PAYMENT ====================
  
  /// Initialize Midtrans payment
  /// Returns: payment_url dan transaction_token
  static Future<Map<String, dynamic>> initiateMidtransPayment(int orderId) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/payment/midtrans'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'order_id': orderId}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to initiate payment');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// ==================== USAGE EXAMPLES ====================

/* 
// 1. LOGIN
try {
  final result = await ApiService.login(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Login success: ${result['user']['full_name']}');
  print('Token: ${result['token']}');
} catch (e) {
  print('Error: $e');
}

// 2. GET PRODUCTS
try {
  final products = await ApiService.getProducts();
  setState(() {
    _products = products;
  });
} catch (e) {
  print('Error: $e');
}

// 3. GET PRODUCTS BY CATEGORY
try {
  final jackets = await ApiService.getProducts(category: 'Jacket');
  print('Found ${jackets.length} jackets');
} catch (e) {
  print('Error: $e');
}

// 4. SEARCH PRODUCTS
try {
  final results = await ApiService.getProducts(search: 'denim');
  print('Found ${results.length} products');
} catch (e) {
  print('Error: $e');
}

// 5. UPLOAD IMAGE
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  try {
    final imageUrl = await ApiService.uploadImage(File(image.path));
    print('Image uploaded: $imageUrl');
    // Sekarang bisa create product dengan imageUrl ini
  } catch (e) {
    print('Error: $e');
  }
}

// 6. CREATE PRODUCT
try {
  final result = await ApiService.createProduct(
    name: 'Urban Denim Jacket',
    price: 599000,
    category: 'Jacket',
    description: 'Jaket denim premium',
    stock: 50,
    imageUrl: '/api/images/abc123.jpg',
    rating: 4.5,
  );
  print('Product created: ${result['id']}');
} catch (e) {
  print('Error: $e');
}

// 7. CREATE ORDER
try {
  final orderResult = await ApiService.createOrder(
    userId: 1,
    items: [
      {'product_id': 1, 'quantity': 2},
      {'product_id': 3, 'quantity': 1},
    ],
    paymentMethod: 'midtrans',
  );
  
  print('Order created: ${orderResult['order_id']}');
  print('Total: Rp ${orderResult['total_amount']}');
  
  // Lanjut ke payment
  final paymentResult = await ApiService.initiateMidtransPayment(
    orderResult['order_id'],
  );
  
  // Buka payment_url di WebView atau browser
  print('Payment URL: ${paymentResult['payment_url']}');
} catch (e) {
  print('Error: $e');
}

// 8. LOGOUT
await ApiService.logout();
print('User logged out');

*/
