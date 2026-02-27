-- Query untuk menambah products
-- Ganti nilai di dalam VALUES(...) sesuai produk Anda

-- Contoh 1: Menambah satu product
INSERT INTO products (name, description, price, category, stock, image_url, rating)
VALUES ('Black T-Shirt', 'Kaos hitam premium berkualitas tinggi', 150000, 'T-Shirt', 50, 'black-tshirt.jpg', 4.5);

-- Contoh 2: Menambah multiple products sekaligus
INSERT INTO products (name, description, price, category, stock, image_url, rating)
VALUES 
('Blue Jeans', 'Celana jeans biru classic fit', 350000, 'Pants', 30, 'blue-jeans.jpg', 4.8),
('Red Dress', 'Dress merah elegan untuk pesta', 550000, 'Dress', 20, 'red-dress.jpg', 4.7),
('White Sneakers', 'Sepatu sneaker putih casual', 450000, 'Shoes', 40, 'white-sneakers.jpg', 4.6),
('Leather Jacket', 'Jaket kulit hitam premium', 750000, 'Jacket', 15, 'leather-jacket.jpg', 4.9),
('Summer Hat', 'Topi musim panas warna krem', 85000, 'Accessories', 60, 'summer-hat.jpg', 4.3);

-- Cek total products sekarang
SELECT COUNT(*) as total_products FROM products;

-- Atau lihat semua products
SELECT * FROM products ORDER BY id DESC;
