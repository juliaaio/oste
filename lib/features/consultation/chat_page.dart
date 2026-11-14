import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/chat_bubble.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/doctor_presence_service.dart';
import 'package:oste/services/patient_presence_service.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Chat Konsultasi Dokter Osteo dengan dukungan POV Pasien & Dokter
class ChatPage extends StatefulWidget {
  final Doctor doctor;
  final DateTime? consultationStartTime;
  final bool isDoctorPOV;
  final String? chatId;
  final String? patientId;
  final String? patientName;
  final String? patientInitial;
  final bool isPatientOnline;
  final String? initialStatus;

  const ChatPage({
    super.key,
    required this.doctor,
    this.consultationStartTime,
    this.isDoctorPOV = false,
    this.chatId,
    this.patientId,
    this.patientName,
    this.patientInitial,
    this.isPatientOnline = true,
    this.initialStatus,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _messageSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _chatMetaSubscription;
  String _consultationStatus = 'active';

  String get _effectiveChatId {
    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      return widget.chatId!;
    }
    final patientUid = widget.patientId ??
        (widget.isDoctorPOV
            ? ''
            : (UserService().currentUser?.uid ??
                (UserService().currentUser?.isAdmin == true
                    ? 'admin_osteo'
                    : 'local_user')));
    return ChatService.formatChatId(
      doctorId: widget.doctor.id,
      patientId: patientUid,
    );
  }

  String get _effectivePatientId {
    if (widget.patientId != null && widget.patientId!.isNotEmpty) {
      return widget.patientId!;
    }
    if (_effectiveChatId.startsWith('chat_${widget.doctor.id}_')) {
      final pid = _effectiveChatId.substring('chat_${widget.doctor.id}_'.length);
      if (pid.isNotEmpty) return pid;
    }
    final user = UserService().currentUser;
    if (user?.isAdmin == true) return user?.uid ?? 'admin_osteo';
    return widget.isDoctorPOV
        ? ''
        : (user?.uid ?? 'local_user');
  }

  String get _patientInitial {
    if (widget.patientInitial != null && widget.patientInitial!.isNotEmpty) {
      return widget.patientInitial!;
    }
    if (widget.patientName != null && widget.patientName!.isNotEmpty) {
      return widget.patientName![0].toUpperCase();
    }
    return 'P';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi presence real-time untuk POV Dokter maupun POV Pasien
    if (widget.isDoctorPOV) {
      final targetPatientId = _effectivePatientId;
      if (targetPatientId.isNotEmpty) {
        PatientPresenceService().startListeningPatient(targetPatientId);
      }
    } else {
      final patientUid = _effectivePatientId;
      if (patientUid.isNotEmpty) {
        PatientPresenceService().setOnline(
          patientUid,
          patientName:
              UserService().currentUser?.name ?? widget.patientName ?? '',
        );
      }
    }

    // Inisialisasi status konsultasi awal
    if (widget.initialStatus != null && widget.initialStatus!.isNotEmpty) {
      _consultationStatus = widget.initialStatus!;
    } else {
      final found = ChatService().conversations.firstWhere(
        (c) => c.chatId == _effectiveChatId,
        orElse: () => ConversationSummary.empty,
      );
      if (found.chatId.isNotEmpty) {
        _consultationStatus = found.consultationStatus;
      }
    }

    // 1. Muat pesan awal yang tersimpan dari cache lokal ChatService
    final existingMessages = ChatService().getMessages(_effectiveChatId);
    if (existingMessages.isNotEmpty) {
      _messages.addAll(existingMessages);
    }

    // 2. Tandai pesan sebagai sudah dibaca sesuai peran pengguna saat ini
    _markCurrentConversationAsRead();

    // 3. Dengarkan pembaruan real-time dari ChatService / Firestore
    _messageSubscription =
        ChatService().getMessagesStream(_effectiveChatId).listen((newMessages) {
      if (newMessages.isNotEmpty && mounted) {
        setState(() {
          // Sinkronisasi list pesan dengan data real-time Firestore
          final pendingLocal = _messages
              .where((m) => !newMessages.any((nm) => nm.id == m.id))
              .toList();
          _messages
            ..clear()
            ..addAll(newMessages)
            ..addAll(pendingLocal);
        });
        _scrollToBottom();

        // Jika halaman masih dibuka saat balasan baru tiba, langsung tandai dibaca
        _markCurrentConversationAsRead();
      }
    });

    // 4. Dengarkan pembaruan status konsultasi dari dokumen induk chat di Firestore
    _chatMetaSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(_effectiveChatId)
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
      if (snap.exists && mounted) {
        final data = snap.data();
        final status =
            data?['consultationStatus']?.toString().toLowerCase().trim();
        if (status != null &&
            (status == 'unread' || status == 'active' || status == 'completed')) {
          if (_consultationStatus != status) {
            setState(() {
              _consultationStatus = status;
            });
          }
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      if (widget.isDoctorPOV) {
        final doctorUid = UserService().currentUser?.uid ?? widget.doctor.id;
        if (doctorUid.isNotEmpty) {
          DoctorPresenceService().setOffline(doctorUid);
        }
      } else {
        final patientUid = _effectivePatientId;
        if (patientUid.isNotEmpty) {
          PatientPresenceService().setOffline(patientUid);
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isDoctorPOV) {
        final doctorUid = UserService().currentUser?.uid ?? widget.doctor.id;
        if (doctorUid.isNotEmpty) {
          DoctorPresenceService().setOnline(
            doctorUid,
            doctorId: widget.doctor.id,
          );
        }
      } else {
        final patientUid = _effectivePatientId;
        if (patientUid.isNotEmpty) {
          PatientPresenceService().setOnline(
            patientUid,
            patientName:
                UserService().currentUser?.name ?? widget.patientName ?? '',
          );
        }
      }
    }
  }

  void _markCurrentConversationAsRead() {
    if (widget.isDoctorPOV) {
      ChatService().markConversationAsRead(_effectiveChatId);
    } else {
      final patientUid = widget.patientId ??
          (UserService().currentUser?.uid ?? 'local_user');
      ChatService().markConversationAsReadByPatient(
        _effectiveChatId,
        patientUid,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.isDoctorPOV) {
      PatientPresenceService().stopListeningPatient(_effectivePatientId);
    }
    _messageSubscription?.cancel();
    _chatMetaSubscription?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final userTime = _formatCurrentTime();
    _textController.clear();

    // ── KONDISI 1: PENGIRIMAN PESAN DALAM POV DOKTER ────────────────────────
    if (widget.isDoctorPOV) {
      final doctorUid = UserService().currentUser?.uid ?? widget.doctor.id;
      final targetPatientId = widget.patientId ??
          (_effectiveChatId.startsWith('chat_${widget.doctor.id}_')
              ? _effectiveChatId.substring('chat_${widget.doctor.id}_'.length)
              : 'patient_current');

      final doctorMsg = ChatMessage(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        time: userTime,
        isFromDoctor: true,
        senderId: doctorUid,
        receiverId: targetPatientId,
        senderRole: 'doctor',
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.add(doctorMsg);
      });

      _scrollToBottom();
      _focusNode.requestFocus();

      // Simpan ke ChatService & Cloud Firestore dengan receiverId milik pasien
      await ChatService().sendMessage(
        chatId: _effectiveChatId,
        text: text,
        isFromDoctor: true,
        senderId: doctorUid,
        receiverId: targetPatientId,
        patientName: widget.patientName ?? '',
        patientId: targetPatientId,
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        doctorSpecialist: widget.doctor.specialist,
        doctorImageUrl: widget.doctor.imageUrl,
      );

      // Selesai! Dalam mode dokter, TIDAK ADA balasan bot otomatis apa pun.
      return;
    }

    // ── KONDISI 2: PENGIRIMAN PESAN DALAM POV PASIEN / ADMIN ────────────────
    final currentUser = UserService().currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final patientUid = _effectivePatientId;
    final patientName = widget.patientName ??
        (currentUser?.name.isNotEmpty == true
            ? (isAdmin ? 'Admin (${currentUser!.name})' : currentUser!.name)
            : (isAdmin ? 'Admin Osteo' : 'Pasien'));
    final senderRole = isAdmin ? 'admin' : 'patient';
    final targetDoctorId = widget.doctor.id;

    final userMsg = ChatMessage(
      id: '${isAdmin ? "admin" : "user"}_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      time: userTime,
      isFromDoctor: false,
      senderId: patientUid,
      receiverId: targetDoctorId,
      senderRole: senderRole,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
    });

    _scrollToBottom();
    _focusNode.requestFocus();

    // Simpan pesan pasien/admin ke ChatService & Firestore dengan receiverId dokter
    await ChatService().sendMessage(
      chatId: _effectiveChatId,
      text: text,
      isFromDoctor: false,
      senderId: patientUid,
      receiverId: targetDoctorId,
      patientName: patientName,
      patientId: patientUid,
      doctorId: targetDoctorId,
      doctorName: widget.doctor.name,
      doctorSpecialist: widget.doctor.specialist,
      doctorImageUrl: widget.doctor.imageUrl,
      senderRole: senderRole,
    );
    // Pesan balasan dari dokter akan diterima secara real-time via Firestore stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Area pesan chat yang dapat discroll
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Badge tanggal "Hari ini"
                  const ChatDateBadge(),

                  // Daftar pesan chat dengan POV dinamis
                  ..._messages.map(
                    (msg) => ChatBubble(
                      key: ValueKey(msg.id),
                      message: msg,
                      doctorAvatarUrl: widget.doctor.imageUrl,
                      isDoctorPOV: widget.isDoctorPOV,
                      patientInitial: _patientInitial,
                    ),
                  ),

                  // Garis pemisah
                  const ChatDividerNotice(),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Kolom input pesan dan tombol kirim
            if (widget.isDoctorPOV && _consultationStatus == 'completed') ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Konsultasi telah selesai',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (!widget.isDoctorPOV && _consultationStatus == 'completed')
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFF92400E),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sesi konsultasi sebelumnya telah selesai. Kirim pesan untuk memulai konsultasi baru.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              MessageInput(
                controller: _textController,
                focusNode: _focusNode,
                isEnabled: true,
                onSend: _handleSendMessage,
                hintText: widget.isDoctorPOV
                    ? 'Ketik pesan balasan untuk ${widget.patientName ?? "pasien"}...'
                    : 'Tulis pesan...',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// AppBar yang menampilkan identitas lawan bicara (Pasien di POV Dokter, atau Dokter di POV Pasien)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      titleSpacing: 0,
      title: ListenableBuilder(
        listenable: Listenable.merge([
          DoctorPresenceService(),
          PatientPresenceService(),
        ]),
        builder: (context, _) {
          final isDoctorOnline =
              DoctorPresenceService().isOnline(widget.doctor.id);
          final isPatientOnline = PatientPresenceService().isOnline(
            _effectivePatientId,
            fallback: widget.isPatientOnline,
          );
          final isOnline =
              widget.isDoctorPOV ? isPatientOnline : isDoctorOnline;

          final isPartnerAdmin = widget.isDoctorPOV &&
              ((widget.patientName?.toLowerCase().contains('admin') == true) ||
                  (widget.patientId?.toLowerCase().contains('admin') == true));

          return Row(
            children: [
              // ── AVATAR LAWAN BICARA ─────────────────────────────────────
              if (widget.isDoctorPOV)
                // Avatar Pasien atau Admin
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPartnerAdmin
                            ? const Color(0xFF6B21A8)
                            : const Color(0xFFF59E0B),
                      ),
                      child: Center(
                        child: isPartnerAdmin
                            ? const Icon(
                                Icons.shield_rounded,
                                size: 20,
                                color: Colors.white,
                              )
                            : Text(
                                _patientInitial,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isPatientOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Avatar Dokter (foto profil dokter)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
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
                          widget.doctor.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.person_rounded,
                            size: 24,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDoctorOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(width: 12),

              // ── NAMA & STATUS LAWAN BICARA ──────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.isDoctorPOV
                                ? (widget.patientName ?? 'Pasien')
                                : widget.doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isPartnerAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFD8B4FE), width: 0.8),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6B21A8),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.isDoctorPOV
                                ? (isPartnerAdmin
                                    ? 'Administrator Osteo'
                                    : 'Pasien OsteoCare')
                                : widget.doctor.specialist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '·',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOnline
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (widget.isDoctorPOV && _consultationStatus == 'active')
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: InkWell(
                onTap: _showCompleteConsultationDialog,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: Color(0xFFB45309),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Selesaikan',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Dialog konfirmasi untuk menyelesaikan konsultasi aktif oleh dokter
  void _showCompleteConsultationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selesaikan Konsultasi?',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Konsultasi dengan ${widget.patientName ?? "pasien"} akan ditandai selesai dan dipindahkan ke kategori Completed. Pasien tetap dapat memulai konsultasi baru kapan saja.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7C948),
              foregroundColor: const Color(0xFF1E293B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ChatService().completeConsultation(_effectiveChatId);
              if (mounted) {
                setState(() {
                  _consultationStatus = 'completed';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Konsultasi telah berhasil diselesaikan.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFF1E293B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Ya, Selesaikan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
