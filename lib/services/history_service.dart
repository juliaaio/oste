import 'package:flutter/foundation.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/services/consultation_history_service.dart';

/// Layanan singleton untuk mengelola riwayat aplikasi (skrining & konsultasi)
class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();

  factory HistoryService() => _instance;

  HistoryService._internal() {
    // Dengarkan pembaruan dari ConsultationHistoryService agar HistoryService reaktif
    ConsultationHistoryService().addListener(_onConsultationUpdated);
  }

  void _onConsultationUpdated() {
    notifyListeners();
  }

  final List<HistoryModel> _screeningHistories = [];

  /// Daftar riwayat skrining saja
  List<HistoryModel> get screeningHistories =>
      List.unmodifiable(_screeningHistories);

  /// Mengambil data hasil skrining terakhir yang dilakukan user.
  /// Mengembalikan `null` jika user belum pernah melakukan skrining.
  HistoryModel? get latestScreening {
    if (_screeningHistories.isEmpty) return null;
    return _screeningHistories.first;
  }

  /// Menambahkan riwayat skrining baru ke urutan teratas
  void addScreening(HistoryModel screening) {
    final existingIndex =
        _screeningHistories.indexWhere((item) => item.id == screening.id);
    if (existingIndex >= 0) {
      _screeningHistories[existingIndex] = screening;
    } else {
      _screeningHistories.insert(0, screening);
    }
    notifyListeners();
  }

  /// Mengambil seluruh riwayat gabungan (skrining dan konsultasi)
  List<HistoryModel> get allHistories {
    final List<HistoryModel> combined = [];

    // Tambahkan riwayat skrining
    combined.addAll(_screeningHistories);

    // Tambahkan riwayat konsultasi dari ConsultationHistoryService
    final consultations = ConsultationHistoryService().allConsultations;
    for (final c in consultations) {
      combined.add(HistoryModel.fromConsultation(c));
    }

    return List.unmodifiable(combined);
  }

  /// Menghapus atau membersihkan (untuk testing jika diperlukan)
  void clearScreeningHistories() {
    _screeningHistories.clear();
    notifyListeners();
  }
}
