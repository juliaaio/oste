import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/articles/admin_article_detail_page.dart';
import 'package:oste/features/admin/articles/admin_article_model.dart';
import 'package:oste/features/admin/articles/admin_article_store.dart';
import 'package:oste/features/admin/articles/edit_article_page.dart';

void main() {
  group('AdminArticleDetailPage Widget Tests', () {
    late AdminArticleItem sampleArticle;

    setUp(() {
      sampleArticle = AdminArticleItem(
        id: 'detail_sample_1',
        title: 'Mengenal Osteoporosis',
        category: 'Edukasi Tulang',
        date: '20 Okt 2025',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/osteoporosis_hero.jpg',
        source: 'Alodokter, 2024',
        description: 'Kenali penyebab dan gejala osteoporosis.',
        content:
            'Osteoporosis adalah kondisi ketika kepadatan tulang menurun sehingga tulang menjadi lebih rapuh dan mudah patah. Penyakit ini sering tidak menunjukkan gejala di awal, namun dapat berisiko tinggi di kemudian hari.',
      );
      AdminArticleStore().addArticle(sampleArticle);
    });

    testWidgets(
        'Renders Detail Artikel page matching screenshot at 360x800 resolution',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminArticleDetailPage(article: sampleArticle),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header: Back button, "Detail Artikel", Bell notification
      expect(find.text('Detail Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Judul Artikel
      expect(find.text('Mengenal Osteoporosis'), findsOneWidget);

      // 3. Status dan Tanggal sesuai screenshot
      expect(find.text('Dipublikasikan'), findsOneWidget);
      expect(find.text('20 Okt 2025'), findsOneWidget);
      expect(find.text('Edukasi Tulang'), findsOneWidget);

      // 4. Isi Konten Artikel
      expect(
        find.text(
          'Osteoporosis adalah kondisi ketika kepadatan tulang menurun sehingga tulang menjadi lebih rapuh dan mudah patah. Penyakit ini sering tidak menunjukkan gejala di awal, namun dapat berisiko tinggi di kemudian hari.',
        ),
        findsOneWidget,
      );

      // 5. Card Sumber / Referensi
      expect(find.textContaining('Alodokter, 2024'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

      // 6. Tombol Aksi Bawah: Edit & Hapus
      expect(find.text('Edit Artikel'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('Tapping Edit Artikel navigates to EditArticlePage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminArticleDetailPage(article: sampleArticle),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke tombol Edit Artikel jika perlu
      await tester.ensureVisible(find.text('Edit Artikel'));
      await tester.tap(find.text('Edit Artikel'));
      await tester.pumpAndSettle();

      // Memastikan berpindah ke halaman EditArticlePage
      expect(find.byType(EditArticlePage), findsOneWidget);
      expect(find.text('Perbarui Artikel'), findsOneWidget);
    });

    testWidgets('Tapping Hapus shows confirmation dialog and removes article',
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
                      builder: (_) =>
                          AdminArticleDetailPage(article: sampleArticle),
                    ),
                  );
                },
                child: const Text('Open Detail'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka Detail Artikel
      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      // Scroll dan ketuk tombol Hapus
      await tester.ensureVisible(find.text('Hapus'));
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Dialog konfirmasi muncul
      expect(find.text('Hapus Artikel?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Konfirmasi Hapus
      await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Otomatis kembali ke halaman awal
      expect(find.text('Open Detail'), findsOneWidget);
      expect(find.text('Detail Artikel'), findsNothing);

      // Artikel terhapus dari store
      expect(
        AdminArticleStore().getArticleById('detail_sample_1'),
        isNull,
      );
    });
  });
}

