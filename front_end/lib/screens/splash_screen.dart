import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'onboarding_screen.dart';

// Provider untuk mengelola state loading splash screen
final splashLoadingProvider = StateProvider<bool>((ref) => true);

// Provider untuk mengelola animasi splash screen
final splashAnimationProvider = StateProvider<double>((ref) => 0.0);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar menjadi transparan untuk tampilan yang lebih bersih
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Inisialisasi animasi dengan durasi yang lebih cepat
    _animationController = AnimationController(
      duration: const Duration(
          milliseconds:
              1200), // Dikurangi dari 2000ms untuk loading yang lebih cepat
      vsync: this,
    );

    // Animasi fade in untuk efek muncul yang halus
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Animasi skala untuk efek zoom yang menarik
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Mulai animasi
    _animationController.forward();

    // Update provider animation state
    _animationController.addListener(() {
      ref.read(splashAnimationProvider.notifier).state =
          _animationController.value;
    });

    // Navigasi ke halaman selanjutnya setelah delay
    _navigateToNext();
  }

  /// Fungsi untuk navigasi ke halaman onboarding menggunakan GetX
  void _navigateToNext() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      // Dikurangi dari 3000ms untuk transisi yang lebih cepat
      if (mounted) {
        // Update loading state
        ref.read(splashLoadingProvider.notifier).state = false;

        // Navigasi menggunakan GetX untuk transisi yang lebih smooth
        Get.off(() => const OnboardingScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider untuk reactive updates
    final isLoading = ref.watch(splashLoadingProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gradient yang menarik untuk background splash
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2), // Biru muda
              Color(0xFF357ABD), // Biru tua
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container untuk logo aplikasi
                    Container(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        'assets/images/Raflefly_logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Widget fallback jika gambar tidak ditemukan - hanya ikon sederhana
                          return const Icon(
                            Icons.shield,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tagline aplikasi
                    const Text(
                      'Your Privacy Guardian',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Indikator loading yang responsif terhadap state
                    if (isLoading)
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
