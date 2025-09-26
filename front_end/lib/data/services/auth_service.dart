import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AuthService {
  // static const String _baseUrl =
  //     'http://localhost:8080/api'; // Update with your Go backend URL
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  UserModel? _currentUser;
  String? _authToken;

  // Getter untuk current user
  UserModel? get currentUser => _currentUser;

  // Constructor - load user data saat service diinisialisasi
  AuthService() {
    _loadUserData();
  }

  /// Load user data dari SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token != null && userData != null) {
        _authToken = token;
        final userJson = jsonDecode(userData);
        _currentUser = UserModel.fromJson(userJson);
      }
    } catch (e) {
      // Ignore error, user will need to login again
      print('Error loading user data: $e');
    }
  }

  /// Save user data ke SharedPreferences
  Future<void> _saveUserData(UserModel user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      _currentUser = user;
      _authToken = token;
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  /// Clear user data dari SharedPreferences
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);

      _currentUser = null;
      _authToken = null;
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  /// Login function
  Future<Map<String, dynamic>> login(
    String emailOrUsername,
    String password,
  ) async {
    try {
      // Untuk demo, gunakan mock data
      // Dalam implementasi nyata, ganti dengan API call ke backend Go
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay

      // Mock login validation
      if ((emailOrUsername == 'admin@example.com' ||
              emailOrUsername == 'admin') &&
          password == 'admin123') {
        final mockUser = UserModel(
          id: '1',
          email: 'admin@example.com',
          username: 'admin',
          firstName: 'Admin',
          lastName: 'User',
          profileImage: null,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        );

        const mockToken = 'mock_jwt_token_123456789';

        await _saveUserData(mockUser, mockToken);

        return {
          'success': true,
          'message': 'Login berhasil',
          'user': mockUser,
          'token': mockToken,
        };
      } else {
        return {
          'success': false,
          'message': 'Email/username atau password salah',
        };
      }

      // Implementasi API call yang sebenarnya (uncomment dan modify sesuai kebutuhan):
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data['user']);
        final token = data['token'];
        
        await _saveUserData(user, token);

        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'user': user,
          'token': token,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login gagal',
        };
      }
      */
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Logout function
  Future<Map<String, dynamic>> logout() async {
    try {
      // Dalam implementasi nyata, bisa menambah API call untuk invalidate token
      await _clearUserData();

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat logout: ${e.toString()}',
      };
    }
  }

  /// Get user profile
  UserModel? getProfile() {
    return _currentUser;
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImage,
  }) async {
    try {
      if (_currentUser == null) {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user data
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        profileImage: profileImage ?? _currentUser!.profileImage,
        updatedAt: DateTime.now(),
      );

      // Save updated data
      if (_authToken != null) {
        await _saveUserData(updatedUser, _authToken!);
      }

      return {
        'success': true,
        'message': 'Profil berhasil diperbarui',
        'user': updatedUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    // Mock data - dalam implementasi nyata diambil dari API
    return {
      'totalDetections': 1247,
      'safeImages': 1198,
      'nsfwImages': 49,
      'accuracy': 96,
      'weeklyData': [15, 23, 18, 31, 27, 19, 12],
    };
  }

  /// Get detection history
  List<DetectionHistoryModel> getDetectionHistory() {
    // Mock data - dalam implementasi nyata diambil dari API
    return [
      DetectionHistoryModel(
        id: '1',
        userId: _currentUser?.id ?? '1',
        imagePath: '/path/to/image1.jpg',
        imageName: 'image1.jpg',
        isNsfw: true,
        confidence: 0.95,
        predictions: {'nsfw': 0.95, 'safe': 0.05},
        detectedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      DetectionHistoryModel(
        id: '2',
        userId: _currentUser?.id ?? '1',
        imagePath: '/path/to/image2.jpg',
        imageName: 'image2.jpg',
        isNsfw: false,
        confidence: 0.98,
        predictions: {'nsfw': 0.02, 'safe': 0.98},
        detectedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  /// Get notifications
  List<NotificationModel> getNotifications() {
    // Mock data - dalam implementasi nyata diambil dari API
    return [
      NotificationModel(
        id: '1',
        userId: _currentUser?.id ?? '1',
        title: 'NSFW Content Detected',
        body: 'Gambar NSFW terdeteksi pada scan terbaru',
        type: 'detection',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      NotificationModel(
        id: '2',
        userId: _currentUser?.id ?? '1',
        title: 'Scan Complete',
        body: 'Scan selesai - 15 gambar aman terdeteksi',
        type: 'detection',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return getNotifications()
        .where((notification) => !notification.isRead)
        .toList();
  }

  /// Get security tips
  List<String> getSecurityTips() {
    return [
      'Selalu verifikasi konten sebelum membagikan',
      'Gunakan filter NSFW untuk keamanan ekstra',
      'Periksa source gambar sebelum menggunakan',
      'Laporkan konten yang mencurigakan',
      'Backup data deteksi secara berkala',
    ];
  }

  /// Reset service (untuk testing)
  void reset() {
    _currentUser = null;
    _authToken = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  /// Get authorization headers
  Map<String, String> get authHeaders {
    if (_authToken == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }
}
