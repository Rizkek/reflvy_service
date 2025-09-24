import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

// Provider untuk mengelola theme aplikasi
final appThemeProvider = StateProvider<ThemeData>((ref) {
  return ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: const Color(0xFF3F88EB),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.raleway().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF181818)),
      titleTextStyle: TextStyle(
        color: Color(0xFF181818),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F88EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
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
    ),
  );
});

// Provider untuk mengelola locale aplikasi
final appLocaleProvider =
    StateProvider<Locale?>((ref) => const Locale('id', 'ID'));

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientasi aplikasi ke portrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Jalankan aplikasi dengan ProviderScope untuk Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme dan locale dari provider
    final theme = ref.watch(appThemeProvider);
    final locale = ref.watch(appLocaleProvider);

    return GetMaterialApp(
      title: 'REFLVY - Your Privacy Guardian',
      debugShowCheckedModeBanner: false,

      // Konfigurasi theme aplikasi
      theme: theme,

      // Konfigurasi locale untuk bahasa Indonesia
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),

      // Translations untuk GetX (opsional - bisa ditambahkan nanti)
      // translations: AppTranslations(),

      // Halaman awal aplikasi
      home: const SplashScreen(),

      // Konfigurasi GetX
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const UnknownRoutePage(),
      ),
    );
  }
}

/// Halaman untuk route yang tidak dikenal
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Halaman Tidak Ditemukan',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Halaman yang Anda cari tidak tersedia',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF979797),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAll(() => const SplashScreen()),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
