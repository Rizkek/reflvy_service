import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/section_header.dart';
import 'widgets/stat_card.dart';
import 'widgets/weekly_bar_chart.dart';
import 'widgets/app_card.dart';
import 'widgets/activity_card.dart';
import 'history_detail_screen.dart';
import 'notification_screen.dart';
import '../services/statistics_service.dart';
import '../services/secure_storage_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _appBreakdown;
  String _displayName = 'Pengguna';
  List<Map<String, dynamic>> _daily = const [];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadDisplayName();
  }

  Future<void> _loadStats() async {
    // Always fetch fresh data on load
    final data = await StatisticsService.fetchToday();
    final w7 = await StatisticsService.get7Days();
    if (!mounted) return;
    setState(() {
      _stats = data?['statistics'] as Map<String, dynamic>?;
      _appBreakdown = (_stats?['appBreakdown'] as Map?)?.cast<String, dynamic>();
      _daily = ((w7?['statistics']?['dailyBreakdown']) as List? ?? [])
          .cast<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    });
  }

  Future<void> refreshStats() async {
    final data = await StatisticsService.fetchToday();
    if (!mounted) return;
    setState(() {
      _stats = data?['statistics'] as Map<String, dynamic>?;
      _appBreakdown = (_stats?['appBreakdown'] as Map?)?.cast<String, dynamic>();
    });
  }

  Future<void> _loadDisplayName() async {
    final user = await SecureStorageService.getUserData();
    if (!mounted) return;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      setState(() => _displayName = user.displayName!.trim());
      return;
    }
    // Fallback to any raw stored fields if available
    final all = await SecureStorageService.getAllData();
    final raw = all['display_name'] ?? all['displayName'];
    if (raw != null && raw.trim().isNotEmpty) {
      if (!mounted) return;
      setState(() => _displayName = raw.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

  final isSmallScreen = screenHeight < 700;
  final isExtraSmall = screenHeight < 620;
  final headerHeight = screenHeight * (isExtraSmall ? 0.10 : 0.12);
  final cardHeight = screenHeight * (isExtraSmall ? 0.11 : 0.13);
  final chartHeight = screenHeight * (isExtraSmall ? 0.07 : 0.08);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: headerHeight.clamp(80.0, 120.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
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
                            'Halo, $_displayName',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF9FAFB),
                              fontSize: isExtraSmall ? 18 : 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hari ini: ${(_stats?['totalGrandTotal'] ?? '-') } deteksi',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE5E7EB),
                              fontSize: isExtraSmall ? 11 : 12,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshStats,
              color: const Color(0xFF3B82F6),
              child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: isSmallScreen ? 10 : 15,
                bottom: screenHeight * 0.15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Hari ini',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 15),
                  Wrap(
                    spacing: isSmallScreen ? 8 : 12,
                    runSpacing: isSmallScreen ? 8 : 12,
                    children: [
                      SizedBox(
                        width: (screenWidth - (screenWidth * 0.1) - (isSmallScreen ? 8 : 12)) / 2,
                        child: StatCard(
                          count: (_stats?['totalGrandTotal'] ?? '-').toString(),
                          title: 'Total',
                          subtitle: 'Semua Level',
                          color: const Color(0xFF2E6FED),
                          icon: Icons.search,
                          height: cardHeight.clamp(90.0, 110.0),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(
                        width: (screenWidth - (screenWidth * 0.1) - (isSmallScreen ? 8 : 12)) / 2,
                        child: StatCard(
                          count: (_stats?['totalLow'] ?? '-').toString(),
                          title: 'Low Risk',
                          subtitle: 'Aman',
                          color: const Color(0xFF10B981),
                          icon: Icons.shield,
                          height: cardHeight.clamp(90.0, 110.0),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(
                        width: (screenWidth - (screenWidth * 0.1) - (isSmallScreen ? 8 : 12)) / 2,
                        child: StatCard(
                          count: (_stats?['totalMedium'] ?? '-').toString(),
                          title: 'Medium Risk',
                          subtitle: 'Hati-hati',
                          color: const Color(0xFFF59E0B),
                          icon: Icons.warning,
                          height: cardHeight.clamp(90.0, 110.0),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(
                        width: (screenWidth - (screenWidth * 0.1) - (isSmallScreen ? 8 : 12)) / 2,
                        child: StatCard(
                          count: (_stats?['totalHigh'] ?? '-').toString(),
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
                  SectionHeader(
                    title: 'Tren 7 Hari Terakhir',
                    isSmallScreen: isSmallScreen,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryDetailScreen(
                            title: 'Trend 7 Hari Terakhir',
                            type: 'weekly',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  WeeklyBarChart(
                    daily: _daily,
                    height: chartHeight.clamp(180.0, 240.0),
                  ),
                  SizedBox(height: isSmallScreen ? 15 : 20),
                  SectionHeader(
                    title: 'Aplikasi Terdeteksi',
                    isSmallScreen: isSmallScreen,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryDetailScreen(
                            title: 'Aplikasi Terdeteksi',
                            type: 'apps',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  ..._buildTopApps(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 15 : 20),
                  SectionHeader(
                    title: 'Activity Terbaru',
                    isSmallScreen: isSmallScreen,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryDetailScreen(
                            title: 'Activity Terbaru',
                            type: 'activity',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  ActivityCard(
                    time: '15:30',
                    appName: 'YouTube',
                    action: 'Aplikasi di Blokir',
                    riskLevel: 'Medium',
                    riskColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  ActivityCard(
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
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopApps(bool isSmallScreen) {
    if (_appBreakdown == null || _appBreakdown!.isEmpty) {
      return [
        Text(
          'Belum ada data aplikasi',
          style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12),
        )
      ];
    }

    // Convert to list and sort by Total desc
    final entries = _appBreakdown!.entries.toList();
    entries.sort((a, b) {
      final aTotal = (a.value['Total'] ?? 0) as int;
      final bTotal = (b.value['Total'] ?? 0) as int;
      return bTotal.compareTo(aTotal);
    });

    // Take top 2 for compact view
    final top = entries.take(2);
    final List<Widget> cards = [];
    for (final e in top) {
      final name = e.key;
      final total = (e.value['Total'] ?? 0).toString();
      // Universal colors (no risk-based colors)
      const bgColor = Color(0xFFF3F4F6); // neutral gray-100
      const riskColor = Color(0xFF3B82F6); // blue accent for icon/percentage
      const riskLabel = '';

      final icon = name.toLowerCase().contains('you')
          ? Icons.play_arrow
          : name.toLowerCase().contains('insta')
              ? Icons.camera_alt
              : name.toLowerCase().contains('face')
                  ? Icons.facebook
                  : name.toLowerCase().contains('twit') || name.toLowerCase() == 'x'
                      ? Icons.close
                      : Icons.apps;

      cards.add(
        AppCard(
          appName: _capitalize(name),
          detections: '$total deteksi',
          percentage: '',
          riskLevel: riskLabel,
          riskColor: riskColor,
          backgroundColor: bgColor,
          icon: icon,
          isSmallScreen: isSmallScreen,
        ),
      );
      cards.add(SizedBox(height: isSmallScreen ? 6 : 8));
    }

    // Remove last spacer
    if (cards.isNotEmpty) cards.removeLast();
    return cards;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
