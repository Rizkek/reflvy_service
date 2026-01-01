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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // App Title - Static
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    'Paradise',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF181818),
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.67,
                    ),
                  ),
                ),

                // Sliding Image Section
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      children: [
                        Image.asset(
                          "assets/images/Onboarding1.png",
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          "assets/images/Onboarding2.png",
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          "assets/images/Onboarding3.png",
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                // Static Content Section
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dynamic Title based on current page
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

                      // Page Indicators
                      _buildPageIndicators(),

                      // Dynamic Description based on current page
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

                      // Buttons Section
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

  String _getTitleForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return "Lindungi\nDirimu";
      case 1:
        return "Mudah\nDigunakan";
      case 2:
        return "Siap\nMulai";
      default:
        return "Lindungi\nDirimu";
    }
  }

  String _getDescriptionForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return "Deteksi otomatis konten NSFW sebelum kamu lihat. Aman & nyaman dalam genggaman.";
      case 1:
        return "Interface yang sederhana dan intuitif membuat pengalaman browsing lebih menyenangkan.";
      case 2:
        return "Mulai petualangan browsing yang aman dan nyaman bersama Paradise sekarang juga!";
      default:
        return "Deteksi otomatis konten NSFW sebelum kamu lihat. Aman & nyaman dalam genggaman.";
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

  Widget _buildBottomButtons(int pageIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: Row(
        children: [
          // Left Button
          Expanded(
            child: _buildButton(
              text: pageIndex == 2 ? 'Back' : 'Skip',
              isOutlined: true,
              onTap: pageIndex == 2 ? _previousPage : _skipOnboarding,
            ),
          ),

          const SizedBox(width: 16),

          // Right Button
          Expanded(
            child: _buildButton(
              text: pageIndex == 2 ? 'Get Started' : 'Next',
              isOutlined: false,
              onTap: pageIndex == 2 ? _getStarted : _nextPage,
            ),
          ),
        ],
      ),
    );
  }

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

  void _nextPage() {
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
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
