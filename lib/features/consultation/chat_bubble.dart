import 'package:flutter/material.dart';
import 'package:oste/models/chat_message.dart';

export 'package:oste/models/chat_message.dart';

/// Widget bubble chat reusable dengan animasi slide-in & fade-in lembut
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String doctorAvatarUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.doctorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget bubbleContent;

    if (message.isSystemClosing) {
      bubbleContent = _SystemClosingNotice(text: message.text);
    } else if (message.isFromDoctor) {
      bubbleContent = DoctorChatBubble(
        text: message.text,
        time: message.time,
        avatarUrl: doctorAvatarUrl,
      );
    } else {
      bubbleContent = UserChatBubble(
        text: message.text,
        time: message.time,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: bubbleContent,
    );
  }
}

/// Bubble pesan dari Dokter dengan avatar di sebelah kiri
class DoctorChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final String avatarUrl;

  const DoctorChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar kecil dokter
          Container(
            width: 34,
            height: 34,
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
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Bubble pesan dokter
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// Bubble pesan dari Pengguna/Pasien yang rata kanan
class UserChatBubble extends StatelessWidget {
  final String text;
  final String time;

  const UserChatBubble({
    super.key,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 44),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indikator animasi tiga titik saat dokter sedang mengetik
class TypingIndicator extends StatefulWidget {
  final String avatarUrl;

  const TypingIndicator({
    super.key,
    required this.avatarUrl,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar kecil dokter
          Container(
            width: 34,
            height: 34,
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
                widget.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Bubble animasi 3 titik
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0.0),
                const SizedBox(width: 4),
                _buildAnimatedDot(0.2),
                const SizedBox(width: 4),
                _buildAnimatedDot(0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value - delay) % 1.0;
        final bounce = (progress < 0.5)
            ? (progress * 2.0)
            : ((1.0 - progress) * 2.0);
        final opacity = 0.3 + (0.7 * bounce);
        final scale = 0.8 + (0.3 * bounce);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Kolom input pesan reusable dengan TextField dan tombol kirim kuning
class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final String hintText;
  final bool isEnabled;

  const MessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.hintText = 'Tulis pesan...',
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.1,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isEnabled,
                showCursor: isEnabled,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isEnabled
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF94A3B8),
                ),
                decoration: InputDecoration(
                  hintText: isEnabled
                      ? hintText
                      : 'Konsultasi telah selesai',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: isEnabled ? (_) => onSend() : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Opacity(
            opacity: isEnabled ? 1.0 : 0.75,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFFF7C948)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF7C948).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isEnabled ? onSend : null,
                  child: Icon(
                    Icons.send_rounded,
                    size: 19,
                    color: isEnabled
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notifikasi penutup sesi konsultasi
class _SystemClosingNotice extends StatelessWidget {
  final String text;

  const _SystemClosingNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFDE68A),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF78350F),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge tanggal hari ini di tengah halaman chat
class ChatDateBadge extends StatelessWidget {
  final String dateText;

  const ChatDateBadge({
    super.key,
    this.dateText = 'Hari ini',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          dateText,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

/// Pemisah teks "Scroll ke atas untuk melihat pesan sebelumnya"
class ChatDividerNotice extends StatelessWidget {
  const ChatDividerNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: Color(0xFFE2E8F0),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Scroll ke atas untuk melihat pesan sebelumnya',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8).withValues(alpha: 0.9),
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: Color(0xFFE2E8F0),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
