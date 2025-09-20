import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/notification_service.dart';
import 'history_detail_screen.dart';
import 'notification_screen.dart';
import 'history_detection_screen.dart';
import 'dart:async';

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
        borderRadius: BorderRadius.circular(16), // More modern radius
        border: Border.all(
          color: color.withOpacity(
            0.2,
          ), // Subtle colored border instead of shadow
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isSmallScreen ? 14 : 18,
        ), // Increased from 12/16 to 14/18
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Even distribution
          children: [
            // Top section - Icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Increased from 6 to 8
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 16 : 18, // Increased from 14/16
                  ),
                ),
                const SizedBox(width: 10), // Increased from 8
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: isSmallScreen ? 11 : 12, // Increased from 10/11
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
                fontSize: isSmallScreen ? 24 : 28, // Increased from 22/26
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),

            // Bottom section - Subtitle
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontSize: isSmallScreen ? 10 : 11, // Increased from 9/10
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

class BrowsingPage extends StatefulWidget {
  const BrowsingPage({super.key});

  @override
  State<BrowsingPage> createState() => _BrowsingPageState();
}

class _BrowsingPageState extends State<BrowsingPage>
    with TickerProviderStateMixin {
  bool isMonitoring = false;
  bool showAlert = false;
  String currentThreatLevel = 'safe';
  String lastDetection = '';
  int detectionCount = 0;
  late AnimationController _pulseController;
  late AnimationController _alertController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _alertAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _alertController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _alertAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _alertController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      isMonitoring = !isMonitoring;
      if (isMonitoring) {
        // Send real push notification
        NotificationService().showMonitoringStatusNotification(isActive: true);

        // Simulate detection after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (isMonitoring) {
            _simulateDetection();
          }
        });
      } else {
        // Send real push notification
        NotificationService().showMonitoringStatusNotification(isActive: false);

        currentThreatLevel = 'safe';
      }
    });
  }

  void _simulateDetection() {
    if (!isMonitoring) return;

    final detectionTypes = [
      {'type': 'low', 'app': 'YouTube', 'content': 'Konten dewasa ringan'},
      {'type': 'medium', 'app': 'Browser', 'content': 'Situs tidak aman'},
      {
        'type': 'high',
        'app': 'Instagram',
        'content': 'Konten eksplisit berbahaya',
      },
    ];

    final random = detectionTypes[detectionCount % detectionTypes.length];
    detectionCount++;

    setState(() {
      currentThreatLevel = random['type'] as String;
      lastDetection = '${random['app']} - ${random['content']}';
    });

    _showThreatNotification(
      random['type'] as String,
      random['app'] as String,
      random['content'] as String,
    );

    // Continue simulation
    if (isMonitoring) {
      Future.delayed(const Duration(seconds: 5), _simulateDetection);
    }
  }

  void _showThreatNotification(String level, String app, String content) {
    // Show pop-up alert for all threat levels (low, medium, high, critical)
    if (level != 'safe') {
      _showThreatAlert(level, app, content);
    }

    // Send real push notification to phone
    NotificationService().showThreatNotification(
      threatLevel: level,
      appName: app,
      contentType: content,
    );
  }

  void _showThreatAlert(String level, String app, String content) {
    setState(() {
      showAlert = true;
      // Store current threat info for display in alert
      currentThreatLevel = level;
      lastDetection = '$app - $content';
    });
    _alertController.forward();

    // Auto hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _alertController.reverse().then((_) {
          setState(() {
            showAlert = false;
          });
        });
      }
    });
  }

  Color _getThreatColor() {
    switch (currentThreatLevel) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFEA580C);
      case 'high':
        return const Color(0xFFDC2626);
      case 'critical':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getThreatText() {
    switch (currentThreatLevel) {
      case 'low':
        return 'Risiko Rendah';
      case 'medium':
        return 'Risiko Sedang';
      case 'high':
        return 'Risiko Tinggi';
      case 'critical':
        return 'BAHAYA KRITIS';
      default:
        return 'Aman';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Deteksi Real-time',
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header
                  Text(
                    'Monitoring aplikasi berisiko secara otomatis',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 32),

                  // Monitoring Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMonitoring
                            ? _getThreatColor()
                            : const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status Indicator
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: isMonitoring
                                      ? _pulseAnimation.value
                                      : 1.0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: isMonitoring
                                          ? _getThreatColor()
                                          : const Color(0xFF9CA3AF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMonitoring
                                        ? 'Monitoring aktif'
                                        : 'Monitoring tidak aktif',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF1F2937),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isMonitoring &&
                                      currentThreatLevel != 'safe')
                                    Text(
                                      'Status: ${_getThreatText()}',
                                      style: GoogleFonts.inter(
                                        color: _getThreatColor(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isMonitoring
                              ? 'Sistem sedang memantau layar dan menganalisis konten secara real-time'
                              : 'Tekan tombol di bawah untuk monitoring aplikasi',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isMonitoring && lastDetection.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getThreatColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getThreatColor().withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deteksi Terakhir:',
                                  style: GoogleFonts.inter(
                                    color: _getThreatColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastDetection,
                                  style: GoogleFonts.inter(
                                    color: _getThreatColor(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Control Buttons - Circular Play Button
                  Center(
                    child: Column(
                      children: [
                        // Main circular button
                        Container(
                          width: isSmallScreen ? 80 : 100,
                          height: isSmallScreen ? 80 : 100,
                          decoration: BoxDecoration(
                            color: isMonitoring
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isMonitoring
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF3B82F6))
                                        .withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleMonitoring,
                              borderRadius: BorderRadius.circular(50),
                              child: Center(
                                child: Icon(
                                  isMonitoring ? Icons.stop : Icons.play_arrow,
                                  color: Colors.white,
                                  size: isSmallScreen ? 35 : 45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        // Button label
                        Text(
                          isMonitoring ? 'Stop Monitoring' : 'Mulai Deteksi',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1F2937),
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 32 : 40),

                  // Features List
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          Icons.security,
                          'AI Detection',
                          'Menggunakan ai untuk mendeteksi\nkonten berisiko secara real-time',
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildFeatureItem(
                          Icons.notifications_active,
                          'Smart Alert',
                          'Notifikasi cerdas berdasarkan\ntingkat risiko konten',
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // History Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HistoryDetectionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 20,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: isSmallScreen ? 20 : 24),
                          const SizedBox(width: 8),
                          Text(
                            'Lihat History Deteksi',
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: isSmallScreen ? 16 : 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom padding for scroll safety
                  SizedBox(height: isSmallScreen ? 40 : 60),
                ],
              ),
            ),
          ),

          // Threat Alert Overlay
          if (showAlert)
            AnimatedBuilder(
              animation: _alertAnimation,
              builder: (context, child) {
                final screenHeight = MediaQuery.of(context).size.height;
                final isSmallScreenAlert = screenHeight < 700;

                // Get alert style based on threat level
                Color alertColor;
                IconData alertIcon;
                String alertTitle;
                String alertMessage;

                switch (currentThreatLevel) {
                  case 'low':
                    alertColor = const Color(0xFF10B981);
                    alertIcon = Icons.info_outline;
                    alertTitle = '⚠️ DETEKSI RINGAN';
                    alertMessage = 'Konten berpotensi tidak pantas terdeteksi';
                    break;
                  case 'medium':
                    alertColor = const Color(0xFFEA580C);
                    alertIcon = Icons.warning_outlined;
                    alertTitle = '⚠️ PERINGATAN SEDANG';
                    alertMessage = 'Konten tidak aman terdeteksi';
                    break;
                  case 'high':
                    alertColor = const Color(0xFFEF4444);
                    alertIcon = Icons.warning_amber_rounded;
                    alertTitle = '⚠️ BAHAYA TINGGI!';
                    alertMessage =
                        'Konten berbahaya terdeteksi - Aplikasi harus ditutup';
                    break;
                  default:
                    alertColor = const Color(0xFFEF4444);
                    alertIcon = Icons.warning_amber_rounded;
                    alertTitle = '⚠️ KONTEN BERBAHAYA TERDETEKSI!';
                    alertMessage = 'Sistem AI mendeteksi konten tidak pantas';
                }

                return Transform.scale(
                  scale: _alertAnimation.value,
                  child: Container(
                    color: Colors.black.withOpacity(0.9),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.all(isSmallScreenAlert ? 24 : 32),
                        padding: EdgeInsets.all(isSmallScreenAlert ? 24 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: alertColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pulsing warning icon
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: isSmallScreenAlert ? 70 : 80,
                                    height: isSmallScreenAlert ? 70 : 80,
                                    decoration: BoxDecoration(
                                      color: alertColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      alertIcon,
                                      color: alertColor,
                                      size: isSmallScreenAlert ? 42 : 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: isSmallScreenAlert ? 18 : 24),
                            Text(
                              alertTitle,
                              style: GoogleFonts.inter(
                                color: alertColor,
                                fontSize: isSmallScreenAlert ? 18 : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreenAlert ? 12 : 16),
                            Container(
                              padding: EdgeInsets.all(
                                isSmallScreenAlert ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: alertColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: alertColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    alertMessage,
                                    style: GoogleFonts.inter(
                                      color: alertColor.withOpacity(0.8),
                                      fontSize: isSmallScreenAlert ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isSmallScreenAlert ? 6 : 8),
                                  Text(
                                    lastDetection,
                                    style: GoogleFonts.inter(
                                      color: alertColor.withOpacity(0.7),
                                      fontSize: isSmallScreenAlert ? 12 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isSmallScreenAlert ? 6 : 8),
                                  Text(
                                    'Aktivitas telah direkam dalam log sistem',
                                    style: GoogleFonts.inter(
                                      color: alertColor.withOpacity(0.6),
                                      fontSize: isSmallScreenAlert ? 11 : 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallScreenAlert ? 18 : 24),
                            // Button layout: High threats only show "Close App", others show both buttons
                            currentThreatLevel == 'high'
                                ? SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _alertController.reverse().then((_) {
                                          setState(() {
                                            showAlert = false;
                                          });
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: alertColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isSmallScreenAlert
                                              ? 12
                                              : 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.exit_to_app,
                                            size: isSmallScreenAlert ? 16 : 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Tutup Aplikasi',
                                            style: GoogleFonts.inter(
                                              fontSize: isSmallScreenAlert
                                                  ? 14
                                                  : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _alertController.reverse().then((
                                              _,
                                            ) {
                                              setState(() {
                                                showAlert = false;
                                              });
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF6B7280,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFF6B7280),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: isSmallScreenAlert
                                                  ? 10
                                                  : 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Abaikan',
                                            style: GoogleFonts.inter(
                                              fontSize: isSmallScreenAlert
                                                  ? 14
                                                  : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isSmallScreenAlert ? 8 : 12,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _alertController.reverse().then((
                                              _,
                                            ) {
                                              setState(() {
                                                showAlert = false;
                                              });
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: alertColor,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: isSmallScreenAlert
                                                  ? 10
                                                  : 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.exit_to_app,
                                                size: isSmallScreenAlert
                                                    ? 16
                                                    : 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Tutup Aplikasi',
                                                style: GoogleFonts.inter(
                                                  fontSize: isSmallScreenAlert
                                                      ? 14
                                                      : 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: isSmallScreen ? 18 : 20),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1F2937),
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Avatar and Info
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Text(
                          'AH',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ahmad Hafizi',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1F2937),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ahmad@example.com',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildContactRow(Icons.email_outlined, 'ahmad@example.com'),
                    const SizedBox(height: 16),
                    _buildContactRow(Icons.phone_outlined, '+6281234567890'),
                    const SizedBox(height: 16),
                    _buildContactRow(
                      Icons.calendar_today_outlined,
                      'Bergabung 15 Sept 2025',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Cards
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '847',
                        'Total Deteksi',
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '23',
                        'Hari Aktif',
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '92%',
                        'Keamanan',
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Deteksi',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      Icons.notifications_outlined,
                      'Notifikasi',
                      'Terima alert saat konten berisiko terdeteksi',
                      () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      Icons.shield_outlined,
                      'High Risk Only',
                      'Hanya alert untuk konten high risk',
                      () {},
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'APLIKASI',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      Icons.security_outlined,
                      'Keamanan & Privasi',
                      'Kelola data dan pengaturan privasi',
                      () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      Icons.help_outline,
                      'Bantuan & Dukungan',
                      'FAQ, tutorial, dan kontak support',
                      () {},
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'AKUN',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      Icons.person_outline,
                      'Informasi Akun',
                      'Kelola data profil dan preferensi',
                      () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      Icons.logout_outlined,
                      'Keluar',
                      'Terima alert saat konten berisiko terdeteksi',
                      () {
                        _showLogoutDialog(context);
                      },
                      isDestructive: true,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 20),
        const SizedBox(width: 16),
        Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : const Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: isDestructive
                              ? Colors.red
                              : const Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Keluar dari Akun',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate back to onboarding
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/onboarding',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Keluar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
