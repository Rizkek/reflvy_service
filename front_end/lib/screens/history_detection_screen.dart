import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_detail_screen.dart';

// Model untuk history detection
class DetectionHistory {
  final String id;
  final String url;
  final String result; // 'blocked', 'safe', 'warning'
  final DateTime timestamp;
  final String? description;
  final double? confidenceScore;

  DetectionHistory({
    required this.id,
    required this.url,
    required this.result,
    required this.timestamp,
    this.description,
    this.confidenceScore,
  });
}

// Provider untuk history detection
final detectionHistoryProvider =
    StateProvider<List<DetectionHistory>>((ref) => [
          DetectionHistory(
            id: '1',
            url: 'example.com/page1',
            result: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            description: 'Konten NSFW terdeteksi dan diblokir',
            confidenceScore: 0.95,
          ),
          DetectionHistory(
            id: '2',
            url: 'safe-website.com',
            result: 'safe',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            description: 'Website aman untuk diakses',
            confidenceScore: 0.98,
          ),
          DetectionHistory(
            id: '3',
            url: 'suspicious-site.com',
            result: 'warning',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            description: 'Konten mencurigakan terdeteksi',
            confidenceScore: 0.75,
          ),
          DetectionHistory(
            id: '4',
            url: 'malicious-content.com',
            result: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            description: 'Konten berbahaya diblokir',
            confidenceScore: 0.92,
          ),
          DetectionHistory(
            id: '5',
            url: 'news-portal.com',
            result: 'safe',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            description: 'Portal berita aman',
            confidenceScore: 0.99,
          ),
        ]);

// Provider untuk filter
final historyFilterProvider = StateProvider<String>(
    (ref) => 'all'); // 'all', 'blocked', 'safe', 'warning'

class HistoryDetectionScreen extends ConsumerWidget {
  const HistoryDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHistory = ref.watch(detectionHistoryProvider);
    final currentFilter = ref.watch(historyFilterProvider);

    // Filter history berdasarkan filter yang dipilih
    final filteredHistory = currentFilter == 'all'
        ? allHistory
        : allHistory.where((item) => item.result == currentFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181818)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Riwayat Deteksi',
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterOptions(ref),
            icon: const Icon(Icons.filter_list, color: Color(0xFF181818)),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, ref),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_history',
                child: Text(
                  'Hapus Riwayat',
                  style: GoogleFonts.raleway(),
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Text(
                  'Export Data',
                  style: GoogleFonts.raleway(),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(ref, currentFilter),

          // Statistics Summary
          _buildStatsSummary(allHistory),

          // History List
          Expanded(
            child: filteredHistory.isEmpty
                ? _buildEmptyState(currentFilter)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = filteredHistory[index];
                      return _buildHistoryItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk filter chips
  Widget _buildFilterChips(WidgetRef ref, String currentFilter) {
    final filters = [
      {'key': 'all', 'label': 'Semua', 'icon': Icons.list},
      {'key': 'blocked', 'label': 'Diblokir', 'icon': Icons.block},
      {'key': 'safe', 'label': 'Aman', 'icon': Icons.check_circle},
      {'key': 'warning', 'label': 'Peringatan', 'icon': Icons.warning},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = currentFilter == filter['key'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF3F88EB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF3F88EB),
                    ),
                  ),
                ],
              ),
              selectedColor: const Color(0xFF3F88EB),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF3F88EB)),
              onSelected: (selected) {
                ref.read(historyFilterProvider.notifier).state =
                    filter['key'] as String;
              },
            ),
          );
        },
      ),
    );
  }

  /// Widget untuk ringkasan statistik
  Widget _buildStatsSummary(List<DetectionHistory> history) {
    final blockedCount =
        history.where((item) => item.result == 'blocked').length;
    final safeCount = history.where((item) => item.result == 'safe').length;
    final warningCount =
        history.where((item) => item.result == 'warning').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Diblokir', blockedCount, Colors.red, Icons.block),
          _buildStatItem('Aman', safeCount, Colors.green, Icons.check_circle),
          _buildStatItem(
              'Peringatan', warningCount, Colors.orange, Icons.warning),
        ],
      ),
    );
  }

  /// Widget untuk item statistik
  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            color: const Color(0xFF979797),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Widget untuk state kosong
  Widget _buildEmptyState(String filter) {
    String message;
    switch (filter) {
      case 'blocked':
        message = 'Tidak ada konten yang diblokir';
        break;
      case 'safe':
        message = 'Tidak ada website aman yang tercatat';
        break;
      case 'warning':
        message = 'Tidak ada peringatan yang tercatat';
        break;
      default:
        message = 'Belum ada riwayat deteksi';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Data',
            style: GoogleFonts.raleway(
              color: const Color(0xFF181818),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.raleway(
              color: const Color(0xFF979797),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk item history
  Widget _buildHistoryItem(DetectionHistory item) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (item.result) {
      case 'blocked':
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'Diblokir';
        break;
      case 'safe':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Aman';
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Peringatan';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.url,
                style: GoogleFonts.raleway(
                  color: const Color(0xFF181818),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.raleway(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (item.description != null)
              Text(
                item.description!,
                style: GoogleFonts.raleway(
                  color: const Color(0xFF979797),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatTimestamp(item.timestamp),
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF979797),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.confidenceScore != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Akurasi: ${(item.confidenceScore! * 100).toInt()}%',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF979797),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigasi ke detail screen
          Get.to(() => HistoryDetailScreen(
                historyId: item.id,
                url: item.url,
                result: item.result,
                timestamp: item.timestamp,
                description: item.description,
                confidenceScore: item.confidenceScore,
              ));
        },
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF979797),
        ),
      ),
    );
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Tampilkan opsi filter
  void _showFilterOptions(WidgetRef ref) {
    // Implementasi sudah ada di filter chips
  }

  /// Handle aksi menu
  void _handleMenuAction(String action, WidgetRef ref) {
    switch (action) {
      case 'clear_history':
        _clearHistory(ref);
        break;
      case 'export':
        Get.snackbar(
          'Info',
          'Fitur export data coming soon',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        break;
    }
  }

  /// Hapus riwayat
  void _clearHistory(WidgetRef ref) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Hapus Riwayat',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua riwayat deteksi?',
          style: GoogleFonts.raleway(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.raleway(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(detectionHistoryProvider.notifier).state = [];
              Get.back();
              Get.snackbar(
                'Info',
                'Riwayat deteksi telah dihapus',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.raleway(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
