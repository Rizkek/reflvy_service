import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
// import '../../../services/pop_up_alert.dart';
import 'ringkasan_tujuh_hari.dart';
import 'notification_screen.dart';
// import '../../history_detection_screen.dart';
import 'dart:async';
import 'package:raflefly_front/screens/main_screens/profile/main_profile.dart';
import 'package:raflefly_front/screens/main_screens/monitoring/monitoring_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Animation properties for bar chart
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;
  Timer? _animationTimer;

  final List<Widget> _pages = [
    const DashboardPage(),
    const BrowsingPage(),
    const SettingsPage(),
  ];

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // Animation properties for bar chart
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;
  Timer? _animationTimer;

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive dimensions
    final headerHeight = screenHeight * 0.12; // 12% of screen height
    final cardHeight =
        screenHeight *
        0.13; // Increased from 0.11 to 0.13 (13% of screen height)
    final chartHeight = screenHeight * 0.08; // 8% of screen height
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // Header with responsive gradient
          Container(
            width: double.infinity,
            height: headerHeight.clamp(80.0, 120.0), // Min 80, Max 120
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1E40AF),
                ], // Softer blue gradient
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35), // Slightly smaller radius
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A3B82F6),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Halo, Ahmad',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF9FAFB),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hari ini: 3 deteksi | paling sering:\nYouTube (2x)',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE5E7EB),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5177C1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content - Responsive with dynamic padding
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05, // 5% of screen width
                right: screenWidth * 0.05, // 5% of screen width
                top: isSmallScreen ? 10 : 15,
                bottom: screenHeight * 0.15, // 15% for bottom nav clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics section with responsive text
                  Text(
                    'Statistik Hari ini',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 15),

                  // Statistics cards grid with flexible layout
                  Wrap(
                    spacing: isSmallScreen ? 8 : 12,
                    runSpacing: isSmallScreen ? 8 : 12,
                    children: [
                      SizedBox(
                        width:
                            (screenWidth -
                                (screenWidth * 0.1) -
                                (isSmallScreen ? 8 : 12)) /
                            2,
                        child: _buildStatCard(
                          count: '5',
                          title: 'Total',
                          subtitle: 'Semua Level',
                          color: const Color(0xFF2E6FED),
                          icon: Icons.search,
                          height: cardHeight.clamp(
                            90.0,
                            110.0,
                          ), // Increased from 80-100 to 90-110
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(
                        width:
                            (screenWidth -
                                (screenWidth * 0.1) -
                                (isSmallScreen ? 8 : 12)) /
                            2,
                        child: _buildStatCard(
                          count: '1',
                          title: 'Low Risk',
                          subtitle: 'Aman',
                          color: const Color(0xFF10B981),
                          icon: Icons.shield,
                          height: cardHeight.clamp(90.0, 110.0),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(
                        width:
                            (screenWidth -
                                (screenWidth * 0.1) -
                                (isSmallScreen ? 8 : 12)) /
                            2,
                        child: _buildStatCard(
                          count: '1',
                          title: 'Medium Risk',
                          subtitle: 'Hati-hati',
                          color: const Color(0xFFF59E0B),
                          icon: Icons.warning,
                          height: cardHeight.clamp(90.0, 110.0),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(
                        width:
                            (screenWidth -
                                (screenWidth * 0.1) -
                                (isSmallScreen ? 8 : 12)) /
                            2,
                        child: _buildStatCard(
                          count: '3',
                          title: 'High Risk',
                          subtitle: 'Bahaya',
                          color: const Color(0xFFEF4444),
                          icon: Icons.dangerous,
                          height: cardHeight.clamp(90.0, 110.0),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 15 : 20),

                  // 7-day trend section
                  _buildSectionHeader(
                    'Tren 7 Hari Terakhir',
                    isSmallScreen,
                    'weekly',
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildTrendChart(
                    chartHeight.clamp(120.0, 160.0),
                    isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 15 : 20),

                  // Detected apps section
                  _buildSectionHeader(
                    'Aplikasi Terdeteksi',
                    isSmallScreen,
                    'apps',
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildAppCard(
                    appName: 'YouTube',
                    detections: '2 deteksi',
                    percentage: '67%',
                    riskLevel: 'Medium',
                    riskColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                    icon: Icons.play_arrow,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildAppCard(
                    appName: 'X',
                    detections: '2 deteksi',
                    percentage: '33%',
                    riskLevel: 'High',
                    riskColor: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFFEE2E2),
                    icon: Icons.close,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 15 : 20),

                  // Recent activity section
                  _buildSectionHeader(
                    'Activity Terbaru',
                    isSmallScreen,
                    'activity',
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildActivityCard(
                    time: '15:30',
                    appName: 'YouTube',
                    action: 'Aplikasi di Blokir',
                    riskLevel: 'Medium',
                    riskColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildActivityCard(
                    time: '15:30',
                    appName: 'YouTube',
                    action: 'User Abaikan',
                    riskLevel: 'Medium',
                    riskColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required double height,
    required bool isSmallScreen,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        // Mengurangi padding
        padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section - Icon and title
            Row(
              children: [
                Container(
                  // Mengurangi ukuran padding icon
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    // Mengurangi ukuran icon
                    size: isSmallScreen ? 14 : 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      // Mengurangi ukuran font title
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Middle section - Count
            Text(
              count,
              style: GoogleFonts.inter(
                color: color,
                // Mengurangi ukuran font count
                fontSize: isSmallScreen ? 22 : 24,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),

            // Bottom section - Subtitle
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                // Mengurangi ukuran font subtitle
                fontSize: isSmallScreen ? 9 : 10,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, [
    bool isSmallScreen = false,
    String? detailType,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF111827),
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: detailType != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailScreen(
                          title: detailType == 'weekly'
                              ? 'Trend 7 Hari Terakhir'
                              : 'Aplikasi Terdeteksi',
                          type: detailType,
                        ),
                      ),
                    );
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Lihat Detail',
                style: GoogleFonts.inter(
                  color: const Color(0xFF3B82F6),
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart([double height = 120, bool isSmallScreen = false]) {
    return Container(
      height: height + 80, // Increased height for better chart display
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header without play button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analisis Mingguan',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1F2937),
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tingkat Risiko Harian',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Static Bar Chart (no animation)
          Expanded(child: BarChart(_mainBarData())),
        ],
      ),
    );
  }

  // Main bar chart data with health risk categories
  BarChartData _mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF37474F),
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String day;
            String riskLevel;
            Color riskColor;

            switch (group.x) {
              case 0:
                day = 'Senin';
                riskLevel = 'Normal';
                riskColor = const Color(0xFF10B981);
                break;
              case 1:
                day = 'Selasa';
                riskLevel = 'Sedang';
                riskColor = const Color(0xFFF59E0B);
                break;
              case 2:
                day = 'Rabu';
                riskLevel = 'Normal';
                riskColor = const Color(0xFF10B981);
                break;
              case 3:
                day = 'Kamis';
                riskLevel = 'Tinggi';
                riskColor = const Color(0xFFEF4444);
                break;
              case 4:
                day = 'Jumat';
                riskLevel = 'Bahaya';
                riskColor = const Color(0xFFDC2626);
                break;
              case 5:
                day = 'Sabtu';
                riskLevel = 'Sedang';
                riskColor = const Color(0xFFF59E0B);
                break;
              case 6:
                day = 'Minggu';
                riskLevel = 'Normal';
                riskColor = const Color(0xFF10B981);
                break;
              default:
                day = '';
                riskLevel = 'Unknown';
                riskColor = Colors.grey;
            }

            return BarTooltipItem(
              '$day\n',
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$riskLevel\n',
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '${rod.toY.toInt()} poin',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _getBottomTitles,
            reservedSize: 30,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: _showingGroups(),
      gridData: const FlGridData(show: false),
      maxY: 20,
    );
  }

  // Generate bar groups with health risk data
  List<BarChartGroupData> _showingGroups() => List.generate(7, (i) {
    switch (i) {
      case 0:
        return _makeGroupData(
          0,
          8,
          isTouched: i == touchedIndex,
          riskLevel: 'Normal',
        );
      case 1:
        return _makeGroupData(
          1,
          12,
          isTouched: i == touchedIndex,
          riskLevel: 'Sedang',
        );
      case 2:
        return _makeGroupData(
          2,
          7,
          isTouched: i == touchedIndex,
          riskLevel: 'Normal',
        );
      case 3:
        return _makeGroupData(
          3,
          15,
          isTouched: i == touchedIndex,
          riskLevel: 'Tinggi',
        );
      case 4:
        return _makeGroupData(
          4,
          18,
          isTouched: i == touchedIndex,
          riskLevel: 'Bahaya',
        );
      case 5:
        return _makeGroupData(
          5,
          11,
          isTouched: i == touchedIndex,
          riskLevel: 'Sedang',
        );
      case 6:
        return _makeGroupData(
          6,
          6,
          isTouched: i == touchedIndex,
          riskLevel: 'Normal',
        );
      default:
        return throw Error();
    }
  });

  // Create individual bar group
  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 20,
    String riskLevel = 'Normal',
  }) {
    // Determine color based on touch state and risk level
    Color finalColor;
    if (isTouched) {
      // Show actual risk color when touched
      switch (riskLevel) {
        case 'Normal':
          finalColor = const Color(0xFF10B981);
          break;
        case 'Sedang':
          finalColor = const Color(0xFFF59E0B);
          break;
        case 'Tinggi':
          finalColor = const Color(0xFFEF4444);
          break;
        case 'Bahaya':
          finalColor = const Color(0xFFDC2626);
          break;
        default:
          finalColor = const Color(0xFF6B7280);
      }
    } else {
      // Show gray when not touched
      finalColor = const Color(0xFFE5E7EB);
    }

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 2 : y,
          color: finalColor,
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: const Color(0xFFF9FAFB),
          ),
        ),
      ],
    );
  }

  // Bottom titles widget
  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF6B7280),
      fontWeight: FontWeight.w500,
      fontSize: 11,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Sen', style: style);
        break;
      case 1:
        text = const Text('Sel', style: style);
        break;
      case 2:
        text = const Text('Rab', style: style);
        break;
      case 3:
        text = const Text('Kam', style: style);
        break;
      case 4:
        text = const Text('Jum', style: style);
        break;
      case 5:
        text = const Text('Sab', style: style);
        break;
      case 6:
        text = const Text('Min', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: text);
  }

  Widget _buildAppCard({
    required String appName,
    required String detections,
    required String percentage,
    required String riskLevel,
    required Color riskColor,
    required Color backgroundColor,
    required IconData icon,
    bool isSmallScreen = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // App icon with colored background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: isSmallScreen ? 20 : 24, color: riskColor),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appName,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111827),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        percentage,
                        style: GoogleFonts.inter(
                          color: riskColor,
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detections,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        riskLevel,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String time,
    required String appName,
    required String action,
    required String riskLevel,
    required Color riskColor,
    required Color backgroundColor,
    bool isSmallScreen = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$appName - $action',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111827),
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    riskLevel,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
