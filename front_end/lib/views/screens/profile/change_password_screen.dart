import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/storage/secure_storage_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();
  String? _email;
  bool _isLoading = false;
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['email'] is String) {
      _email = (args['email'] as String?)?.trim();
    }
  }

  @override
  void dispose() {
    _oldPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPwd = _oldPwdController.text;
    final newPwd = _newPwdController.text;
    final confirmPwd = _confirmPwdController.text;

    if (newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = _email ?? user?.email;
    if (user == null || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada pengguna aktif')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cred = EmailAuthProvider.credential(email: email, password: oldPwd);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPwd);

      // Refresh token after password change
      final newToken = await user.getIdToken(true);
      if (newToken != null && newToken.isNotEmpty) {
        await SecureStorageService.updateToken(newToken);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Password lama salah';
          break;
        case 'weak-password':
          msg = 'Password baru terlalu lemah';
          break;
        case 'requires-recent-login':
          msg = 'Sesi login sudah lama, silakan login ulang';
          break;
        default:
          msg = e.message ?? 'Gagal mengubah password';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToForgot() {
    final email = _email ?? FirebaseAuth.instance.currentUser?.email;
    Navigator.pushNamed(
      context,
      '/forgot-password',
      arguments: {
        'initialEmail': email,
        'readOnlyEmail': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubah Password',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Password Lama', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldPwdController,
                  obscureText: !_showOld,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password lama',
                    suffixIcon: IconButton(
                      icon: Icon(_showOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showOld = !_showOld),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password lama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                Text('Password Baru', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPwdController,
                  obscureText: !_showNew,
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(_showNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showNew = !_showNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password baru minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                Text('Konfirmasi Password Baru', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPwdController,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    hintText: 'Ulangi password baru',
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Konfirmasi password wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _goToForgot,
                    child: const Text('Lupa password?'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Simpan Password Baru'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
