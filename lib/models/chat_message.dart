/// Model representasi data pesan dalam percakapan chat konsultasi
class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isFromDoctor;
  final bool isSystemClosing;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isFromDoctor,
    this.isSystemClosing = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    String? time,
    bool? isFromDoctor,
    bool? isSystemClosing,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isFromDoctor: isFromDoctor ?? this.isFromDoctor,
      isSystemClosing: isSystemClosing ?? this.isSystemClosing,
    );
  }
}
