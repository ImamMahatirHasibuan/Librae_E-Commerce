"""
FashionHub Backend API
- Authentication (Login/Register)
- Product Management
- Image Upload
- Payment Gateway (Midtrans)
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import psycopg2
import psycopg2.extras
import jwt
import datetime
import os
import uuid

app = Flask(__name__)
CORS(app)

load_dotenv()

# Configurations
app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
app.config['UPLOAD_FOLDER'] = 'uploads/products'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = int(os.getenv('DB_PORT', '5432'))
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_NAME = os.getenv('DB_NAME', 'fashionhub')

# Create upload folder if not exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_db():
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        dbname=DB_NAME,
        port=DB_PORT
    )

def ensure_database():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            dbname='postgres',
            port=DB_PORT
        )
        conn.autocommit = True
        c = conn.cursor()
        c.execute(f"SELECT 1 FROM pg_database WHERE datname = '{DB_NAME}'")
        if not c.fetchone():
            c.execute(f"CREATE DATABASE {DB_NAME}")
        c.close()
        conn.close()
    except Exception as e:
        print(f"Database creation error: {e}")

def init_db():
    """Initialize database with tables"""
    ensure_database()
    conn = get_db()
    c = conn.cursor()
    
    # Table: users
    c.execute('''CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        full_name VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''')
    
    # Table: products
    c.execute('''CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(12,2) NOT NULL,
        category VARCHAR(100) NOT NULL,
        stock INT DEFAULT 0,
        image_url VARCHAR(255),
        rating DECIMAL(3,2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''')
    
    # Table: orders
    c.execute('''CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        total_amount DECIMAL(12,2) NOT NULL,
        status VARCHAR(30) DEFAULT 'pending',
        payment_method VARCHAR(50),
        payment_status VARCHAR(30) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id)
    )''')
    
    # Table: order_items
    c.execute('''CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INT NOT NULL,
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        price DECIMAL(12,2) NOT NULL,
        FOREIGN KEY(order_id) REFERENCES orders(id),
        FOREIGN KEY(product_id) REFERENCES products(id)
    )''')
    
    # Insert demo products
    demo_products = [
        ('Urban Denim Jacket', 'Jaket denim premium untuk gaya street', 599000, 'Jacket', 50, 'denim-jacket.jpg', 4.5),
        ('Classic White T-Shirt', 'Kaos putih basic berkualitas tinggi', 299000, 'T-Shirt', 100, 'white-tshirt.jpg', 4.8),
        ('Night Party Dress', 'Dress elegant untuk acara malam', 899000, 'Dress', 30, 'party-dress.jpg', 4.7),
        ('Smart Casual Blazer', 'Blazer formal untuk kantor', 750000, 'Jacket', 40, 'blazer.jpg', 4.6),
        ('Sporty Track Pants', 'Celana olahraga nyaman', 350000, 'Pants', 80, 'track-pants.jpg', 4.4),
    ]
    
    try:
        for product in demo_products:
            c.execute('''INSERT INTO products (name, description, price, category, stock, image_url, rating)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT DO NOTHING''', product)
    except Exception as e:
        print(f"Product insert warning: {e}")
    
    conn.commit()
    conn.close()
    print("[OK] Database initialized successfully!")

# Initialize database on startup
init_db()

# ==================== AUTHENTICATION ENDPOINTS ====================

def create_token(user_id, email):
    """Create JWT token"""
    payload = {
        'user_id': user_id,
        'email': email,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
    }
    return jwt.encode(payload, app.config['SECRET_KEY'], algorithm='HS256')

def verify_token(token):
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
        return payload
    except:
        return None

@app.route('/api/auth/register', methods=['POST'])
def register():
    """Register new user"""
    data = request.json
    email = data.get('email')
    password = data.get('password')
    full_name = data.get('full_name')
    phone = data.get('phone', '')
    
    if not email or not password or not full_name:
        return jsonify({'error': 'Email, password, and full name required'}), 400
    
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    # Check if email exists
    c.execute('SELECT id FROM users WHERE email = %s', (email,))
    if c.fetchone():
        conn.close()
        return jsonify({'error': 'Email already registered'}), 400
    
    # Hash password and insert user
    hashed_password = generate_password_hash(password)
    c.execute('INSERT INTO users (email, password, full_name, phone) VALUES (%s, %s, %s, %s) RETURNING id',
              (email, hashed_password, full_name, phone))
    user_id = c.fetchone()['id']
    conn.commit()
    conn.close()
    
    token = create_token(user_id, email)
    
    return jsonify({
        'message': 'Registration successful',
        'token': token,
        'user': {
            'id': user_id,
            'email': email,
            'full_name': full_name
        }
    }), 201

@app.route('/api/auth/login', methods=['POST'])
def login():
    """User login"""
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({'error': 'Email and password required'}), 400
    
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    c.execute('SELECT * FROM users WHERE email = %s', (email,))
    user = c.fetchone()
    conn.close()
    
    if not user or not check_password_hash(user['password'], password):
        return jsonify({'error': 'Invalid email or password'}), 401
    
    token = create_token(user['id'], user['email'])
    
    return jsonify({
        'message': 'Login successful',
        'token': token,
        'user': {
            'id': user['id'],
            'email': user['email'],
            'full_name': user['full_name'],
            'phone': user['phone']
        }
    })

# ==================== PRODUCTS ENDPOINTS ====================

@app.route('/api/products', methods=['GET'])
def get_products():
    """Get all products with optional filters"""
    category = request.args.get('category')
    search = request.args.get('search')
    
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    query = 'SELECT * FROM products WHERE 1=1'
    params = []
    
    if category:
        query += ' AND category = %s'
        params.append(category)
    
    if search:
        query += ' AND (name LIKE %s OR description LIKE %s)'
        params.extend([f'%{search}%', f'%{search}%'])
    
    query += ' ORDER BY created_at DESC'
    
    c.execute(query, tuple(params))
    products = c.fetchall()
    conn.close()
    
    return jsonify(products)

@app.route('/api/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get single product by ID"""
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    c.execute('SELECT * FROM products WHERE id = %s', (product_id,))
    product = c.fetchone()
    conn.close()
    
    if not product:
        return jsonify({'error': 'Product not found'}), 404
    
    return jsonify(product)

@app.route('/api/products', methods=['POST'])
def create_product():
    """Create new product (Admin only)"""
    # TODO: Add authentication check for admin
    data = request.json
    
    required_fields = ['name', 'price', 'category']
    if not all(field in data for field in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400
    
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    c.execute('''INSERT INTO products (name, description, price, category, stock, image_url, rating)
                 VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id''',
              (data['name'], data.get('description', ''), data['price'], 
               data['category'], data.get('stock', 0), data.get('image_url', ''), 
               data.get('rating', 0)))
    product_id = c.fetchone()['id']
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Product created', 'id': product_id}), 201

@app.route('/api/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Update product (Admin only)"""
    # TODO: Add authentication check for admin
    data = request.json
    
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    update_fields = []
    params = []
    
    for field in ['name', 'description', 'price', 'category', 'stock', 'image_url', 'rating']:
        if field in data:
            update_fields.append(f'{field} = %s')
            params.append(data[field])
    
    if not update_fields:
        return jsonify({'error': 'No fields to update'}), 400
    
    params.append(product_id)
    query = f"UPDATE products SET {', '.join(update_fields)} WHERE id = %s"
    
    c.execute(query, tuple(params))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Product updated'})

@app.route('/api/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Delete product (Admin only)"""
    # TODO: Add authentication check for admin
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    c.execute('DELETE FROM products WHERE id = %s', (product_id,))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Product deleted'})

# ==================== IMAGE UPLOAD ENDPOINTS ====================

@app.route('/api/upload', methods=['POST'])
def upload_image():
    """Upload product image"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type. Allowed: png, jpg, jpeg, gif, webp'}), 400
    
    # Generate unique filename
    ext = file.filename.rsplit('.', 1)[1].lower()
    filename = f"{uuid.uuid4()}.{ext}"
    
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)
    
    # Return URL
    image_url = f"/api/images/{filename}"
    
    return jsonify({
        'message': 'Image uploaded successfully',
        'image_url': image_url,
        'filename': filename
    }), 201

@app.route('/api/images/<filename>')
def get_image(filename):
    """Serve uploaded images"""
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ==================== ORDERS ENDPOINTS ====================

@app.route('/api/orders', methods=['POST'])
def create_order():
    """Create new order"""
    # TODO: Add authentication to get user_id from token
    data = request.json
    user_id = data.get('user_id')  # In production, get from JWT token
    items = data.get('items', [])
    payment_method = data.get('payment_method', 'credit_card')
    
    if not items:
        return jsonify({'error': 'No items in order'}), 400
    
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    # Calculate total
    total_amount = 0
    for item in items:
        c.execute('SELECT price FROM products WHERE id = %s', (item['product_id'],))
        product = c.fetchone()
        if product:
            total_amount += float(product['price']) * item['quantity']
    
    # Create order
    c.execute('''INSERT INTO orders (user_id, total_amount, payment_method)
                 VALUES (%s, %s, %s) RETURNING id''', (user_id, total_amount, payment_method))
    order_id = c.fetchone()['id']
    
    # Add order items
    for item in items:
        c.execute('SELECT price FROM products WHERE id = %s', (item['product_id'],))
        product = c.fetchone()
        if product:
                c.execute('''INSERT INTO order_items (order_id, product_id, quantity, price)
                                VALUES (%s, %s, %s, %s)''',
                     (order_id, item['product_id'], item['quantity'], product['price']))
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'message': 'Order created',
        'order_id': order_id,
        'total_amount': total_amount
    }), 201

@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    """Get order details"""
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    c.execute('SELECT * FROM orders WHERE id = %s', (order_id,))
    order = c.fetchone()
    
    if not order:
        conn.close()
        return jsonify({'error': 'Order not found'}), 404
    
    # Get order items
    c.execute('''SELECT oi.*, p.name, p.image_url 
                 FROM order_items oi 
                 JOIN products p ON oi.product_id = p.id 
                 WHERE oi.order_id = %s''', (order_id,))
    items = c.fetchall()
    conn.close()
    
    order_dict = dict(order)
    order_dict['items'] = items
    
    return jsonify(order_dict)

# ==================== PAYMENT ENDPOINTS ====================

@app.route('/api/payment/midtrans', methods=['POST'])
def create_midtrans_payment():
    """Create Midtrans payment (Snap)"""
    # This is a simplified example. In production, use Midtrans SDK
    # pip install midtransclient
    
    data = request.json
    order_id = data.get('order_id')
    
    # TODO: Integrate with Midtrans
    # import midtransclient
    # snap = midtransclient.Snap(
    #     is_production=False,
    #     server_key='YOUR_SERVER_KEY'
    # )
    
    # For now, return mock response
    return jsonify({
        'message': 'Payment initiated',
        'payment_url': 'https://app.sandbox.midtrans.com/snap/v1/...',
        'transaction_token': 'mock-token-12345'
    })

@app.route('/api/payment/callback', methods=['POST'])
def payment_callback():
    """Handle payment callback from Midtrans"""
    data = request.json
    order_id = data.get('order_id')
    transaction_status = data.get('transaction_status')
    
    # Update order payment status
    conn = get_db()
    c = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    payment_status = 'paid' if transaction_status == 'settlement' else 'failed'
    c.execute('UPDATE orders SET payment_status = %s, status = %s WHERE id = %s',
              (payment_status, 'processing' if payment_status == 'paid' else 'cancelled', order_id))
    
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Payment status updated'})

# ==================== HEALTH CHECK ====================

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'OK', 'message': 'FashionHub API is running'})

if __name__ == '__main__':
    flask_host = os.getenv('FLASK_HOST', '0.0.0.0')
    flask_port = int(os.getenv('FLASK_PORT', '5000'))
    flask_debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    
    print("[START] Starting FashionHub Backend API...")
    print(f"[URL] Running at http://{flask_host}:{flask_port}")
    print("[INFO] Untuk akses dari laptop lain, gunakan IP address Anda:")
    print("[INFO] http://<YOUR_IP>:5000")
    print("[INFO] Endpoints:")
    print("   - POST /api/auth/register - Register user")
    print("   - POST /api/auth/login - Login user")
    print("   - GET  /api/products - Get all products")
    print("   - POST /api/products - Create product")
    print("   - POST /api/upload - Upload image")
    print("   - POST /api/orders - Create order")
    print("   - POST /api/payment/midtrans - Initialize payment")
    app.run(debug=flask_debug, host=flask_host, port=flask_port)
