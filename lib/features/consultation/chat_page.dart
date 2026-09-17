import 'package:flutter/material.dart';
import 'package:oste/features/consultation/chat_bubble.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/models/doctor_model.dart';

/// Halaman Chat Konsultasi Dokter Osteo dengan pengalaman percakapan interaktif
class ChatPage extends StatefulWidget {
  final Doctor doctor;
  final DateTime? consultationStartTime;

  const ChatPage({
    super.key,
    required this.doctor,
    this.consultationStartTime,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isDoctorTyping = false;
  bool _showSummaryCard = false;
  bool _isConsultationCompleted = false;

  int _currentTurn = 0;

  // Percakapan utama yang telah disiapkan secara terstruktur
  static const List<String> _doctorMainReplies = [
    'Dari data kamu, coba atur pola makan, perbanyak serat, dan kelola stress dengan baik.',
    'Hindari mengangkat beban berat secara mendadak. Usahakan olahraga ringan seperti jalan santai 30 menit setiap hari.',
    'Sama-sama, Aulia. Sesi konsultasi awal kita sudah selesai dengan baik. Semoga kesehatan tulang Anda selalu terjaga.',
  ];

  @override
  void initState() {
    super.initState();
    final start = widget.consultationStartTime ?? DateTime.now();
    final initialTime =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    // Pada saat ChatPage dibuka, hanya tampilkan 1 pesan sapaan awal dari dokter
    _messages.add(
      ChatMessage(
        id: 'msg_greeting',
        text: 'Selamat pagi, Aulia.\nAda yang bisa saya bantu hari ini?',
        time: initialTime,
        isFromDoctor: true,
      ),
    );
  }

  @override
  void dispose() {
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
    if (_isConsultationCompleted) return;

    final text = _textController.text.trim();
    if (text.isEmpty || _isDoctorTyping) return;

    final userTime = _formatCurrentTime();

    // 1. Tambahkan pesan pengguna langsung
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          time: userTime,
          isFromDoctor: false,
        ),
      );
      _isDoctorTyping = true;
    });

    _textController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();

    // 2. Dokter membalas otomatis setelah sekitar 800 ms
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    String replyText;
    if (_currentTurn < _doctorMainReplies.length) {
      replyText = _doctorMainReplies[_currentTurn];
    } else {
      replyText =
          'Jangan ragu untuk berkonsultasi kembali jika keluhan bertambah berat. Tetap jaga kesehatan tulang!';
    }

    final doctorTime = _formatCurrentTime();

    // 3. Tambahkan balasan dokter
    setState(() {
      _isDoctorTyping = false;
      _messages.add(
        ChatMessage(
          id: 'doctor_${DateTime.now().millisecondsSinceEpoch}',
          text: replyText,
          time: doctorTime,
          isFromDoctor: true,
        ),
      );
      _currentTurn++;
    });

    _scrollToBottom();

    // 4. Cek apakah sesi telah selesai untuk memunculkan SATU kartu ringkasan konsultasi & menutup chat
    if (_currentTurn >= _doctorMainReplies.length && !_isConsultationCompleted) {
      _focusNode.unfocus();

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      setState(() {
        _messages.add(
          const ChatMessage(
            id: 'closing_notice',
            text:
                'Sesi konsultasi Anda telah selesai dengan baik.\nSilakan tinjau ringkasan konsultasi Anda di bawah.',
            time: '',
            isFromDoctor: false,
            isSystemClosing: true,
          ),
        );
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      setState(() {
        _showSummaryCard = true;
        _isConsultationCompleted = true;
      });
      _scrollToBottom();
    } else {
      _focusNode.requestFocus();
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Foto dokter dengan indikator online
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

            // Nama dokter, spesialisasi, dan status online
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.doctor.name,
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
                          widget.doctor.specialist,
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
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

                  // Daftar pesan chat dengan animasi slide & fade
                  ..._messages.map(
                    (msg) => ChatBubble(
                      key: ValueKey(msg.id),
                      message: msg,
                      doctorAvatarUrl: widget.doctor.imageUrl,
                    ),
                  ),

                  // Indikator mengetik dokter yang tampil saat memproses balasan
                  if (_isDoctorTyping)
                    AnimatedOpacity(
                      opacity: _isDoctorTyping ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: TypingIndicator(
                        avatarUrl: widget.doctor.imageUrl,
                      ),
                    ),

                  // Garis pemisah
                  const ChatDividerNotice(),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Tampilkan SATU Kartu Ringkasan Konsultasi Reusable yang dapat diklik
            if (_showSummaryCard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationSummaryPage(
                          doctor: widget.doctor,
                          messages: _messages,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF7C948),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFF7C948).withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: Color(0xFFB45309),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lihat Ringkasan Konsultasi",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Ketuk untuk melihat diagnosis & rekomendasi",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFF59E0B),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Kolom input pesan dan tombol kirim (dinonaktifkan jika konsultasi telah selesai)
            MessageInput(
              controller: _textController,
              focusNode: _focusNode,
              isEnabled: !_isConsultationCompleted,
              onSend: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
