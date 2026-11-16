import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/auth/login/login_page.dart';
import 'package:oste/features/profile/profile_page.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/user_service.dart';

void main() {
  setUp(() {
    UserService().setCurrentUserForTesting(
      UserModel(
        uid: 'test_uid_123',
        name: 'Budi Santoso',
        email: 'budi@gmail.com',
        role: 'patient',
      ),
    );
  });

  tearDown(() {
    UserService().setCurrentUserForTesting(null);
  });

  testWidgets('ProfilePage renders Hapus Akun menu item with delete_forever icon and red color below Change Password', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePage(showBottomNav: false),
      ),
    );
    await tester.pump();

    // Verify Change Password exists
    expect(find.text('Change Password'), findsOneWidget);

    // Verify Hapus Akun tile exists
    expect(find.text('Hapus Akun'), findsOneWidget);
    expect(find.text('Hapus akun dan seluruh data secara permanen'), findsOneWidget);
    expect(find.byIcon(Icons.delete_forever_rounded), findsOneWidget);

    // Verify Logout exists
    expect(find.text('Logout'), findsOneWidget);

    // Check vertical order: Change Password -> Hapus Akun -> Logout
    final changePassY = tester.getTopLeft(find.text('Change Password')).dy;
    final hapusAkunY = tester.getTopLeft(find.text('Hapus Akun')).dy;
    final logoutY = tester.getTopLeft(find.text('Logout')).dy;

    expect(hapusAkunY, greaterThan(changePassY), reason: 'Hapus Akun harus di bawah Change Password');
    expect(logoutY, greaterThan(hapusAkunY), reason: 'Logout harus di bawah Hapus Akun');
  });

  testWidgets('Tapping Hapus Akun displays confirmation dialog with required texts and buttons', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePage(showBottomNav: false),
      ),
    );
    await tester.pump();

    // Tap Hapus Akun
    await tester.tap(find.text('Hapus Akun'));
    await tester.pumpAndSettle();

    // Dialog title, tile title, and confirmation button
    expect(find.text('Hapus Akun'), findsNWidgets(3)); // tile title, dialog title, dialog button

    // Dialog message
    expect(
      find.text(
        'Apakah Anda yakin ingin menghapus akun? Seluruh data akun, termasuk riwayat skrining dan riwayat konsultasi, akan dihapus secara permanen dan tidak dapat dipulihkan.',
      ),
      findsOneWidget,
    );

    // Dialog buttons: Batal and Hapus Akun
    expect(find.text('Batal'), findsOneWidget);

    // Tapping Batal dismisses dialog
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    // Dialog is closed, message no longer visible
    expect(
      find.text(
        'Apakah Anda yakin ingin menghapus akun? Seluruh data akun, termasuk riwayat skrining dan riwayat konsultasi, akan dihapus secara permanen dan tidak dapat dipulihkan.',
      ),
      findsNothing,
    );
  });

  testWidgets('Confirming Hapus Akun executes delete, clears user, and navigates to LoginPage', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePage(showBottomNav: false),
      ),
    );
    await tester.pump();

    // Tap Hapus Akun
    await tester.tap(find.text('Hapus Akun'));
    await tester.pumpAndSettle();

    // Tap the 'Hapus Akun' confirmation button inside the dialog
    final confirmButtons = find.widgetWithText(TextButton, 'Hapus Akun');
    expect(confirmButtons, findsOneWidget);
    await tester.tap(confirmButtons);

    await tester.pump(); // starts async operation / shows loading
    await tester.pumpAndSettle();

    // User is logged out and cleared
    expect(UserService().currentUser, isNull);

    // Navigated to LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);

    // SnackBar is shown
    expect(find.text('Akun berhasil dihapus.'), findsOneWidget);
  });

  testWidgets('DeleteAccountResult recent login required displays guide dialog', (tester) async {
    const errorResult = DeleteAccountResult.error(
      'Demi keamanan akun Anda, tindakan ini memerlukan autentikasi terbaru. Silakan logout dan login kembali sebelum menghapus akun.',
      isRecentLoginRequired: true,
    );

    expect(errorResult.isSuccess, isFalse);
    expect(errorResult.isRecentLoginRequired, isTrue);
    expect(errorResult.message, contains('autentikasi terbaru'));
  });

  testWidgets('DeleteAccountResult error displays error message properly', (tester) async {
    const errorResult = DeleteAccountResult.error(
      'Gagal menghapus data: Izin ditolak. Silakan coba lagi nanti.',
    );

    expect(errorResult.isSuccess, isFalse);
    expect(errorResult.isRecentLoginRequired, isFalse);
    expect(errorResult.message, contains('Izin ditolak'));
  });
}
