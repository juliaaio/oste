import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/articles/edit_article_page.dart';
import 'package:oste/features/admin/articles/admin_article_model.dart';
import 'package:oste/features/admin/articles/admin_article_store.dart';

void main() {
  group('EditArticlePage Widget Tests', () {
    late AdminArticleItem testArticle;

    setUp(() {
      testArticle = AdminArticleItem(
        id: 'test_1',
        title: 'Mengenal Osteoporosis',
        category: 'Edukasi',
        date: '12 Okt 2026',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/osteoporosis_hero.jpg',
        source: 'Alodokter, 2024',
        description: 'Kenali penyebab dan gejala pengeroposan tulang.',
        content: 'Osteoporosis adalah kondisi ketika kepadatan tulang berkurang.',
      );
      AdminArticleStore().addArticle(testArticle);
    });

    testWidgets(
        'Renders Edit Artikel form prefilled with article data matching screenshot',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: EditArticlePage(article: testArticle),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header: Back button, "Edit Artikel", Bell notification
      expect(find.text('Edit Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Gambar saat ini & Tombol "Ubah Gambar"
      expect(find.text('Ubah Gambar'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsWidgets);

      // 3. Form terisi data artikel sebelumnya
      expect(find.text('Mengenal Osteoporosis'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Alodokter, 2024'), findsOneWidget);
      expect(find.text('Kenali penyebab dan gejala pengeroposan tulang.'), findsOneWidget);
      expect(
        find.text('Osteoporosis adalah kondisi ketika kepadatan tulang berkurang.'),
        findsOneWidget,
      );

      // 4. Status Publikasi Switch
      expect(find.text('Status Publikasi'), findsOneWidget);
      expect(find.text('Publikasikan'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // 5. Tombol Aksi Bawah
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Perbarui Artikel'), findsOneWidget);
    });

    testWidgets('Edits title and content, saves changes to AdminArticleStore',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: EditArticlePage(article: testArticle),
        ),
      );
      await tester.pumpAndSettle();

      // Ubah judul artikel
      final titleField = find.widgetWithText(TextFormField, 'Mengenal Osteoporosis');
      await tester.enterText(titleField, 'Mengenal Osteoporosis Versi Terbaru');

      // Scroll ke tombol Perbarui Artikel
      await tester.ensureVisible(find.text('Perbarui Artikel'));
      await tester.tap(find.text('Perbarui Artikel'));
      await tester.pumpAndSettle();

      // Verifikasi di AdminArticleStore bahwa judul telah diperbarui
      final updatedInStore = AdminArticleStore().getArticleById('test_1');
      expect(updatedInStore?.title, equals('Mengenal Osteoporosis Versi Terbaru'));
    });

    testWidgets('Tapping Batal exits without saving changes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => EditArticlePage(article: testArticle),
                    ),
                  );
                },
                child: const Text('Open Edit'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka halaman Edit
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Artikel'), findsOneWidget);

      // Ubah teks tanpa simpan
      final titleField = find.widgetWithText(TextFormField, 'Mengenal Osteoporosis');
      await tester.enterText(titleField, 'Judul Yang Dibatalkan');

      // Ketuk Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Kembali ke halaman awal
      expect(find.text('Open Edit'), findsOneWidget);
      expect(find.text('Edit Artikel'), findsNothing);

      // Data di store tidak berubah
      final currentInStore = AdminArticleStore().getArticleById('test_1');
      expect(currentInStore?.title, isNot(equals('Judul Yang Dibatalkan')));
    });
  });
}

