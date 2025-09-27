import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/statistics_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String title;
  final String type; // "weekly", "apps", atau "activity"

  const HistoryDetailScreen({Key? key, required this.title, required this.type})
    : super(key: key);

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  // State for "apps" (today) loaded from SharedPreferences
  List<Map<String, dynamic>> _todayAppItems = [];
  int _todayTotalApps = 0; // distinct apps detected today (Total > 0)
  String _todayWorstApp = '-';

  // Dummy data untuk history 7 hari terakhir
  final List<Map<String, dynamic>> weeklyHistory = [
    {
      'day': 'Sen',
      'total': 2,
      'low': 1,
      'medium': 0,
      'high': 1,
      'date': '9 Sep',
    },
    {
      'day': 'Sel',
      'total': 4,
      'low': 2,
      'medium': 1,
      'high': 1,
      'date': '10 Sep',
    },
    {
      'day': 'Rab',
      'total': 1,
      'low': 1,
      'medium': 0,
      'high': 0,
      'date': '11 Sep',
    },
    {
      'day': 'Kam',
      'total': 6,
      'low': 2,
      'medium': 2,
      'high': 2,
      'date': '12 Sep',
    },
    {
      'day': 'Jum',
      'total': 3,
      'low': 1,
      'medium': 1,
      'high': 1,
      'date': '13 Sep',
    },
    {
      'day': 'Sab',
      'total': 2,
      'low': 0,
      'medium': 1,
      'high': 1,
      'date': '14 Sep',
    },
    {
      'day': 'Min',
      'total': 1,
      'low': 1,
      'medium': 0,
      'high': 0,
      'date': '15 Sep',
    },
  ];

  // Dummy data untuk aplikasi terdeteksi
  // NOTE: For "apps" tab, we will load today's real data from SharedPreferences via StatisticsService.

  // Dummy data untuk activity terbaru
  final List<Map<String, dynamic>> activityHistory = [
    {
      'time': '15:30',
      'date': '15 Sep 2024',
      'appName': 'YouTube',
      'action': 'Aplikasi di Blokir',
      'level': 'medium',
      'details':
          'Video konten dewasa terdeteksi dan aplikasi diblokir otomatis',
      'icon': Icons.play_circle_fill,
      'color': Colors.red,
    },
    {
      'time': '15:30',
      'date': '15 Sep 2024',
      'appName': 'YouTube',
      'action': 'User Abaikan',
      'level': 'medium',
      'details': 'Peringatan diabaikan oleh pengguna, monitoring berlanjut',
      'icon': Icons.play_circle_fill,
      'color': Colors.red,
    },
    {
      'time': '14:20',
      'date': '15 Sep 2024',
      'appName': 'Instagram',
      'action': 'Konten Terdeteksi',
      'level': 'low',
      'details':
          'Konten tidak pantas terdeteksi tapi tidak memerlukan tindakan',
      'icon': Icons.camera_alt,
      'color': Colors.purple,
    },
    {
      'time': '13:45',
      'date': '15 Sep 2024',
      'appName': 'TikTok',
      'action': 'Aplikasi di Blokir',
      'level': 'high',
      'details': 'Konten eksplisit terdeteksi, aplikasi ditutup paksa',
      'icon': Icons.music_note,
      'color': Colors.black,
    },
    {
      'time': '12:30',
      'date': '15 Sep 2024',
      'appName': 'YouTube',
      'action': 'Peringatan Ditampilkan',
      'level': 'medium',
      'details':
          'Peringatan ditampilkan kepada pengguna tentang konten berisiko',
      'icon': Icons.play_circle_fill,
      'color': Colors.red,
    },
    {
      'time': '11:15',
      'date': '14 Sep 2024',
      'appName': 'Instagram',
      'action': 'User Abaikan',
      'level': 'low',
      'details': 'Peringatan diabaikan, konten dilanjutkan dengan monitoring',
      'icon': Icons.camera_alt,
      'color': Colors.purple,
    },
    {
      'time': '20:45',
      'date': '14 Sep 2024',
      'appName': 'TikTok',
      'action': 'Aplikasi di Blokir',
      'level': 'high',
      'details': 'Video dengan konten kekerasan terdeteksi dan diblokir',
      'icon': Icons.music_note,
      'color': Colors.black,
    },
    {
      'time': '18:20',
      'date': '14 Sep 2024',
      'appName': 'YouTube',
      'action': 'Konten Terdeteksi',
      'level': 'medium',
      'details': 'Thumbnail tidak pantas terdeteksi dalam video yang ditonton',
      'icon': Icons.play_circle_fill,
      'color': Colors.red,
    },
  ];

  Color _getThreatColor(String level) {
    switch (level) {
      case 'low':
        return const Color(0xFF22C55E); // Green
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
    return SingleChildScrollView(
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
                        weeklyHistory
                            .fold(0, (sum, day) => sum + (day['total'] as int))
                            .toString(),
                        Icons.search,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        'Hari Terburuk',
                        weeklyHistory.reduce(
                          (a, b) => a['total'] > b['total'] ? a : b,
                        )['day'],
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

          ...weeklyHistory.map((day) => _buildDayDetail(day)).toList(),
        ],
      ),
    );
  }

  Widget _buildAppsDetail() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _ensureTodayAppsLoaded(),
      builder: (context, snapshot) {
        return SingleChildScrollView(
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
    return Container(
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
    );
  }

  Widget _buildDayDetail(Map<String, dynamic> day) {
    return Container(
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
                      : const Color(0xFF22C55E).withOpacity(0.1),
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
                        : const Color(0xFF22C55E),
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
                  const Color(0xFF22C55E),
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
    );
  }

  Widget _buildThreatCount(String label, int count, Color color) {
    return Container(
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
    );
  }

  Widget _buildAppDetail(Map<String, dynamic> app) {
    return Container(
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
      child: ExpansionTile(
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
                    Expanded(child: _buildThreatCount('Low', app['low'] as int, const Color(0xFF22C55E))),
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
                            '${activityHistory.length} aktivitas tercatat',
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
                        '${activityHistory.length}',
                        Colors.blue.shade700,
                        Icons.list_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivityStat(
                        'Diblokir',
                        '${activityHistory.where((a) => a['action'].contains('Blokir')).length}',
                        Colors.red.shade700,
                        Icons.block,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivityStat(
                        'Diabaikan',
                        '${activityHistory.where((a) => a['action'].contains('Abaikan')).length}',
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

          ...activityHistory
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
    return Container(
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
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
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
    );
  }
}
