// Model untuk riwayat deteksi NSFW
class DetectionHistoryModel {
  final String id;
  final String userId;
  final String imagePath;
  final String imageName;
  final double nsfwScore;
  final bool isNsfw;
  final DateTime detectionDate;
  final String status; // 'safe', 'unsafe', 'reviewed'

  DetectionHistoryModel({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.imageName,
    required this.nsfwScore,
    required this.isNsfw,
    required this.detectionDate,
    this.status = 'safe',
  });

  // Konversi dari Map ke DetectionHistoryModel
  factory DetectionHistoryModel.fromMap(Map<String, dynamic> map) {
    return DetectionHistoryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imagePath: map['imagePath'] ?? '',
      imageName: map['imageName'] ?? '',
      nsfwScore: (map['nsfwScore'] ?? 0.0).toDouble(),
      isNsfw: map['isNsfw'] ?? false,
      detectionDate: DateTime.parse(map['detectionDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'safe',
    );
  }

  // Konversi dari DetectionHistoryModel ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imagePath': imagePath,
      'imageName': imageName,
      'nsfwScore': nsfwScore,
      'isNsfw': isNsfw,
      'detectionDate': detectionDate.toIso8601String(),
      'status': status,
    };
  }

  // Mendapatkan tingkat keamanan dalam bahasa Indonesia
  String get safetyLevel {
    if (nsfwScore < 0.3) return 'Aman';
    if (nsfwScore < 0.7) return 'Perlu Perhatian';
    return 'Tidak Aman';
  }

  // Mendapatkan warna berdasarkan tingkat keamanan
  String get safetyColor {
    if (nsfwScore < 0.3) return 'green';
    if (nsfwScore < 0.7) return 'orange';
    return 'red';
  }

  // Fungsi copyWith
  DetectionHistoryModel copyWith({
    String? id,
    String? userId,
    String? imagePath,
    String? imageName,
    double? nsfwScore,
    bool? isNsfw,
    DateTime? detectionDate,
    String? status,
  }) {
    return DetectionHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      imageName: imageName ?? this.imageName,
      nsfwScore: nsfwScore ?? this.nsfwScore,
      isNsfw: isNsfw ?? this.isNsfw,
      detectionDate: detectionDate ?? this.detectionDate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'DetectionHistoryModel(id: $id, imageName: $imageName, safetyLevel: $safetyLevel)';
  }
}