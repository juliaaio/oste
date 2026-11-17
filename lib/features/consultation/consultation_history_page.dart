import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/consultation_history_card.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/models/consultation_history_model.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Riwayat Konsultasi (Dapat difilter khusus dokter tertentu atau menampilkan semua)
class ConsultationHistoryPage extends StatelessWidget {
  final Doctor? doctor;

  const ConsultationHistoryPage({
    super.key,
    this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    String uid = '';
    try {
      uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {}
    if (uid.isEmpty) {
      uid = UserService().currentUser?.uid ?? '';
    }

    Stream<QuerySnapshot<Map<String, dynamic>>> stream = const Stream.empty();
    if (uid.isNotEmpty) {
      try {
        stream = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('riwayat_konsultasi')
            .snapshots();
      } catch (_) {}
    }

    final title = doctor != null
        ? 'Riwayat: ${doctor!.name}'
        : 'Riwayat Konsultasi';

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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            List<ConsultationHistory> histories = [];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              histories = snapshot.data!.docs.map((doc) {
                return ConsultationHistory.fromFirestore(doc);
              }).toList();

              // Filter khusus dokter tertentu jika diberikan parameter
              if (doctor != null) {
                histories = histories
                    .where((item) => item.doctorId == doctor!.id)
                    .toList();
              }

              // Urutkan riwayat dari yang terbaru ke terlama
              histories.sort((a, b) {
                final aTime = a.completedAt ?? a.createdAt;
                final bTime = b.completedAt ?? b.createdAt;
                if (aTime != null && bTime != null) {
                  return bTime.compareTo(aTime);
                }
                return b.id.compareTo(a.id);
              });
            }

            if (histories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.history_toggle_off_rounded,
                          size: 38,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        doctor != null
                            ? 'Belum ada riwayat konsultasi dengan ${doctor!.name}'
                            : 'Belum ada riwayat konsultasi',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Konsultasi yang telah selesai akan tersimpan secara otomatis di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final item = histories[index];
                return ConsultationHistoryCard(
                  consultation: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationSummaryPage(
                          consultation: item,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
