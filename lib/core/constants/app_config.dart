/// Konfigurasi global aplikasi Osteocare.
///
/// Pengaturan di class ini memanfaatkan [String.fromEnvironment] sehingga dapat
/// dikonfigurasi saat build atau run tanpa mengubah kode sumber:
///
/// Contoh penggunaan CLI:
/// ```bash
/// flutter run --dart-define=BASE_URL=http://192.168.1.10:8000
/// ```
/// Atau dengan file environment:
/// ```bash
/// flutter run --dart-define-from-file=.env
/// ```
class AppConfig {
  AppConfig._();

  /// Base URL backend FastAPI.
  /// Default: 'http://10.0.2.2:8000' (alamat host mesin pengembangan dari Android Emulator).
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}

