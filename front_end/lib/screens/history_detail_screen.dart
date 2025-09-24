import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final String historyId;
  final String url;
  final String result;
  final DateTime timestamp;
  final String? description;
  final double? confidenceScore;

  const HistoryDetailScreen({
    super.key,
    required this.historyId,
    required this.url,
    required this.result,
    required this.timestamp,
    this.description,
    this.confidenceScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    // Tentukan warna dan ikon berdasarkan hasil
    switch (result) {
      case 'blocked':
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'DIBLOKIR';
        break;
      case 'safe':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'AMAN';
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'PERINGATAN';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'UNKNOWN';
    }

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
          'Detail Riwayat',
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Text(
                  'Bagikan',
                  style: GoogleFonts.raleway(),
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Text(
                  'Laporkan Masalah',
                  style: GoogleFonts.raleway(),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(statusColor, statusIcon, statusText),

            const SizedBox(height: 24),

            // URL Information
            _buildInfoSection('Informasi URL', [
              _buildInfoRow('URL', url),
              _buildInfoRow('Tanggal & Waktu', _formatDateTime(timestamp)),
              if (confidenceScore != null)
                _buildInfoRow(
                    'Tingkat Akurasi', '${(confidenceScore! * 100).toInt()}%'),
            ]),

            const SizedBox(height: 24),

            // Detection Details
            if (description != null)
              _buildInfoSection('Detail Deteksi', [
                _buildInfoRow('Deskripsi', description!),
                _buildInfoRow('Tindakan', _getActionText(result)),
              ]),

            const SizedBox(height: 24),

            // Technical Information
            _buildInfoSection('Informasi Teknis', [
              _buildInfoRow('ID Riwayat', historyId),
              _buildInfoRow('Status', statusText),
              _buildInfoRow('Metode Deteksi', 'AI Deep Learning'),
              _buildInfoRow('Engine Version', 'v2.1.0'),
            ]),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(statusColor),
          ],
        ),
      ),
    );
  }

  /// Widget untuk card status utama
  Widget _buildStatusCard(
      Color statusColor, IconData statusIcon, String statusText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(statusIcon, color: statusColor, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: GoogleFonts.raleway(
              color: statusColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            url,
            style: GoogleFonts.raleway(
              color: const Color(0xFF181818),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (confidenceScore != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Akurasi: ${(confidenceScore! * 100).toInt()}%',
                style: GoogleFonts.raleway(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget untuk section informasi
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Widget untuk baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.raleway(
                color: const Color(0xFF979797),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk tombol aksi
  Widget _buildActionButtons(Color statusColor) {
    return Column(
      children: [
        // Tombol utama berdasarkan status
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _handlePrimaryAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(_getPrimaryActionIcon()),
            label: Text(
              _getPrimaryActionText(),
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tombol sekunder
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDetailDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3F88EB),
                  side: const BorderSide(color: Color(0xFF3F88EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.info_outline, size: 18),
                label: Text(
                  'Detail Teknis',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareResult(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3F88EB),
                  side: const BorderSide(color: Color(0xFF3F88EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(
                  'Bagikan',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Format date time untuk display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Dapatkan teks aksi berdasarkan hasil
  String _getActionText(String result) {
    switch (result) {
      case 'blocked':
        return 'Konten diblokir dan akses ditolak';
      case 'safe':
        return 'Konten diizinkan untuk diakses';
      case 'warning':
        return 'Peringatan ditampilkan kepada pengguna';
      default:
        return 'Tidak ada tindakan yang diambil';
    }
  }

  /// Dapatkan teks tombol utama
  String _getPrimaryActionText() {
    switch (result) {
      case 'blocked':
        return 'Laporkan False Positive';
      case 'safe':
        return 'Laporkan Jika Berbahaya';
      case 'warning':
        return 'Berikan Feedback';
      default:
        return 'Laporkan Masalah';
    }
  }

  /// Dapatkan ikon tombol utama
  IconData _getPrimaryActionIcon() {
    switch (result) {
      case 'blocked':
        return Icons.report_outlined;
      case 'safe':
        return Icons.feedback_outlined;
      case 'warning':
        return Icons.rate_review_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// Handle aksi utama
  void _handlePrimaryAction() {
    Get.snackbar(
      'Info',
      'Fitur ${_getPrimaryActionText().toLowerCase()} akan segera tersedia',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Handle aksi menu
  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareResult();
        break;
      case 'report':
        _reportProblem();
        break;
    }
  }

  /// Tampilkan dialog detail teknis
  void _showDetailDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Detail Teknis',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Deteksi: $historyId', style: GoogleFonts.raleway()),
            const SizedBox(height: 8),
            Text('Algoritma: Deep Learning CNN', style: GoogleFonts.raleway()),
            const SizedBox(height: 8),
            Text('Model Version: v2.1.0', style: GoogleFonts.raleway()),
            const SizedBox(height: 8),
            if (confidenceScore != null)
              Text('Confidence Score: ${confidenceScore!.toStringAsFixed(3)}',
                  style: GoogleFonts.raleway()),
            const SizedBox(height: 8),
            Text('Processing Time: <100ms', style: GoogleFonts.raleway()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Tutup',
              style: GoogleFonts.raleway(color: const Color(0xFF3F88EB)),
            ),
          ),
        ],
      ),
    );
  }

  /// Bagikan hasil deteksi
  void _shareResult() {
    Get.snackbar(
      'Info',
      'Fitur berbagi akan segera tersedia',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Laporkan masalah
  void _reportProblem() {
    Get.snackbar(
      'Info',
      'Fitur laporan masalah akan segera tersedia',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
