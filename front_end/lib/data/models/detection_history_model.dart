class DetectionHistoryModel {
  final String id;
  final String userId;
  final String imagePath;
  final String imageName;
  final bool isNsfw;
  final double confidence;
  final Map<String, double> predictions;
  final DateTime detectedAt;
  final String status; // 'processed', 'pending', 'failed'

  DetectionHistoryModel({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.imageName,
    required this.isNsfw,
    required this.confidence,
    required this.predictions,
    required this.detectedAt,
    this.status = 'processed',
  });

  factory DetectionHistoryModel.fromJson(Map<String, dynamic> json) {
    return DetectionHistoryModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      imagePath: json['image_path'] ?? '',
      imageName: json['image_name'] ?? '',
      isNsfw: json['is_nsfw'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      predictions: Map<String, double>.from(json['predictions'] ?? {}),
      detectedAt: DateTime.parse(
        json['detected_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'processed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'image_name': imageName,
      'is_nsfw': isNsfw,
      'confidence': confidence,
      'predictions': predictions,
      'detected_at': detectedAt.toIso8601String(),
      'status': status,
    };
  }

  DetectionHistoryModel copyWith({
    String? id,
    String? userId,
    String? imagePath,
    String? imageName,
    bool? isNsfw,
    double? confidence,
    Map<String, double>? predictions,
    DateTime? detectedAt,
    String? status,
  }) {
    return DetectionHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      imageName: imageName ?? this.imageName,
      isNsfw: isNsfw ?? this.isNsfw,
      confidence: confidence ?? this.confidence,
      predictions: predictions ?? this.predictions,
      detectedAt: detectedAt ?? this.detectedAt,
      status: status ?? this.status,
    );
  }

  String get riskLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.5) return 'Medium';
    return 'Low';
  }

  String get resultText => isNsfw ? 'NSFW Detected' : 'Safe Content';

  @override
  String toString() {
    return 'DetectionHistoryModel(id: $id, imageName: $imageName, isNsfw: $isNsfw, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectionHistoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
