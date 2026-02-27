import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = int(os.getenv('DB_PORT', '5432'))
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_NAME = os.getenv('DB_NAME', 'fashionhub')

conn = psycopg2.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD,
    dbname=DB_NAME,
    port=DB_PORT
)

c = conn.cursor()

# Cek berapa produk yang ada
c.execute("SELECT COUNT(*) FROM products")
count = c.fetchone()[0]
print(f"Jumlah produk saat ini: {count}")

if count == 0:
    print("Menambahkan produk demo...")
    
    demo_products = [
        ('Urban Denim Jacket', 'Jaket denim premium untuk gaya street', 599000, 'Jacket', 50, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400', 4.5),
        ('Classic White T-Shirt', 'Kaos putih basic berkualitas tinggi', 299000, 'T-Shirt', 100, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400', 4.8),
        ('Night Party Dress', 'Dress elegant untuk acara malam', 899000, 'Dress', 30, 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=400', 4.7),
        ('Smart Casual Blazer', 'Blazer formal untuk kantor', 750000, 'Jacket', 40, 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400', 4.6),
        ('Sporty Track Pants', 'Celana olahraga nyaman', 350000, 'Pants', 80, 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400', 4.4),
        ('Leather Handbag', 'Tas kulit premium untuk wanita', 1200000, 'Accessories', 25, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400', 4.9),
        ('Summer Floral Dress', 'Dress cantik motif bunga', 450000, 'Dress', 60, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=400', 4.6),
        ('Casual Sneakers', 'Sepatu casual untuk sehari-hari', 550000, 'Shoes', 45, 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400', 4.5),
    ]
    
    for product in demo_products:
        c.execute('''INSERT INTO products (name, description, price, category, stock, image_url, rating)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)''', product)
        print(f"  ✓ Added: {product[0]}")
    
    conn.commit()
    print(f"\n✅ Berhasil menambahkan {len(demo_products)} produk!")
else:
    print("Produk sudah ada di database")
    c.execute("SELECT id, name, price, category FROM products LIMIT 5")
    products = c.fetchall()
    print("\nContoh produk:")
    for p in products:
        print(f"  - ID: {p[0]}, Nama: {p[1]}, Harga: {p[2]}, Kategori: {p[3]}")

c.close()
conn.close()
