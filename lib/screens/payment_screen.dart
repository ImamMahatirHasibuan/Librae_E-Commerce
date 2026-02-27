import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import 'ordersuccess_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentMethod;
  final IconData paymentIcon;
  final double total;

  const PaymentScreen({
    super.key,
    required this.paymentMethod,
    required this.paymentIcon,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  // Credit Card fields
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  String _fmt(double v) {
    final s = v.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp$s';
  }

  bool get _isCreditCard => widget.paymentMethod == 'Credit Card';
  bool get _isBankTransfer => widget.paymentMethod == 'Bank Transfer';
  bool get _isEWallet => widget.paymentMethod == 'E-Wallet';
  bool get _isCOD => widget.paymentMethod == 'COD';

  void _processPayment() async {
    // Validation for credit card
    if (_isCreditCard) {
      if (_cardNumberCtrl.text.length < 16 ||
          _cardNameCtrl.text.isEmpty ||
          _expiryCtrl.text.length < 5 ||
          _cvvCtrl.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi data kartu'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    if (!mounted) return;

    // Clear cart after successful payment
    cartProducts.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          paymentMethod: widget.paymentMethod,
          total: widget.total,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pembayaran - ${widget.paymentMethod}',
          style: const TextStyle(
            color: Color(0xFF1E2D4E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E2D4E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Payment header card
            _buildPaymentHeader(),
            const SizedBox(height: 20),
            // Payment form based on method
            if (_isCreditCard) _buildCreditCardForm(),
            if (_isBankTransfer) _buildBankTransfer(),
            if (_isEWallet) _buildEWallet(),
            if (_isCOD) _buildCOD(),
            const SizedBox(height: 20),
            // Order total
            _buildTotalCard(),
            const SizedBox(height: 30),
            // Pay button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2D4E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF1E2D4E).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Memproses pembayaran...',
                              style: TextStyle(fontSize: 15)),
                        ],
                      )
                    : Text(
                        _isCOD
                            ? 'Konfirmasi Pesanan'
                            : 'Bayar ${_fmt(widget.total)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Transaksi aman & terenkripsi',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D4E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(widget.paymentIcon,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.paymentMethod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2D4E),
                ),
              ),
              Text(
                'Total: ${_fmt(widget.total)}',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview card
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E2D4E), Color(0xFF3A5080)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LIBRAE PAY',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2),
                    ),
                    const Icon(Icons.credit_card,
                        color: Colors.white70, size: 28),
                  ],
                ),
                Text(
                  _cardNumberCtrl.text.isEmpty
                      ? '•••• •••• •••• ••••'
                      : _formatCardDisplay(_cardNumberCtrl.text),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NAMA',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 10)),
                        Text(
                          _cardNameCtrl.text.isEmpty
                              ? 'NAMA PEMILIK'
                              : _cardNameCtrl.text.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BERLAKU SAMPAI',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 10)),
                        Text(
                          _expiryCtrl.text.isEmpty
                              ? 'MM/YY'
                              : _expiryCtrl.text,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nomor Kartu',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2D4E),
                fontSize: 13),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _cardNumberCtrl,
            hint: '1234 5678 9012 3456',
            inputType: TextInputType.number,
            maxLen: 16,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nama Pemilik Kartu',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2D4E),
                fontSize: 13),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _cardNameCtrl,
            hint: 'Nama sesuai kartu',
            inputType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Kadaluarsa',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E2D4E),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _expiryCtrl,
                      hint: 'MM/YY',
                      inputType: TextInputType.number,
                      maxLen: 5,
                      formatters: [_ExpiryFormatter()],
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CVV',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E2D4E),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _cvvCtrl,
                      hint: '•••',
                      inputType: TextInputType.number,
                      maxLen: 3,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      obscure: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransfer() {
    final banks = [
      {'name': 'BCA', 'no': '1234567890', 'an': 'PT Librae Indonesia'},
      {'name': 'BNI', 'no': '0987654321', 'an': 'PT Librae Indonesia'},
      {'name': 'Mandiri', 'no': '1122334455', 'an': 'PT Librae Indonesia'},
    ];

    return Column(
      children: banks.map((bank) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D4E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    bank['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2D4E),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank ${bank['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2D4E),
                        fontSize: 14,
                      ),
                    ),
                    Text(bank['no']!,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E2D4E))),
                    Text('a/n ${bank['an']}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: bank['no']!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No. rekening ${bank['name']} disalin'),
                      backgroundColor: const Color(0xFF1E2D4E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.copy,
                    size: 18, color: Color(0xFF1E2D4E)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEWallet() {
    final wallets = [
      {'name': 'GoPay', 'no': '+62 812-3456-7890', 'color': Color(0xFF00A651)},
      {'name': 'OVO', 'no': '+62 812-3456-7890', 'color': Color(0xFF6B42E8)},
      {'name': 'Dana', 'no': '+62 812-3456-7890', 'color': Color(0xFF118EEA)},
    ];

    return Column(
      children: wallets.map((w) {
        final color = w['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    w['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2D4E),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Nomor: ${w['no']}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: w['no'] as String));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Nomor ${w['name']} disalin'),
                      backgroundColor: const Color(0xFF1E2D4E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.copy,
                    size: 18, color: Color(0xFF1E2D4E)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCOD() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D4E).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.money,
                size: 36, color: Color(0xFF1E2D4E)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bayar di Tempat (COD)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2D4E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Siapkan uang tunai saat kurir tiba. Pastikan kamu ada di lokasi pengiriman.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.orange, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Harap siapkan uang pas sejumlah ${_fmt(widget.total)}',
                    style: const TextStyle(
                        color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D4E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            _fmt(widget.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
    int? maxLen,
    List<TextInputFormatter>? formatters,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        maxLength: maxLen,
        inputFormatters: formatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          counterText: '',
        ),
        style: const TextStyle(
            color: Color(0xFF1E2D4E), fontSize: 14),
      ),
    );
  }

  String _formatCardDisplay(String text) {
    final digits = text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    // Pad with bullets
    final result = buffer.toString();
    final groups = result.split(' ');
    final padded = groups.map((g) {
      return g + '•' * (4 - g.length);
    });
    return padded.join(' ');
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final text = next.text.replaceAll('/', '');
    if (text.length >= 3) {
      final result = '${text.substring(0, 2)}/${text.substring(2)}';
      return next.copyWith(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }
    return next;
  }
}