import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/chat/admin_doctor_list_page.dart';
import 'package:oste/features/admin/doctors/add_doctor_page.dart';
import 'package:oste/features/admin/doctors/edit_doctor_page.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/doctor_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminDoctorListPage UI & Component Tests', () {
    testWidgets('Renders AppBar back button, title, description, search bar, and add button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDoctorListPage(),
        ),
      );
      await tester.pump();

      // Header Osteo and Kelola Dokter
      expect(find.text('Osteo'), findsOneWidget);
      expect(find.text('Kelola Dokter'), findsOneWidget);
      expect(
        find.text('Kelola data dokter yang tersedia di aplikasi Osteo.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // Search bar
      expect(find.text('Cari nama dokter...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Tambah Dokter button
      expect(find.text('Tambah Dokter'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Bottom Navigation Bar with Dokter tab
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Dokter'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Renders doctor cards with name, speciality, active/inactive badge, edit & delete buttons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDoctorListPage(),
        ),
      );
      await tester.pump();

      // Screenshot doctors should be present
      expect(find.text('dr. Amira Salsabila, Sp.PD'), findsOneWidget);
      expect(find.text('Spesialis Penyakit Dalam'), findsOneWidget);
      expect(find.text('Aktif'), findsWidgets);

      expect(find.text('dr. Raka Pratama, Sp.OT'), findsOneWidget);
      expect(find.text('Spesialis Ortopedi'), findsOneWidget);

      expect(find.text('dr. Lestari Wulandari, Sp.KFR'), findsOneWidget);
      expect(
          find.text('Spesialis Kedokteran Fisik dan Rehabilitasi'),
          findsOneWidget);
      expect(find.text('Nonaktif'), findsWidgets);

      // Action buttons: Edit (pencil) and Delete (trash)
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    });

    testWidgets('Search query filters doctors accurately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDoctorListPage(),
        ),
      );
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Search for "Amira"
      await tester.enterText(searchField, 'Amira');
      await tester.pump();

      expect(find.text('dr. Amira Salsabila, Sp.PD'), findsOneWidget);
      expect(find.text('dr. Raka Pratama, Sp.OT'), findsNothing);
      expect(find.text('dr. Lestari Wulandari, Sp.KFR'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pump();

      expect(find.text('dr. Amira Salsabila, Sp.PD'), findsOneWidget);
      expect(find.text('dr. Raka Pratama, Sp.OT'), findsOneWidget);
    });

    testWidgets('Tapping "+ Tambah Dokter" navigates to AddDoctorPage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDoctorListPage(),
        ),
      );
      await tester.pump();

      final addBtn = find.widgetWithText(ElevatedButton, 'Tambah Dokter');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AddDoctorPage), findsOneWidget);
      expect(find.text('Nama Dokter *'), findsOneWidget);
      expect(find.text('Spesialisasi *'), findsOneWidget);
      expect(find.text('Simpan Dokter'), findsOneWidget);
    });

    testWidgets('Tapping Edit on doctor card navigates to EditDoctorPage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDoctorListPage(),
        ),
      );
      await tester.pump();

      final editButtons = find.byIcon(Icons.edit_outlined);
      expect(editButtons, findsWidgets);

      // Tap first edit button (dr. Amira)
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(EditDoctorPage), findsOneWidget);
      expect(find.text('Edit Dokter'), findsOneWidget);
      expect(find.text('dr. Amira Salsabila, Sp.PD'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets('Tapping Delete shows confirmation dialog with Batal and Hapus',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDoctorListPage(),
        ),
      );
      await tester.pump();

      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButtons, findsWidgets);

      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible
      expect(find.text('Hapus Dokter?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Dokter?'), findsNothing);
    });
  });
}

