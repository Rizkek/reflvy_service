import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String title;
  final String type; // "weekly", "apps", atau "activity"

  const HistoryDetailScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
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
  final List<Map<String, dynamic>> appsHistory = [
    {
      'name': 'YouTube',
      'percentage': 67,
      'detections': 8,
      'lastDetection': '15 Sep, 14:30',
      'icon': Icons.play_circle_fill,
      'color': Colors.red,
      'details': [
        {
          'time': '15 Sep, 14:30',
          'level': 'medium',
          'content': 'Video konten dewasa',
        },
        {
          'time': '15 Sep, 12:15',
          'level': 'low',
          'content': 'Thumbnail tidak pantas',
        },
        {
          'time': '14 Sep, 20:45',
          'level': 'high',
          'content': 'Konten eksplisit',
        },
        {
          'time': '14 Sep, 18:20',
          'level': 'low',
          'content': 'Komentar tidak pantas',
        },
        {
          'time': '13 Sep, 16:30',
          'level': 'medium',
          'content': 'Video berbahaya',
        },
      ],
    },
    {
      'name': 'Instagram',
      'percentage': 23,
      'detections': 3,
      'lastDetection': '14 Sep, 19:15',
      'icon': Icons.camera_alt,
      'color': Colors.purple,
      'details': [
        {'time': '14 Sep, 19:15', 'level': 'high', 'content': 'Foto eksplisit'},
        {
          'time': '13 Sep, 15:45',
          'level': 'medium',
          'content': 'Story tidak pantas',
        },
        {'time': '12 Sep, 22:30', 'level': 'low', 'content': 'Caption vulgar'},
      ],
    },
    {
      'name': 'TikTok',
      'percentage': 10,
      'detections': 1,
      'lastDetection': '12 Sep, 16:20',
      'icon': Icons.music_note,
      'color': Colors.black,
      'details': [
        {
          'time': '12 Sep, 16:20',
          'level': 'medium',
          'content': 'Video dance tidak pantas',
        },
      ],
    },
  ];

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

  IconData _getThreatIcon(String level) {
    switch (level) {
      case 'low':
        return Icons.info_outline;
      case 'medium':
        return Icons.warning_outlined;
      case 'high':
        return Icons.dangerous_outlined;
      default:
        return Icons.help_outline;
    }
  }

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
                  'Ringkasan Aplikasi Terdeteksi',
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
                        appsHistory.length.toString(),
                        Icons.apps,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        'Terburuk',
                        appsHistory.first['name'],
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

          ...appsHistory.map((app) => _buildAppDetail(app)).toList(),
        ],
      ),
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
            color: app['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(app['icon'], color: app['color'], size: 20),
        ),
        title: Text(
          app['name'],
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          '${app['detections']} deteksi • ${app['percentage']}% dari total',
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
                  'History Deteksi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                ...app['details']
                    .map<Widget>((detail) => _buildDetectionItem(detail))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(Map<String, dynamic> detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getThreatColor(detail['level']).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getThreatColor(detail['level']).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getThreatIcon(detail['level']),
            color: _getThreatColor(detail['level']),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail['content'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${detail['time']} • ${_getThreatLabel(detail['level'])}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
