import 'package:flutter/foundation.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/models/chat_message.dart';
import 'package:oste/models/consultation_history_model.dart';

/// Layanan singleton untuk mengelola penyimpanan & riwayat konsultasi medis
class ConsultationHistoryService extends ChangeNotifier {
  static final ConsultationHistoryService _instance =
      ConsultationHistoryService._internal();

  factory ConsultationHistoryService() => _instance;

  ConsultationHistoryService._internal() {
    _seedInitialHistory();
  }

  final List<ConsultationHistory> _histories = [];

  List<ConsultationHistory> get allConsultations =>
      List.unmodifiable(_histories);

  /// Mengambil daftar riwayat khusus dokter tertentu
  List<ConsultationHistory> getConsultationsByDoctorId(String doctorId) {
    return _histories
        .where((item) => item.doctor.id == doctorId)
        .toList();
  }

  /// Menambahkan riwayat konsultasi baru ke urutan teratas
  void addConsultation(ConsultationHistory consultation) {
    // Hindari duplikasi jika sudah ada dengan id yang sama
    final existingIndex =
        _histories.indexWhere((item) => item.id == consultation.id);
    if (existingIndex >= 0) {
      _histories[existingIndex] = consultation;
    } else {
      _histories.insert(0, consultation);
    }
    notifyListeners();
  }

  /// Mencari riwayat konsultasi berdasarkan ID
  ConsultationHistory? getById(String id) {
    try {
      return _histories.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Inisialisasi data riwayat bawaan sesuai spesifikasi
  void _seedInitialHistory() {
    final docAndi = doctorList.firstWhere(
      (d) => d.id == 'doc_1',
      orElse: () => doctorList[0],
    );

    _histories.addAll([
      ConsultationHistory(
        id: 'hist_andi_3',
        doctor: docAndi,
        date: '20 September 2026',
        time: '14:15 WIB',
        summary: 'Evaluasi respon terapi suplemen kalsium dan perkembangan nyeri sendi.',
        diagnosis: 'Pemulihan Kepadatan Tulang Terkontrol (Osteopenia Stabil)',
        doctorNotes:
            'Kondisi kepadatan tulang terpantau membaik. Nyeri pada pergelangan kaki berkurang secara signifikan.',
        doctorRecommendation:
            'Lanjutkan latihan beban tubuh ringan (bodyweight) 3x seminggu. Hindari aktivitas melompat.',
        nutritionRecommendation:
            'Pertahankan konsumsi kalsium 1000 mg/hari dan paparan sinar matahari pagi selama 15 menit.',
        messages: const [
          ChatMessage(
            id: 'm1',
            text: 'Halo dr. Andi, saya ingin kontrol evaluasi rutin minggu ini.',
            time: '14:00',
            isFromDoctor: false,
          ),
          ChatMessage(
            id: 'm2',
            text:
                'Selamat siang. Bagaimana rasa nyeri sendi setelah rutin jalan pagi dan konsumsi suplemen?',
            time: '14:02',
            isFromDoctor: true,
          ),
          ChatMessage(
            id: 'm3',
            text: 'Sudah jauh berkurang dok, jalan kaki sudah lebih nyaman.',
            time: '14:05',
            isFromDoctor: false,
          ),
          ChatMessage(
            id: 'm4',
            text:
                'Bagus sekali. Pertahankan rutinitas latihan fisik ringan dan asupan nutrisi Anda.',
            time: '14:08',
            isFromDoctor: true,
          ),
        ],
      ),
      ConsultationHistory(
        id: 'hist_andi_2',
        doctor: docAndi,
        date: '17 September 2026',
        time: '10:30 WIB',
        summary: 'Konsultasi lanjutan keluhan nyeri pinggang dan review asupan vitamin D.',
        diagnosis: 'Indikasi Osteoporosis Ringan dengan Spasme Otot Punggung Bawah',
        doctorNotes:
            'Pasien mengeluhkan ngilu di area lumbar saat bangun tidur. Diperlukan koreksi postur duduk saat bekerja.',
        doctorRecommendation:
            'Gunakan kursi ergonomis dengan bantalan lumbar. Lakukan peregangan pinggang tiap 45 menit duduk.',
        nutritionRecommendation:
            'Tingkatkan asupan magnesium dan vitamin D3 1000 IU harian untuk relaksasi otot dan penyerapan kalsium.',
        messages: const [
          ChatMessage(
            id: 'm1',
            text: 'Selamat pagi dok, akhir-akhir ini pinggang saya sering kaku saat bangun tidur.',
            time: '10:20',
            isFromDoctor: false,
          ),
          ChatMessage(
            id: 'm2',
            text:
                'Pagi. Apakah posisi tidur Anda sering melengkung atau kasur terlalu empuk?',
            time: '10:22',
            isFromDoctor: true,
          ),
        ],
      ),
      ConsultationHistory(
        id: 'hist_andi_1',
        doctor: docAndi,
        date: '10 September 2026',
        time: '09:00 WIB',
        summary: 'Konsultasi awal skrining risiko osteoporosis dan edukasi pencegahan.',
        diagnosis: 'Risiko Osteoporosis Sedang (Skrining Awal)',
        doctorNotes:
            'Pemeriksaan skrining mandiri menunjukkan skor risiko sedang karena gaya hidup kurang bergerak (sedentary).',
        doctorRecommendation:
            'Mulai program jalan santai harian 30 menit dan lakukan tes BMD (Bone Mineral Density) jika gejala menetap.',
        nutritionRecommendation:
            'Konsumsi susu tinggi kalsium atau olahan kedelai, brokoli, dan kurangi kafein berlebih.',
        messages: const [
          ChatMessage(
            id: 'm1',
            text: 'Halo dr. Andi, hasil skrining mandiri saya terindikasi risiko osteoporosis.',
            time: '08:50',
            isFromDoctor: false,
          ),
          ChatMessage(
            id: 'm2',
            text:
                'Selamat pagi. Jangan cemas, pada usia produktif kita masih bisa meningkatkan masa tulang secara optimal.',
            time: '08:52',
            isFromDoctor: true,
          ),
        ],
      ),
    ]);
  }
}
