import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/auth/login/login_page.dart';
import 'package:oste/features/auth/register/register_page.dart';
import 'package:oste/features/auth/register_success/register_success_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/profile/profile_page.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/user_service.dart';

void main() {
  setUp(() {
    // Reset UserService state
    UserService().logout();
  });

  group('UserService & Sync Tests', () {
    test('Register stores user and updates currentUser', () {
      final service = UserService();
      final success = service.register(
        name: 'Ahmad Dahlan',
        email: 'ahmad@example.com',
        phone: '08123456789',
        password: 'password123',
        gender: 'Laki-laki',
        birthDate: '10 Januari 1995',
      );

      expect(success, isTrue);
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.name, equals('Ahmad Dahlan'));
      expect(service.currentUser!.firstName, equals('Ahmad'));
      expect(service.currentUser!.email, equals('ahmad@example.com'));
      expect(service.currentUser!.phone, equals('08123456789'));
      expect(service.currentUser!.gender, equals('Laki-laki'));
      expect(service.currentUser!.birthDate, equals('10 Januari 1995'));
    });

    test('Login sets currentUser correctly', () {
      final service = UserService();
      service.register(
        name: 'Siti Nurhaliza',
        email: 'siti@example.com',
        phone: '08987654321',
        password: 'secretPassword',
        gender: 'Perempuan',
        birthDate: '20 Februari 1998',
      );

      // Log out
      service.logout();
      expect(service.currentUser, isNull);

      // Log in
      final ok = service.login(email: 'siti@example.com', password: 'secretPassword');
      expect(ok, isTrue);
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.name, equals('Siti Nurhaliza'));
      expect(service.currentUser!.firstName, equals('Siti'));
    });

    testWidgets('DashboardPage and ProfilePage display data from UserService.currentUser', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = UserService();
      service.loginDirect(
        const UserModel(
          name: 'Budi Santoso',
          email: 'budi.santoso@example.com',
          phone: '081122334455',
          password: 'pass',
          gender: 'Laki-laki',
          birthDate: '12 Desember 1990',
          weight: 65,
          height: 172,
        ),
      );

      // Verify Dashboard shows 'Hai, Budi 👋'
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hai, Budi 👋'), findsOneWidget);

      // Verify Profile shows full identity
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsNWidgets(2)); // in header and data row
      expect(find.text('budi.santoso@example.com'), findsNWidgets(2)); // in header and data row
      expect(find.text('081122334455'), findsNWidgets(2)); // in header and data row
      expect(find.text('Laki-laki'), findsOneWidget);
      expect(find.text('12 Desember 1990'), findsOneWidget);
      expect(find.text('65 kg'), findsOneWidget);
      expect(find.text('172 cm'), findsOneWidget);
    });

    testWidgets('LoginPage sets currentUser and navigates to Dashboard with correct credentials', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = UserService();
      service.register(
        name: 'Dewi Lestari',
        email: 'dewi@example.com',
        phone: '085566778899',
        password: 'Password123!',
        gender: 'Perempuan',
        birthDate: '1 Januari 2000',
      );
      service.logout();

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'dewi@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'Password123!');
      await tester.pumpAndSettle();

      // Tap Masuk
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.name, equals('Dewi Lestari'));
      expect(find.text('Hai, Dewi 👋'), findsOneWidget);
    });

    testWidgets('LoginPage rejects wrong password or unregistered email', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = UserService();
      service.register(
        name: 'Dewi Lestari',
        email: 'dewi@example.com',
        phone: '085566778899',
        password: 'Password123!',
      );
      service.logout();

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Unregistered email
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'notfound@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'Password123!');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsNothing);
      expect(find.textContaining('Email belum terdaftar'), findsOneWidget);

      // 2. Wrong password
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'dewi@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'WrongPassword123!');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsNothing);
      expect(find.textContaining('Password salah'), findsOneWidget);
    });

    testWidgets('RegisterPage updates requirement indicators in realtime when typing password', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Awalnya: tidak ada centang hijau
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Ketik password yang memenuhi semua syarat
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'Password123!');
      await tester.pumpAndSettle();

      // Sekarang: semua 4 baris indikator menampilkan centang hijau
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
    });

    testWidgets('RegisterPage blocks registration if password does not meet requirements', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = UserService();
      service.logout();

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Isi form dengan password lemah
      await tester.enterText(find.widgetWithText(TextField, 'Nama Lengkap'), 'Joko Anwar');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'joko@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Nomor Telepon'), '081234567890');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'weakpass');
      await tester.enterText(find.widgetWithText(TextField, 'Konfirmasi Pasword'), 'weakpass');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap Daftar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
      await tester.pumpAndSettle();

      // Harus gagal dan menampilkan SnackBar error
      expect(find.byType(RegisterSuccessPage), findsNothing);
      expect(find.textContaining('Password belum memenuhi'), findsOneWidget);
      expect(service.currentUser, isNull);

      // Sekarang ubah password menjadi valid
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'StrongPassword123!');
      await tester.enterText(find.widgetWithText(TextField, 'Konfirmasi Pasword'), 'StrongPassword123!');
      await tester.pumpAndSettle();

      // Tap Daftar lagi
      await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
      await tester.pumpAndSettle();

      // Harus berhasil navigasi ke RegisterSuccessPage dan currentUser tersimpan
      expect(find.byType(RegisterSuccessPage), findsOneWidget);
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.name, equals('Joko Anwar'));
      expect(service.currentUser!.password, equals('StrongPassword123!'));
    });
  });
}
