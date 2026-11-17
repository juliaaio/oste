import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/dashboard/admin_dashboard_page.dart';
import 'package:oste/services/article_repository.dart';
import 'package:oste/services/doctor_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminDashboardPage UI & Integration Tests', () {
    testWidgets('Renders Header, Welcome Card, and eliminates notification bell',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pump();

      // Header Osteo and Dashboard Admin
      expect(find.text('Osteo'), findsOneWidget);
      expect(find.text('Dashboard Admin'), findsOneWidget);

      // Notification bell must NOT be present
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
      expect(find.byIcon(Icons.notifications), findsNothing);

      // Welcome Card
      expect(find.text('Halo, Admin!'), findsOneWidget);
      expect(
        find.text(
          'Kelola data dokter, artikel,\ndan konten edukasi\nOsteo di sini.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders real-time statistics from repositories',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pump();

      final expectedDoctors = DoctorRepository().totalCount.toString();
      final expectedArticles = ArticleRepository().totalCount.toString();

      expect(find.text('Total Dokter'), findsOneWidget);
      expect(find.text(expectedDoctors), findsOneWidget);

      expect(find.text('Total Artikel'), findsOneWidget);
      expect(find.text(expectedArticles), findsOneWidget);
    });

    testWidgets('Renders 3 Management Cards with proper titles and descriptions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Menu Pengelolaan'), findsOneWidget);

      // 1. Kelola Dokter
      expect(find.text('Kelola Dokter'), findsOneWidget);
      expect(find.text('Tambah, ubah, dan hapus data dokter'), findsOneWidget);

      // 2. Kelola Edukasi
      expect(find.text('Kelola Edukasi'), findsOneWidget);
      expect(
        find.text(
            'Tambah, ubah, dan hapus materi latihan, nutrisi, dan vitamin'),
        findsOneWidget,
      );

      // 3. Kelola Artikel
      expect(find.text('Kelola Artikel'), findsOneWidget);
      expect(find.text('Tambah, ubah, dan hapus artikel'), findsOneWidget);

      // Chevrons
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
    });

    testWidgets('Renders 5 Bottom Navigation items with Beranda active',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Dokter'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Home icon for active Beranda
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });
  });
}
