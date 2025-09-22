import '../app_data.dart';
import '../models/models.dart';

/// Service untuk mengelola data aplikasi
/// Menyediakan akses ke berbagai data yang dibutuhkan aplikasi
class DataService {
  // Instance singleton
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  /// Mendapatkan semua data riwayat deteksi
  /// Return: List DetectionHistoryModel
  List<DetectionHistoryModel> getAllDetectionHistory() {
    return List.from(AppData.detectionHistory);
  }

  /// Mendapatkan riwayat deteksi berdasarkan user ID
  /// Parameter:
  /// - userId: ID pengguna
  /// Return: List DetectionHistoryModel untuk user tersebut
  List<DetectionHistoryModel> getDetectionHistoryByUserId(String userId) {
    return AppData.getDetectionHistoryByUserId(userId);
  }

  /// Mendapatkan riwayat deteksi hari ini
  /// Parameter:
  /// - userId: ID pengguna
  /// Return: List DetectionHistoryModel hari ini
  List<DetectionHistoryModel> getTodayDetectionHistory(String userId) {
    final today = DateTime.now();
    return AppData.getDetectionHistoryByUserId(userId).where((detection) {
      return detection.detectionDate.day == today.day &&
             detection.detectionDate.month == today.month &&
             detection.detectionDate.year == today.year;
    }).toList();
  }

  /// Mendapatkan deteksi berdasarkan status
  /// Parameter:
  /// - userId: ID pengguna
  /// - status: Status deteksi ('safe', 'unsafe', 'reviewed')
  /// Return: List DetectionHistoryModel dengan status tertentu
  List<DetectionHistoryModel> getDetectionByStatus(String userId, String status) {
    return AppData.getDetectionHistoryByUserId(userId)
        .where((detection) => detection.status == status)
        .toList();
  }

  /// Mendapatkan deteksi gambar yang tidak aman
  /// Parameter:
  /// - userId: ID pengguna
  /// Return: List DetectionHistoryModel yang tidak aman
  List<DetectionHistoryModel> getUnsafeDetections(String userId) {
    return AppData.getDetectionHistoryByUserId(userId)
        .where((detection) => detection.isNsfw)
        .toList();
  }

  /// Mendapatkan deteksi gambar yang aman
  /// Parameter:
  /// - userId: ID pengguna
  /// Return: List DetectionHistoryModel yang aman
  List<DetectionHistoryModel> getSafeDetections(String userId) {
    return AppData.getDetectionHistoryByUserId(userId)
        .where((detection) => !detection.isNsfw)
        .toList();
  }

  /// Mendapatkan detail deteksi berdasarkan ID
  /// Parameter:
  /// - detectionId: ID deteksi
  /// Return: DetectionHistoryModel atau null
  DetectionHistoryModel? getDetectionById(String detectionId) {
    try {
      return AppData.detectionHistory.firstWhere(
        (detection) => detection.id == detectionId
      );
    } catch (e) {
      return null;
    }
  }

  /// Simulasi menambah deteksi baru
  /// Parameter:
  /// - userId: ID pengguna
  /// - imageName: Nama file gambar
  /// - imagePath: Path gambar
  /// - nsfwScore: Skor NSFW (0.0 - 1.0)
  /// Return: DetectionHistoryModel yang baru dibuat
  DetectionHistoryModel addNewDetection({
    required String userId,
    required String imageName,
    required String imagePath,
    required double nsfwScore,
  }) {
    final newDetection = DetectionHistoryModel(
      id: 'detection_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      imagePath: imagePath,
      imageName: imageName,
      nsfwScore: nsfwScore,
      isNsfw: nsfwScore > 0.5, // Threshold untuk NSFW
      detectionDate: DateTime.now(),
      status: nsfwScore > 0.5 ? 'unsafe' : 'safe',
    );

    // Untuk simulasi, kita tambahkan ke data statis
    AppData.detectionHistory.add(newDetection);

    return newDetection;
  }

  /// Mendapatkan statistik deteksi untuk user
  /// Parameter:
  /// - userId: ID pengguna
  /// Return: Map berisi statistik
  Map<String, dynamic> getDetectionStats(String userId) {
    final userDetections = getDetectionHistoryByUserId(userId);
    final safeCount = userDetections.where((d) => !d.isNsfw).length;
    final unsafeCount = userDetections.where((d) => d.isNsfw).length;
    final todayCount = getTodayDetectionHistory(userId).length;

    double averageScore = 0.0;
    if (userDetections.isNotEmpty) {
      averageScore = userDetections
          .map((d) => d.nsfwScore)
          .reduce((a, b) => a + b) / userDetections.length;
    }

    return {
      'totalDetections': userDetections.length,
      'safeImages': safeCount,
      'unsafeImages': unsafeCount,
      'todayDetections': todayCount,
      'averageSafetyScore': averageScore,
      'safetyPercentage': userDetections.isEmpty ? 0.0 : 
          (safeCount / userDetections.length) * 100,
    };
  }

  /// Mendapatkan tips keamanan
  /// Return: List tips keamanan
  List<String> getSecurityTips() {
    return List.from(AppData.securityTips);
  }

  /// Mendapatkan tips keamanan random
  /// Parameter:
  /// - count: Jumlah tips yang diinginkan (default 3)
  /// Return: List tips keamanan acak
  List<String> getRandomSecurityTips([int count = 3]) {
    final tips = List<String>.from(AppData.securityTips);
    tips.shuffle();
    return tips.take(count).toList();
  }

  /// Simulasi pencarian deteksi berdasarkan nama file
  /// Parameter:
  /// - userId: ID pengguna
  /// - query: Query pencarian
  /// Return: List DetectionHistoryModel yang cocok
  List<DetectionHistoryModel> searchDetections(String userId, String query) {
    return AppData.getDetectionHistoryByUserId(userId)
        .where((detection) => 
            detection.imageName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Mendapatkan deteksi terbaru
  /// Parameter:
  /// - userId: ID pengguna
  /// - limit: Batas jumlah data (default 5)
  /// Return: List DetectionHistoryModel terbaru
  List<DetectionHistoryModel> getRecentDetections(String userId, [int limit = 5]) {
    final detections = AppData.getDetectionHistoryByUserId(userId);
    detections.sort((a, b) => b.detectionDate.compareTo(a.detectionDate));
    return detections.take(limit).toList();
  }
}