import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/profile/edit_page.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/user_service.dart';

void main() {
  setUp(() {
    UserService().logout();
  });

  testWidgets('EditPage renders all required UI elements pixel-perfect', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditPage(),
      ),
    );

    // Header
    expect(find.text('Edit Profil'), findsOneWidget);

    // Profile photo & camera icon badge
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);

    // Card title & subtitle
    expect(find.text('Data Pribadi'), findsOneWidget);
    expect(
      find.text('Lengkapi dan perbarui data diri Anda'),
      findsOneWidget,
    );

    // Labels
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Nomor HP'), findsOneWidget);
    expect(find.text('Jenis Kelamin'), findsOneWidget);
    expect(find.text('Tanggal Lahir'), findsOneWidget);
    expect(find.text('Berat Badan'), findsOneWidget);
    expect(find.text('Tinggi Badan'), findsOneWidget);

    // Suffixes
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);

    // Button
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('EditPage triggers validation errors when fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditPage(),
      ),
    );

    final saveButton = find.text('Simpan Perubahan');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap wajib diisi'), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Nomor HP wajib diisi'), findsOneWidget);
    expect(find.text('Jenis Kelamin wajib diisi'), findsOneWidget);
    expect(find.text('Tanggal Lahir wajib diisi'), findsOneWidget);
    expect(find.text('Berat Badan wajib diisi'), findsOneWidget);
    expect(find.text('Tinggi Badan wajib diisi'), findsOneWidget);
  });

  testWidgets('EditPage validates invalid email format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditPage(),
      ),
    );

    // Fill invalid email
    final emailField = find.ancestor(
      of: find.byIcon(Icons.mail_outline_rounded),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, 'notanemail');

    final saveButton = find.text('Simpan Perubahan');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Format email tidak valid'), findsOneWidget);
  });

  testWidgets('EditPage saves valid data and updates UserService', (
    WidgetTester tester,
  ) async {
    // Initial user
    UserService().setCurrentUserForTesting(
      const UserModel(
        uid: 'test-user-id',
        name: 'Initial User',
        email: 'initial@email.com',
        phone: '081234567890',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: EditPage(),
      ),
    );

    // Fill form
    final nameField = find.ancestor(
      of: find.byIcon(Icons.person_outline_rounded),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(nameField, 'Budi Santoso');

    final emailField = find.ancestor(
      of: find.byIcon(Icons.mail_outline_rounded),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, 'budi.santoso@email.com');

    final phoneField = find.ancestor(
      of: find.byIcon(Icons.phone_outlined),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(phoneField, '081298765432');

    // Select Gender dropdown
    final genderDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(genderDropdown);
    await tester.tap(genderDropdown);
    await tester.pumpAndSettle();

    final maleOption = find.text('Laki-laki').last;
    await tester.tap(maleOption);
    await tester.pumpAndSettle();

    // Pick Tanggal Lahir via date picker
    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Fill Berat Badan
    final weightField = find.ancestor(
      of: find.byIcon(Icons.scale_outlined),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(weightField);
    await tester.enterText(weightField, '65');

    // Fill Tinggi Badan
    final heightField = find.ancestor(
      of: find.byIcon(Icons.accessibility_new_rounded),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(heightField);
    await tester.enterText(heightField, '172');

    // Tap Simpan Perubahan
    final saveButton = find.text('Simpan Perubahan');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify SnackBar
    expect(find.text('Profil berhasil diperbarui'), findsOneWidget);

    // Verify UserService updated
    final updated = UserService().currentUser;
    expect(updated?.name, 'Budi Santoso');
    expect(updated?.phone, '081298765432');
    expect(updated?.gender, 'Laki-laki');
    expect(updated?.birthDate, '15 Mei 1998');
    expect(updated?.weight, 65.0);
    expect(updated?.height, 172.0);
  });
}
