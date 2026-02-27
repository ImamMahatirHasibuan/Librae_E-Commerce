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

# Cek jumlah user
c.execute("SELECT COUNT(*) FROM users")
count = c.fetchone()[0]
print(f"Total users: {count}\n")

# Tampilkan semua user (tanpa password)
c.execute("SELECT id, email, full_name, phone, created_at FROM users ORDER BY created_at DESC")
users = c.fetchall()

if users:
    print("Daftar Users:")
    print("-" * 80)
    for user in users:
        print(f"ID: {user[0]}")
        print(f"Email: {user[1]}")
        print(f"Name: {user[2]}")
        print(f"Phone: {user[3]}")
        print(f"Created: {user[4]}")
        print("-" * 80)
else:
    print("Belum ada user terdaftar.")

c.close()
conn.close()
