import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:raflefly_front/screens/main_screens/profile/main_profile.dart';
import 'package:raflefly_front/screens/legal_screen/syarat_ketentuan.dart';
import 'package:raflefly_front/services/splash_screen.dart';
import 'services/onboarding_screen.dart';
import 'screens/auth_screen/login_screen.dart';
import 'screens/auth_screen/register_screen.dart';
import 'screens/auth_screen/forgot_password_screen.dart';
import 'screens/main_screens/dashboard/home_screen.dart';
import 'screens/main_screens/dashboard/notification_screen.dart';
import 'screens/main_screens/monitoring/history_detection_screen.dart';
import 'screens/main_screens/dashboard/ringkasan_tujuh_hari.dart';
import 'services/pop_up_alert.dart';
import 'controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RafleFly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(
          name: '/syarat-ketentuan',
          page: () => const SyaratKetentuanScreen(),
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/profile', page: () => const SettingsPage()),
        GetPage(name: '/notifications', page: () => const NotificationScreen()),
        GetPage(name: '/history', page: () => const HistoryDetectionScreen()),
        GetPage(
          name: '/history-detail',
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return HistoryDetailScreen(
              title: args['title'] ?? 'History Detail',
              type: args['type'] ?? 'weekly',
            );
          },
        ),
      ],
    );
  }
}
