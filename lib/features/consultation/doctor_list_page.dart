import 'package:flutter/material.dart';
import 'package:oste/features/consultation/doctor_card.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/consultation/doctor_profile_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/doctor_presence_service.dart';
import 'package:oste/services/doctor_schedule_service.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Daftar Dokter OSTEOCARE
/// Redesain modern, clean, dan profesional sesuai panduan desain OSTEOCARE
class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final patientUid = UserService().currentUser?.uid ?? '';
    if (patientUid.isNotEmpty) {
      ChatService().startListeningPatientConversations(patientUid);
    }
    // Mulai mendengarkan status online dan jadwal praktik semua dokter secara real-time
    DoctorPresenceService().startListeningAllDoctors();
    DoctorScheduleService().startListening();
  }

  @override
  void dispose() {
    DoctorPresenceService().stopListeningAllDoctors();
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> get _filteredDoctors {
    if (_searchQuery.trim().isEmpty) {
      return doctorList;
    }
    final query = _searchQuery.toLowerCase().trim();
    return doctorList.where((doc) {
      final nameMatches = doc.name.toLowerCase().contains(query);
      final specialistMatches = doc.specialist.toLowerCase().contains(query);
      return nameMatches || specialistMatches;
    }).toList();
  }

  void _navigateBackToDashboard() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDoctors;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header Halaman dengan Tombol Kembali, Judul, Subtitle & Ilustrasi 3D
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sisi Kiri: Tombol Back, Judul & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tombol Kembali Berbentuk Lingkaran Kuning Pastel
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _navigateBackToDashboard,
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0BD),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF14213D),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Judul Besar & Tebal
                        const Text(
                          'Daftar Dokter',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14213D),
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        const Text(
                          'Temukan dokter yang tepat untuk kesehatan tulangmu.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8A9AB5),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sisi Kanan: Ilustrasi Dokter 3D Ramah dengan Aksen Bentuk Kuning Pastel
                  SizedBox(
                    width: 132,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Bentuk dekoratif kuning pastel di belakang ilustrasi
                        Positioned(
                          right: 0,
                          top: 10,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0BD).withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Ilustrasi Dokter Perempuan 3D
                        Image.asset(
                          'assets/images/doctor_header_illustration.png',
                          width: 132,
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFFE8EBF1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14213D).withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: Color(0xFF14213D),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF14213D),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama dokter atau spesialisasi',
                          hintStyle: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF8A9AB5),
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF8A9AB5),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            // Banner Notifikasi Balasan Dokter (Jika Ada Pesan Belum Dibaca)
            ListenableBuilder(
              listenable: ChatService(),
              builder: (context, _) {
                final totalUnread = ChatService().totalPatientUnreadCount;
                if (totalUnread <= 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7C948)
                                .withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_chat_unread_rounded,
                            size: 20,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Balasan Baru Dari Dokter',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF14213D),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ada $totalUnread pesan belum dibaca. Ketuk dokter terkait untuk membalas.',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalUnread baru',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 3. Section Header: "Dokter Tersedia" & Jumlah Dokter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Dokter Tersedia',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14213D),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${filtered.length} Dokter',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A9AB5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. Daftar Kartu Dokter (Scrollable)
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 52,
                            color: const Color(0xFF8A9AB5).withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Dokter tidak ditemukan',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF8A9AB5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Coba gunakan kata kunci pencarian yang lain.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8A9AB5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doctor = filtered[index];
                        return DoctorCard(
                          doctor: doctor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DoctorProfilePage(doctor: doctor),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 5. Tombol Besar "Kembali Ke Beranda" di Bawah Layar
      bottomNavigationBar: Container(
        color: const Color(0xFFFFFEFA),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD34E),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD34E).withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_rounded,
                        color: Color(0xFF14213D),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kembali Ke Beranda',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF14213D),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
