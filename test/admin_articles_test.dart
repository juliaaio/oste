import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/articles/add_article_page.dart';
import 'package:oste/features/admin/articles/admin_article_detail_page.dart';
import 'package:oste/features/admin/articles/admin_article_store.dart';
import 'package:oste/features/admin/articles/admin_articles_page.dart';
import 'package:oste/features/admin/articles/edit_article_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminArticlesPage Widget Tests', () {
    setUp(() {
      AdminArticleStore();
    });

    testWidgets(
        'Renders Header, Title, Description, Search Bar, Add Button, and Bottom Nav',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      // Header Osteo & Kelola Artikel
      expect(find.text('Osteo'), findsOneWidget);
      expect(find.text('Kelola Artikel'), findsOneWidget);
      expect(
        find.text('Kelola artikel kesehatan seputar osteoporosis.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // Search Bar
      expect(find.text('Cari judul artikel...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Tombol Tambah Artikel
      expect(find.text('Tambah Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Bottom Navigation Bar with Artikel tab
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Dokter'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets(
        'Renders article cards with thumbnail, title, published date, edit & delete buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      // Artikel sesuai screenshot
      expect(
        find.text(
            'Mengenal Osteoporosis: Penyebab, Gejala, dan Pencegahan'),
        findsOneWidget,
      );
      expect(
        find.text('Makanan yang Baik untuk Kesehatan Tulang'),
        findsOneWidget,
      );
      expect(
        find.text('Pentingnya Aktivitas Fisik di Usia Dewasa'),
        findsOneWidget,
      );

      // Tanggal publish dengan ikon kalender
      expect(find.byIcon(Icons.calendar_today_outlined), findsWidgets);
      expect(find.text('10 Nov 2026'), findsWidgets);
      expect(find.text('5 Nov 2026'), findsWidgets);
      expect(find.text('1 Nov 2026'), findsWidgets);

      // Ikon Aksi Edit & Hapus pada setiap kartu
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    });

    testWidgets('Search input filters article list dynamically',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Masukkan kata kunci pencarian "Makanan"
      await tester.enterText(searchField, 'Makanan');
      await tester.pump();

      expect(
        find.text('Makanan yang Baik untuk Kesehatan Tulang'),
        findsOneWidget,
      );
      expect(
        find.text(
            'Mengenal Osteoporosis: Penyebab, Gejala, dan Pencegahan'),
        findsNothing,
      );

      // Bersihkan pencarian
      await tester.enterText(searchField, '');
      await tester.pump();

      expect(
        find.text(
            'Mengenal Osteoporosis: Penyebab, Gejala, dan Pencegahan'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping "+ Tambah Artikel" navigates to AddArticlePage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      final addBtn = find.widgetWithText(ElevatedButton, 'Tambah Artikel');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AddArticlePage), findsOneWidget);
      expect(find.text('Tambah Artikel'), findsWidgets);
      expect(find.text('Simpan Artikel'), findsOneWidget);
    });

    testWidgets('Tapping edit icon navigates to EditArticlePage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      // Ketuk ikon pensil pada artikel pertama
      final firstEditBtn = find.byIcon(Icons.edit_outlined).first;
      await tester.tap(firstEditBtn);
      await tester.pumpAndSettle();

      expect(find.byType(EditArticlePage), findsOneWidget);
      expect(find.text('Edit Artikel'), findsOneWidget);
      expect(find.text('Perbarui Artikel'), findsOneWidget);
    });

    testWidgets(
        'Tapping delete button shows confirmation dialog before deleting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      // Ketuk tombol hapus pada artikel pertama
      final firstDeleteButton =
          find.byIcon(Icons.delete_outline_rounded).first;
      await tester.tap(firstDeleteButton);
      await tester.pumpAndSettle();

      // Dialog konfirmasi harus muncul
      expect(find.text('Hapus Artikel?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tekan Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Artikel?'), findsNothing);
    });

    testWidgets('Tapping article card body navigates to AdminArticleDetailPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminArticlesPage(),
        ),
      );
      await tester.pump();

      // Ketuk kartu "Makanan yang Baik untuk Kesehatan Tulang"
      await tester.tap(
          find.text('Makanan yang Baik untuk Kesehatan Tulang'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminArticleDetailPage), findsOneWidget);
      expect(find.text('Detail Artikel'), findsOneWidget);
    });
  });
}
