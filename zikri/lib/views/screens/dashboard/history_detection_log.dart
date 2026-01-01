import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/statistic/statistics_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String title;
  final String type; // "weekly", "apps", atau "activity"

  const HistoryDetailScreen({Key? key, required this.title, required this.type})
    : super(key: key);

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> 
    with AutomaticKeepAliveClientMixin {
  // State for "apps" (today) loaded from SharedPreferences
  List<Map<String, dynamic>> _todayAppItems = [];
  int _todayTotalApps = 0; // distinct apps detected today (Total > 0)
  String _todayWorstApp = '-';

  // State for weekly data from API
  List<Map<String, dynamic>> _weeklyHistory = [];
  bool _weeklyLoaded = false;

  // State for activity data (currently using empty list as activity endpoint not available)
  List<Map<String, dynamic>> _activityHistory = [];

  @override
  bool get wantKeepAlive => true;

  Color _getThreatColor(String level) {
    switch (level) {
      case 'low':
        return const Color.fromARGB(255, 255, 230, 0); // Yellow
      case 'medium':
        return const Color(0xFFF59E0B); // Orange
      case 'high':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  String _getThreatLabel(String level) {
    switch (level) {
      case 'low':
        return 'Ringan';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      default:
        return 'Unknown';
    }
  }

  // removed _getThreatIcon – not needed in today's app detail

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Text(
          widget.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: widget.type == 'weekly'
          ? _buildWeeklyDetail()
          : widget.type == 'apps'
          ? _buildAppsDetail()
          : _buildActivityDetail(),
    );
  }

  Widget _buildWeeklyDetail() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _ensureWeeklyLoaded(),
      builder: (context, snapshot) {
        // Show loading only on first load
        if (snapshot.connectionState == ConnectionState.waiting && !_weeklyLoaded) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error if failed
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final weeklyData = _weeklyHistory.isNotEmpty ? _weeklyHistory : [];
        
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan 7 Hari Terakhir',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Deteksi',
                            weeklyData.isEmpty
                                ? '0'
                                : weeklyData
                                    .fold<int>(0, (sum, day) => sum + ((day['total'] ?? 0) as int))
                                    .toString(),
                            Icons.search,
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryItem(
                            'Hari Terburuk',
                            _getWorstDay(weeklyData),
                            Icons.warning,
                            const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail per hari
              Text(
                'Detail Per Hari',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              if (weeklyData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Belum ada data deteksi 7 hari terakhir',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                )
              else
                ...weeklyData.map((day) => _buildDayDetail(day)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppsDetail() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _ensureTodayAppsLoaded(),
      builder: (context, snapshot) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Aplikasi Terdeteksi Hari Ini',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Apps',
                            _todayTotalApps.toString(),
                            Icons.apps,
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryItem(
                            'Terburuk',
                            _todayWorstApp,
                            Icons.warning,
                            const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail per aplikasi
              Text(
                'Detail Per Aplikasi',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              if (_todayAppItems.isEmpty)
                Text(
                  'Belum ada data aplikasi terdeteksi hari ini',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                )
              else
                ..._todayAppItems.map((app) => _buildAppDetail(app)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetail(Map<String, dynamic> day) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day['day']}, ${day['date']}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '${day['total']} deteksi total',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: day['total'] > 4
                      ? const Color(0xFFEF4444).withOpacity(0.1)
                      : day['total'] > 2
                      ? const Color(0xFFF59E0B).withOpacity(0.1)
                      : const Color.fromARGB(255, 255, 230, 0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  day['total'] > 4
                      ? 'Tinggi'
                      : day['total'] > 2
                      ? 'Sedang'
                      : 'Rendah',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: day['total'] > 4
                        ? const Color(0xFFEF4444)
                        : day['total'] > 2
                        ? const Color(0xFFF59E0B)
                        : const Color.fromARGB(255, 255, 230, 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThreatCount(
                  'Ringan',
                  day['low'],
                  const Color.fromARGB(255, 255, 230, 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThreatCount(
                  'Sedang',
                  day['medium'],
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThreatCount(
                  'Tinggi',
                  day['high'],
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildThreatCount(String label, int count, Color color) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDetail(Map<String, dynamic> app) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.grey.shade100,
            highlightColor: Colors.grey.shade50,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.centerLeft,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (app['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(app['icon'] as IconData, color: app['color'] as Color, size: 20),
            ),
            title: Text(
              app['name'] as String,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              '${app['total']} deteksi',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Hari Ini (Low/Medium/High)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildThreatCount('Low', app['low'] as int, const Color.fromARGB(255, 255, 230, 0))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildThreatCount('Medium', app['medium'] as int, const Color(0xFFF59E0B))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildThreatCount('High', app['high'] as int, const Color(0xFFEF4444))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _ensureTodayAppsLoaded() async {
    if (_todayAppItems.isNotEmpty) return {};
    final cached = await StatisticsService.getCachedToday();
    Map<String, dynamic>? source = cached;
    source ??= await StatisticsService.getToday();
    if (!mounted) return source;
    final List<Map<String, dynamic>> items = [];
    String worstName = '-';
    int totalApps = 0;
    if (source != null) {
      final stats = source['statistics'] as Map<String, dynamic>?;
      final appBreakdown = (stats?['appBreakdown'] as Map?)?.cast<String, dynamic>();
      if (appBreakdown != null && appBreakdown.isNotEmpty) {
        for (final entry in appBreakdown.entries) {
          final name = entry.key;
          final val = (entry.value as Map).cast<String, dynamic>();
          final total = (val['Total'] ?? 0) as int;
          if (total <= 0) continue;
          final low = (val['Low'] ?? 0) as int;
          final med = (val['Medium'] ?? 0) as int;
          final high = (val['High'] ?? 0) as int;
          final iconAndColor = _iconAndColorForApp(name);
          items.add({
            'name': _capitalize(name),
            'total': total,
            'low': low,
            'medium': med,
            'high': high,
            'icon': iconAndColor['icon'] as IconData,
            'color': iconAndColor['color'] as Color,
          });
        }
        // Sort items by total desc for listing
        items.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
        totalApps = items.length;
        if (items.isNotEmpty) {
          final worst = List<Map<String, dynamic>>.from(items)
            ..sort((a, b) {
              final hb = b['high'] as int;
              final ha = a['high'] as int;
              if (hb != ha) return hb.compareTo(ha);
              final mb = b['medium'] as int;
              final ma = a['medium'] as int;
              if (mb != ma) return mb.compareTo(ma);
              return (b['total'] as int).compareTo(a['total'] as int);
            });
          worstName = worst.first['name'] as String;
        }
      }
    }
    setState(() {
      _todayAppItems = items;
      _todayTotalApps = totalApps;
      _todayWorstApp = worstName;
    });
    return source;
  }

  Future<Map<String, dynamic>?> _ensureWeeklyLoaded() async {
    try {
      if (_weeklyLoaded && _weeklyHistory.isNotEmpty) return {};
      
      // First try to get from secure storage
      final secureData = await StatisticsService.getDailyBreakdown();
      if (secureData != null && secureData.isNotEmpty) {
        print('Loading weekly data from secure storage: ${secureData.length} days');
        _parseAndSetWeeklyData(secureData);
        if (mounted) {
          setState(() {
            _weeklyLoaded = true;
          });
        }
      }
      
      // Then fetch from API (will update secure storage)
      final cached = await StatisticsService.getCached7Days();
      Map<String, dynamic>? source = cached;
      source ??= await StatisticsService.get7Days();
      
      if (!mounted) return source;
      
      if (source != null) {
        final stats = source['statistics'] as Map<String, dynamic>?;
        final dailyBreakdown = (stats?['dailyBreakdown'] as List?)?.cast<Map<String, dynamic>>();
        
        if (dailyBreakdown != null && dailyBreakdown.isNotEmpty) {
          print('Loading weekly data from API: ${dailyBreakdown.length} days');
          _parseAndSetWeeklyData(dailyBreakdown);
        }
      }
      
      if (mounted) {
        setState(() {
          _weeklyLoaded = true;
        });
      }
      
      return source;
    } catch (e) {
      // Log error but mark as loaded to prevent infinite loading
      print('Error loading weekly data: $e');
      if (mounted) {
        setState(() {
          _weeklyLoaded = true;
        });
      }
      rethrow; // Rethrow to let FutureBuilder handle it
    }
  }

  void _parseAndSetWeeklyData(List<Map<String, dynamic>> dailyBreakdown) {
    final List<Map<String, dynamic>> items = [];
    
    for (final dayData in dailyBreakdown) {
      final dateStr = dayData['date'] as String?;
      if (dateStr == null) continue;
      
      // Parse date format from API (e.g., "October 28, 2025")
      final dt = _parseDate(dateStr);
      final dayName = _getDayName(dt.weekday);
      final dateFormatted = '${dt.day} ${_getMonthShort(dt.month)}';
      
      final low = (dayData['totalLow'] ?? 0) as int;
      final medium = (dayData['totalMedium'] ?? 0) as int;
      final high = (dayData['totalHigh'] ?? 0) as int;
      final total = (dayData['grandTotal'] ?? 0) as int;
      
      items.add({
        'day': dayName,
        'total': total,
        'low': low,
        'medium': medium,
        'high': high,
        'date': dateFormatted,
      });
    }
    
    _weeklyHistory = items;
    print('Parsed ${items.length} days of weekly data');
  }

  DateTime _parseDate(String dateStr) {
    try {
      // Handle format: "September 27, 2025"
      final parts = dateStr.split(',');
      if (parts.length < 2) return DateTime.now();
      
      final year = int.tryParse(parts[1].trim()) ?? DateTime.now().year;
      final monthDay = parts[0].trim().split(' ');
      if (monthDay.length < 2) return DateTime.now();
      
      final monthName = monthDay[0].toLowerCase();
      final day = int.tryParse(monthDay[1]) ?? 1;
      
      const months = {
        'january': 1, 'february': 2, 'march': 3, 'april': 4,
        'may': 5, 'june': 6, 'july': 7, 'august': 8,
        'september': 9, 'october': 10, 'november': 11, 'december': 12
      };
      
      final month = months[monthName] ?? 1;
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _getDayName(int weekday) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    // DateTime weekday: Monday=1, Sunday=7
    return days[weekday % 7];
  }

  String _getMonthShort(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month];
  }

  String _getWorstDay(List<dynamic> weeklyData) {
    if (weeklyData.isEmpty) return '-';
    
    Map<String, dynamic> worst = weeklyData.first as Map<String, dynamic>;
    int maxTotal = (worst['total'] as int?) ?? 0;
    
    for (final day in weeklyData) {
      final dayMap = day as Map<String, dynamic>;
      final total = (dayMap['total'] as int?) ?? 0;
      if (total > maxTotal) {
        maxTotal = total;
        worst = dayMap;
      }
    }
    
    return worst['day'] as String? ?? '-';
  }

  Map<String, dynamic> _iconAndColorForApp(String name) {
    final n = name.toLowerCase();
    if (n.contains('you')) return {'icon': Icons.play_arrow, 'color': const Color(0xFFDC2626)};
    if (n.contains('insta')) return {'icon': Icons.camera_alt, 'color': const Color(0xFF8B5CF6)};
    if (n.contains('face')) return {'icon': Icons.facebook, 'color': const Color(0xFF2563EB)};
    if (n.contains('twit') || n == 'x') return {'icon': Icons.close, 'color': const Color(0xFF0EA5E9)};
    if (n.contains('tiktok') || n.contains('tok')) return {'icon': Icons.music_note, 'color': const Color(0xFF111827)};
    return {'icon': Icons.apps, 'color': const Color(0xFF3B82F6)};
  }

  // (removed) old detection item renderer – not used in today's apps detail

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildActivityDetail() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Terbaru',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${_activityHistory.length} aktivitas tercatat',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Summary stats
                Row(
                  children: [
                    Expanded(
                      child: _buildActivityStat(
                        'Total',
                        '${_activityHistory.length}',
                        Colors.blue.shade700,
                        Icons.list_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivityStat(
                        'Diblokir',
                        '${_activityHistory.where((a) => (a['action'] as String?)?.contains('Blokir') ?? false).length}',
                        Colors.red.shade700,
                        Icons.block,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivityStat(
                        'Diabaikan',
                        '${_activityHistory.where((a) => (a['action'] as String?)?.contains('Abaikan') ?? false).length}',
                        Colors.orange.shade700,
                        Icons.warning_amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Activity list
          Text(
            'Riwayat Aktivitas',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          if (_activityHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data aktivitas',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data aktivitas detail akan tersedia ketika endpoint API sudah siap',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._activityHistory
                .map((activity) => _buildActivityItem(activity))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildActivityStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with time and threat level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    activity['time'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    activity['date'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getThreatColor(activity['level']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getThreatLabel(activity['level']),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // App info and action
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['appName'],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      activity['action'],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: activity['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity['details'],
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
