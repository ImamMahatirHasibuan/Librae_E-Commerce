/// Server Configuration
/// 
/// Ubah SERVER_IP sesuai IP address laptop server Anda
/// Cek IP address dengan: ipconfig (di command prompt)
/// Cari "IPv4 Address", misal: 192.168.1.100

class ServerConfig {
  // ============ UBAH INI SESUAI IP LAPTOP ANDA ============
  // Untuk akses lokal (laptop yang sama): 127.0.0.1
  // Untuk akses network lain: gunakan IP address, misal 192.168.1.100
  static const String SERVER_IP = '192.168.20.31'; // ← IP Anda
  // ========================================================
  
  static const int SERVER_PORT = 5000;
  static const String API_VERSION = 'api';
  
  /// Build full base URL
  static String get baseUrl => 'http://$SERVER_IP:$SERVER_PORT/$API_VERSION';
  
  /// Build image URL
  static String getImageUrl(String filename) {
    if (filename.isEmpty) return '';
    if (filename.startsWith('http')) return filename;
    return 'http://$SERVER_IP:$SERVER_PORT/$API_VERSION/images/$filename';
  }
  
  /// Informasi untuk user
  static String get serverInfo => '''
SERVER CONFIGURATION
IP Address: $SERVER_IP
Port: $SERVER_PORT
API URL: $baseUrl

Untuk testing di laptop lain:
1. Jalankan backend: python app.py
2. Cari IP address: ipconfig
3. Update SERVER_IP di file ini
4. Jalankan Flutter: flutter run -d chrome
5. Akses dari laptop lain: http://<IP_ANDA>:5000
''';
}
