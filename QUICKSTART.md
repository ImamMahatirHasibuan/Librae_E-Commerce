# 🚀 Quick Start Guide - FashionHub Full Stack

Panduan lengkap menjalankan Backend + Flutter App untuk FashionHub.

---

## 📦 Yang Sudah Dibuat

### Backend (Python Flask)
✅ `/backend/app.py` - Main API server  
✅ `/backend/requirements.txt` - Python dependencies  
✅ `/backend/README.md` - Dokumentasi lengkap API  
✅ `/backend/.env.example` - Template konfigurasi  

### Flutter
✅ `/lib/services/api_service.dart` - Service untuk API calls  
✅ `/pubspec.yaml` - Updated dengan dependencies (http, shared_preferences, image_picker)  

---

## 🎯 Langkah 1: Setup Backend

### 1.1. Install Python Dependencies

Buka terminal di folder backend:

```bash
cd backend
pip install -r requirements.txt
```

**Dependencies yang diinstall:**
- Flask (Web framework)
- Flask-CORS (Handle CORS untuk Flutter)
- PyJWT (JSON Web Token untuk authentication)
- Werkzeug (Password hashing & file upload)

### 1.2. Setup Environment Variables (Optional)

```bash
copy .env.example .env
```

Edit `.env` jika ingin custom settings (untuk production).

### 1.3. Jalankan Backend Server

```bash
python app.py
```

**Output yang benar:**
```
✅ Database initialized successfully!
🚀 Starting FashionHub Backend API...
📍 URL: http://localhost:5000
 * Running on http://0.0.0.0:5000
```

✅ **Backend siap!** Biarkan terminal ini tetap terbuka.

---

## 🎯 Langkah 2: Setup Flutter

### 2.1. Install Flutter Dependencies

Buka terminal baru di folder root project Flutter:

```bash
flutter pub get
```

**Dependencies yang diinstall:**
- `http` - HTTP client untuk API calls
- `shared_preferences` - Local storage untuk token
- `image_picker` - Upload gambar produk

### 2.2. Update Base URL (Penting!)

Edit `lib/services/api_service.dart`:

**Jika test di Chrome (Web):**
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**Jika test di Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**Jika test di device fisik:**
```dart
static const String baseUrl = 'http://192.168.1.XXX:5000/api';
// Ganti XXX dengan IP komputer Anda
// Cara cek IP: jalankan 'ipconfig' (Windows) atau 'ifconfig' (Mac/Linux)
```

### 2.3. Jalankan Flutter App

```bash
flutter run -d chrome
```

Atau tekan **F5** di VS Code.

---

## 🧪 Langkah 3: Test API (Opsional tapi Recommended)

### Test dengan Browser

Buka browser dan akses:

```
http://localhost:5000/api/health
```

**Response yang benar:**
```json
{
  "status": "OK",
  "message": "FashionHub API is running"
}
```

### Test Get Products

```
http://localhost:5000/api/products
```

Akan menampilkan 5 demo products yang sudah ada di database.

### Test dengan Postman/Thunder Client

**1. Register User:**
```http
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "test123",
  "full_name": "Test User",
  "phone": "08123456789"
}
```

**2. Login:**
```http
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "test123"
}
```

Copy token dari response untuk request selanjutnya.

---

## 🎨 Langkah 4: Integrasi ke Flutter App

### 4.1. Contoh: Login Screen

Edit `lib/screens/login_screen.dart` atau buat baru:

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await ApiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Login berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ${result['user']['full_name']}!')),
      );
      
      // Navigate ke home
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      // Login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.2. Contoh: Load Products dari Backend

Update `lib/screens/shop_screen.dart`:

```dart
import '../services/api_service.dart';

class _ShopScreenState extends State<ShopScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          child: Column(
            children: [
              // Load image dari backend
              Image.network(
                ApiService.getImageUrl(product['image_url']),
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported),
                  );
                },
              ),
              Text(product['name']),
              Text('Rp ${product['price']}'),
            ],
          ),
        );
      },
    );
  }
}
```

### 4.3. Contoh: Upload Image

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

Future<void> _pickAndUploadImage() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image != null) {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading image...')),
      );
      
      // Upload
      final imageUrl = await ApiService.uploadImage(File(image.path));
      
      print('Image uploaded: $imageUrl');
      
      // Sekarang imageUrl bisa digunakan untuk create/update product
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }
}
```

---

## 💳 Langkah 5: Setup Payment (Midtrans)

### 5.1. Daftar Akun Midtrans

1. Kunjungi: https://midtrans.com
2. Daftar akun **Sandbox** (gratis untuk testing)
3. Login ke Dashboard
4. Copy **Server Key** dan **Client Key**

### 5.2. Update Backend

Edit `backend/.env`:
```
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxxx
MIDTRANS_IS_PRODUCTION=false
```

### 5.3. Install Midtrans SDK (Optional)

```bash
cd backend
pip install midtransclient
```

Uncomment code Midtrans di `backend/app.py` (ada di bagian payment).

### 5.4. Test Payment di Flutter

```dart
// Create order
final orderResult = await ApiService.createOrder(
  userId: currentUserId,
  items: cartItems.map((item) => {
    'product_id': item.productId,
    'quantity': item.quantity,
  }).toList(),
);

// Initiate payment
final paymentResult = await ApiService.initiateMidtransPayment(
  orderResult['order_id'],
);

// Open payment URL in WebView or InAppBrowser
// Install package: url_launcher
import 'package:url_launcher/url_launcher.dart';

final url = Uri.parse(paymentResult['payment_url']);
if (await canLaunchUrl(url)) {
  await launchUrl(url);
}
```

---

## 🐛 Troubleshooting

### Error: "Connection refused" / "Network error"

**Penyebab:** Flutter tidak bisa connect ke backend.

**Solusi:**
1. Pastikan backend running di `http://localhost:5000`
2. Cek base URL di `api_service.dart`:
   - Chrome: `http://localhost:5000/api`
   - Android Emulator: `http://10.0.2.2:5000/api`
   - Device fisik: `http://[IP-KOMPUTER]:5000/api`
3. Cek firewall tidak block port 5000
4. Cek CORS enabled di backend (sudah otomatis)

### Error: "ModuleNotFoundError: No module named 'flask'"

**Solusi:**
```bash
cd backend
pip install -r requirements.txt
```

### Error: Image tidak tampil di Flutter

**Solusi:**
1. Pastikan folder `backend/uploads/products` exist
2. Gunakan `ApiService.getImageUrl(imageUrl)` untuk convert path
3. Cek image URL di response API

### Error: "Invalid token" saat access protected endpoint

**Solusi:**
1. Login ulang untuk dapat token baru
2. Token expired (default 7 hari)
3. Pastikan `shared_preferences` menyimpan token dengan benar

---

## 📚 Next Steps

Setelah basic setup berhasil:

1. **Implement Authentication Flow**
   - Login screen
   - Register screen
   - Protected routes
   - Auto-logout saat token expired

2. **Upgrade Database**
   - Dari SQLite ke PostgreSQL untuk production
   - Add migration tool (Alembic)

3. **Add More Features**
   - Wishlist sync to backend
   - Order history
   - User profile edit
   - Product reviews & ratings

4. **Deploy to Production**
   - Backend: Heroku, Railway, DigitalOcean
   - Flutter: Build APK/iOS app
   - Setup domain & HTTPS

5. **Security Enhancements**
   - Rate limiting
   - Input validation
   - SQL injection prevention
   - XSS protection

---

## 📞 Testing Checklist

- [ ] Backend server running di port 5000
- [ ] Demo products muncul di `/api/products`
- [ ] Register user berhasil
- [ ] Login berhasil dan dapat token
- [ ] Flutter app connect ke backend
- [ ] Products load dari backend
- [ ] Upload image berhasil
- [ ] Create order berhasil
- [ ] Payment flow works (sandbox)

---

**Happy Coding! 🚀**

Jika ada error atau pertanyaan, cek:
1. Terminal backend untuk error logs
2. Flutter console untuk error messages
3. README.md di folder backend untuk API docs
