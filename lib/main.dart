import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/admin/dashboard/admin_dashboard_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/doctor_dashboard/doctor_dashboard_page.dart';
import 'features/welcome/welcome_page.dart';
import 'routes/app_routes.dart';
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
      routes: {
        AppRoutes.welcome: (_) => const WelcomePage(),
        AppRoutes.dashboard: (_) => const DashboardPage(),
        AppRoutes.doctorDashboard: (_) => const DoctorDashboardPage(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardPage(),
      },
    );
  }
}

/// Menentukan halaman awal berdasarkan sesi Firebase yang aktif dan role terverifikasi dari Firestore.
///
/// - Jika sesi aktif & role admin → AdminDashboardPage.
/// - Jika sesi aktif & role dokter → DoctorDashboardPage.
/// - Jika sesi aktif & role pasien → DashboardPage (dashboard pasien).
/// - Jika tidak ada sesi → WelcomePage.
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

              // Arahkan berdasarkan role yang terverifikasi dari data Firestore
              if (currentUser.isAdmin) {
                return const AdminDashboardPage();
              }

              if (currentUser.isDoctor) {
                return const DoctorDashboardPage();
              }

              if (currentUser.isPatient) {
                return const DashboardPage();
              }

              // Role tidak valid atau tidak dikenali
              return Scaffold(
                backgroundColor: const Color(0xFFFFF9E8),
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 64,
                            color: Color(0xFFE11D48),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Role Pengguna Tidak Ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3748),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Akun Anda terotentikasi, namun role "${currentUser.role}" tidak memiliki hak akses yang sesuai di sistem.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718096),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => UserService().logout(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7C948),
                              foregroundColor: const Color(0xFF2D3748),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Keluar Akun',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        // Tidak ada sesi — tampilkan halaman Welcome
        return const WelcomePage();
      },
    );
  }
}
