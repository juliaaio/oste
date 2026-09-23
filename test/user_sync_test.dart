import 'package:flutter_test/flutter_test.dart';
import 'package:oste/models/user_model.dart';

/// Unit tests untuk UserModel dan logika validasi lokal.
///
/// Catatan: Pengujian integrasi Firebase Auth / Firestore memerlukan
/// Firebase Emulator Suite dan tidak dicakup di sini.
/// Hanya logika murni Dart yang diuji di file ini.
void main() {
  group('UserModel', () {
    const user = UserModel(
      uid: 'uid-123',
      name: 'Budi Santoso',
      email: 'budi@example.com',
      phone: '081122334455',
      gender: 'Laki-laki',
      birthDate: '12 Desember 1990',
      weight: 65,
      height: 172,
    );

    test('firstName returns first word of name', () {
      expect(user.firstName, equals('Budi'));
    });

    test('firstName handles single-word name', () {
      const singleName = UserModel(uid: 'x', name: 'Budi', email: 'b@b.com');
      expect(singleName.firstName, equals('Budi'));
    });

    test('firstName handles empty name gracefully', () {
      const emptyName = UserModel(uid: 'x', name: '', email: 'b@b.com');
      expect(emptyName.firstName, equals(''));
    });

    test('toFirestore serializes all fields correctly', () {
      final map = user.toFirestore();
      expect(map['uid'], equals('uid-123'));
      expect(map['name'], equals('Budi Santoso'));
      expect(map['email'], equals('budi@example.com'));
      expect(map['phone'], equals('081122334455'));
      expect(map['gender'], equals('Laki-laki'));
      expect(map['birth_date'], equals('12 Desember 1990'));
      expect(map['weight'], equals(65.0));
      expect(map['height'], equals(172.0));
    });

    test('toMap is alias of toFirestore', () {
      expect(user.toMap(), equals(user.toFirestore()));
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'name': 'Siti Nurhaliza',
        'email': 'siti@example.com',
        'phone': '089988776655',
        'gender': 'Perempuan',
        'birth_date': '20 Februari 1998',
        'weight': 52.0,
        'height': 158.0,
      };
      final fromMap = UserModel.fromMap('uid-456', map);
      expect(fromMap.uid, equals('uid-456'));
      expect(fromMap.name, equals('Siti Nurhaliza'));
      expect(fromMap.email, equals('siti@example.com'));
      expect(fromMap.phone, equals('089988776655'));
      expect(fromMap.gender, equals('Perempuan'));
      expect(fromMap.birthDate, equals('20 Februari 1998'));
      expect(fromMap.weight, equals(52.0));
      expect(fromMap.height, equals(158.0));
    });

    test('fromMap handles missing optional fields with defaults', () {
      final sparse = UserModel.fromMap('uid-789', {'name': 'Ahmad', 'email': 'a@a.com'});
      expect(sparse.phone, equals(''));
      expect(sparse.gender, equals(''));
      expect(sparse.birthDate, equals(''));
      expect(sparse.weight, isNull);
      expect(sparse.height, isNull);
    });

    test('fromMap robustly parses string and int numbers for weight and height', () {
      final parsed = UserModel.fromMap('uid-999', {
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': 81234567890,
        'birthDate': '10 Januari 1995',
        'weight': '68.5',
        'height': 175,
      });
      expect(parsed.phone, equals('81234567890'));
      expect(parsed.birthDate, equals('10 Januari 1995'));
      expect(parsed.weight, equals(68.5));
      expect(parsed.height, equals(175.0));
    });

    test('copyWith returns updated model with unchanged fields preserved', () {
      final updated = user.copyWith(name: 'Budi Santoso Jr', weight: 70);
      expect(updated.uid, equals(user.uid));
      expect(updated.name, equals('Budi Santoso Jr'));
      expect(updated.email, equals(user.email));
      expect(updated.weight, equals(70));
      expect(updated.height, equals(user.height));
    });

    test('copyWith with no args returns equivalent model', () {
      final copy = user.copyWith();
      expect(copy.uid, equals(user.uid));
      expect(copy.name, equals(user.name));
      expect(copy.email, equals(user.email));
    });
  });
}
