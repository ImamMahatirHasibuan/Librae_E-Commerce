-- Query untuk menghapus semua data dari database
-- Hapus order_items dulu (karena punya foreign key)
DELETE FROM order_items;

-- Hapus orders
DELETE FROM orders;

-- Hapus products
DELETE FROM products;

-- Hapus users
DELETE FROM users;

-- Cek jumlah data setelah delete
SELECT 'users' as table_name, COUNT(*) as total FROM users
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
