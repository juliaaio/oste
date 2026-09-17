import 'package:flutter/material.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';

/// Halaman pemilih akun Google (UI dummy, belum terintegrasi Firebase Auth).
///
/// Menampilkan daftar akun yang bisa dipilih pengguna untuk melanjutkan
/// ke aplikasi Oste. Mengikuti desain Figma Google Account Picker.
class GoogleAccountPickerPage extends StatelessWidget {
  const GoogleAccountPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Colors.white],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _PickerCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF5F6368)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Google Logo ─────────────────────────────────────────────────
          const _GoogleLogo(),

          // ── Title & Subtitle ────────────────────────────────────────────
          const SizedBox(height: 16),
          const Text(
            'Pilih akun',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202124),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'untuk melanjutkan ke Osteocare',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5F6368),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // ── Divider ─────────────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

          // ── Account List ────────────────────────────────────────────────
          _AccountTile(
            avatar: _PhotoAvatar(),
            name: 'Risma Putri',
            email: 'risma@gmail.com',
            onTap: (context) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
          ),
          const Divider(height: 1, indent: 72, color: Color(0xFFF1F3F4)),
          _AccountTile(
            avatar: _InitialAvatar(initial: 'R', color: Color(0xFF1A73E8)),
            name: 'Risma',
            email: 'risma@student.ac.id',
            onTap: null,
          ),
          const Divider(height: 1, indent: 72, color: Color(0xFFF1F3F4)),
          _AccountTile(
            avatar: _InitialAvatar(initial: 'A', color: Color(0xFF7B1FA2)),
            name: 'Andini',
            email: 'andini@gmail.com',
            onTap: null,
          ),
          const Divider(height: 1, indent: 72, color: Color(0xFFF1F3F4)),
          _UseAnotherAccountTile(),

          // ── Divider ─────────────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

          // ── Footer ──────────────────────────────────────────────────────
          _Footer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Google Logo (text-based, pixel-perfect) ─────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    // Representasi teks logo Google dengan warna yang benar
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('G', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
          Text('o', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFEA4335))),
          Text('o', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFBBC05))),
          Text('g', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
          Text('l', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF34A853))),
          Text('e', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFEA4335))),
        ],
      ),
    );
  }
}

// ── Account Tile ─────────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.avatar,
    required this.name,
    required this.email,
    required this.onTap,
  });

  final Widget avatar;
  final String name;
  final String email;
  final void Function(BuildContext context)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap!(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F6368),
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
}

// ── "Gunakan akun lain" tile ─────────────────────────────────────────────────

class _UseAnotherAccountTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigasi ke halaman login akan diimplementasikan nanti
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F3F4),
              ),
              child: const Icon(
                Icons.person_add_outlined,
                size: 20,
                color: Color(0xFF5F6368),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Gunakan akun lain',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF202124),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar Widgets ────────────────────────────────────────────────────────────

/// Avatar foto untuk akun pertama (Risma Putri)
class _PhotoAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD4A574),
        image: null, // Ganti dengan DecorationImage jika ada aset foto
      ),
      child: ClipOval(
        child: Container(
          color: const Color(0xFFBCAAA4),
          child: const Icon(Icons.person, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}

/// Avatar inisial huruf dengan warna latar belakang
class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: RichText(
        textAlign: TextAlign.left,
        text: const TextSpan(
          style: TextStyle(fontSize: 12, color: Color(0xFF5F6368), height: 1.5),
          children: [
            TextSpan(text: 'Dengan melanjutkan, Anda menyetujui '),
            TextSpan(
              text: 'Kebijakan Privasi',
              style: TextStyle(color: Color(0xFF1A73E8)),
            ),
            TextSpan(text: '\ndan '),
            TextSpan(
              text: 'Persyaratan Layanan',
              style: TextStyle(color: Color(0xFF1A73E8)),
            ),
            TextSpan(text: ' Google.'),
          ],
        ),
      ),
    );
  }
}
