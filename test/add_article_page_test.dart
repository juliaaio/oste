import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/articles/add_article_page.dart';
import 'package:oste/features/admin/articles/admin_article_store.dart';

void main() {
  group('AddArticlePage Widget Tests', () {
    testWidgets(
        'Renders Tambah Artikel form matching screenshot at 360x800 resolution',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddArticlePage(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header: Back button, "Tambah Artikel", Bell notification
      expect(find.text('Tambah Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Upload Gambar Card
      expect(find.text('Unggah Gambar'), findsOneWidget);
      expect(find.text('Pilih gambar dari galeri'), findsOneWidget);

      // 3. Form Labels sesuai instruksi & screenshot
      expect(find.text('Judul Artikel'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Ringkasan Artikel'), findsOneWidget);
      expect(find.text('Isi Artikel'), findsOneWidget);
      expect(find.text('Sumber / Referensi'), findsOneWidget);
      expect(find.text('Status Publikasi'), findsOneWidget);

      // 4. Toolbar Editor
      expect(find.text('B'), findsOneWidget);
      expect(find.text('I'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);

      // 5. Tombol Aksi Bawah
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Simpan Artikel'), findsOneWidget);
    });

    testWidgets('Validates required fields when saving empty form',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddArticlePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke bawah untuk menemukan tombol Simpan Artikel
      await tester.ensureVisible(find.text('Simpan Artikel'));
      await tester.tap(find.text('Simpan Artikel'));
      await tester.pumpAndSettle();

      // Pesan error validasi muncul
      expect(find.text('Judul artikel wajib diisi'), findsOneWidget);
    });

    testWidgets('Fills form and successfully saves new article to store',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialCount = AdminArticleStore().totalCount;

      await tester.pumpWidget(
        const MaterialApp(
          home: AddArticlePage(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Isi Judul Artikel
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Masukkan judul artikel'),
        'Pentingnya Vitamin D untuk Tulang',
      );

      // 2. Pilih Kategori dari Dropdown
      await tester.tap(find.text('Pilih kategori'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edukasi Tulang').last);
      await tester.pumpAndSettle();

      // 3. Isi Isi Artikel
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tulis isi artikel di sini...'),
        'Vitamin D membantu penyerapan kalsium dalam tubuh secara optimal.',
      );

      // 4. Scroll dan tekan Simpan Artikel
      await tester.ensureVisible(find.text('Simpan Artikel'));
      await tester.tap(find.text('Simpan Artikel'));
      await tester.pumpAndSettle();

      // Memastikan jumlah artikel bertambah 1 di AdminArticleStore
      expect(AdminArticleStore().totalCount, equals(initialCount + 1));
      expect(
        AdminArticleStore().articles.any((a) => a.title == 'Pentingnya Vitamin D untuk Tulang'),
        isTrue,
      );
    });
  });
}

