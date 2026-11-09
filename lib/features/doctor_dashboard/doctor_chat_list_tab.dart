import 'package:flutter/material.dart';
import 'package:oste/features/consultation/chat_page.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/patient_presence_service.dart';

/// Tab Chat Pasien sesuai Figma Screenshot 2
class DoctorChatListTab extends StatefulWidget {
  const DoctorChatListTab({super.key});

  @override
  State<DoctorChatListTab> createState() => _DoctorChatListTabState();
}

class _DoctorChatListTabState extends State<DoctorChatListTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    PatientPresenceService().startListeningAllPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    PatientPresenceService().stopListeningAllPatients();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ChatService(), PatientPresenceService()]),
      builder: (context, _) {
        final allConversations = ChatService().conversations;

        // Filter percakapan berdasarkan query pencarian
        final filteredList = allConversations.where((item) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return item.patientName.toLowerCase().contains(q) ||
              item.lastMessage.toLowerCase().contains(q);
        }).toList();

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Chat Pasien ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Chat Pasien',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: DoctorThemeColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola dan balas pesan dari pasien Anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: DoctorThemeColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Search Bar: "Cari nama pasien atau pesan..." ─────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari nama pasien atau pesan...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Daftar Kartu Percakapan Pasien ──────────────────────────
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Color(0xFFCBD5E1),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Percakapan tidak ditemukan',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildPatientConversationCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Kartu percakapan pasien sesuai mockup Figma
  Widget _buildPatientConversationCard(
    BuildContext context,
    ConversationSummary item,
  ) {
    final isPatientOnline = PatientPresenceService().isOnline(
      item.patientId,
      fallback: item.isOnline,
    );

    return InkWell(
      onTap: () async {
        // Tandai percakapan sebagai sudah dibaca segera saat dokter mengetuk
        await ChatService().markConversationAsRead(item.chatId);

        if (!context.mounted) return;

        // Buka halaman chat konsultasi dalam POV DOKTER
        final doctor = doctorList.firstWhere(
          (d) => d.id == 'doc_1',
          orElse: () => doctorList[0],
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              doctor: doctor,
              chatId: item.chatId,
              patientId: item.patientId,
              patientName: item.patientName,
              patientInitial: item.patientInitial,
              isPatientOnline: isPatientOnline,
              isDoctorPOV: true, // POV DOKTER AKTIF!
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Sorot latar kuning butter tipis untuk percakapan yang belum dibaca
          color: item.unreadCount > 0
              ? const Color(0xFFFFFBEB)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.unreadCount > 0
                ? const Color(0xFFFDE68A)
                : const Color(0xFFF1F5F9),
            width: item.unreadCount > 0 ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: item.unreadCount > 0
                  ? const Color(0xFFF7C948).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar inisial dengan badge status online/offline ──────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B), // Butter yellow / amber avatar
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.patientInitial,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Indikator status (hijau = online, abu-abu = offline)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isPatientOnline
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

            // ── Informasi Pasien & Kutipan Pesan Terakhir ───────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: DoctorThemeColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Keterangan status Online / Offline
                      _buildStatusBadge(isPatientOnline),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: item.unreadCount > 0
                          ? const Color(0xFF334155)
                          : DoctorThemeColors.textMuted,
                      fontWeight: item.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Waktu & Badge Pesan Belum Dibaca ────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: item.unreadCount > 0
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: item.unreadCount > 0
                        ? const Color(0xFF475569)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 6),
                if (item.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${item.unreadCount}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Badge status keterangan Online / Offline identik dengan kartu konsultasi dokter
  Widget _buildStatusBadge(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2.5,
      ),
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFFE5F9EC)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF16B86A)
                  : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOnline
                  ? const Color(0xFF16B86A)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
