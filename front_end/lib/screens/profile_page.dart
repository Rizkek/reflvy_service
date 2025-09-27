import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/secure_storage_service.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  bool _isVerified = false;
  String? _gender;
  int? _age;
  String? _uid;
  DateTime? _loginTime;
  bool _tokenExpired = false;
  bool _updatingName = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await SecureStorageService.getUserData();
    final isExpired = await SecureStorageService.isTokenExpired();
    if (!mounted) return;
    if (user != null) {
      setState(() {
        _name = user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : 'Pengguna';
        _email = user.email;
        _isVerified = user.isVerified == true;
        _gender = user.gender;
        _age = user.age;
        _uid = user.uid;
        _loginTime = user.loginTime;
        _tokenExpired = isExpired;
      });
      return;
    }
    // Fallback to raw storage (if any legacy fields exist)
    final data = await SecureStorageService.getAllData();
    if (!mounted) return;
    setState(() {
      _name = data['display_name'] ?? 'Pengguna';
      _email = data['email'] ?? '-';
      _isVerified = data['is_verified'] == 'true';
      _gender = data['gender'];
      _age = int.tryParse(data['age'] ?? '');
      _uid = data['uid'];
      final lt = data['login_time'];
      if (lt != null) {
        _loginTime = DateTime.tryParse(lt);
      }
      _tokenExpired = isExpired;
    });
  }

  Future<void> _promptUpdateDisplayName() async {
    final controller = TextEditingController(text: _name ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ubah Display Name'),
          content: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'Masukkan nama baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (newName == null) return; // dismissed
    if (newName.isEmpty || newName == _name) {
      if (newName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong')),
        );
      }
      return;
    }

    setState(() => _updatingName = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada pengguna aktif')),
        );
        return;
      }

      await user.updateDisplayName(newName);
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;

      if (refreshed?.displayName?.trim() == newName) {
        await SecureStorageService.updateDisplayName(newName);
        if (!mounted) return;
        setState(() {
          _name = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memverifikasi perubahan nama di Firebase')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui nama: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingName = false);
    }
  }

  Future<void> _logout() async {
    await SecureStorageService.clearAllData();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF3B82F6),
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: isSmall ? 26 : 30,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: CircleAvatar(
                        radius: isSmall ? 22 : 26,
                        backgroundColor: Colors.white,
                        child: Text(
                          (_name != null && _name!.isNotEmpty) ? _name![0].toUpperCase() : 'U',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1F2937),
                            fontSize: isSmall ? 18 : 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _name ?? 'Pengguna',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: isSmall ? 16 : 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isVerified ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(_isVerified ? Icons.verified : Icons.error_outline, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isVerified ? 'Verified' : 'Unverified',
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: isSmall ? 12 : 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Quick stats
              Row(
                children: [
                  Expanded(
                    child: _statChip(
                      icon: Icons.fingerprint,
                      label: 'UID',
                      value: _uid != null && _uid!.length > 8 ? '${_uid!.substring(0, 4)}...${_uid!.substring(_uid!.length - 4)}' : (_uid ?? '-'),
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statChip(
                      icon: _tokenExpired ? Icons.lock_clock : Icons.lock_open,
                      label: 'Token',
                      value: _tokenExpired ? 'Expired' : 'Valid',
                      color: _tokenExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statChip(
                      icon: Icons.schedule,
                      label: 'Login',
                      value: _loginTime != null ? _formatDate(_loginTime!) : '-',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Personal Info
              _sectionCard(
                title: 'Informasi Pribadi',
                children: [
                  _editableInfoRow('Nama', _name ?? '-', onEdit: _updatingName ? null : _promptUpdateDisplayName),
                  const SizedBox(height: 10),
                  _infoRow('Email', _email ?? '-'),
                  const SizedBox(height: 10),
                  _infoRow('Gender', _gender ?? '-'),
                  const SizedBox(height: 10),
                  _infoRow('Umur', _age != null ? '$_age' : '-'),
                ],
              ),

              const SizedBox(height: 12),

              // Account & Security
              _sectionCard(
                title: 'Akun & Keamanan',
                children: [
                  _infoRow('UID', _uid ?? '-'),
                  const SizedBox(height: 10),
                  _infoRow('Status Email', _isVerified ? 'Terverifikasi' : 'Belum Verifikasi'),
                  const SizedBox(height: 10),
                  _infoRow('Token', _tokenExpired ? 'Expired' : 'Valid'),
                  const SizedBox(height: 10),
                  _infoRow('Login Terakhir', _loginTime != null ? _formatDate(_loginTime!) : '-'),
                ],
              ),

              const SizedBox(height: 12),

              // Navigate to Change Password Page
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/change-password',
                      arguments: {'email': _email},
                    );
                  },
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Ubah Password'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    foregroundColor: const Color(0xFF1F2937),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loadProfile,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Segarkan'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        foregroundColor: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _editableInfoRow(String label, String value, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Ubah nama',
              icon: _updatingName
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit, size: 18),
              onPressed: onEdit,
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statChip({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: const Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  String _formatDate(DateTime dt) {
    // e.g., 2025-09-27 14:35
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }
}
