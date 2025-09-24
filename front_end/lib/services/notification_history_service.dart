import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model untuk notifikasi history
class NotificationHistoryItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final String date;
  final String type;
  final String level;
  final IconData icon;
  final Color color;
  final bool isRead;
  final String app;
  final String? action;
  final DateTime timestamp;

  NotificationHistoryItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    required this.type,
    required this.level,
    required this.icon,
    required this.color,
    required this.isRead,
    required this.app,
    this.action,
    required this.timestamp,
  });

  NotificationHistoryItem copyWith({bool? isRead}) {
    return NotificationHistoryItem(
      id: id,
      title: title,
      message: message,
      time: time,
      date: date,
      type: type,
      level: level,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
      app: app,
      action: action,
      timestamp: timestamp,
    );
  }
}

// Provider untuk daftar history notifikasi
final notificationHistoryProvider = StateNotifierProvider<
    NotificationHistoryNotifier, List<NotificationHistoryItem>>((ref) {
  return NotificationHistoryNotifier();
});

// Provider untuk NotificationHistoryService
final notificationHistoryServiceProvider =
    Provider<NotificationHistoryService>((ref) {
  return NotificationHistoryService(ref);
});

class NotificationHistoryNotifier
    extends StateNotifier<List<NotificationHistoryItem>> {
  NotificationHistoryNotifier() : super([]);

  void addNotification(NotificationHistoryItem notification) {
    state = [notification, ...state];

    // Batasi maksimal 100 notifikasi untuk mencegah masalah memori
    if (state.length > 100) {
      state = state.take(100).toList();
    }
  }

  void markAsRead(int id) {
    state = state.map((notification) {
      return notification.id == id
          ? notification.copyWith(isRead: true)
          : notification;
    }).toList();
  }

  void markAllAsRead() {
    state = state
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
  }

  void clearAll() {
    state = [];
  }

  void removeNotification(int id) {
    state = state.where((notification) => notification.id != id).toList();
  }
}

class NotificationHistoryService {
  final Ref ref;

  NotificationHistoryService(this.ref);

  /// Tambah notifikasi baru
  void addNotification({
    required String title,
    required String message,
    required String type, // 'threat', 'warning', 'info', 'success'
    required String level, // 'low', 'medium', 'high', 'critical'
    required String app,
    String? action,
  }) {
    final notification = NotificationHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: message,
      time: _formatTime(DateTime.now()),
      date: _formatDate(DateTime.now()),
      type: type,
      level: level,
      icon: _getIconForType(type),
      color: _getColorForLevel(level),
      isRead: false,
      app: app,
      action: action,
      timestamp: DateTime.now(),
    );

    ref
        .read(notificationHistoryProvider.notifier)
        .addNotification(notification);
  }

  /// Tambah notifikasi ancaman
  void addThreatNotification({
    required String threatLevel,
    required String appName,
    required String contentType,
    required String action,
  }) {
    String title;
    String message;

    switch (threatLevel) {
      case 'low':
        title = 'Deteksi Ringan';
        message = '$appName: $contentType terdeteksi';
        break;
      case 'medium':
        title = 'Peringatan Sedang';
        message = '$appName: $contentType - Waspada!';
        break;
      case 'high':
        title = 'Ancaman Tinggi';
        message = '$appName: $contentType - Segera tutup!';
        break;
      case 'critical':
        title = 'BAHAYA KRITIS!';
        message = '$appName: $contentType - NSFW TERDETEKSI!';
        break;
      default:
        title = 'Sistem Aman';
        message = 'Monitoring berjalan normal';
    }

    addNotification(
      title: title,
      message: message,
      type: 'threat',
      level: threatLevel,
      app: appName,
      action: action,
    );
  }

  /// Tambah notifikasi monitoring
  void addMonitoringNotification({required bool isActive}) {
    addNotification(
      title: isActive ? 'Monitoring Aktif' : 'Monitoring Dihentikan',
      message: isActive
          ? 'Sistem sedang memantau konten berbahaya secara real-time'
          : 'Perlindungan real-time telah dinonaktifkan',
      type: 'info',
      level: isActive ? 'medium' : 'low',
      app: 'REFLVY System',
      action: isActive ? 'Monitoring dimulai' : 'Monitoring dihentikan',
    );
  }

  /// Tambah notifikasi sukses
  void addSuccessNotification({
    required String title,
    required String message,
    required String app,
  }) {
    addNotification(
      title: title,
      message: message,
      type: 'success',
      level: 'low',
      app: app,
    );
  }

  /// Tambah notifikasi error
  void addErrorNotification({
    required String title,
    required String message,
    required String app,
  }) {
    addNotification(
      title: title,
      message: message,
      type: 'error',
      level: 'high',
      app: app,
    );
  }

  /// Tandai notifikasi sebagai dibaca
  void markAsRead(int id) {
    ref.read(notificationHistoryProvider.notifier).markAsRead(id);
  }

  /// Tandai semua notifikasi sebagai dibaca
  void markAllAsRead() {
    ref.read(notificationHistoryProvider.notifier).markAllAsRead();
  }

  /// Hapus semua notifikasi
  void clearAll() {
    ref.read(notificationHistoryProvider.notifier).clearAll();
  }

  /// Hapus notifikasi berdasarkan ID
  void removeNotification(int id) {
    ref.read(notificationHistoryProvider.notifier).removeNotification(id);
  }

  /// Dapatkan semua notifikasi
  List<NotificationHistoryItem> getAllNotifications() {
    return ref.read(notificationHistoryProvider);
  }

  /// Dapatkan jumlah notifikasi yang belum dibaca
  int getUnreadCount() {
    final notifications = ref.read(notificationHistoryProvider);
    return notifications.where((n) => !n.isRead).length;
  }

  /// Dapatkan jumlah notifikasi hari ini
  int getTodayCount() {
    final today = _formatDate(DateTime.now());
    final notifications = ref.read(notificationHistoryProvider);
    return notifications.where((n) => n.date == today).length;
  }

  /// Dapatkan jumlah notifikasi ancaman
  int getThreatCount() {
    final notifications = ref.read(notificationHistoryProvider);
    return notifications
        .where((n) => n.level == 'high' || n.level == 'critical')
        .length;
  }

  /// Helper: Format waktu
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Helper: Format tanggal
  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  /// Helper: Dapatkan ikon berdasarkan tipe
  IconData _getIconForType(String type) {
    switch (type) {
      case 'threat':
        return Icons.security;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  /// Helper: Dapatkan warna berdasarkan level
  Color _getColorForLevel(String level) {
    switch (level) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
