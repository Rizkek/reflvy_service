import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181818)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Syarat dan Ketentuan',
          style: GoogleFonts.raleway(
            color: const Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Ketentuan Umum',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dengan menggunakan aplikasi ini, Anda menyetujui untuk terikat dengan syarat dan ketentuan yang berlaku. Jika Anda tidak setuju dengan salah satu ketentuan ini, Anda tidak diperkenankan menggunakan aplikasi.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '2. Penggunaan Aplikasi',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda bertanggung jawab untuk menjaga kerahasiaan akun dan password Anda. Aplikasi ini hanya boleh digunakan untuk tujuan yang legal dan sesuai dengan ketentuan yang berlaku.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '3. Batasan Usia',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pengguna aplikasi ini harus berusia minimal 13 tahun. Pengguna di bawah 18 tahun harus mendapat persetujuan dari orang tua atau wali yang sah.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '4. Privasi',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami menghargai privasi Anda. Penggunaan data pribadi Anda akan diatur sesuai dengan Kebijakan Privasi kami.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '5. Perubahan Ketentuan',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami berhak untuk mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan efektif setelah diumumkan dalam aplikasi.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
