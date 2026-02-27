"""
Script untuk menghapus semua products dari database
"""
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = int(os.getenv('DB_PORT', '5432'))
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_NAME = os.getenv('DB_NAME', 'fashionhub')

try:
    # Connect ke database
    conn = psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        dbname=DB_NAME,
        port=DB_PORT
    )
    c = conn.cursor()
    
    # Hapus semua products
    c.execute('DELETE FROM products')
    conn.commit()
    
    print("✓ Semua products berhasil dihapus!")
    
    # Cek jumlah products yang tersisa
    c.execute('SELECT COUNT(*) FROM products')
    count = c.fetchone()[0]
    print(f"Total products sekarang: {count}")
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
