import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

/// Provider untuk mengelola state email/username login
final loginEmailProvider = StateProvider<String>((ref) => '');

/// Provider untuk mengelola state password login
final loginPasswordProvider = StateProvider<String>((ref) => '');

/// Provider untuk mengelola visibility password
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

/// Provider untuk form key
final loginFormKeyProvider =
    Provider<GlobalKey<FormState>>((ref) => GlobalKey<FormState>());

/// Screen untuk halaman login aplikasi REFLVY
/// Menggunakan data statis dari folder data untuk autentikasi
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controller untuk text input
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;

  // Instance AuthController menggunakan GetX
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dan form key
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = ref.read(loginFormKeyProvider);

    // Set default values untuk demo (bisa dihapus untuk production)
    _emailController.text = 'user@reflvy.com';
    _passwordController.text = 'reflvy123';
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget di-dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk validasi email
  /// Parameter: value - nilai input email
  /// Return: String? - pesan error atau null jika valid
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email/Username tidak boleh kosong';
    }
    return null;
  }

  /// Fungsi untuk validasi password
  /// Parameter: value - nilai input password
  /// Return: String? - pesan error atau null jika valid
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Fungsi untuk menangani proses login
  /// Menggunakan AuthController yang terhubung dengan data dari folder data
  Future<void> _handleLogin() async {
    // Validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      try {
        // Panggil fungsi login dari AuthController
        final isSuccess = await _authController.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Jika login berhasil, navigasi ke halaman home
        if (isSuccess) {
          // Update provider dengan nilai yang dimasukkan
          ref.read(loginEmailProvider.notifier).state = _emailController.text;
          ref.read(loginPasswordProvider.notifier).state = _passwordController.text;

          // Navigasi ke halaman home menggunakan GetX
          Get.off(
            () => const HomeScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        }
        // Error handling sudah dilakukan di AuthController
      } catch (e) {
        // Handle unexpected error
        Get.snackbar(
          'Error',
          'Terjadi kesalahan tidak terduga: ${e.toString()}',
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// Fungsi untuk navigasi ke halaman register
  void _navigateToRegister() {
    Get.to(
      () => const RegisterScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Fungsi untuk navigasi ke halaman forgot password
  void _navigateToForgotPassword() {
    Get.to(
      () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers untuk reactive updates
    final obscurePassword = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Header dengan logo dan title aplikasi
              Center(
                child: Column(
                  children: [
                    // Logo aplikasi
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F88EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama aplikasi
                    Text(
                      'REFLVY',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Masuk ke akun Anda',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF979797),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Card informasi demo login
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3F88EB).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF3F88EB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Login',
                          style: GoogleFonts.raleway(
                            color: const Color(0xFF3F88EB),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: user@reflvy.com\nPassword: reflvy123',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form login
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label dan field Email/Username
                    Text(
                      'Email atau Username',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      onChanged: (value) {
                        ref.read(loginEmailProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan email atau username',
                        hintStyle: GoogleFonts.raleway(
                          color: const Color(0xFF979797),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: const Color(0xFF979797),
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3F88EB),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Label dan field Password
                    Text(
                      'Password',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      validator: _validatePassword,
                      onChanged: (value) {
                        ref.read(loginPasswordProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        hintStyle: GoogleFonts.raleway(
                          color: const Color(0xFF979797),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: const Color(0xFF979797),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF979797),
                            size: 20,
                          ),
                          onPressed: () {
                            ref.read(passwordVisibilityProvider.notifier).state =
                                !obscurePassword;
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3F88EB),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Link Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: Text(
                          'Lupa Password?',
                          style: GoogleFonts.raleway(
                            color: const Color(0xFF3F88EB),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol Login dengan Obx untuk reactive state
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F88EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFF3F88EB).withOpacity(0.6),
                            ),
                            child: _authController.isLoading.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Memproses...',
                                        style: GoogleFonts.raleway(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Masuk',
                                    style: GoogleFonts.raleway(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ATAU',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF979797),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Link untuk mendaftar
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF979797),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Daftar Sekarang',
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF3F88EB),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}