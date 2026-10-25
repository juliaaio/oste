import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/chat_bubble.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/chat_service.dart';
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
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _messageSubscription;

  String get _effectiveChatId {
    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      return widget.chatId!;
    }
    final patientUid = widget.patientId ??
        (widget.isDoctorPOV
            ? 'demo_patient'
            : (UserService().currentUser?.uid ?? 'local_user'));
    return ChatService.formatChatId(
      doctorId: widget.doctor.id,
      patientId: patientUid,
    );
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
    _messageSubscription?.cancel();
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

    // ── KONDISI 2: PENGIRIMAN PESAN DALAM POV PASIEN ────────────────────────
    final patientUid = UserService().currentUser?.uid ?? 'patient_current';
    final patientName = UserService().currentUser?.name ?? 'Pasien';
    final targetDoctorId = widget.doctor.id;

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      time: userTime,
      isFromDoctor: false,
      senderId: patientUid,
      receiverId: targetDoctorId,
      senderRole: 'patient',
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
    });

    _scrollToBottom();
    _focusNode.requestFocus();

    // Simpan pesan pasien ke ChatService & Firestore dengan receiverId dokter
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
      title: Row(
        children: [
          // ── AVATAR LAWAN BICARA ─────────────────────────────────────
          if (widget.isDoctorPOV)
            // Avatar Pasien (lingkaran amber dengan inisial)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF59E0B),
                  ),
                  child: Center(
                    child: Text(
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
                      color: widget.isPatientOnline
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        size: 24,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                if (widget.doctor.isOnline)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
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
                Text(
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.isDoctorPOV
                            ? 'Pasien OsteoCare'
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
                      widget.isDoctorPOV
                          ? (widget.isPatientOnline ? 'Online' : 'Offline')
                          : 'Online',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: (widget.isDoctorPOV
                                ? widget.isPatientOnline
                                : widget.doctor.isOnline)
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
      ),
    );
  }
}
