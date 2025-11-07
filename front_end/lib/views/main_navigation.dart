import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/monitoring/monitoring_screen.dart';
import '../services/monitoring/auto_screenshot_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final GlobalKey<DashboardPageState> _dashboardKey = GlobalKey<DashboardPageState>();

  @override
  void initState() {
    super.initState();
    
    // Initialize GetX controller untuk monitoring
    Get.put(AutoScreenshotService());
    
    _pages = [
      DashboardPage(key: _dashboardKey),
      // Real-time monitoring dengan screen capture dan NSFW detection
      const MonitoringScreen(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          if (_currentIndex == index && index == 0) {
            // Re-selecting Dashboard: refresh statistics
            _dashboardKey.currentState?.refreshStats();
          }
          _currentIndex = index;
        }),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3F88EB),
        unselectedItemColor: const Color(0xFF979797),
        selectedLabelStyle: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_rounded),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
