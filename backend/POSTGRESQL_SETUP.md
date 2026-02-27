# Setup PostgreSQL untuk FashionHub Backend

## 1. Install PostgreSQL

Download dan install PostgreSQL dari: https://www.postgresql.org/download/windows/

Atau gunakan installer EDB: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

**Catatan:** Catat password yang Anda buat untuk user `postgres` saat instalasi.

## 2. Konfigurasi Database

Setelah instalasi, pastikan PostgreSQL service berjalan:

```powershell
# Cek status service PostgreSQL
Get-Service -Name postgresql*
```

## 3. Update File .env

Edit file `.env` dan sesuaikan dengan konfigurasi PostgreSQL Anda:

```env
# PostgreSQL Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD_HERE
DB_NAME=fashionhub
```

**Penting:** Ganti `YOUR_POSTGRES_PASSWORD_HERE` dengan password PostgreSQL yang Anda buat saat instalasi.

## 4. Install Dependencies Python

```powershell
cd backend
pip install -r requirements.txt
```

## 5. Jalankan Backend

```powershell
python app.py
```

Backend akan otomatis:
- Membuat database `fashionhub` jika belum ada
- Membuat semua tabel yang diperlukan
- Menambahkan data produk demo

## 6. Testing

Buka browser dan akses: http://localhost:5000/api/health

Seharusnya muncul response:
```json
{
  "status": "OK",
  "message": "FashionHub API is running"
}
```

## Troubleshooting

### Error: Password authentication failed

Pastikan password di file `.env` sesuai dengan password PostgreSQL Anda.

### Error: Connection refused

Pastikan PostgreSQL service sudah berjalan:
```powershell
Start-Service postgresql-x64-15  # Sesuaikan dengan versi Anda
```

### Error: database does not exist

Aplikasi akan otomatis membuat database. Jika gagal, Anda bisa membuat manual:
```sql
-- Buka psql atau pgAdmin
CREATE DATABASE fashionhub;
```

## Perbedaan dari MySQL

Migrasi dari MySQL ke PostgreSQL sudah selesai dengan perubahan:
- ✅ Driver database: `PyMySQL` → `psycopg2-binary`
- ✅ Port default: `3306` → `5432`
- ✅ Syntax SQL: `AUTO_INCREMENT` → `SERIAL`
- ✅ Timestamp handling: `DATETIME` → `TIMESTAMP`
- ✅ Cursor factory: Dictionary cursor untuk JSON response

## Tools GUI PostgreSQL (Opsional)

Untuk mempermudah management database, install salah satu:
- **pgAdmin 4** (sudah include saat install PostgreSQL)
- **DBeaver** (https://dbeaver.io/)
- **TablePlus** (https://tableplus.com/)
