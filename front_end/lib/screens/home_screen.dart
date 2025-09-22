import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controller/auth_controller.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'history_detection_screen.dart';

// Providers untuk mengelola state home screen
final currentBottomNavIndexProvider = StateProvider<int>((ref) => 0);
final detectionStatsProvider = StateProvider<Map<String, int>>((ref) => {
      'today': 12,
      'week': 45,
      'month': 180,
      'blocked': 25,
    });

/// Halaman utama aplikasi dengan bottom navigation
/// Menampilkan dashboard, monitoring, dan profile
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch current index untuk reactive updates
    final currentIndex = ref.watch(currentBottomNavIndexProvider);

    // Daftar halaman untuk navigation
    final List<Widget> pages = [
      const DashboardPage(),
      const MonitoringPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentBottomNavIndexProvider.notifier).state = index;
        },
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
            icon: Icon(Icons.monitor_heart_outlined),
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

/// Halaman Dashboard utama yang menampilkan statistik deteksi NSFW
/// Data diambil dari AuthController yang terhubung dengan folder data
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menggunakan AuthController untuk mendapatkan data dari folder data
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang',
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF979797),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  authController.currentUser.value?.displayName ?? 'User',
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF181818),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                Get.to(
                  () => const NotificationScreen(),
                  transition: Transition.rightToLeft,
                );
              },
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF181818),
                    size: 24,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF44336),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card statistik utama menggunakan data dari AuthController
            Obx(() {
              final stats = authController.getDashboardStats();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3F88EB),
                      Color(0xFF2196F3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3F88EB).withAlpha(25),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Hari Ini',
                      style: GoogleFonts.raleway(
                        color: Colors.white.withAlpha(230),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats['totalDetections'] ?? 0} Deteksi',
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Aman',
                            '${stats['safeImages'] ?? 0}',
                            Icons.check_circle_outline,
                            Colors.white.withAlpha(230),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            'NSFW',
                            '${stats['nsfwImages'] ?? 0}',
                            Icons.warning_amber_outlined,
                            Colors.white.withAlpha(230),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Grid menu fitur utama
            Text(
              'Fitur Utama',
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(
                  'Deteksi Gambar',
                  'Analisis konten NSFW',
                  Icons.image_search,
                  const Color(0xFF4CAF50),
                  () {
                    // Navigasi ke halaman deteksi gambar
                    Get.snackbar(
                      'Info',
                      'Fitur deteksi gambar akan segera hadir',
                      backgroundColor: const Color(0xFF4CAF50),
                      colorText: Colors.white,
                    );
                  },
                ),
                _buildFeatureCard(
                  'Riwayat',
                  'Lihat history deteksi',
                  Icons.history,
                  const Color(0xFF9C27B0),
                  () {
                    Get.to(
                      () => const HistoryDetectionScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                ),
                _buildFeatureCard(
                  'Statistik',
                  'Laporan lengkap',
                  Icons.analytics_outlined,
                  const Color(0xFFFF9800),
                  () {
                    ref.read(currentBottomNavIndexProvider.notifier).state = 1;
                  },
                ),
                _buildFeatureCard(
                  'Pengaturan',
                  'Konfigurasi aplikasi',
                  Icons.settings_outlined,
                  const Color(0xFF607D8B),
                  () {
                    ref.read(currentBottomNavIndexProvider.notifier).state = 2;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card grafik minggu ini (menggunakan data dari AuthController)
            Obx(() {
              final weeklyData = authController.getWeeklyStats();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktivitas Minggu Ini',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF181818),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Text(
                                      days[value.toInt()],
                                      style: GoogleFonts.raleway(
                                        fontSize: 12,
                                        color: const Color(0xFF979797),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: weeklyData.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFF3F88EB),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFF3F88EB),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF3F88EB).withAlpha(25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Aktivitas terbaru menggunakan data dari AuthController
            Text(
              'Aktivitas Terbaru',
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final recentActivities = authController.getRecentActivities();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: recentActivities.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final activity = recentActivities[index];
                    return _buildActivityItem(
                      activity['title'] ?? '',
                      activity['time'] ?? '',
                      activity['icon'] ?? Icons.info,
                      activity['color'] ?? const Color(0xFF3F88EB),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan item statistik
  /// Parameters: label, value, icon, color
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.raleway(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.raleway(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget untuk menampilkan card fitur
  /// Parameters: title, subtitle, icon, color, onTap function
  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.raleway(
                color: const Color(0xFF979797),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan item aktivitas
  /// Parameters: title, time, icon, color
  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.raleway(
                  color: const Color(0xFF181818),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.raleway(
                  color: const Color(0xFF979797),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Halaman Monitoring untuk menampilkan statistik detail
/// Menampilkan grafik dan analisis mendalam tentang deteksi NSFW
class MonitoringPage extends ConsumerWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Monitoring',
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Obx(() {
              final monthlyStats = authController.getMonthlyStats();
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryCard(
                    'Total Deteksi',
                    '${monthlyStats['totalDetections'] ?? 0}',
                    Icons.analytics,
                    const Color(0xFF3F88EB),
                  ),
                  _buildSummaryCard(
                    'Gambar Aman',
                    '${monthlyStats['safeImages'] ?? 0}',
                    Icons.check_circle,
                    const Color(0xFF4CAF50),
                  ),
                  _buildSummaryCard(
                    'Gambar NSFW',
                    '${monthlyStats['nsfwImages'] ?? 0}',
                    Icons.warning,
                    const Color(0xFFF44336),
                  ),
                  _buildSummaryCard(
                    'Tingkat Akurasi',
                    '${monthlyStats['accuracy'] ?? 95}%',
                    Icons.precision_manufacturing,
                    const Color(0xFF9C27B0),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Chart section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trend Deteksi Bulanan',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF181818),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: Obx(() {
                      final monthlyData = authController.getMonthlyTrend();
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: monthlyData.isNotEmpty 
                              ? monthlyData.reduce((a, b) => a > b ? a : b).toDouble() * 1.2
                              : 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
                                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                                    return Text(
                                      months[value.toInt()],
                                      style: GoogleFonts.raleway(
                                        fontSize: 12,
                                        color: const Color(0xFF979797),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: monthlyData.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: const Color(0xFF3F88EB),
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan summary card
  /// Parameters: title, value, icon, color
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.raleway(
              color: const Color(0xFF181818),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: const Color(0xFF979797),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Halaman Profile yang menggunakan ProfileScreen yang sudah ada
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}