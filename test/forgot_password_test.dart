import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/auth/forgot_password/forgot_password_page.dart';
import 'package:oste/features/auth/forgot_password/check_email_page.dart';
import 'package:oste/features/auth/forgot_password/reset_password_page.dart';
import 'package:oste/features/auth/forgot_password/password_success_page.dart';
import 'package:oste/features/auth/login/login_page.dart';

void main() {
  group('Forgot Password Flow Tests', () {
    testWidgets('ForgotPasswordPage renders and validates empty email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordPage(),
        ),
      );

      // Verify UI elements exist
      expect(find.text('Lupa Password?'), findsOneWidget);
      expect(find.text('Kirim Link Reset'), findsOneWidget);
      expect(find.text('Kembali ke Login'), findsOneWidget);

      // Tap Kirim without typing email
      await tester.tap(find.text('Kirim Link Reset'));
      await tester.pump();

      // Error message should appear
      expect(find.text('Alamat email tidak boleh kosong.'), findsWidgets);
    });

    testWidgets('CheckEmailPage displays provided email and elements', (WidgetTester tester) async {
      const testEmail = 'risma@gmail.com';
      await tester.pumpWidget(
        const MaterialApp(
          home: CheckEmailPage(email: testEmail),
        ),
      );

      expect(find.text('Cek Email Anda'), findsOneWidget);
      expect(find.text(testEmail), findsOneWidget);
      expect(find.text('Buka Email'), findsOneWidget);
      expect(find.textContaining('Kirim Ulang Email'), findsOneWidget);
      expect(find.text('Tidak menerima email?'), findsOneWidget);
    });

    testWidgets('ResetPasswordPage validates matching passwords', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordPage(),
        ),
      );

      expect(find.text('Buat Password Baru'), findsOneWidget);
      expect(find.text('Password Baru'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
      expect(find.text('Password harus mengandung:'), findsOneWidget);
      expect(find.text('Simpan Password'), findsOneWidget);

      // Scroll to Simpan Password and tap with empty inputs
      await tester.ensureVisible(find.text('Simpan Password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Password'));
      await tester.pump();

      expect(find.text('Mohon isi password baru dan konfirmasi password.'), findsOneWidget);
    });

    testWidgets('PasswordSuccessPage displays success info and button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PasswordSuccessPage(),
        ),
      );

      expect(find.text('Password Berhasil\nDiubah'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
    });

    testWidgets('Complete End-to-End Navigation Flow', (WidgetTester tester) async {
      // Set phone size
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordPage(),
        ),
      );

      // 1. ForgotPasswordPage: enter email and submit
      await tester.enterText(find.byType(TextField), 'risma@gmail.com');
      await tester.pump();
      await tester.tap(find.text('Kirim Link Reset'));
      await tester.pumpAndSettle();

      // 2. CheckEmailPage: verify email is shown and tap "Buka Email"
      expect(find.byType(CheckEmailPage), findsOneWidget);
      expect(find.text('risma@gmail.com'), findsOneWidget);
      await tester.tap(find.text('Buka Email'));
      await tester.pumpAndSettle();

      // 3. ResetPasswordPage: enter new matching password
      expect(find.byType(ResetPasswordPage), findsOneWidget);
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), 'Password123!');
      await tester.enterText(textFields.at(1), 'Password123!');
      await tester.pump();

      await tester.ensureVisible(find.text('Simpan Password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Password'));
      await tester.pumpAndSettle();

      // 4. PasswordSuccessPage: tap "Masuk Sekarang"
      expect(find.byType(PasswordSuccessPage), findsOneWidget);
      await tester.tap(find.text('Masuk Sekarang'));
      await tester.pumpAndSettle();

      // 5. Arrived at LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
