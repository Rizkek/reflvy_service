import 'package:get/get.dart';
import '../feature/auth/login.dart';
import '../feature/auth/register.dart';
import '../main.dart';
import '../feature/dashboard/home.dart';

class AppRoutes {
  static const initial = '/login';

  static final pages = [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(name: '/home', page: () => const HomePage()),
    GetPage(name: '/counter', page: () => const AppRoot()),
  ];
}
