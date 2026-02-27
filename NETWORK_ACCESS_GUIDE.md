# Panduan Akses Aplikasi dari Laptop Lain

## Langkah-Langkah Setup

### 1. **Cari IP Address Laptop Server (Yang Menjalankan Backend)**

**Di Windows Command Prompt / PowerShell:**
```powershell
ipconfig
```

Cari bagian `Ethernet adapter` atau `Wireless LAN adapter`:
```
IPv4 Address. . . . . . . . . . . : 192.168.1.100  ← CATAT INI
Subnet Mask . . . . . . . . . . . : 255.255.255.0
```

**Contoh IP yang valid:**
- `192.168.1.100`
- `192.168.0.50`
- `10.0.0.20`

---

### 2. **Update File Konfigurasi**

Edit file: `lib/config/server_config.dart`

Ubah baris ini dari:
```dart
static const String SERVER_IP = '127.0.0.1'; // lokal
```

Menjadi:
```dart
static const String SERVER_IP = '192.168.1.100'; // ganti dengan IP Anda
```

---

### 3. **Jalankan Backend Server**

**Terminal 1: Backend (Laptop Server)**
```powershell
cd C:\BelajarFlutter\aplikasi_pertama\backend
python app.py
```

Output akan menunjukkan:
```
🚀 Server running at http://0.0.0.0:5000
   Untuk akses dari laptop lain, gunakan IP address Anda:
   http://<YOUR_IP>:5000
```

---

### 4. **Jalankan Frontend Flutter**

**Terminal 2: Flutter (Laptop Server)**
```powershell
cd C:\BelajarFlutter\aplikasi_pertama
flutter run -d chrome
```

---

### 5. **Test di Laptop Server**
Aplikasi akan berjalan di browser pada `http://localhost:8080`

Pastikan:
- ✅ Login/Register berhasil
- ✅ Products muncul
- ✅ Gambar dapat ditampilkan

---

### 6. **Akses dari Laptop Lain**

**Di laptop/perangkat lain (yang sama network WiFi):**

Buka browser dan akses:
```
http://192.168.1.100:8080
```
atau sesuai IP yang Anda dapat (ganti 192.168.1.100 dengan IP server)

---

## Troubleshooting

### ❌ Aplikasi tidak bisa diakses dari laptop lain

**Solusi 1: Pastikan 2 laptop dalam 1 network WiFi**
```powershell
# Di laptop lain, test koneksi:
ping 192.168.1.100
```

Jika REPLY terima, network OK. Jika timeout, beda network.

**Solusi 2: Pastikan Backend Running**
Di laptop server, pastikan terminal menunjukkan:
```
Running on http://0.0.0.0:5000
```

**Solusi 3: Cek IP Address Benar**
```powershell
ipconfig  # Ambil IPv4 Address yang benar
```

**Solusi 4: Update ServerConfig**
```dart
// Pastikan di lib/config/server_config.dart
static const String SERVER_IP = '192.168.1.100'; // ganti dengan IP Anda
```

**Solusi 5: Hot Reload**
Setelah update ServerConfig, tekan `r` di terminal Flutter untuk hot reload.

---

## Testing Endpoint Langsung

### Test Backend API dari Browser:

**Login Test:**
```
http://192.168.1.100:5000/api/auth/login
(POST request dari Postman)
```

**Products Test:**
```
http://192.168.1.100:5000/api/products
```

**Image Test:**
```
http://192.168.1.100:5000/api/images/Black%20Regular%20Fit%20T%20Shirt%20Mockup.jpg
```

---

## Catatan Penting

1. **IP Address berubah jika restart router**
   - Solusi: Setting Static IP atau manual update ServerConfig lagi

2. **Hanya bisa akses dalam 1 WiFi network**
   - Untuk akses dari mana saja, perlu deploy ke cloud

3. **Port 5000 harus terbuka**
   - Jika blocked firewall, buka di Windows Firewall settings

4. **Jangan expose database langsung ke internet**
   - Saat ini backend sudah protected oleh API keys (pastikan di production)

---

## Quick Reference

| Komponen | Local | Network Lain |
|----------|-------|--------------|
| Backend | http://127.0.0.1:5000 | http://192.168.1.100:5000 |
| Frontend | http://localhost:8080 | http://192.168.1.100:8080 |
| IMAGE API | /api/images/file.jpg | http://192.168.1.100:5000/api/images/file.jpg |
| ServerConfig | 127.0.0.1 | 192.168.1.100 |

---

**Pertanyaan?** Silakan tanya di sini! 👍
