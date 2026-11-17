import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/education/add_education_page.dart';
import 'package:oste/features/admin/education/admin_education_page.dart';
import 'package:oste/features/admin/education/edit_education_page.dart';
import 'package:oste/models/education_model.dart';
import 'package:oste/services/education_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminEducationPage UI & Component Tests', () {
    testWidgets(
        'Renders Header, Title, Description, Search Bar, Add Button, and Category Filters',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      // Header Osteo & Kelola Edukasi
      expect(find.text('Osteo'), findsOneWidget);
      expect(find.text('Kelola Edukasi'), findsOneWidget);
      expect(
        find.text('Kelola materi edukasi (latihan, nutrisi, dan vitamin).'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // Search bar
      expect(find.text('Cari judul edukasi...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Tambah Edukasi button
      expect(find.text('Tambah Edukasi'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Category filters
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Latihan'), findsWidgets);
      expect(find.text('Nutrisi'), findsWidgets);
      expect(find.text('Vitamin'), findsWidgets);

      // Bottom Navigation Bar with Edukasi tab
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Dokter'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets(
        'Renders education cards with thumbnail, title, category badge, edit & delete buttons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      // Screenshot education items should be present
      expect(find.text('Latihan Penguatan Tulang'), findsOneWidget);
      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsOneWidget);
      expect(find.text('Rekomendasi Vitamin D'), findsOneWidget);

      // Action buttons: Edit (pencil) and Delete (trash)
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    });

    testWidgets('Tapping category filter chips filters education items',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      // Tap "Latihan" filter chip
      await tester.tap(find.text('Latihan').first);
      await tester.pump();

      expect(find.text('Latihan Penguatan Tulang'), findsOneWidget);
      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsNothing);
      expect(find.text('Rekomendasi Vitamin D'), findsNothing);

      // Tap "Nutrisi" filter chip
      await tester.tap(find.text('Nutrisi').first);
      await tester.pump();

      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsOneWidget);
      expect(find.text('Latihan Penguatan Tulang'), findsNothing);
      expect(find.text('Rekomendasi Vitamin D'), findsNothing);

      // Tap "Semua" filter chip to reset
      await tester.tap(find.text('Semua'));
      await tester.pump();

      expect(find.text('Latihan Penguatan Tulang'), findsOneWidget);
      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsOneWidget);
      expect(find.text('Rekomendasi Vitamin D'), findsOneWidget);
    });

    testWidgets('Search query filters education items accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Search for "Nutrisi"
      await tester.enterText(searchField, 'Nutrisi');
      await tester.pump();

      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsOneWidget);
      expect(find.text('Latihan Penguatan Tulang'), findsNothing);
      expect(find.text('Rekomendasi Vitamin D'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pump();

      expect(find.text('Latihan Penguatan Tulang'), findsOneWidget);
      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsOneWidget);
    });

    testWidgets('Tapping "+ Tambah Edukasi" navigates to AddEducationPage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      final addBtn = find.widgetWithText(ElevatedButton, 'Tambah Edukasi');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AddEducationPage), findsOneWidget);
      expect(find.text('Judul Materi Edukasi *'), findsOneWidget);
      expect(find.text('Kategori Edukasi *'), findsOneWidget);
      expect(find.text('Simpan Edukasi'), findsOneWidget);
    });

    testWidgets('Tapping Edit on education card navigates to EditEducationPage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      final editButtons = find.byIcon(Icons.edit_outlined);
      expect(editButtons, findsWidgets);

      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(EditEducationPage), findsOneWidget);
      expect(find.text('Edit Edukasi'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets(
        'Tapping Delete shows confirmation dialog with Batal and Hapus',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEducationPage(),
        ),
      );
      await tester.pump();

      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButtons, findsWidgets);

      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Dialog confirmation should appear
      expect(find.text('Hapus Edukasi?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Edukasi?'), findsNothing);
    });
  });
}

