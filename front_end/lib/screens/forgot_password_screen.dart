import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers untuk mengelola state forgot password
final forgotPasswordEmailProvider = StateProvider<String>((ref) => '');
final forgotPasswordLoadingProvider = StateProvider<bool>((ref) => false);

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Fungsi untuk mengirim email reset password
  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      // Set loading state
      ref.read(forgotPasswordLoadingProvider.notifier).state = true;

      try {
        // TODO: Implementasi Firebase Auth reset password
        // Simulasi loading untuk saat ini
        await Future.delayed(const Duration(seconds: 2));

        // Update provider dengan email yang dimasukkan
        ref.read(forgotPasswordEmailProvider.notifier).state =
            _emailController.text;

        // Tampilkan pesan sukses
        Get.snackbar(
          'Berhasil',
          'Link reset password telah dikirim ke email Anda',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Kembali ke login screen setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Get.back();
          }
        });
      } catch (e) {
        // Tampilkan error message
        Get.snackbar(
          'Error',
          'Gagal mengirim email reset: \${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        // Reset loading state
        if (mounted) {
          ref.read(forgotPasswordLoadingProvider.notifier).state = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers untuk reactive updates
    final isLoading = ref.watch(forgotPasswordLoadingProvider);

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
          'Lupa Password',
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

              // Ikon dan judul
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F88EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: Color(0xFF3F88EB),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reset Password',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Masukkan email Anda dan kami akan mengirimkan link untuk reset password',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF979797),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Form reset password
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
                        ref.read(forgotPasswordEmailProvider.notifier).state =
                            value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan email Anda',
                        hintStyle: GoogleFonts.raleway(
                          color: const Color(0xFF979797),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF979797),
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

                    const SizedBox(height: 32),

                    // Tombol Kirim Reset Email
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendResetEmail,
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
                                'Kirim Link Reset',
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Link kembali ke login
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Kembali ke Halaman Login',
                          style: GoogleFonts.raleway(
                            color: const Color(0xFF3F88EB),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Informasi tambahan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F88EB).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3F88EB).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF3F88EB),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Periksa folder spam jika Anda tidak menerima email dalam beberapa menit',
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF3F88EB),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
