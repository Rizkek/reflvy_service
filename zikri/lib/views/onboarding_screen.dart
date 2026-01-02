import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation to splash
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Sliding Image Section
              Expanded(
                flex: 4,
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                  children: [
                    _buildImagePage("assets/images/Onboarding1.png"),
                    _buildImagePage("assets/images/Onboarding2.png"),
                    _buildImagePage("assets/images/Onboarding3.png"),
                  ],
                ),
              ),

              // Static Content Section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Page Indicators
                        _buildPageIndicators(),

                        const SizedBox(height: 10),

                        // Dynamic Title based on current page
                        Column(
                          children: [
                            Text(
                              _getTitleForPage(currentPage),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1E293B),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Dynamic Description
                            Text(
                              _getDescriptionForPage(currentPage),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF64748B),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),

                        // Main Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: currentPage == 2
                                ? _getStarted
                                : _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F88EB),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(0x403F88EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              currentPage == 2 ? 'Mulai Sekarang' : 'Lanjut',
                              style: GoogleFonts.raleway(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
          );
        },
      ),
    );
  }

  String _getTitleForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return "Lindungi Keluarga\nDengan Cerdas";
      case 1:
        return "Notifikasi Real-time\nKe Ponsel Anda";
      case 2:
        return "Aman & Nyaman\nBersama Paradise";
      default:
        return "Paradise";
    }
  }

  String _getDescriptionForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return "Deteksi otomatis konten yang tidak diinginkan dengan teknologi AI yang canggih.";
      case 1:
        return "Dapatkan pemberitahuan langsung saat terdeteksi aktivitas yang mencurigakan.";
      case 2:
        return "Ciptakan lingkungan digital yang sehat untuk tumbuh kembang buah hati.";
      default:
        return "";
    }
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3F88EB) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  void _nextPage() {
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
