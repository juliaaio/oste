import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/core/utils/password_validator.dart';
import 'package:oste/core/widgets/password_requirements_card.dart';
import 'package:oste/features/profile/change_password_page.dart';

void main() {
  group('PasswordValidator Unit Tests', () {
    test('validates minimum length', () {
      expect(PasswordValidator.hasMinLength(''), isFalse);
      expect(PasswordValidator.hasMinLength('Ab1!'), isFalse);
      expect(PasswordValidator.hasMinLength('Abc1234'), isFalse); // 7 chars
      expect(PasswordValidator.hasMinLength('Abc12345'), isTrue); // 8 chars
      expect(PasswordValidator.hasMinLength('Abc123456789'), isTrue);
    });

    test('validates uppercase characters', () {
      expect(PasswordValidator.hasUppercase('password123!'), isFalse);
      expect(PasswordValidator.hasUppercase('Password123!'), isTrue);
      expect(PasswordValidator.hasUppercase('passWord'), isTrue);
    });

    test('validates lowercase characters', () {
      expect(PasswordValidator.hasLowercase('PASSWORD123!'), isFalse);
      expect(PasswordValidator.hasLowercase('Password123!'), isTrue);
      expect(PasswordValidator.hasLowercase('passWORD'), isTrue);
    });

    test('validates digits', () {
      expect(PasswordValidator.hasDigit('Password!'), isFalse);
      expect(PasswordValidator.hasDigit('Password1!'), isTrue);
      expect(PasswordValidator.hasDigit('01234567'), isTrue);
    });

    test('validates special characters', () {
      expect(PasswordValidator.hasSpecialChar('Password123'), isFalse);
      expect(PasswordValidator.hasSpecialChar('Password 123'), isFalse); // whitespace is excluded
      expect(PasswordValidator.hasSpecialChar('Password123!'), isTrue);
      expect(PasswordValidator.hasSpecialChar('Password123@'), isTrue);
      expect(PasswordValidator.hasSpecialChar('Password123#'), isTrue);
    });

    test('validates full isValid requirement combo', () {
      expect(PasswordValidator.isValid('weak'), isFalse);
      expect(PasswordValidator.isValid('weakpassword'), isFalse);
      expect(PasswordValidator.isValid('WeakPassword'), isFalse);
      expect(PasswordValidator.isValid('WeakPassword123'), isFalse); // missing special char
      expect(PasswordValidator.isValid('weakpassword123!'), isFalse); // missing uppercase
      expect(PasswordValidator.isValid('WEAKPASSWORD123!'), isFalse); // missing lowercase
      expect(PasswordValidator.isValid('WeakPassword!'), isFalse); // missing digit
      expect(PasswordValidator.isValid('Weak!1'), isFalse); // length < 8
      expect(PasswordValidator.isValid('StrongP@ss1'), isTrue);
      expect(PasswordValidator.isValid('Valid#2026'), isTrue);
    });
  });

  group('PasswordRequirementsCard Widget Tests', () {
    testWidgets('renders all requirement texts correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordRequirementsCard(
              hasMinLength: false,
              hasUppercase: false,
              hasLowercase: false,
              hasDigit: false,
              hasSpecialChar: false,
            ),
          ),
        ),
      );

      expect(find.text('Password harus mengandung:'), findsOneWidget);
      expect(find.text('Minimal 8 karakter'), findsOneWidget);
      expect(find.text('Huruf besar dan huruf kecil'), findsOneWidget);
      expect(find.text('Angka'), findsOneWidget);
      expect(find.text('Karakter khusus (contoh: !@#)'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('renders check_circle icons when requirements are met', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordRequirementsCard(
              hasMinLength: true,
              hasUppercase: true,
              hasLowercase: true,
              hasDigit: true,
              hasSpecialChar: true,
            ),
          ),
        ),
      );

      // All 4 criteria fulfilled -> 4 check_circle icons
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
    });
  });

  group('ChangePasswordPage Widget Tests', () {
    testWidgets('renders form fields and requirements card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordPage(),
        ),
      );

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.byType(PasswordRequirementsCard), findsOneWidget);
      expect(find.text('Password harus mengandung:'), findsOneWidget);
    });

    testWidgets('live updates password requirements card as user types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordPage(),
        ),
      );

      // Initially no check icons
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Enter lowercase text < 8 chars into New Password
      final newPasswordFinder = find.widgetWithText(TextFormField, 'Enter New Password');
      await tester.enterText(newPasswordFinder, 'abc');
      await tester.pump();

      // Still no requirement completely satisfied (needs uppercase too for the 2nd row)
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Add uppercase
      await tester.enterText(newPasswordFinder, 'abcABC');
      await tester.pump();
      // 'Huruf besar dan huruf kecil' should be satisfied (1 check)
      expect(find.byIcon(Icons.check_circle), findsNWidgets(1));

      // Add min length >= 8
      await tester.enterText(newPasswordFinder, 'abcABC12');
      await tester.pump();
      // 'Minimal 8 karakter', 'Huruf besar dan huruf kecil', and 'Angka' satisfied (3 checks)
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));

      // Add special char
      await tester.enterText(newPasswordFinder, 'abcABC12!');
      await tester.pump();
      // All 4 checks met
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
    });

    testWidgets('validator rejects passwords not meeting all requirements', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordPage(),
        ),
      );

      // Fill current password
      final currentFinder = find.widgetWithText(TextFormField, 'Enter Current Password');
      await tester.enterText(currentFinder, 'currentPass123!');

      // Fill invalid new password (only length and lowercase)
      final newFinder = find.widgetWithText(TextFormField, 'Enter New Password');
      await tester.enterText(newFinder, 'passwordonly');

      // Fill confirm password matching the invalid password
      final confirmFinder = find.widgetWithText(TextFormField, 'Enter Confirm New Password');
      await tester.enterText(confirmFinder, 'passwordonly');

      // Ensure button is visible and tap
      final saveButton = find.text('Save Password');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Form validation error should appear
      expect(find.text('Password does not meet all requirements'), findsOneWidget);
    });
  });
}
