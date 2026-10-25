import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/doctor_dashboard/doctor_dashboard_page.dart';
import 'features/welcome/welcome_page.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

/// Menentukan halaman awal berdasarkan sesi Firebase yang aktif dan role terverifikasi.
///
/// - Jika sesi aktif & role dokter → DoctorDashboardPage.
/// - Jika sesi aktif & role pasien → DashboardPage (dashboard pasien yang sekarang).
/// - Jika tidak ada sesi → WelcomePage (alur normal).
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final Stream<User?> stream;
    try {
      stream = FirebaseAuth.instance.authStateChanges();
    } catch (_) {
      // Firebase belum diinisialisasi (misal di lingkungan widget test)
      return const WelcomePage();
    }

    return StreamBuilder<User?>(
      stream: stream,
      builder: (context, snapshot) {
        // Masih menunggu status auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF7C948),
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // Sesi aktif — dengarkan UserService untuk verifikasi role Firestore
          return AnimatedBuilder(
            animation: UserService(),
            builder: (context, _) {
              final currentUser = UserService().currentUser;

              // Masih memuat data profil dari Firestore
              if (currentUser == null) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF7C948),
                    ),
                  ),
                );
              }

              // Arahkan berdasarkan role yang terverifikasi
              if (currentUser.isDoctor) {
                return const DoctorDashboardPage();
              }

              // Pasien masuk ke dashboard pasien yang sekarang
              return const DashboardPage();
            },
          );
        }

        // Tidak ada sesi — tampilkan halaman Welcome
        return const WelcomePage();
      },
    );
  }
}