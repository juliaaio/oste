import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/articles/admin_articles_page.dart';
import 'package:oste/features/admin/articles/admin_article_store.dart';
import 'package:oste/features/admin/articles/add_article_page.dart';
import 'package:oste/features/admin/articles/edit_article_page.dart';
import 'package:oste/features/admin/articles/admin_article_detail_page.dart';

void main() {
  group('AdminArticlesPage Widget Tests', () {
    setUp(() {
      // Pastikan store diisi dengan artikel default
      AdminArticleStore();
    });

    testWidgets(
        'Renders Kelola Artikel page matching screenshot with 360x800 resolution',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header: Back button, Title "Kelola Artikel", Bell Notification
      expect(find.text('Kelola Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Search Bar: "Cari artikel..."
      expect(find.text('Cari artikel...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // 3. Artikel dari screenshot
      expect(find.text('Mengenal Osteoporosis'), findsOneWidget);
      expect(find.text('Jenis Osteoporosis dan Cara Mencegahnya'), findsOneWidget);
      expect(find.text('Pencegahan Osteoporosis Sejak Usia Muda'), findsOneWidget);
      expect(find.text('Mitos dan Fakta Osteoporosis'), findsOneWidget);
      expect(find.text('Skrining & Deteksi Osteoporosis'), findsOneWidget);

      // 4. Status Dipublikasikan pada tiap kartu
      expect(find.text('Dipublikasikan'), findsWidgets);

      // 5. Ikon Aksi Edit & Hapus pada setiap kartu
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

      // 6. Bottom Navigation Bar konsisten
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Tambah'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Search input filters article list dynamically',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Masukkan kata kunci pencarian "Mitos"
      await tester.enterText(find.byType(TextField), 'Mitos');
      await tester.pumpAndSettle();

      expect(find.text('Mitos dan Fakta Osteoporosis'), findsOneWidget);
      expect(find.text('Mengenal Osteoporosis'), findsNothing);

      // Bersihkan pencarian dengan tombol X
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Mengenal Osteoporosis'), findsOneWidget);
    });

    testWidgets('Tapping delete button shows confirmation dialog before deleting',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk tombol hapus pada artikel pertama
      final firstDeleteButton = find.byIcon(Icons.delete_outline_rounded).first;
      await tester.tap(firstDeleteButton);
      await tester.pumpAndSettle();

      // Dialog konfirmasi harus muncul
      expect(find.text('Hapus Artikel?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tekan Batal terlebih dahulu
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Artikel?'), findsNothing);
    });

    testWidgets('Tapping an article card navigates to AdminArticleDetailPage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk kartu "Mengenal Osteoporosis"
      await tester.tap(find.text('Mengenal Osteoporosis'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminArticleDetailPage), findsOneWidget);
      expect(find.text('Detail Artikel'), findsOneWidget);
    });

    testWidgets('Tapping edit icon navigates to EditArticlePage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk ikon pensil pada artikel pertama
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      expect(find.byType(EditArticlePage), findsOneWidget);
      expect(find.text('Edit Artikel'), findsOneWidget);
      expect(find.text('Perbarui Artikel'), findsOneWidget);
    });

    testWidgets('Tapping bottom nav Tambah navigates to AdminAddArticlePage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk Tambah di bottom nav
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.byType(AddArticlePage), findsOneWidget);
      expect(find.text('Tambah Artikel'), findsWidgets);
      expect(find.text('Simpan Artikel'), findsOneWidget);
    });
  });
}

