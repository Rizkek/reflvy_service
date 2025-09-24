import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Model untuk notifikasi
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'security', 'warning', 'info'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

// Provider untuk daftar notifikasi
final notificationsProvider = StateProvider<List<NotificationItem>>((ref) => [
      NotificationItem(
        id: '1',
        title: 'Konten NSFW Diblokir',
        message: 'Sistem berhasil memblokir 5 konten NSFW dalam 1 jam terakhir',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: 'security',
      ),
      NotificationItem(
        id: '2',
        title: 'Pemindaian Selesai',
        message:
            'Pemindaian otomatis telah selesai. Tidak ada ancaman terdeteksi.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'info',
      ),
      NotificationItem(
        id: '3',
        title: 'Peringatan Keamanan',
        message:
            'Website berbahaya terdeteksi. Akses telah diblokir untuk keamanan Anda.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        type: 'warning',
      ),
      NotificationItem(
        id: '4',
        title: 'Update Tersedia',
        message:
            'Versi terbaru aplikasi tersedia. Update untuk mendapatkan fitur terbaru.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'info',
      ),
    ]);

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((notif) => !notif.isRead).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181818)),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi',
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount belum dibaca',
                style: GoogleFonts.raleway(
                  color: const Color(0xFF979797),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => _markAllAsRead(ref),
              child: Text(
                'Tandai Semua',
                style: GoogleFonts.raleway(
                  color: const Color(0xFF3F88EB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, ref),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Text(
                  'Hapus Semua',
                  style: GoogleFonts.raleway(),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text(
                  'Pengaturan',
                  style: GoogleFonts.raleway(),
                ),
              ),
            ],
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification, ref);
              },
            ),
    );
  }

  /// Widget untuk state kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Notifikasi',
            style: GoogleFonts.raleway(
              color: const Color(0xFF181818),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua notifikasi akan muncul di sini',
            style: GoogleFonts.raleway(
              color: const Color(0xFF979797),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk item notifikasi
  Widget _buildNotificationItem(NotificationItem notification, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.withOpacity(0.2)
              : Colors.blue.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(notification.type),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: GoogleFonts.raleway(
                  color: const Color(0xFF181818),
                  fontSize: 14,
                  fontWeight:
                      notification.isRead ? FontWeight.w600 : FontWeight.w700,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3F88EB),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.raleway(
                color: const Color(0xFF979797),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification.timestamp),
              style: GoogleFonts.raleway(
                color: const Color(0xFF979797),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification, ref),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleNotificationAction(value, notification, ref),
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'mark_read',
                child: Text(
                  'Tandai Dibaca',
                  style: GoogleFonts.raleway(),
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Hapus',
                style: GoogleFonts.raleway(color: Colors.red),
              ),
            ),
          ],
          child: const Icon(
            Icons.more_vert,
            color: Color(0xFF979797),
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Widget untuk ikon notifikasi berdasarkan tipe
  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'security':
        iconData = Icons.security;
        color = Colors.green;
        break;
      case 'warning':
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case 'info':
      default:
        iconData = Icons.info;
        color = Colors.blue;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  /// Format timestamp untuk ditampilkan
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Handle tap pada notifikasi
  void _handleNotificationTap(NotificationItem notification, WidgetRef ref) {
    if (!notification.isRead) {
      _markAsRead(notification, ref);
    }

    // TODO: Navigate ke detail atau aksi yang sesuai berdasarkan tipe notifikasi
    Get.snackbar(
      'Info',
      'Detail notifikasi: ${notification.title}',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Handle aksi pada notifikasi
  void _handleNotificationAction(
      String action, NotificationItem notification, WidgetRef ref) {
    switch (action) {
      case 'mark_read':
        _markAsRead(notification, ref);
        break;
      case 'delete':
        _deleteNotification(notification, ref);
        break;
    }
  }

  /// Handle aksi menu
  void _handleMenuAction(String action, WidgetRef ref) {
    switch (action) {
      case 'clear_all':
        _clearAllNotifications(ref);
        break;
      case 'settings':
        Get.snackbar(
          'Info',
          'Pengaturan notifikasi coming soon',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        break;
    }
  }

  /// Tandai notifikasi sebagai dibaca
  void _markAsRead(NotificationItem notification, WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications = notifications.map((notif) {
      return notif.id == notification.id ? notif.copyWith(isRead: true) : notif;
    }).toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;
  }

  /// Tandai semua notifikasi sebagai dibaca
  void _markAllAsRead(WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications = notifications.map((notif) {
      return notif.copyWith(isRead: true);
    }).toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;

    Get.snackbar(
      'Info',
      'Semua notifikasi telah ditandai sebagai dibaca',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Hapus notifikasi
  void _deleteNotification(NotificationItem notification, WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications =
        notifications.where((notif) => notif.id != notification.id).toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;

    Get.snackbar(
      'Info',
      'Notifikasi dihapus',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  /// Hapus semua notifikasi
  void _clearAllNotifications(WidgetRef ref) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Hapus Semua Notifikasi',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua notifikasi?',
          style: GoogleFonts.raleway(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.raleway(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).state = [];
              Get.back();
              Get.snackbar(
                'Info',
                'Semua notifikasi telah dihapus',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.raleway(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
