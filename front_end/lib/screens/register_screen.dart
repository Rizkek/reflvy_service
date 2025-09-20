import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers untuk mengelola state registrasi
final registerNameProvider = StateProvider<String>((ref) => '');
final registerEmailProvider = StateProvider<String>((ref) => '');
final registerPasswordProvider = StateProvider<String>((ref) => '');
final registerConfirmPasswordProvider = StateProvider<String>((ref) => '');
final registerLoadingProvider = StateProvider<bool>((ref) => false);
final registerPasswordVisibilityProvider = StateProvider<bool>((ref) => true);
final registerConfirmPasswordVisibilityProvider =
    StateProvider<bool>((ref) => true);
final acceptTermsProvider = StateProvider<bool>((ref) => false);

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menangani proses registrasi
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final acceptTerms = ref.read(acceptTermsProvider);

      if (!acceptTerms) {
        Get.snackbar(
          'Perhatian',
          'Anda harus menyetujui syarat dan ketentuan',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Set loading state
      ref.read(registerLoadingProvider.notifier).state = true;

      try {
        // TODO: Implementasi Firebase Auth register
        // Simulasi loading untuk saat ini
        await Future.delayed(const Duration(seconds: 2));

        // Update providers dengan nilai yang dimasukkan
        ref.read(registerNameProvider.notifier).state = _nameController.text;
        ref.read(registerEmailProvider.notifier).state = _emailController.text;

        // Tampilkan pesan sukses
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil! Silakan login',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Kembali ke login screen
        Get.back();
      } catch (e) {
        // Tampilkan error message
        Get.snackbar(
          'Error',
          'Gagal mendaftar: \${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        // Reset loading state
        if (mounted) {
          ref.read(registerLoadingProvider.notifier).state = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers untuk reactive updates
    final isLoading = ref.watch(registerLoadingProvider);
    final obscurePassword = ref.watch(registerPasswordVisibilityProvider);
    final obscureConfirmPassword =
        ref.watch(registerConfirmPasswordVisibilityProvider);
    final acceptTerms = ref.watch(acceptTermsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181818)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daftar Akun',
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Deskripsi
              Center(
                child: Text(
                  'Buat akun baru untuk melindungi pengalaman browsing Anda',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF979797),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Form registrasi
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field Nama Lengkap
                    Text(
                      'Nama Lengkap',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      onChanged: (value) {
                        ref.read(registerNameProvider.notifier).state = value;
                      },
                      decoration:
                          _buildInputDecoration('Masukkan nama lengkap Anda'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Nama lengkap minimal 3 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

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
                        ref.read(registerEmailProvider.notifier).state = value;
                      },
                      decoration: _buildInputDecoration('Masukkan email Anda'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$')
                            .hasMatch(value)) {
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
                        ref.read(registerPasswordProvider.notifier).state =
                            value;
                      },
                      decoration:
                          _buildInputDecoration('Masukkan password Anda')
                              .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF979797),
                          ),
                          onPressed: () {
                            ref
                                .read(
                                    registerPasswordVisibilityProvider.notifier)
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

                    const SizedBox(height: 24),

                    // Field Konfirmasi Password
                    Text(
                      'Konfirmasi Password',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      onChanged: (value) {
                        ref
                            .read(registerConfirmPasswordProvider.notifier)
                            .state = value;
                      },
                      decoration:
                          _buildInputDecoration('Konfirmasi password Anda')
                              .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF979797),
                          ),
                          onPressed: () {
                            ref
                                .read(registerConfirmPasswordVisibilityProvider
                                    .notifier)
                                .state = !obscureConfirmPassword;
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak sama';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Checkbox Syarat dan Ketentuan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: acceptTerms,
                          onChanged: (value) {
                            ref.read(acceptTermsProvider.notifier).state =
                                value ?? false;
                          },
                          activeColor: const Color(0xFF3F88EB),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Saya menyetujui ',
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF979797),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Syarat dan Ketentuan',
                                  style: GoogleFonts.raleway(
                                    color: const Color(0xFF3F88EB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text: ' dan ',
                                  style: GoogleFonts.raleway(
                                    color: const Color(0xFF979797),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: GoogleFonts.raleway(
                                    color: const Color(0xFF3F88EB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signUp,
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
                                'Daftar',
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Link ke Login
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF979797),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Masuk',
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

  /// Helper function untuk membuat InputDecoration yang konsisten
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.raleway(
        color: const Color(0xFF979797),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3F88EB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
