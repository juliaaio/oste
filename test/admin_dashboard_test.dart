import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/dashboard/admin_dashboard_page.dart';

void main() {
  group('AdminDashboardPage Widget Tests', () {
    testWidgets(
        'Renders Admin Dashboard with 360x800 resolution matching reference design',
        (WidgetTester tester) async {
      // Set ukuran layar tepat 360 x 800 px sesuai spesifikasi prompt
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header Osteo Admin & Bell Notification
      expect(find.text('Osteo Admin'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Sapaan Halo Admin & Subjudul
      expect(find.text('Halo, Admin!'), findsOneWidget);
      expect(find.text('Kelola informasi osteoporosis\ndi sini.'), findsOneWidget);

      // 3. Statistik Total Artikel & Dipublikasikan
      expect(find.text('Total Artikel'), findsOneWidget);
      expect(find.text('Dipublikasikan'), findsWidgets); // di stat card & artikel
      expect(find.text('05'), findsNWidgets(2));

      // 4. Menu Pengelolaan
      expect(find.text('Menu Pengelolaan'), findsOneWidget);
      expect(find.text('Kelola Artikel'), findsOneWidget);
      expect(find.text('Edit dan hapus artikel'), findsOneWidget);
      expect(find.text('Tambah Artikel'), findsOneWidget);
      expect(find.text('Buat artikel baru'), findsOneWidget);

      // 5. Artikel Terbaru
      expect(find.text('Artikel Terbaru'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);
      expect(find.text('Mengenal\nOsteoporosis'), findsOneWidget);

      // 6. Bottom Navigation Bar
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Tambah'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Tapping on bottom navigation tabs updates selection smoothly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap tab Artikel
      await tester.tap(find.text('Artikel'));
      await tester.pump();

      // Snackbar info muncul
      expect(find.text('Menu Artikel akan segera tersedia.'), findsOneWidget);

      // Tap tab Tambah
      await tester.tap(find.text('Tambah'));
      await tester.pump();

      expect(find.text('Menu Tambah akan segera tersedia.'), findsOneWidget);
    });

    testWidgets('Tapping management menu cards shows appropriate action feedback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Kelola Artikel
      await tester.tap(find.text('Kelola Artikel'));
      await tester.pump();
      expect(find.text('Menu Kelola Artikel dibuka.'), findsOneWidget);

      // Tap Tambah Artikel
      await tester.tap(find.text('Tambah Artikel'));
      await tester.pump();
      expect(find.text('Menu Tambah Artikel baru dibuka.'), findsOneWidget);
    });
  });
}

