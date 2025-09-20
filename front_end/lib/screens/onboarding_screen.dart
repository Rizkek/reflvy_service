import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

// Provider untuk mengelola halaman onboarding saat ini
final onboardingPageProvider = StateProvider<int>((ref) => 0);

// Provider untuk PageController
final pageControllerProvider =
    Provider<PageController>((ref) => PageController());

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ref.read(pageControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Watch current page untuk reactive updates
    final currentPage = ref.watch(onboardingPageProvider);

    return WillPopScope(
      onWillPop: () async => false, // Mencegah navigasi kembali ke splash
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Judul aplikasi - Static
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    'RAFLEFLY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF181818),
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.67,
                    ),
                  ),
                ),

                // Bagian gambar yang dapat digeser
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        // Update state menggunakan Riverpod
                        ref.read(onboardingPageProvider.notifier).state = page;
                      },
                      children: [
                        Image.asset(
                          "assets/images/Onboarding1.png",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100),
                        ),
                        Image.asset(
                          "assets/images/Onboarding2.png",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100),
                        ),
                        Image.asset(
                          "assets/images/Onboarding3.png",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bagian konten statis
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Judul dinamis berdasarkan halaman saat ini
                      Text(
                        _getTitleForPage(currentPage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.raleway(
                          color: const Color(0xFF181818),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.48,
                        ),
                      ),

                      // Indikator halaman
                      _buildPageIndicators(currentPage),

                      // Deskripsi dinamis berdasarkan halaman saat ini
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _getDescriptionForPage(currentPage),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                            color: const Color(0xFF979797),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            letterSpacing: -0.48,
                          ),
                        ),
                      ),

                      // Bagian tombol
                      _buildBottomButtons(currentPage),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mendapatkan judul berdasarkan indeks halaman
  String _getTitleForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return "Lindungi\\nDirimu";
      case 1:
        return "Mudah\\nDigunakan";
      case 2:
        return "Siap\\nMulai";
      default:
        return "Lindungi\\nDirimu";
    }
  }

  /// Mendapatkan deskripsi berdasarkan indeks halaman
  String _getDescriptionForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return "Deteksi otomatis konten NSFW sebelum kamu lihat. Aman & nyaman dalam genggaman.";
      case 1:
        return "Interface yang sederhana dan intuitif membuat pengalaman browsing lebih menyenangkan.";
      case 2:
        return "Mulai petualangan browsing yang aman dan nyaman bersama Raflefly sekarang juga!";
      default:
        return "Deteksi otomatis konten NSFW sebelum kamu lihat. Aman & nyaman dalam genggaman.";
    }
  }

  /// Widget untuk membuat indikator halaman
  Widget _buildPageIndicators(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3F88EB) : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  /// Widget untuk membuat tombol bagian bawah
  Widget _buildBottomButtons(int pageIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: Row(
        children: [
          // Tombol kiri
          Expanded(
            child: _buildButton(
              text: pageIndex == 2 ? 'Kembali' : 'Lewati',
              isOutlined: true,
              onTap: pageIndex == 2 ? _previousPage : _skipOnboarding,
            ),
          ),

          const SizedBox(width: 16),

          // Tombol kanan
          Expanded(
            child: _buildButton(
              text: pageIndex == 2 ? 'Mulai' : 'Lanjut',
              isOutlined: false,
              onTap: pageIndex == 2 ? _getStarted : _nextPage,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk membuat tombol dengan style yang konsisten
  Widget _buildButton({
    required String text,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : const Color(0xFF3F88EB),
          borderRadius: BorderRadius.circular(12),
          border: isOutlined
              ? Border.all(color: const Color(0xFF3F88EB), width: 1.5)
              : null,
          boxShadow: !isOutlined
              ? [
                  const BoxShadow(
                    color: Color(0x19003078),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.raleway(
              color: isOutlined ? const Color(0xFF3F88EB) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.48,
            ),
          ),
        ),
      ),
    );
  }

  /// Navigasi ke halaman selanjutnya
  void _nextPage() {
    final currentPage = ref.read(onboardingPageProvider);
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigasi ke halaman sebelumnya
  void _previousPage() {
    final currentPage = ref.read(onboardingPageProvider);
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Melewati onboarding dan langsung ke login menggunakan GetX
  void _skipOnboarding() {
    Get.off(() => const LoginScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300));
  }

  /// Mulai aplikasi dan navigasi ke login menggunakan GetX
  void _getStarted() {
    Get.off(() => const LoginScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
