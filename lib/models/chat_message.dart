import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data pesan dalam percakapan chat konsultasi
class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isFromDoctor;
  final bool isSystemClosing;
  final String senderId;
  final String receiverId;
  final String senderRole;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isFromDoctor,
    this.isSystemClosing = false,
    this.senderId = '',
    this.receiverId = '',
    String? senderRole,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  }) : senderRole = senderRole ?? (isFromDoctor ? 'doctor' : 'patient');

  /// Apakah pesan ini dikirim oleh Admin
  bool get isFromAdmin => senderRole.toLowerCase() == 'admin';

  ChatMessage copyWith({
    String? id,
    String? text,
    String? time,
    bool? isFromDoctor,
    bool? isSystemClosing,
    String? senderId,
    String? receiverId,
    String? senderRole,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isFromDoctor: isFromDoctor ?? this.isFromDoctor,
      isSystemClosing: isSystemClosing ?? this.isSystemClosing,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderRole: senderRole ?? this.senderRole,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Membuat ChatMessage dari Map data Firestore
  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    DateTime? dt;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      dt = rawCreated.toDate();
    } else if (rawCreated is String) {
      dt = DateTime.tryParse(rawCreated);
    } else if (rawCreated is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(rawCreated);
    }

    DateTime? readDt;
    final rawReadAt = data['readAt'];
    if (rawReadAt is Timestamp) {
      readDt = rawReadAt.toDate();
    } else if (rawReadAt is String) {
      readDt = DateTime.tryParse(rawReadAt);
    } else if (rawReadAt is int) {
      readDt = DateTime.fromMillisecondsSinceEpoch(rawReadAt);
    }

    final isFromDoc = data['isFromDoctor'] as bool? ??
        (data['senderRole']?.toString().toLowerCase() == 'doctor');

    return ChatMessage(
      id: id,
      text: data['text']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      isFromDoctor: isFromDoc,
      isSystemClosing: data['isSystemClosing'] as bool? ?? false,
      senderId: data['senderId']?.toString() ?? '',
      receiverId: data['receiverId']?.toString() ?? '',
      senderRole: data['senderRole']?.toString() ??
          (isFromDoc ? 'doctor' : 'patient'),
      isRead: data['isRead'] as bool? ?? false,
      readAt: readDt,
      createdAt: dt,
    );
  }

  /// Membuat ChatMessage dari DocumentSnapshot Firestore
  factory ChatMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ChatMessage.fromMap(doc.id, doc.data() ?? {});
  }

  /// Konversi ke Map untuk disimpan di Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'time': time,
      'isFromDoctor': isFromDoctor,
      'isSystemClosing': isSystemClosing,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderRole': senderRole,
      'isRead': isRead,
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
