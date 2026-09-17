import 'package:flutter/material.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/models/chat_message.dart';
import 'package:oste/models/consultation_history_model.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/consultation_history_service.dart';

/// Halaman Ringkasan Konsultasi Medis Reusable
/// Dapat menampilkan riwayat yang tersimpan (Read-Only) atau hasil konsultasi baru
class ConsultationSummaryPage extends StatefulWidget {
  final Doctor? doctor;
  final List<ChatMessage>? messages;
  final ConsultationHistory? consultation;

  const ConsultationSummaryPage({
    super.key,
    this.doctor,
    this.messages,
    this.consultation,
  }) : assert(consultation != null || doctor != null,
            'Harus menyertakan consultation atau doctor');

  @override
  State<ConsultationSummaryPage> createState() =>
      _ConsultationSummaryPageState();
}

class _ConsultationSummaryPageState extends State<ConsultationSummaryPage> {
  late final Doctor _doctor;
  late final String _date;
  late final String _time;
  late final String _diagnosis;
  late final String _doctorRecommendation;
  late final String _nutritionRecommendation;
  late final String _doctorNotes;
  late final String _followUpAdvice;
  late final String _summary;
  late final List<ChatMessage> _messages;
  late final bool _isFromExistingRecord;

  @override
  void initState() {
    super.initState();

    if (widget.consultation != null) {
      final c = widget.consultation!;
      _doctor = c.doctor;
      _date = c.date;
      _time = c.time;
      _diagnosis = c.diagnosis;
      _doctorRecommendation = c.doctorRecommendation;
      _nutritionRecommendation = c.nutritionRecommendation;
      _doctorNotes = c.doctorNotes;
      _followUpAdvice = c.followUpAdvice;
      _summary = c.summary;
      _messages = c.messages;
      _isFromExistingRecord = true;
    } else {
      _doctor = widget.doctor!;
      _messages = widget.messages ?? [];
      _isFromExistingRecord = false;

      final now = DateTime.now();
      _date = _formatDateIndonesian(now);
      _time = _formatTimeIndonesian(now);

      _diagnosis =
          'Indikasi Osteoporosis Ringan dengan Penurunan Densitas Tulang Lumbar';
      _doctorRecommendation =
          '• Latihan fisik beban ringan (jalan santai/senam tulang) 30 menit setiap hari.\n• Hindari mengangkat beban berat secara mendadak dan posisi bungkuk berlebih.\n• Lakukan pemeriksaan kepadatan tulang (BMD scan) berkala jika keluhan berlanjut.';
      _nutritionRecommendation =
          '• Penuhi asupan kalsium 1.000 - 1.200 mg per hari (susu rendah lemak, yogurt, brokoli, tahu/tempe).\n• Asupan Vitamin D3 1.000 IU/hari & berjemur sinar matahari pagi 15-20 menit.\n• Batasi konsumsi kafein, garam berlebih, dan minuman berkarbonasi.';
      _doctorNotes =
          'Sesi konsultasi berjalan dengan baik. Pasien disarankan menjaga postur ergonomis saat beraktivitas dan rutin memantau asupan kalsium.';
      _followUpAdvice =
          '• Lakukan kontrol berkala atau evaluasi lanjutan dalam 1-3 bulan ke depan.\n• Segera kunjungi fasilitas kesehatan jika mengalami nyeri tulang/sendi akut atau pembengkakan.';
      _summary =
          'Konsultasi kesehatan tulang dan edukasi pencegahan osteoporosis.';
    }
  }

  String _formatDateIndonesian(DateTime dt) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeIndonesian(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  void _handleBackToDashboard() {
    // Jika merupakan konsultasi baru, otomatis simpan ke ConsultationHistoryService
    if (!_isFromExistingRecord) {
      final newHistory = ConsultationHistory(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        doctor: _doctor,
        date: _date,
        time: _time,
        summary: _summary,
        diagnosis: _diagnosis,
        doctorNotes: _doctorNotes,
        doctorRecommendation: _doctorRecommendation,
        nutritionRecommendation: _nutritionRecommendation,
        followUpAdvice: _followUpAdvice,
        messages: _messages,
      );

      ConsultationHistoryService().addConsultation(newHistory);
    }

    // Kembali ke Dashboard
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1E293B),
            size: 24,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              _handleBackToDashboard();
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Ringkasan Konsultasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Kartu Info Dokter & Waktu Konsultasi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    _doctor.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.person_rounded,
                                      size: 30,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _doctor.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _doctor.specialist,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _doctor.hospital,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(
                            color: Color(0xFFF1F5F9),
                            thickness: 1,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Seksi 1: Diagnosis Medis
                    _buildSectionCard(
                      icon: Icons.assignment_turned_in_outlined,
                      iconColor: const Color(0xFFE11D48),
                      iconBgColor: const Color(0xFFFFE4E6),
                      title: 'Diagnosis Medis',
                      content: Text(
                        _diagnosis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seksi 2: Rekomendasi Dokter
                    _buildSectionCard(
                      icon: Icons.health_and_safety_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      iconBgColor: const Color(0xFFEFF6FF),
                      title: 'Rekomendasi Dokter',
                      content: Text(
                        _doctorRecommendation,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seksi 3: Rekomendasi Nutrisi
                    _buildSectionCard(
                      icon: Icons.restaurant_outlined,
                      iconColor: const Color(0xFF16A34A),
                      iconBgColor: const Color(0xFFDCFCE7),
                      title: 'Rekomendasi Nutrisi & Pola Hidup',
                      content: Text(
                        _nutritionRecommendation,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seksi 4: Catatan Dokter
                    _buildSectionCard(
                      icon: Icons.sticky_note_2_outlined,
                      iconColor: const Color(0xFFD97706),
                      iconBgColor: const Color(0xFFFEF3C7),
                      title: 'Catatan Dokter',
                      content: Text(
                        _doctorNotes,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seksi 5: Saran Tindak Lanjut
                    _buildSectionCard(
                      icon: Icons.event_repeat_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFFF3E8FF),
                      title: 'Saran Tindak Lanjut',
                      content: Text(
                        _followUpAdvice,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Tombol "Kembali Ke Beranda"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7C948),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF7C948).withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _handleBackToDashboard,
                    child: const Center(
                      child: Text(
                        'Kembali Ke Beranda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
