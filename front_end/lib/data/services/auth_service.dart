import '../app_data.dart';
import '../models/models.dart';

/// Service untuk mengelola autentikasi pengguna
/// Menggunakan data statis dari AppData untuk simulasi login
class AuthService {
  // Instance singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // User yang sedang login
  UserModel? _currentUser;

  // Getter untuk mendapatkan user yang sedang login
  UserModel? get currentUser => _currentUser;

  // Getter untuk mengecek status login
  bool get isLoggedIn => _currentUser != null;

  /// Fungsi untuk melakukan login
  /// Parameter:
  /// - emailOrUsername: Email atau username pengguna
  /// - password: Password pengguna
  /// Return: Map dengan status dan pesan
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    try {
      // Simulasi delay untuk loading
      await Future.delayed(const Duration(seconds: 1));

      // Validasi input
      if (emailOrUsername.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Email/Username dan password tidak boleh kosong',
          'user': null,
        };
      }

      // Validasi login dengan data statis
      bool isValid = AppData.validateLogin(emailOrUsername, password);
      
      if (isValid) {
        // Ambil data user dan update last login
        _currentUser = AppData.getUserByEmailOrUsername(emailOrUsername);
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(lastLogin: DateTime.now());
        }

        return {
          'success': true,
          'message': 'Login berhasil! Selamat datang ${_currentUser!.firstName}',
          'user': _currentUser,
        };
      } else {
        return {
          'success': false,
          'message': 'Email/Username atau password salah',
          'user': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
        'user': null,
      };
    }
  }

  /// Fungsi untuk melakukan logout
  /// Return: Map dengan status dan pesan
  Future<Map<String, dynamic>> logout() async {
    try {
      // Simulasi delay untuk loading
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat logout: ${e.toString()}',
      };
    }
  }

  /// Fungsi untuk mendapatkan profil user yang sedang login
  UserModel? getProfile() {
    return _currentUser;
  }

  /// Fungsi untuk update profil user
  /// Parameter:
  /// - firstName: Nama depan baru
  /// - lastName: Nama belakang baru
  /// - profileImage: Path gambar profil baru
  /// Return: Map dengan status dan pesan
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImage,
  }) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'User belum login',
          'user': null,
        };
      }

      // Simulasi delay untuk loading
      await Future.delayed(const Duration(milliseconds: 800));

      // Update data user
      _currentUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        profileImage: profileImage ?? _currentUser!.profileImage,
      );

      return {
        'success': true,
        'message': 'Profil berhasil diperbarui',
        'user': _currentUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat update profil: ${e.toString()}',
        'user': null,
      };
    }
  }

  /// Fungsi untuk mendapatkan statistik dashboard user
  Map<String, dynamic> getDashboardStats() {
    if (_currentUser == null) return {};
    
    return AppData.dashboardStats;
  }

  /// Fungsi untuk mendapatkan riwayat deteksi user
  List<DetectionHistoryModel> getDetectionHistory() {
    if (_currentUser == null) return [];
    
    return AppData.getDetectionHistoryByUserId(_currentUser!.id);
  }

  /// Fungsi untuk mendapatkan notifikasi user
  List<NotificationModel> getNotifications() {
    if (_currentUser == null) return [];
    
    return AppData.getNotificationsByUserId(_currentUser!.id);
  }

  /// Fungsi untuk mendapatkan notifikasi yang belum dibaca
  List<NotificationModel> getUnreadNotifications() {
    if (_currentUser == null) return [];
    
    return AppData.getUnreadNotifications(_currentUser!.id);
  }

  /// Fungsi untuk mendapatkan tips keamanan
  List<String> getSecurityTips() {
    return AppData.securityTips;
  }

  /// Fungsi untuk reset instance (untuk testing)
  void reset() {
    _currentUser = null;
  }
}