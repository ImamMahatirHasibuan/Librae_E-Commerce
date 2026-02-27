# FashionHub Backend API 🛍️

Backend API untuk aplikasi Flutter FashionHub dengan fitur lengkap:
- 🔐 Authentication (Login/Register dengan JWT)
- 📦 Product Management (CRUD)
- 🖼️ Image Upload
- 💳 Payment Gateway (Midtrans)
- 📱 Database SQLite (upgrade ke PostgreSQL untuk production)

---

## 🚀 Cara Setup & Menjalankan

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Setup Environment Variables

Copy file `.env.example` menjadi `.env`:
```bash
copy .env.example .env
```

Edit `.env` dan isi dengan konfigurasi Anda (untuk Midtrans, dll).

### 3. Jalankan Server

```bash
python app.py
```

Server akan berjalan di: **http://localhost:5000**

---

## 📍 API Endpoints

### Authentication

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "phone": "08123456789"
}
```

**Response:**
```json
{
  "message": "Registration successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe"
  }
}
```

#### Login User
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

---

### Products

#### Get All Products
```http
GET /api/products
GET /api/products?category=Jacket
GET /api/products?search=denim
```

#### Get Single Product
```http
GET /api/products/1
```

#### Create Product (Admin)
```http
POST /api/products
Content-Type: application/json

{
  "name": "Urban Denim Jacket",
  "description": "Jaket denim premium",
  "price": 599000,
  "category": "Jacket",
  "stock": 50,
  "image_url": "/api/images/abc123.jpg",
  "rating": 4.5
}
```

#### Update Product (Admin)
```http
PUT /api/products/1
Content-Type: application/json

{
  "price": 549000,
  "stock": 45
}
```

#### Delete Product (Admin)
```http
DELETE /api/products/1
```

---

### Image Upload

#### Upload Image
```http
POST /api/upload
Content-Type: multipart/form-data

file: [binary data]
```

**Response:**
```json
{
  "message": "Image uploaded successfully",
  "image_url": "/api/images/abc123-def456.jpg",
  "filename": "abc123-def456.jpg"
}
```

#### View Image
```http
GET /api/images/abc123-def456.jpg
```

---

### Orders

#### Create Order
```http
POST /api/orders
Content-Type: application/json

{
  "user_id": 1,
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    },
    {
      "product_id": 3,
      "quantity": 1
    }
  ],
  "payment_method": "midtrans"
}
```

#### Get Order Details
```http
GET /api/orders/1
```

---

### Payment

#### Initialize Midtrans Payment
```http
POST /api/payment/midtrans
Content-Type: application/json

{
  "order_id": 1
}
```

**Response:**
```json
{
  "message": "Payment initiated",
  "payment_url": "https://app.sandbox.midtrans.com/snap/v1/...",
  "transaction_token": "abc123-token"
}
```

#### Payment Callback (Webhook dari Midtrans)
```http
POST /api/payment/callback
Content-Type: application/json

{
  "order_id": "1",
  "transaction_status": "settlement"
}
```

---

## 🔧 Integrasi dengan Flutter

### 1. Install HTTP Package di Flutter

Edit `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

### 2. Buat Service Class

Buat file `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }
  
  // Get Products
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    return jsonDecode(response.body);
  }
  
  // Upload Image
  static Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var result = jsonDecode(String.fromCharCodes(responseData));
    
    return result['image_url'];
  }
}
```

### 3. Contoh Penggunaan di Widget

```dart
// Login Example
final result = await ApiService.login('user@example.com', 'password123');
if (result['token'] != null) {
  // Save token and navigate to home
  print('Login success: ${result['token']}');
}

// Get Products Example
final products = await ApiService.getProducts();
setState(() {
  _products = products;
});
```

---

## 🔐 Setup Midtrans Payment Gateway

### 1. Daftar Akun Midtrans
- Kunjungi: https://midtrans.com
- Daftar dan verifikasi akun
- Dapatkan **Server Key** dan **Client Key** dari dashboard

### 2. Install Midtrans SDK (Optional untuk advanced features)
```bash
pip install midtransclient
```

### 3. Update Code untuk Midtrans
Uncomment dan sesuaikan code Midtrans di `app.py`:

```python
import midtransclient

snap = midtransclient.Snap(
    is_production=False,
    server_key='YOUR-SERVER-KEY-HERE'
)

param = {
    "transaction_details": {
        "order_id": f"ORDER-{order_id}",
        "gross_amount": total_amount
    },
    "customer_details": {
        "email": user_email,
        "first_name": user_name
    }
}

transaction = snap.create_transaction(param)
# transaction['redirect_url'] untuk web
# transaction['token'] untuk mobile
```

---

## 📦 Database Schema

### Table: users
```sql
- id (PRIMARY KEY)
- email (UNIQUE)
- password (hashed)
- full_name
- phone
- created_at
```

### Table: products
```sql
- id (PRIMARY KEY)
- name
- description
- price
- category
- stock
- image_url
- rating
- created_at
```

### Table: orders
```sql
- id (PRIMARY KEY)
- user_id (FOREIGN KEY)
- total_amount
- status (pending/processing/completed/cancelled)
- payment_method
- payment_status (pending/paid/failed)
- created_at
```

### Table: order_items
```sql
- id (PRIMARY KEY)
- order_id (FOREIGN KEY)
- product_id (FOREIGN KEY)
- quantity
- price
```

---

## 🚀 Upgrade ke Production

### 1. Ganti SQLite dengan PostgreSQL
```bash
pip install psycopg2-binary
```

Update connection string di `app.py` atau gunakan `DATABASE_URL` dari `.env`.

### 2. Deploy ke Cloud
- **Heroku**: Mudah untuk pemula
- **Railway**: Modern dan mudah
- **DigitalOcean**: Fleksibel
- **AWS/GCP**: Untuk skala besar

### 3. Setup File Storage Cloud
- **AWS S3**: Paling populer
- **Cloudinary**: Khusus image/video
- **Google Cloud Storage**: Terintegrasi GCP

### 4. Security Checklist
- ✅ Ganti `SECRET_KEY` dengan random string
- ✅ Enable HTTPS
- ✅ Validate semua input
- ✅ Rate limiting
- ✅ Backup database regular

---

## 📝 TODO untuk Production

- [ ] Add authentication middleware untuk endpoint admin
- [ ] Implement rate limiting
- [ ] Add logging
- [ ] Add unit tests
- [ ] Setup CI/CD
- [ ] Add input validation dengan Marshmallow/Pydantic
- [ ] Implement refresh token
- [ ] Add email verification
- [ ] Add forgot password feature

---

## 🐛 Troubleshooting

**Error: ModuleNotFoundError**
```bash
pip install -r requirements.txt
```

**Error: Port already in use**
```bash
# Ganti port di app.py:
app.run(debug=True, port=5001)
```

**CORS Error dari Flutter**
- Pastikan Flutter app URL sudah ada di `CORS_ORIGINS`
- Atau set `CORS(app, origins="*")` untuk development

---

## 📞 Support

Jika ada pertanyaan atau issue:
1. Check documentation di atas
2. Lihat kode `app.py` untuk detail implementasi
3. Test endpoints dengan Postman atau curl

---

**Happy Coding! 🚀**
