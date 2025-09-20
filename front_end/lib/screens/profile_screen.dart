import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers untuk mengelola state profile
final userNameProvider = StateProvider<String>((ref) => 'John Doe');
final userEmailProvider =
    StateProvider<String>((ref) => 'john.doe@example.com');
final notificationEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeProvider = StateProvider<bool>((ref) => false);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers untuk reactive updates
    final userName = ref.watch(userNameProvider);
    final userEmail = ref.watch(userEmailProvider);
    final notificationEnabled = ref.watch(notificationEnabledProvider);
    final darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementasi edit profile
              Get.snackbar(
                'Info',
                'Fitur edit profile coming soon',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.edit, color: Color(0xFF181818)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(userName, userEmail),

            const SizedBox(height: 32),

            // Settings Section
            _buildSettingsSection(ref, notificationEnabled, darkMode),

            const SizedBox(height: 24),

            // Account Section
            _buildAccountSection(),

            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(),

            const SizedBox(height: 32),

            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  /// Widget untuk header profile
  Widget _buildProfileHeader(String userName, String userEmail) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF3F88EB),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: GoogleFonts.raleway(
              color: const Color(0xFF181818),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: GoogleFonts.raleway(
              color: const Color(0xFF979797),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Premium User',
              style: GoogleFonts.raleway(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk section pengaturan
  Widget _buildSettingsSection(
      WidgetRef ref, bool notificationEnabled, bool darkMode) {
    return Container(
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
              'Pengaturan',
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSettingsItem(
            'Notifikasi',
            'Terima notifikasi untuk aktivitas terbaru',
            Icons.notifications_outlined,
            trailing: Switch(
              value: notificationEnabled,
              onChanged: (value) {
                ref.read(notificationEnabledProvider.notifier).state = value;
              },
              activeColor: const Color(0xFF3F88EB),
            ),
          ),
          _buildSettingsItem(
            'Mode Gelap',
            'Ubah tema aplikasi ke mode gelap',
            Icons.dark_mode_outlined,
            trailing: Switch(
              value: darkMode,
              onChanged: (value) {
                ref.read(darkModeProvider.notifier).state = value;
                Get.snackbar(
                  'Info',
                  'Mode gelap akan diterapkan di update berikutnya',
                  backgroundColor: Colors.grey,
                  colorText: Colors.white,
                );
              },
              activeColor: const Color(0xFF3F88EB),
            ),
          ),
          _buildSettingsItem(
            'Keamanan',
            'Kelola pengaturan keamanan akun',
            Icons.security_outlined,
            onTap: () {
              Get.snackbar(
                'Info',
                'Pengaturan keamanan coming soon',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Widget untuk section akun
  Widget _buildAccountSection() {
    return Container(
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
              'Akun',
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSettingsItem(
            'Ubah Password',
            'Perbarui password akun Anda',
            Icons.lock_outlined,
            onTap: () {
              Get.snackbar(
                'Info',
                'Fitur ubah password coming soon',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
          _buildSettingsItem(
            'Privasi',
            'Kelola pengaturan privasi data',
            Icons.privacy_tip_outlined,
            onTap: () {
              Get.snackbar(
                'Info',
                'Pengaturan privasi coming soon',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
          _buildSettingsItem(
            'Hapus Akun',
            'Hapus akun secara permanen',
            Icons.delete_outline,
            textColor: Colors.red,
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  /// Widget untuk section tentang
  Widget _buildAboutSection() {
    return Container(
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
              'Tentang',
              style: GoogleFonts.raleway(
                color: const Color(0xFF181818),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSettingsItem(
            'Bantuan & Dukungan',
            'Dapatkan bantuan dan dukungan',
            Icons.help_outline,
            onTap: () {
              Get.snackbar(
                'Info',
                'Halaman bantuan coming soon',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
          _buildSettingsItem(
            'Syarat & Ketentuan',
            'Baca syarat dan ketentuan layanan',
            Icons.description_outlined,
            onTap: () {
              Get.snackbar(
                'Info',
                'Syarat & ketentuan coming soon',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
          _buildSettingsItem(
            'Versi Aplikasi',
            'v1.0.0',
            Icons.info_outline,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  /// Widget untuk item pengaturan
  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? const Color(0xFF181818)),
      title: Text(
        title,
        style: GoogleFonts.raleway(
          color: textColor ?? const Color(0xFF181818),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.raleway(
          color: const Color(0xFF979797),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          (showArrow
              ? const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Color(0xFF979797))
              : null),
    );
  }

  /// Widget untuk tombol logout
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Keluar',
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Dialog konfirmasi logout
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
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
              Get.back();
              // TODO: Implementasi logout
              Get.snackbar(
                'Info',
                'Berhasil keluar dari aplikasi',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.raleway(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog konfirmasi hapus akun
  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Hapus Akun',
          style: GoogleFonts.raleway(
              fontWeight: FontWeight.w700, color: Colors.red),
        ),
        content: Text(
          'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.',
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
              Get.back();
              Get.snackbar(
                'Info',
                'Fitur hapus akun coming soon',
                backgroundColor: Colors.orange,
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
