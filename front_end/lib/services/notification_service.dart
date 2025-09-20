import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Provider untuk NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider untuk status permission notifikasi
final notificationPermissionProvider = StateProvider<bool>((ref) => false);

// Provider untuk status inisialisasi notifikasi
final notificationInitializedProvider = StateProvider<bool>((ref) => false);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi service notifikasi
  Future<void> initialize() async {
    // Konfigurasi untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Konfigurasi untuk iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inisialisasi plugin notifikasi
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle ketika notifikasi di-tap
        _handleNotificationTap(response);
      },
    );

    // Minta permission untuk notifikasi
    await _requestPermissions();
  }

  /// Meminta permission notifikasi dari user
  Future<void> _requestPermissions() async {
    // Minta permission notifikasi
    await Permission.notification.request();

    // Untuk Android 13+, minta permission POST_NOTIFICATIONS
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Handle ketika notifikasi di-tap
  void _handleNotificationTap(NotificationResponse response) {
    print('Notifikasi di-tap: ${response.payload}');
    // TODO: Implementasi navigasi berdasarkan payload
  }

  /// Tampilkan notifikasi instan
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'instant_notifications',
      'Notifikasi Instan',
      channelDescription: 'Notifikasi real-time untuk deteksi ancaman',
      importance: importance,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Tampilkan notifikasi ancaman berdasarkan level
  Future<void> showThreatNotification({
    required String threatLevel,
    required String appName,
    required String contentType,
  }) async {
    String title;
    String body;
    Importance importance;
    Priority priority;

    // Tentukan pesan berdasarkan level ancaman
    switch (threatLevel) {
      case 'low':
        title = '⚠️ Deteksi Ringan';
        body = '$appName: $contentType terdeteksi';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case 'medium':
        title = '🔶 Peringatan Sedang';
        body = '$appName: $contentType - Waspada!';
        importance = Importance.high;
        priority = Priority.high;
        break;
      case 'high':
        title = '🔴 Ancaman Tinggi';
        body = '$appName: $contentType - Segera tutup!';
        importance = Importance.max;
        priority = Priority.max;
        break;
      case 'critical':
        title = '🚨 BAHAYA KRITIS!';
        body = '$appName: $contentType - NSFW TERDETEKSI!';
        importance = Importance.max;
        priority = Priority.max;
        break;
      default:
        title = '✅ Sistem Aman';
        body = 'Monitoring berjalan normal';
        importance = Importance.low;
        priority = Priority.low;
    }

    // Simpan ke riwayat notifikasi - akan dihandle oleh provider yang memanggil

    // Buat channel notifikasi khusus untuk ancaman
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'threat_notifications',
      'Peringatan Ancaman',
      channelDescription: 'Notifikasi peringatan deteksi ancaman kritis',
      importance: importance,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'REFLVY Security',
      ),
      color: Color(_getThreatColor(threatLevel) ?? 0xFF10B981),
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: 'threat:$threatLevel:$appName',
    );
  }

  /// Tampilkan notifikasi status monitoring
  Future<void> showMonitoringStatusNotification({
    required bool isActive,
  }) async {
    String title =
        isActive ? '🛡️ Monitoring Aktif' : '⏹️ Monitoring Dihentikan';
    String body = isActive
        ? 'Sistem sedang memantau konten berbahaya secara real-time'
        : 'Perlindungan real-time telah dinonaktifkan';

    // Simpan ke riwayat notifikasi - akan dihandle oleh provider yang memanggil

    await showInstantNotification(
      title: title,
      body: body,
      importance: isActive ? Importance.defaultImportance : Importance.low,
      priority: isActive ? Priority.defaultPriority : Priority.low,
      payload: 'monitoring:${isActive ? 'started' : 'stopped'}',
    );
  }

  /// Tampilkan notifikasi sukses
  Future<void> showSuccessNotification({
    required String title,
    required String message,
  }) async {
    await showInstantNotification(
      title: '✅ $title',
      body: message,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      payload: 'success',
    );
  }

  /// Tampilkan notifikasi error
  Future<void> showErrorNotification({
    required String title,
    required String message,
  }) async {
    await showInstantNotification(
      title: '❌ $title',
      body: message,
      importance: Importance.high,
      priority: Priority.high,
      payload: 'error',
    );
  }

  /// Tampilkan notifikasi info
  Future<void> showInfoNotification({
    required String title,
    required String message,
  }) async {
    await showInstantNotification(
      title: 'ℹ️ $title',
      body: message,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      payload: 'info',
    );
  }

  /// Helper method untuk mendapatkan warna berdasarkan level ancaman
  int? _getThreatColor(String threatLevel) {
    switch (threatLevel) {
      case 'low':
        return 0xFF10B981; // Hijau
      case 'medium':
        return 0xFFEA580C; // Oranye
      case 'high':
        return 0xFFDC2626; // Merah
      case 'critical':
        return 0xFF7C3AED; // Ungu
      default:
        return 0xFF10B981; // Hijau
    }
  }

  /// Batalkan semua notifikasi
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Batalkan notifikasi berdasarkan ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cek apakah permission notifikasi sudah diberikan
  Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Minta permission notifikasi
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
