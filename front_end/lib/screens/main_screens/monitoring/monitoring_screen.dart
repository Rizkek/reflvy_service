import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raflefly_front/screens/main_screens/monitoring/history_detection_screen.dart';
import 'package:raflefly_front/services/pop_up_alert.dart';

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
                  SizedBox(
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
