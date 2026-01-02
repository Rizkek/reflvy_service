import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/settings_controller.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    final SettingsController controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Pengaturan Proteksi',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Fitur Utama'),
            const SizedBox(height: 10),

            // Toggle Protection
            Obx(
              () => _buildSwitchTile(
                title: 'Proteksi Otomatis',
                subtitle: 'Blur & blokir konten tidak senonoh secara otomatis',
                value: controller.isProtectionEnabled.value,
                onChanged: controller.toggleProtection,
                icon: Icons.security,
                activeColor: Colors.green,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Konfigurasi Blokir'),
            const SizedBox(height: 10),

            // Toggle Social Media Block
            Obx(
              () => _buildSwitchTile(
                title: 'Blokir Media Sosial',
                subtitle: 'Batasi akses ke Instagram, TikTok, dll.',
                value: controller.blockSocialMedia.value,
                onChanged: controller.toggleSocialMediaBlock,
                icon: Icons.block,
                activeColor: Colors.red,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Sensitivitas Deteksi'),
            const SizedBox(height: 10),

            // Sensitivity Levels
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Obx(
                    () => _buildRadioTile(
                      title: 'Rendah (Low)',
                      subtitle: 'Hanya peringatan untuk konten ringan (Kuning)',
                      value: 1,
                      groupValue: controller.sensitivityLevel.value,
                      onChanged: (v) => controller.setSensitivity(v!),
                      color: Colors.amber,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => _buildRadioTile(
                      title: 'Sedang (Medium)',
                      subtitle: 'Blokir konten sugestif (Oranye)',
                      value: 2,
                      groupValue: controller.sensitivityLevel.value,
                      onChanged: (v) => controller.setSensitivity(v!),
                      color: Colors.orange,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => _buildRadioTile(
                      title: 'Tinggi (High)',
                      subtitle: 'Blokir ketat semua konten dewasa (Merah)',
                      value: 3,
                      groupValue: controller.sensitivityLevel.value,
                      onChanged: (v) => controller.setSensitivity(v!),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.raleway(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: activeColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.raleway(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required int value,
    required int groupValue,
    required Function(int?) onChanged,
    required Color color,
  }) {
    return RadioListTile<int>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: color,
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.raleway(
          fontSize: 12,
          color: const Color(0xFF64748B),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
