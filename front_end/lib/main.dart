import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/register_screen.dart';
import 'views/screens/auth/forgot_password_screen.dart';
import 'views/main_navigation.dart';
import 'views/screens/profile/profile_screen.dart';
import 'views/screens/notification/notification_screen.dart';
import 'views/screens/dashboard/history_detection_log.dart';
import 'services/notifications/notification_service.dart';

import 'views/screens/profile/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      // initialBinding: BindingsBuilder(() {
      //   Get.put(AuthController());
      // }),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
  GetPage(name: '/change-password', page: () => const ChangePasswordScreen()),
        GetPage(name: '/notifications', page: () => const NotificationScreen()),
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
