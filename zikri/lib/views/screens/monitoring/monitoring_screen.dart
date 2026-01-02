import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/monitoring/auto_screenshot_service.dart';
import '../../../services/monitoring/app_detection_service.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  final AutoScreenshotService _screenshotService =
      Get.find<AutoScreenshotService>();
  final AppDetectionService _appDetectionService = AppDetectionService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _checkPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (await Permission.systemAlertWindow.isDenied) {
        if (mounted) _showOverlayPermissionDialog();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () async {
      bool hasPermission = await _appDetectionService.hasPermission();
      if (!hasPermission && mounted) _showUsageStatsPermissionDialog();
    });
  }

  void _showOverlayPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(
              'Izin Overlay',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Aplikasi memerlukan izin "Display over other apps" untuk menampilkan alert NSFW di atas aplikasi yang sedang dibuka.',
          style: GoogleFonts.raleway(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Nanti')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Permission.systemAlertWindow.request();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showUsageStatsPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.apps, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(
              'Izin Usage Access',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Aplikasi memerlukan izin "Usage Access" untuk mendeteksi aplikasi yang sedang dibuka.',
          style: GoogleFonts.raleway(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Nanti')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _appDetectionService.requestPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Buka Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2E), Color(0xFF2D2D44), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Status Card
                      _buildStatusCard(),
                      const SizedBox(height: 20),

                      // Stats Grid
                      _buildStatsGrid(),
                      const SizedBox(height: 20),

                      // Control Button
                      _buildControlButton(),
                      const SizedBox(height: 24),

                      // Screenshot Gallery
                      _buildScreenshotGallery(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paradise Monitor',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Real-time Protection',
                style: GoogleFonts.raleway(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _screenshotService.isRecording.value
                    ? Colors.red.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _screenshotService.isRecording.value
                      ? Colors.red
                      : Colors.blue,
                  width: 2,
                ),
              ),
              child: Icon(
                _screenshotService.isRecording.value
                    ? Icons.fiber_manual_record
                    : Icons.play_circle_outline,
                color: _screenshotService.isRecording.value
                    ? Colors.red
                    : Colors.blue,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Obx(
      () => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _screenshotService.isRecording.value
                    ? [
                        const Color(0xFFEF4444).withOpacity(0.3),
                        const Color(0xFFDC2626).withOpacity(0.2),
                      ]
                    : [
                        const Color(0xFF6366F1).withOpacity(0.3),
                        const Color(0xFF4F46E5).withOpacity(0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _screenshotService.isRecording.value
                      ? Colors.red.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Pulsing Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: _screenshotService.isRecording.value
                            ? Colors.red.withOpacity(
                                0.5 + (_animationController.value * 0.5),
                              )
                            : Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: _screenshotService.isRecording.value
                            ? _animationController.value * 10
                            : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _screenshotService.isRecording.value
                        ? Icons.shield
                        : Icons.shield_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _screenshotService.isRecording.value
                      ? '🔴 PROTECTION ACTIVE'
                      : '⏸️ PROTECTION PAUSED',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _screenshotService.isRecording.value
                      ? 'Monitoring setiap 5 detik'
                      : 'Tekan tombol untuk mulai',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.camera_alt,
              label: 'Screenshots',
              value: '${_screenshotService.screenshotCount.value}',
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.apps,
              label: 'Current App',
              value: _screenshotService.currentApp.value.length > 8
                  ? '${_screenshotService.currentApp.value.substring(0, 8)}...'
                  : _screenshotService.currentApp.value,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.raleway(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton() {
    return Obx(
      () => GestureDetector(
        onTap: () {
          if (_screenshotService.isRecording.value) {
            _screenshotService.stopAutoScreenshot();
          } else {
            _screenshotService.startAutoScreenshot();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _screenshotService.isRecording.value
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFF10B981), const Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _screenshotService.isRecording.value
                    ? Colors.red.withOpacity(0.4)
                    : Colors.green.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _screenshotService.isRecording.value
                    ? Icons.stop_circle
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _screenshotService.isRecording.value
                    ? 'STOP MONITORING'
                    : 'START MONITORING',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotGallery() {
    return Obx(() {
      if (_screenshotService.screenshots.isEmpty) {
        return _buildEmptyGallery();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Screenshot History',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '${_screenshotService.screenshots.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _screenshotService.screenshots.length,
            reverse: true,
            itemBuilder: (context, index) {
              final reversedIndex =
                  _screenshotService.screenshots.length - 1 - index;
              final screenshot = _screenshotService.screenshots[reversedIndex];
              final imageBytes = screenshot['image_bytes'];

              return GestureDetector(
                onTap: () => _showFullscreenImage(screenshot),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(imageBytes, fit: BoxFit.cover),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        // Info
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  screenshot['app_name'],
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${screenshot['timestamp'].toString().substring(11, 19)}',
                                  style: GoogleFonts.raleway(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildEmptyGallery() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada screenshot',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai monitoring untuk melihat tangkapan layar',
            style: GoogleFonts.raleway(fontSize: 13, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFullscreenImage(Map<String, dynamic> screenshot) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: Image.memory(screenshot['image_bytes'])),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
