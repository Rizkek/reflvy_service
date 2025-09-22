import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/services.dart';
import '../data/models/models.dart';

/// Controller untuk mengelola autentikasi pengguna
/// Menggunakan AuthService dari folder data untuk operasi login/logout
class AuthController extends GetxController {
  // Instance dari AuthService
  final AuthService _authService = AuthService();

  // Observable variables untuk reactive state management
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Cek status login saat controller diinisialisasi
    _checkLoginStatus();
  }

  /// Mengecek status login saat aplikasi dimulai
  void _checkLoginStatus() {
    final user = _authService.currentUser;
    if (user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
    }
  }

  /// Fungsi untuk melakukan login
  /// Parameter:
  /// - emailOrUsername: Email atau username pengguna
  /// - password: Password pengguna
  /// Return: Future<bool> - true jika berhasil, false jika gagal
  Future<bool> login(String emailOrUsername, String password) async {
    try {
      // Set loading state
      isLoading.value = true;
      errorMessage.value = '';

      // Panggil service untuk login
      final result = await _authService.login(emailOrUsername, password);

      if (result['success'] == true) {
        // Update state jika login berhasil
        currentUser.value = result['user'];
        isLoggedIn.value = true;

        // Tampilkan pesan sukses
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        // Set error message jika login gagal
        errorMessage.value = result['message'];

        // Tampilkan pesan error
        Get.snackbar(
          'Login Gagal',
          result['message'],
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      // Handle error
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';

      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat login',
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  /// Fungsi untuk melakukan logout
  /// Return: Future<bool> - true jika berhasil, false jika gagal
  Future<bool> logout() async {
    try {
      // Set loading state
      isLoading.value = true;
      errorMessage.value = '';

      // Panggil service untuk logout
      final result = await _authService.logout();

      if (result['success'] == true) {
        // Reset state jika logout berhasil
        currentUser.value = null;
        isLoggedIn.value = false;

        // Tampilkan pesan sukses
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        // Set error message jika logout gagal
        errorMessage.value = result['message'];

        Get.snackbar(
          'Logout Gagal',
          result['message'],
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      // Handle error
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';

      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat logout',
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  /// Fungsi untuk mendapatkan profil pengguna
  /// Return: UserModel? - data pengguna atau null
  UserModel? getProfile() {
    return _authService.getProfile();
  }

  /// Fungsi untuk update profil pengguna
  /// Parameter:
  /// - firstName: Nama depan baru
  /// - lastName: Nama belakang baru
  /// - profileImage: Path gambar profil baru
  /// Return: Future<bool> - true jika berhasil, false jika gagal
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImage,
  }) async {
    try {
      // Set loading state
      isLoading.value = true;
      errorMessage.value = '';

      // Panggil service untuk update profil
      final result = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        profileImage: profileImage,
      );

      if (result['success'] == true) {
        // Update state jika berhasil
        currentUser.value = result['user'];

        // Tampilkan pesan sukses
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        // Set error message jika gagal
        errorMessage.value = result['message'];

        Get.snackbar(
          'Update Gagal',
          result['message'],
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      // Handle error
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';

      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat update profil',
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  /// Fungsi untuk mendapatkan statistik dashboard
  /// Return: Map<String, dynamic> - statistik pengguna
  Map<String, dynamic> getDashboardStats() {
    return _authService.getDashboardStats();
  }

  /// Fungsi untuk mendapatkan riwayat deteksi
  /// Return: List<DetectionHistoryModel> - riwayat deteksi pengguna
  List<DetectionHistoryModel> getDetectionHistory() {
    return _authService.getDetectionHistory();
  }

  /// Fungsi untuk mendapatkan notifikasi
  /// Return: List<NotificationModel> - notifikasi pengguna
  List<NotificationModel> getNotifications() {
    return _authService.getNotifications();
  }

  /// Fungsi untuk mendapatkan notifikasi yang belum dibaca
  /// Return: List<NotificationModel> - notifikasi yang belum dibaca
  List<NotificationModel> getUnreadNotifications() {
    return _authService.getUnreadNotifications();
  }

  /// Fungsi untuk mendapatkan tips keamanan
  /// Return: List<String> - tips keamanan
  List<String> getSecurityTips() {
    return _authService.getSecurityTips();
  }

  /// Fungsi untuk clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Mendapatkan data statistik mingguan untuk grafik
  /// Return: List<int> - data deteksi per hari dalam seminggu
  List<int> getWeeklyStats() {
    // Data dummy untuk demo - dalam implementasi nyata diambil dari API/database
    return [15, 23, 18, 31, 27, 19, 12];
  }

  /// Mendapatkan list aktivitas terbaru
  /// Return: List<Map<String, dynamic>> - list aktivitas dengan title, time, icon, color
  List<Map<String, dynamic>> getRecentActivities() {
    return [
      {
        'title': 'Gambar NSFW terdeteksi',
        'time': '2 menit yang lalu',
        'icon': Icons.warning_amber_outlined,
        'color': const Color(0xFFF44336),
      },
      {
        'title': 'Scan selesai - 15 gambar aman',
        'time': '5 menit yang lalu',
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Upload batch gambar',
        'time': '10 menit yang lalu',
        'icon': Icons.cloud_upload_outlined,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Konfigurasi threshold diperbarui',
        'time': '1 jam yang lalu',
        'icon': Icons.settings_outlined,
        'color': const Color(0xFF9C27B0),
      },
    ];
  }

  /// Mendapatkan statistik bulanan
  /// Return: Map<String, int> - data statistik bulan ini
  Map<String, int> getMonthlyStats() {
    return {
      'totalDetections': 1247,
      'safeImages': 1198,
      'nsfwImages': 49,
      'accuracy': 96,
    };
  }

  /// Mendapatkan trend data bulanan untuk chart
  /// Return: List<int> - data trend 6 bulan terakhir
  List<int> getMonthlyTrend() {
    return [890, 1120, 950, 1300, 1150, 1247];
  }

  /// Fungsi untuk reset controller (untuk testing)
  void reset() {
    currentUser.value = null;
    isLoading.value = false;
    errorMessage.value = '';
    isLoggedIn.value = false;
    _authService.reset();
  }
}
