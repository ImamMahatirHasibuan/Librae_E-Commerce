import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _notifications = [
    _NotifItem(
      icon: Icons.local_offer_outlined,
      iconBg: Color(0xFF1E2D4E),
      title: 'Flash Sale!',
      subtitle: "Diskon hingga 70% hari ini! Jangan sampai ketinggalan.",
      time: '1 jam lalu',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.local_shipping_outlined,
      iconBg: Color(0xFF1E2D4E),
      title: 'Pesanan Dikirim',
      subtitle: 'Pesanan #1234 kamu sedang dalam perjalanan.',
      time: '2 jam lalu',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.person_outline,
      iconBg: Color(0xFF1E2D4E),
      title: 'Selamat datang di Librae!',
      subtitle: 'Terima kasih telah bergabung bersama kami.',
      time: '1 hari lalu',
      isRead: true,
    ),
    _NotifItem(
      icon: Icons.star_outline,
      iconBg: Color(0xFF1E2D4E),
      title: 'Beri Ulasan',
      subtitle: 'Bagaimana pengalaman belanja kamu? Berikan ulasan.',
      time: '2 hari lalu',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF1E2D4E),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in _notifications) {
                    n.isRead = true;
                  }
                });
              },
              child: const Text(
                'Tandai semua',
                style: TextStyle(
                    color: Color(0xFF1E2D4E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (ctx, i) => _buildCard(i),
            ),
    );
  }

  Widget _buildCard(int index) {
    final notif = _notifications[index];
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            Text('Hapus',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      onDismissed: (_) {
        setState(() => _notifications.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            backgroundColor: const Color(0xFF1E2D4E),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => notif.isRead = true),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notif.isRead
                ? Colors.white
                : const Color(0xFF1E2D4E).withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: !notif.isRead
                ? Border.all(
                    color: const Color(0xFF1E2D4E).withOpacity(0.15))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: notif.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(notif.icon, color: Colors.white, size: 22),
            ),
            title: Text(
              notif.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    notif.isRead ? FontWeight.w600 : FontWeight.bold,
                color: const Color(0xFF1E2D4E),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                notif.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notif.time,
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 6),
                if (!notif.isRead)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E2D4E),
                      shape: BoxShape.circle,
                    ),
                  ),
                if (notif.isRead)
                  const Icon(Icons.arrow_forward_ios,
                      size: 11, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D4E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_none_outlined,
                size: 40, color: Color(0xFF1E2D4E)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2D4E),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String time;
  bool isRead;

  _NotifItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
  });
}