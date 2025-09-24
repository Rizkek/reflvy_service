import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

// Provider untuk mengelola state email
final emailProvider = StateProvider<String>((ref) => '');

// Provider untuk mengelola state password
final passwordProvider = StateProvider<String>((ref) => '');

// Provider untuk mengelola state loading
final loginLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk mengelola visibility password
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

// Provider untuk form key
final loginFormKeyProvider =
    Provider<GlobalKey<FormState>>((ref) => GlobalKey<FormState>());

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = ref.read(loginFormKeyProvider);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menangani proses sign in
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      // Set loading state
      ref.read(loginLoadingProvider.notifier).state = true;

      try {
        // TODO: Implementasi Firebase Auth login
        // Simulasi loading untuk saat ini
        await Future.delayed(const Duration(seconds: 2));

        // Update provider dengan nilai yang dimasukkan
        ref.read(emailProvider.notifier).state = _emailController.text;
        ref.read(passwordProvider.notifier).state = _passwordController.text;

        // Navigasi ke halaman home menggunakan GetX
        Get.off(() => const HomeScreen(),
            transition: Transition.fade,
            duration: const Duration(milliseconds: 500));
      } catch (e) {
        // Tampilkan error message menggunakan GetX snackbar
        Get.snackbar(
          'Error',
          'Gagal masuk: \${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        // Reset loading state
        if (mounted) {
          ref.read(loginLoadingProvider.notifier).state = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers untuk reactive updates
    final isLoading = ref.watch(loginLoadingProvider);
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

              // Logo dan nama aplikasi
              Center(
                child: Column(
                  children: [
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
                    Text(
                      'REFLVY',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.48,
                      ),
                    ),
                    const SizedBox(height: 8),
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

              // Form login
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field Email
                    Text(
                      'Email',
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
                      onChanged: (value) {
                        ref.read(emailProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan email Anda',
                        hintStyle: GoogleFonts.raleway(
                          color: const Color(0xFF979797),
                          fontSize: 14,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(
                          r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$',
                        ).hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Field Password
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
                      onChanged: (value) {
                        ref.read(passwordProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan password Anda',
                        hintStyle: GoogleFonts.raleway(
                          color: const Color(0xFF979797),
                          fontSize: 14,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF979797),
                          ),
                          onPressed: () {
                            ref
                                .read(passwordVisibilityProvider.notifier)
                                .state = !obscurePassword;
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Link Lupa Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => const ForgotPasswordScreen(),
                              transition: Transition.rightToLeft);
                        },
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

                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F88EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Masuk',
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Link Daftar
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
                            onPressed: () {
                              Get.to(() => const RegisterScreen(),
                                  transition: Transition.rightToLeft);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Daftar',
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF3F88EB),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
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
