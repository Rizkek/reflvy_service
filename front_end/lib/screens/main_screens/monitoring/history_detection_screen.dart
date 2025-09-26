import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/notification_history_service.dart';

class HistoryDetectionScreen extends StatefulWidget {
  const HistoryDetectionScreen({super.key});

  @override
  State<HistoryDetectionScreen> createState() => _HistoryDetectionScreenState();
}

class _HistoryDetectionScreenState extends State<HistoryDetectionScreen> {
  final NotificationHistoryService _historyService =
      NotificationHistoryService();
  List<Map<String, dynamic>> allDetections = [];
  List<Map<String, dynamic>> filteredDetections = [];
  String selectedFilter = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDetections();
  }

  void _loadDetections() {
    // Get real notifications from service and convert to detection format
    final notifications = _historyService.getAllNotifications();

    allDetections = notifications.map((notif) {
      return {
        'id': notif['id'],
        'date': notif['date'],
        'time': notif['time'],
        'app': notif['app'],
        'contentType': _extractContentType(notif['message']),
        'duration': _generateDuration(),
        'action': _extractAction(notif['message'], notif['level']),
        'level': notif['level'],
        'icon': _getAppIcon(notif['app']),
        'color': _getAppColor(notif['app']),
        'riskColor': _getRiskColor(notif['level']),
        'timestamp': notif['timestamp'] ?? DateTime.now(),
      };
    }).toList();

    // Add some additional sample data if empty
    if (allDetections.isEmpty) {
      _addSampleDetections();
    }

    _applyFilters();
  }

  void _addSampleDetections() {
    // Add some realistic sample detections based on common threat scenarios
    _historyService.addThreatNotification(
      threatLevel: 'high',
      appName: 'Facebook',
      contentType: 'Konten NSFW',
      action: 'Aplikasi diblokir',
    );

    _historyService.addThreatNotification(
      threatLevel: 'medium',
      appName: 'Twitter',
      contentType: 'Konten NSFW',
      action: 'User abaikan',
    );

    _historyService.addThreatNotification(
      threatLevel: 'low',
      appName: 'YouTube',
      contentType: 'Konten kekerasan ringan',
      action: 'User abaikan',
    );

    _historyService.addThreatNotification(
      threatLevel: 'low',
      appName: 'YouTube',
      contentType: 'Konten kekerasan ringan',
      action: 'Aplikasi diblokir',
    );

    // Reload detections from service
    final notifications = _historyService.getAllNotifications();
    allDetections = notifications.map((notif) {
      return {
        'id': notif['id'],
        'date': _formatDateDetection(notif['timestamp'] ?? DateTime.now()),
        'time': notif['time'],
        'app': notif['app'],
        'contentType': _extractContentType(notif['message']),
        'duration': _generateDuration(),
        'action':
            notif['action'] ?? _extractAction(notif['message'], notif['level']),
        'level': notif['level'],
        'icon': _getAppIcon(notif['app']),
        'color': _getAppColor(notif['app']),
        'riskColor': _getRiskColor(notif['level']),
        'timestamp': notif['timestamp'] ?? DateTime.now(),
      };
    }).toList();
  }

  String _formatDateDetection(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _extractContentType(String message) {
    if (message.contains('eksplisit') || message.contains('NSFW')) {
      return 'Konten NSFW';
    } else if (message.contains('kekerasan')) {
      return 'Konten kekerasan ringan';
    } else if (message.contains('dewasa')) {
      return 'Konten dewasa';
    } else if (message.contains('tidak pantas')) {
      return 'Konten tidak pantas';
    } else {
      return 'Konten berisiko';
    }
  }

  String _generateDuration() {
    final durations = [
      '1 menit',
      '5 menit',
      '15 menit',
      '30 menit',
      '45 menit',
      '1 jam',
    ];
    return durations[DateTime.now().millisecond % durations.length];
  }

  String _extractAction(String message, String level) {
    if (message.contains('diblokir') ||
        message.contains('ditutup') ||
        level == 'high') {
      return 'Aplikasi diblokir';
    } else if (message.contains('abaikan')) {
      return 'User abaikan';
    } else {
      return 'Peringatan ditampilkan';
    }
  }

  IconData _getAppIcon(String app) {
    switch (app.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_fill;
      case 'instagram':
        return Icons.camera_alt;
      case 'tiktok':
        return Icons.music_note;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'system':
        return Icons.security;
      default:
        return Icons.apps;
    }
  }

  Color _getAppColor(String app) {
    switch (app.toLowerCase()) {
      case 'youtube':
        return Colors.red;
      case 'instagram':
        return Colors.purple;
      case 'tiktok':
        return Colors.black;
      case 'facebook':
        return Colors.blue;
      case 'twitter':
        return Colors.lightBlue;
      case 'system':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRiskLabel(String level) {
    switch (level) {
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'LOW';
      default:
        return 'UNKNOWN';
    }
  }

  void _applyFilters() {
    setState(() {
      filteredDetections = allDetections.where((detection) {
        bool matchesFilter =
            selectedFilter == 'Semua' ||
            _getRiskLabel(detection['level']) == selectedFilter;

        bool matchesSearch =
            searchQuery.isEmpty ||
            detection['app'].toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            detection['contentType'].toLowerCase().contains(
              searchQuery.toLowerCase(),
            );

        return matchesFilter && matchesSearch;
      }).toList();

      // Sort by timestamp (newest first)
      filteredDetections.sort(
        (a, b) => b['timestamp'].compareTo(a['timestamp']),
      );
    });
  }

  void _onFilterChanged(String filter) {
    selectedFilter = filter;
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    searchQuery = query;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    // Calculate statistics
    final totalDetections = allDetections.length;
    final highRiskCount = allDetections
        .where((d) => d['level'] == 'high')
        .length;
    final weekChange = totalDetections > 0
        ? ((totalDetections - 23) / 23 * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'History Deteksi',
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Riwayat lengkap aktivitas monitoring',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Statistics Header
          Container(
            margin: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik Minggu Ini',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Deteksi',
                        '$totalDetections',
                        weekChange >= 0
                            ? '↗ $weekChange%'
                            : '↘ ${weekChange.abs()}%',
                        weekChange >= 0 ? Colors.green : Colors.red,
                        isSmallScreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'High Risk',
                        '$highRiskCount',
                        '− Sama',
                        Colors.grey,
                        isSmallScreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari aplikasi atau konten...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('Semua'),
                      _buildFilterChip('HIGH'),
                      _buildFilterChip('Medium'),
                      _buildFilterChip('LOW'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detection List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Deteksi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${filteredDetections.length} hasil',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Detection List
          Expanded(
            child: filteredDetections.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDetections.length,
                    itemBuilder: (context, index) {
                      return _buildDetectionItem(filteredDetections[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String change,
    Color changeColor,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 11 : 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 10 : 11,
              color: changeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => _onFilterChanged(label),
        backgroundColor: Colors.grey.shade200,
        selectedColor: const Color(0xFF6366F1),
        checkmarkColor: Colors.white,
        elevation: 0,
        pressElevation: 0,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Deteksi',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada hasil untuk filter yang dipilih',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(Map<String, dynamic> detection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date/time and risk level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${detection['date']} • ${detection['time']}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: detection['riskColor'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRiskLabel(detection['level']),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // App and content info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: detection['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  detection['icon'],
                  color: detection['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection['app'],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      detection['contentType'],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'Durasi: ${detection['duration']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action taken
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: detection['action'].contains('diblokir')
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: detection['action'].contains('diblokir')
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Aksi: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: detection['action'].contains('diblokir')
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    detection['action'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: detection['action'].contains('diblokir')
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
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
