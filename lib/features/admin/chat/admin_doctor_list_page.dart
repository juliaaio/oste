import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/chat_page.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/doctor_presence_service.dart';
import 'package:oste/services/doctor_schedule_service.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Daftar Dokter untuk Admin OSTEOCARE
/// Memungkinkan Admin melihat daftar dokter dan mengirim pesan/chat ke dokter.
class AdminDoctorListPage extends StatefulWidget {
  const AdminDoctorListPage({super.key});

  @override
  State<AdminDoctorListPage> createState() => _AdminDoctorListPageState();
}

class _AdminDoctorListPageState extends State<AdminDoctorListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StreamSubscription<QuerySnapshot>? _registeredDoctorsSubscription;
  final List<Doctor> _registeredDoctors = [];

  @override
  void initState() {
    super.initState();
    DoctorPresenceService().startListeningAllDoctors();
    DoctorScheduleService().startListening();

    // Pastikan listener pesan pasien/admin aktif agar unread count ter-update
    final adminUid = UserService().currentUser?.uid ?? 'admin_osteo';
    ChatService().startListeningPatientConversations(adminUid);

    // Muat dokter terdaftar dari Firestore users (role == 'doctor' atau 'dokter')
    _listenRegisteredDoctors();
  }

  void _listenRegisteredDoctors() {
    try {
      _registeredDoctorsSubscription = FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .listen((snapshot) {
        final List<Doctor> fetched = [];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final role = data['role']?.toString().toLowerCase().trim() ?? '';
          if (role == 'doctor' || role == 'dokter') {
            final uid = doc.id;
            final name = data['name']?.toString() ?? 'Dokter Osteo';
            final specialist = data['specialist']?.toString() ??
                'Sp. Orthopaedi & Traumatologi';
            final photoUrl = data['photoUrl']?.toString() ??
                data['imageUrl']?.toString() ??
                '';

            // Jangan masukkan duplikat jika ID sudah cocok dengan doctorList
            final alreadyInStatic =
                doctorList.any((d) => d.id == uid || d.name == name);
            if (!alreadyInStatic) {
              fetched.add(Doctor(
                id: uid,
                name: name,
                specialist: specialist,
                rating: 5.0,
                isOnline: false,
                imageUrl: photoUrl.isNotEmpty
                    ? photoUrl
                    : 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=400&q=80',
                experienceYears: 5,
                patientCount: 100,
                hospital: 'RS OSTEOCARE',
                biography: 'Dokter spesialis ortopedi terdaftar di OsteoCare.',
                consultationFee: 0,
                consultationFeeFormatted: 'Konsultasi Tim',
                schedules: 'Setiap Hari Kerja',
              ));
            }
          }
        }

        if (mounted) {
          setState(() {
            _registeredDoctors
              ..clear()
              ..addAll(fetched);
          });
        }
      }, onError: (e) {
        debugPrint('[AdminDoctorList] Error mengambil daftar dokter Firestore: $e');
      });
    } catch (e) {
      debugPrint('[AdminDoctorList] Gagal inisialisasi query dokter: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _registeredDoctorsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDoctors = [...doctorList, ..._registeredDoctors];

    // Filter pencarian
    final filtered = allDoctors.where((doc) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return doc.name.toLowerCase().contains(q) ||
          doc.specialist.toLowerCase().contains(q) ||
          doc.hospital.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat Dokter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF1F5F9),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Info Bar ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Dokter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pesan yang Anda kirim akan langsung masuk ke akun dokter tujuan.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama dokter atau spesialisasi...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── List Dokter ────────────────────────────────────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  ChatService(),
                  DoctorPresenceService(),
                  DoctorScheduleService(),
                ]),
                builder: (context, _) {
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.person_search_rounded,
                            size: 52,
                            color: Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Dokter tidak ditemukan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final isOnline =
                          DoctorPresenceService().isOnline(doc.id);
                      final adminUid =
                          UserService().currentUser?.uid ?? 'admin_osteo';
                      final unreadCount = ChatService()
                          .getPatientUnreadCountForDoctor(doc.id,
                              patientId: adminUid);

                      return _buildDoctorCard(
                        context: context,
                        doctor: doc,
                        isOnline: isOnline,
                        unreadCount: unreadCount,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard({
    required BuildContext context,
    required Doctor doctor,
    required bool isOnline,
    required int unreadCount,
  }) {
    final schedule = DoctorScheduleService().getSchedule(
      doctor.id,
      fallbackDoctorName: doctor.name,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unreadCount > 0
              ? const Color(0xFFFDE68A)
              : const Color(0xFFF1F5F9),
          width: unreadCount > 0 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openChatWithDoctor(context, doctor),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Foto Profil & Status Online ──────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          doctor.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // ── Informasi Dokter ─────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCount baru',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doctor.specialist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.hospital,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // ── Status Praktik & Jadwal Dokter Realtime ──────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: schedule.isActive
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: schedule.isActive
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFCA5A5),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5.5,
                                  height: 5.5,
                                  decoration: BoxDecoration(
                                    color: schedule.isActive
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  schedule.isActive ? 'Aktif' : 'Tidak Aktif',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: schedule.isActive
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${schedule.getRepeatDaysFormatted()} · ${schedule.getFormattedTimeRange()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ── Tombol Chat ──────────────────────────────────────────────
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChatWithDoctor(BuildContext context, Doctor doctor) {
    final currentUser = UserService().currentUser;
    final adminUid = currentUser?.uid ?? 'admin_osteo';
    final adminName = currentUser?.name.isNotEmpty == true
        ? 'Admin (${currentUser!.name})'
        : 'Admin Osteo';

    final chatId = ChatService.formatChatId(
      doctorId: doctor.id,
      patientId: adminUid,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          doctor: doctor,
          chatId: chatId,
          patientId: adminUid,
          patientName: adminName,
          isDoctorPOV: false, // POV Admin (berlaku sebagai pengirim eksternal)
        ),
      ),
    );
  }
}
