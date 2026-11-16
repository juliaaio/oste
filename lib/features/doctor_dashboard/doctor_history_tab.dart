import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/models/consultation_history_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/consultation_history_service.dart';
import 'package:oste/services/history_service.dart';
import 'package:oste/services/user_service.dart';

/// Tab Riwayat untuk Dokter
class DoctorHistoryTab extends StatefulWidget {
  const DoctorHistoryTab({super.key});

  @override
  State<DoctorHistoryTab> createState() => _DoctorHistoryTabState();
}

class _DoctorHistoryTabState extends State<DoctorHistoryTab> {
  int _selectedTabIndex = 0; // 0 = Skrining Pasien, 1 = Riwayat Konsultasi
  final Map<String, String> _patientNamesCache = {};

  @override
  void initState() {
    super.initState();
    _populateInitialNames();
  }

  void _populateInitialNames() {
    for (final conv in ChatService().conversations) {
      if (conv.patientId.isNotEmpty && conv.patientName.isNotEmpty) {
        _patientNamesCache[conv.patientId] = conv.patientName;
      }
    }
    final user = UserService().currentUser;
    if (user != null && !user.isDoctor && user.name.isNotEmpty) {
      _patientNamesCache[user.uid] = user.name;
    }
  }

  void _fetchAndCachePatientName(String patientId) {
    if (patientId.isEmpty || _patientNamesCache.containsKey(patientId)) return;
    _patientNamesCache[patientId] = ''; // Cegah request berulang
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get()
          .then((doc) {
        if (doc.exists && doc.data() != null) {
          final name = doc.data()!['name']?.toString() ?? '';
          if (name.isNotEmpty && mounted) {
            setState(() {
              _patientNamesCache[patientId] = name;
            });
          }
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  String _resolvePatientNameForScreening(HistoryModel item) {
    if (item.patientName != null && item.patientName!.trim().isNotEmpty) {
      return item.patientName!.trim();
    }
    if (item.patientId != null && item.patientId!.isNotEmpty) {
      final cached = _patientNamesCache[item.patientId!];
      if (cached != null && cached.isNotEmpty) return cached;
    }
    final convs = ChatService().conversations;
    for (final conv in convs) {
      if (conv.patientName.isNotEmpty &&
          !ChatService.isDummyConversation(conv.chatId, conv.patientName)) {
        return conv.patientName;
      }
    }
    final user = UserService().currentUser;
    if (user != null && !user.isDoctor && user.name.isNotEmpty) {
      return user.name;
    }
    return '';
  }

  String _resolvePatientNameForConsultation(dynamic c) {
    if (c is ConsultationHistory) {
      if (c.patientName != null && c.patientName!.trim().isNotEmpty) {
        return c.patientName!.trim();
      }
      if (c.patientId != null && c.patientId!.isNotEmpty) {
        final cached = _patientNamesCache[c.patientId!];
        if (cached != null && cached.isNotEmpty) return cached;
      }
    }
    final convs = ChatService().conversations;
    for (final conv in convs) {
      if (conv.patientName.isNotEmpty &&
          !ChatService.isDummyConversation(conv.chatId, conv.patientName)) {
        return conv.patientName;
      }
    }
    final user = UserService().currentUser;
    if (user != null && !user.isDoctor && user.name.isNotEmpty) {
      return user.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final historyService = HistoryService();
    final consultationService = ConsultationHistoryService();
    final chatService = ChatService();

    Stream<QuerySnapshot<Map<String, dynamic>>>? screeningStream;
    try {
      screeningStream = FirebaseFirestore.instance
          .collectionGroup('riwayat_skrining')
          .snapshots();
    } catch (_) {
      screeningStream = null;
    }

    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: screeningStream,
        builder: (context, firestoreSnapshot) {
          return AnimatedBuilder(
            animation: Listenable.merge([historyService, consultationService, chatService]),
            builder: (context, _) {
              List<HistoryModel> liveScreenings = [];

              if (firestoreSnapshot.hasData &&
                  firestoreSnapshot.data!.docs.isNotEmpty) {
                liveScreenings = firestoreSnapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;
                  final parentUid = doc.reference.parent.parent?.id ?? '';
                  final patientId =
                      (data['patientId'] ?? data['userId'] ?? parentUid).toString();

                  String pName = (data['patientName'] ??
                          data['userName'] ??
                          data['namaPasien'] ??
                          '')
                      .toString();
                  if (pName.isEmpty && patientId.isNotEmpty) {
                    pName = _patientNamesCache[patientId] ?? '';
                    if (pName.isEmpty) {
                      _fetchAndCachePatientName(patientId);
                    }
                  }
                  data['patientName'] = pName;
                  data['patientId'] = patientId;

                  return HistoryModel.fromMap(data);
                }).toList();

                // Urutkan dari yang terbaru
                liveScreenings.sort((a, b) => b.tanggal.compareTo(a.tanggal));
              }

              // Jika snapshot kosong atau offline, gunakan data HistoryService
              if (liveScreenings.isEmpty) {
                liveScreenings = historyService.screeningHistories;
              }

              // Sinkronkan cache percakapan dari ChatService
              for (final conv in chatService.conversations) {
                if (conv.patientId.isNotEmpty && conv.patientName.isNotEmpty) {
                  _patientNamesCache.putIfAbsent(conv.patientId, () => conv.patientName);
                }
              }

              // Gabungkan riwayat konsultasi dari ConsultationHistoryService dan ChatService yang telah selesai
              final List<ConsultationHistory> consultations = [];
              consultations.addAll(consultationService.allConsultations);

              for (final conv in chatService.completedConversations) {
                final alreadyExists = consultations.any(
                  (c) => c.id == conv.chatId || c.id.contains(conv.chatId),
                );
                if (!alreadyExists) {
                  final doc = doctorList.firstWhere(
                    (d) => d.id == conv.doctorId,
                    orElse: () => doctorList.first,
                  );
                  consultations.add(
                    ConsultationHistory(
                      id: conv.chatId,
                      doctor: doc,
                      date: conv.time,
                      time: '',
                      summary: conv.lastMessage.isNotEmpty
                          ? conv.lastMessage
                          : 'Sesi konsultasi medis telah diselesaikan.',
                      diagnosis: 'Konsultasi Selesai',
                      doctorNotes: 'Konsultasi selesai dengan ${conv.patientName}.',
                      doctorRecommendation:
                          'Ikuti anjuran dokter dan kontrol berkala bila perlu.',
                      nutritionRecommendation:
                          'Pertahankan asupan kalsium dan vitamin D harian.',
                      patientName: conv.patientName,
                      patientId: conv.patientId,
                    ),
                  );
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Riwayat Dokter ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Riwayat Pasien',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: DoctorThemeColors.textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pantau riwayat skrining dan konsultasi pasien',
                          style: TextStyle(
                            fontSize: 13,
                            color: DoctorThemeColors.textMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Tab Bar (Skrining Pasien vs Konsultasi) ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              title: 'Skrining Pasien',
                              isSelected: _selectedTabIndex == 0,
                              onTap: () => setState(() => _selectedTabIndex = 0),
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              title: 'Konsultasi',
                              isSelected: _selectedTabIndex == 1,
                              onTap: () => setState(() => _selectedTabIndex = 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Daftar Riwayat Berdasarkan Tab Terpilih ─────────────
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? _buildScreeningHistoryList(liveScreenings)
                        : _buildConsultationHistoryList(consultations),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? DoctorThemeColors.textDark
                  : DoctorThemeColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  /// Daftar riwayat skrining pasien
  Widget _buildScreeningHistoryList(List<HistoryModel> liveScreenings) {
    if (liveScreenings.isNotEmpty) {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: liveScreenings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = liveScreenings[index];
          final color = item.isPositive
              ? const Color(0xFFE11D48)
              : const Color(0xFF10B981);
          final category = item.riskCategory ?? item.status;
          final patientName = _resolvePatientNameForScreening(item);

          return _buildScreeningCard(
            patientName: patientName,
            title: item.status,
            date:
                '${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}',
            probability: '${item.probabilitas}%',
            category: category,
            categoryColor: color,
            description: item.summary ??
                'Riwayat analisis skrining risiko osteoporosis pasien.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HasilScreeningPage(
                    scorePercentage: item.probabilitas.toDouble(),
                    modelConfidence: item.modelConfidence,
                    prediction: item.isPositive ? 1 : 0,
                    riskTitle: item.riskCategory ??
                        (item.isPositive ? 'risiko sedang' : 'risiko rendah'),
                    riskDescription: item.summary ?? '',
                    predictionData: item.predictionData,
                    recommendations: item.recommendations,
                    screeningId: item.id,
                    autoSave: false,
                    source: 'history',
                    isReadOnly: true,
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Tampilkan empty state jika belum ada data riwayat skrining
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Color(0xFFCBD5E1),
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada riwayat skrining pasien',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Hasil skrining pasien akan otomatis tercatat di sini',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningCard({
    required String patientName,
    required String title,
    required String date,
    required String probability,
    required String category,
    required Color categoryColor,
    required String description,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
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
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (patientName.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Nama Pasien: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorThemeColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DoctorThemeColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: DoctorThemeColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.analytics_outlined,
                      size: 13, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    'Probabilitas: $probability',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: DoctorThemeColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Daftar riwayat konsultasi pasien
  Widget _buildConsultationHistoryList(dynamic consultations) {
    if (consultations == null || consultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history_toggle_off_rounded,
                size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 8),
            Text(
              'Belum ada riwayat konsultasi',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: consultations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = consultations[index];
        final patientName = _resolvePatientNameForConsultation(c);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConsultationSummaryPage(
                    doctor: c.doctor,
                    messages: c.messages,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
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
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (patientName.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Nama Pasien: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: DoctorThemeColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: DoctorThemeColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c.diagnosis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: DoctorThemeColors.textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        c.time.toString().isNotEmpty
                            ? '${c.date} · ${c.time}'
                            : c.date.toString(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: DoctorThemeColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
