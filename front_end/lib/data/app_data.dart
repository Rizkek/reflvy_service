import 'models/models.dart';

/// Data statis untuk aplikasi REFLVY
/// Berisi data dummy yang akan digunakan untuk simulasi aplikasi
class AppData {
  // Data pengguna tetap untuk login
  static final UserModel defaultUser = UserModel(
    id: 'user_001',
    username: 'reflvy_user',
    email: 'user@reflvy.com',
    password: 'reflvy123', // Password default untuk demo
    firstName: 'Reflvy',
    lastName: 'User',
    profileImage: 'assets/images/default_profile.png',
    createdAt: DateTime(2024, 1, 1),
    lastLogin: DateTime.now(),
  );

  // Data riwayat deteksi untuk demo
  static List<DetectionHistoryModel> get detectionHistory => [
    DetectionHistoryModel(
      id: 'detection_001',
      userId: defaultUser.id,
      imagePath: 'assets/images/sample1.jpg',
      imageName: 'foto_keluarga.jpg',
      nsfwScore: 0.15,
      isNsfw: false,
      detectionDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'safe',
    ),
    DetectionHistoryModel(
      id: 'detection_002',
      userId: defaultUser.id,
      imagePath: 'assets/images/sample2.jpg',
      imageName: 'gambar_profil.jpg',
      nsfwScore: 0.05,
      isNsfw: false,
      detectionDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'safe',
    ),
    DetectionHistoryModel(
      id: 'detection_003',
      userId: defaultUser.id,
      imagePath: 'assets/images/sample3.jpg',
      imageName: 'konten_media.jpg',
      nsfwScore: 0.85,
      isNsfw: true,
      detectionDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'unsafe',
    ),
    DetectionHistoryModel(
      id: 'detection_004',
      userId: defaultUser.id,
      imagePath: 'assets/images/sample4.jpg',
      imageName: 'avatar_sosmed.jpg',
      nsfwScore: 0.25,
      isNsfw: false,
      detectionDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'safe',
    ),
    DetectionHistoryModel(
      id: 'detection_005',
      userId: defaultUser.id,
      imagePath: 'assets/images/sample5.jpg',
      imageName: 'foto_liburan.jpg',
      nsfwScore: 0.02,
      isNsfw: false,
      detectionDate: DateTime.now().subtract(const Duration(days: 3)),
      status: 'safe',
    ),
  ];

  // Data notifikasi untuk demo
  static List<NotificationModel> get notifications => [
    NotificationModel(
      id: 'notif_001',
      userId: defaultUser.id,
      title: 'Deteksi Selesai',
      message: 'Gambar "foto_keluarga.jpg" telah dianalisis dan dinyatakan aman.',
      type: 'detection',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      additionalData: {'detectionId': 'detection_001'},
    ),
    NotificationModel(
      id: 'notif_002',
      userId: defaultUser.id,
      title: 'Konten Tidak Aman Terdeteksi',
      message: 'Gambar "konten_media.jpg" mengandung konten yang tidak pantas. Silakan periksa kembali.',
      type: 'security',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      additionalData: {'detectionId': 'detection_003'},
    ),
    NotificationModel(
      id: 'notif_003',
      userId: defaultUser.id,
      title: 'Selamat Datang di REFLVY',
      message: 'Terima kasih telah bergabung dengan REFLVY. Mari lindungi privasi digital Anda!',
      type: 'system',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      additionalData: null,
    ),
    NotificationModel(
      id: 'notif_004',
      userId: defaultUser.id,
      title: 'Update Sistem',
      message: 'Sistem deteksi NSFW telah diperbarui untuk akurasi yang lebih baik.',
      type: 'system',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      additionalData: null,
    ),
    NotificationModel(
      id: 'notif_005',
      userId: defaultUser.id,
      title: 'Analisis Bulanan',
      message: 'Anda telah memproses 25 gambar bulan ini dengan tingkat keamanan 95%.',
      type: 'detection',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      additionalData: {'totalImages': 25, 'safetyRate': 95},
    ),
  ];

  // Statistik untuk dashboard
  static Map<String, dynamic> get dashboardStats => {
    'totalDetections': detectionHistory.length,
    'safeImages': detectionHistory.where((d) => !d.isNsfw).length,
    'unsafeImages': detectionHistory.where((d) => d.isNsfw).length,
    'todayDetections': detectionHistory.where((d) => 
      d.detectionDate.day == DateTime.now().day &&
      d.detectionDate.month == DateTime.now().month &&
      d.detectionDate.year == DateTime.now().year
    ).length,
    'unreadNotifications': notifications.where((n) => !n.isRead).length,
    'averageSafetyScore': detectionHistory.isEmpty ? 0.0 : 
      detectionHistory.map((d) => d.nsfwScore).reduce((a, b) => a + b) / detectionHistory.length,
  };

  // Tips keamanan untuk aplikasi
  static List<String> get securityTips => [
    'Selalu periksa gambar sebelum membagikan di media sosial',
    'Gunakan fitur analisis batch untuk memeriksa banyak gambar sekaligus',
    'Aktifkan notifikasi untuk mendapat peringatan real-time',
    'Backup data riwayat deteksi secara berkala',
    'Perbarui aplikasi secara rutin untuk fitur keamanan terbaru',
    'Jangan simpan gambar sensitif di perangkat yang mudah diakses',
    'Gunakan password yang kuat untuk akun REFLVY Anda',
    'Laporkan konten mencurigakan melalui fitur laporan',
  ];

  // Validasi login dengan data statis
  static bool validateLogin(String emailOrUsername, String password) {
    return (emailOrUsername == defaultUser.email || 
            emailOrUsername == defaultUser.username) && 
           password == defaultUser.password;
  }

  // Mendapatkan user berdasarkan email atau username
  static UserModel? getUserByEmailOrUsername(String emailOrUsername) {
    if (emailOrUsername == defaultUser.email || 
        emailOrUsername == defaultUser.username) {
      return defaultUser;
    }
    return null;
  }

  // Mendapatkan riwayat deteksi berdasarkan user ID
  static List<DetectionHistoryModel> getDetectionHistoryByUserId(String userId) {
    return detectionHistory.where((d) => d.userId == userId).toList();
  }

  // Mendapatkan notifikasi berdasarkan user ID
  static List<NotificationModel> getNotificationsByUserId(String userId) {
    return notifications.where((n) => n.userId == userId).toList();
  }

  // Mendapatkan notifikasi yang belum dibaca
  static List<NotificationModel> getUnreadNotifications(String userId) {
    return notifications.where((n) => n.userId == userId && !n.isRead).toList();
  }
}