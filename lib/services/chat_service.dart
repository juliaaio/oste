import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:oste/models/chat_message.dart';
import 'package:oste/services/user_service.dart';

/// Model metadata percakapan chat untuk daftar percakapan pasien-dokter
class ConversationSummary {
  final String chatId;
  final String patientId;
  final String patientName;
  final String patientInitial;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialist;
  final String doctorImageUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unreadCount; // Alias untuk dokter unread count (backward compatibility)
  final int unreadCountDoctor;
  final int unreadCountPatient;
  final String lastSenderRole;
  final String lastSenderId;
  final DateTime? updatedAt;

  const ConversationSummary({
    required this.chatId,
    required this.patientId,
    required this.patientName,
    required this.patientInitial,
    this.doctorId = '',
    this.doctorName = '',
    this.doctorSpecialist = '',
    this.doctorImageUrl = '',
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    this.unreadCount = 0,
    int? unreadCountDoctor,
    this.unreadCountPatient = 0,
    this.lastSenderRole = '',
    this.lastSenderId = '',
    this.updatedAt,
  }) : unreadCountDoctor = unreadCountDoctor ?? unreadCount;

  static const ConversationSummary empty = ConversationSummary(
    chatId: '',
    patientId: '',
    patientName: '',
    patientInitial: '',
    lastMessage: '',
    time: '',
    isOnline: false,
    unreadCount: 0,
    unreadCountDoctor: 0,
    unreadCountPatient: 0,
  );

  ConversationSummary copyWith({
    String? chatId,
    String? patientId,
    String? patientName,
    String? patientInitial,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialist,
    String? doctorImageUrl,
    String? lastMessage,
    String? time,
    bool? isOnline,
    int? unreadCount,
    int? unreadCountDoctor,
    int? unreadCountPatient,
    String? lastSenderRole,
    String? lastSenderId,
    DateTime? updatedAt,
  }) {
    final newUnreadDoctor = unreadCountDoctor ?? unreadCount ?? this.unreadCountDoctor;
    return ConversationSummary(
      chatId: chatId ?? this.chatId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientInitial: patientInitial ?? this.patientInitial,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialist: doctorSpecialist ?? this.doctorSpecialist,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: newUnreadDoctor,
      unreadCountDoctor: newUnreadDoctor,
      unreadCountPatient: unreadCountPatient ?? this.unreadCountPatient,
      lastSenderRole: lastSenderRole ?? this.lastSenderRole,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Buat ConversationSummary dari dokumen Firestore
  factory ConversationSummary.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final pName = data['patientName']?.toString() ?? 'Pasien';
    final docId = data['doctorId']?.toString() ?? '';
    final docName = data['doctorName']?.toString() ?? '';
    final rawTime = data['updatedAt'];
    String timeStr = data['lastMessageTime']?.toString() ?? '';
    if (timeStr.isEmpty && rawTime is Timestamp) {
      final dt = rawTime.toDate().toLocal();
      timeStr =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    DateTime? updatedAt;
    if (rawTime is Timestamp) updatedAt = rawTime.toDate();

    final docUnread = (data['unreadCount'] as num?)?.toInt() ??
        (data['unreadCountDoctor'] as num?)?.toInt() ??
        0;
    final patientUnread = (data['unreadCountPatient'] as num?)?.toInt() ?? 0;

    return ConversationSummary(
      chatId: doc.id,
      patientId: data['patientId']?.toString() ?? '',
      patientName: pName,
      patientInitial: pName.isNotEmpty ? pName[0].toUpperCase() : 'P',
      doctorId: docId,
      doctorName: docName,
      doctorSpecialist: data['doctorSpecialist']?.toString() ?? '',
      doctorImageUrl: data['doctorImageUrl']?.toString() ?? '',
      lastMessage: data['lastMessage']?.toString() ?? '',
      time: timeStr,
      isOnline: data['isPatientOnline'] as bool? ?? false,
      unreadCount: docUnread,
      unreadCountDoctor: docUnread,
      unreadCountPatient: patientUnread,
      lastSenderRole: data['lastSenderRole']?.toString() ?? '',
      lastSenderId: data['lastSenderId']?.toString() ?? '',
      updatedAt: updatedAt,
    );
  }
}

/// Layanan singleton untuk mengelola penyimpanan chat Firestore & lokal
class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  ChatService._internal() {
    _seedInitialConversations();
  }

  /// Format ID percakapan konsisten dan deterministik dari identitas dokter dan pasien.
  /// Mencegah pembuatan percakapan baru ganda saat halaman dibuka berulang kali.
  static String formatChatId({
    required String doctorId,
    required String patientId,
  }) {
    final d = doctorId.trim();
    final p = patientId.trim();
    return 'chat_${d}_$p';
  }

  // Cache lokal pesan per chatId
  final Map<String, List<ChatMessage>> _localMessages = {};

  // Cache lokal daftar percakapan dokter (gabungan: seed + Firestore)
  final List<ConversationSummary> _conversations = [];

  // Cache lokal daftar percakapan pasien (dari Firestore)
  final List<ConversationSummary> _patientConversations = [];

  // Subscription Firestore
  StreamSubscription<QuerySnapshot>? _doctorConversationsSubscription;
  StreamSubscription<QuerySnapshot>? _patientConversationsSubscription;

  List<ConversationSummary> get conversations =>
      List.unmodifiable(_conversations);

  List<ConversationSummary> get patientConversations =>
      List.unmodifiable(_patientConversations);

  // ── SISI DOKTER ────────────────────────────────────────────────────────────

  /// Mulai memantau daftar percakapan milik dokter dari Firestore secara real-time.
  void startListeningDoctorConversations(String doctorId) {
    _doctorConversationsSubscription?.cancel();
    try {
      _doctorConversationsSubscription = FirebaseFirestore.instance
          .collection('chats')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final summary = ConversationSummary.fromFirestore(doc);
          final idx =
              _conversations.indexWhere((c) => c.chatId == summary.chatId);
          if (idx >= 0) {
            _conversations[idx] = summary;
          } else {
            _conversations.insert(0, summary);
          }
        }
        _conversations.sort((a, b) {
          final aTime = a.updatedAt ?? DateTime(0);
          final bTime = b.updatedAt ?? DateTime(0);
          return bTime.compareTo(aTime);
        });
        notifyListeners();
      }, onError: (e) {
        debugPrint('[ChatService] Error memantau percakapan dokter: $e');
      });
    } catch (e) {
      debugPrint('[ChatService] Gagal memulai listener percakapan dokter: $e');
    }
  }

  /// Hentikan pemantauan daftar percakapan dokter
  void stopListeningDoctorConversations() {
    _doctorConversationsSubscription?.cancel();
    _doctorConversationsSubscription = null;
  }

  /// Total pesan belum dibaca di semua percakapan dokter (untuk badge dokter)
  int get totalUnreadCount =>
      _conversations.fold(0, (total, c) => total + c.unreadCount);

  /// Tandai percakapan sebagai sudah dibaca oleh dokter.
  ///
  /// Mereset unreadCount dokter di cache lokal dan Firestore,
  /// serta menandai pesan yang belum dibaca dari pasien sebagai dibaca (isRead = true).
  Future<void> markConversationAsRead(String chatId) async {
    final idx = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idx >= 0 && _conversations[idx].unreadCount > 0) {
      _conversations[idx] = _conversations[idx].copyWith(
        unreadCount: 0,
        unreadCountDoctor: 0,
      );
      notifyListeners();
    }

    final localMsgs = _localMessages[chatId];
    if (localMsgs != null) {
      bool changed = false;
      for (int i = 0; i < localMsgs.length; i++) {
        final m = localMsgs[i];
        if (!m.isFromDoctor && !m.isRead) {
          localMsgs[i] = m.copyWith(isRead: true, readAt: DateTime.now());
          changed = true;
        }
      }
      if (changed) notifyListeners();
    }

    try {
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      await chatDocRef.set({
        'unreadCount': 0,
        'unreadCountDoctor': 0,
      }, SetOptions(merge: true));

      final unreadQuery = await chatDocRef
          .collection('messages')
          .where('isFromDoctor', isEqualTo: false)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadQuery.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in unreadQuery.docs) {
          batch.update(doc.reference, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('[ChatService] Gagal reset unreadCount di Firestore: $e');
    }
  }

  // ── SISI PASIEN ────────────────────────────────────────────────────────────

  /// Mulai memantau percakapan milik pasien secara real-time dari Firestore.
  void startListeningPatientConversations(String patientId) {
    if (patientId.isEmpty) return;
    _patientConversationsSubscription?.cancel();
    try {
      _patientConversationsSubscription = FirebaseFirestore.instance
          .collection('chats')
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .listen((snapshot) {
        _patientConversations.clear();
        for (final doc in snapshot.docs) {
          final summary = ConversationSummary.fromFirestore(doc);
          _patientConversations.add(summary);
        }
        _patientConversations.sort((a, b) {
          final aTime = a.updatedAt ?? DateTime(0);
          final bTime = b.updatedAt ?? DateTime(0);
          return bTime.compareTo(aTime);
        });
        notifyListeners();
      }, onError: (e) {
        debugPrint('[ChatService] Error memantau percakapan pasien: $e');
      });
    } catch (e) {
      debugPrint('[ChatService] Gagal memulai listener percakapan pasien: $e');
    }
  }

  /// Hentikan pemantauan daftar percakapan pasien
  void stopListeningPatientConversations() {
    _patientConversationsSubscription?.cancel();
    _patientConversationsSubscription = null;
  }

  /// Reset state cache untuk keperluan testing
  @visibleForTesting
  void clearForTesting() {
    _localMessages.clear();
    _patientConversations.clear();
    _conversations.clear();
    _seedInitialConversations();
  }

  /// Total balasan dokter yang belum dibaca oleh pasien (untuk badge dashboard & menu)
  int get totalPatientUnreadCount {
    final currentPatientUid = UserService().currentUser?.uid ?? '';
    final list = currentPatientUid.isNotEmpty
        ? _patientConversations.where((c) => c.patientId == currentPatientUid || c.chatId.endsWith('_$currentPatientUid'))
        : _patientConversations;
    return list.fold(0, (total, c) => total + c.unreadCountPatient);
  }

  /// Jumlah balasan belum dibaca dari dokter spesifik untuk pasien ini
  int getPatientUnreadCountForDoctor(String doctorId, {String? patientId}) {
    if (doctorId.isEmpty) return 0;
    final currentPatient = (patientId != null && patientId.isNotEmpty)
        ? patientId
        : (UserService().currentUser?.uid ?? '');

    final matches = _patientConversations.where((c) {
      final matchesDoctor =
          c.doctorId == doctorId || c.chatId.startsWith('chat_${doctorId}_');
      if (!matchesDoctor) return false;
      if (currentPatient.isNotEmpty) {
        return c.patientId == currentPatient ||
            c.chatId.endsWith('_$currentPatient');
      }
      return true;
    });
    return matches.fold(0, (total, c) => total + c.unreadCountPatient);
  }

  /// Tandai percakapan sebagai sudah dibaca oleh pasien.
  ///
  /// Mereset unreadCountPatient di cache lokal dan Firestore,
  /// serta menandai pesan yang memang ditujukan kepada pasien (isFromDoctor == true)
  /// sebagai sudah dibaca (isRead = true).
  Future<void> markConversationAsReadByPatient(
      String chatId, String patientId) async {
    // 1. Reset di cache percakapan pasien
    final idx = _patientConversations.indexWhere((c) => c.chatId == chatId);
    if (idx >= 0 && _patientConversations[idx].unreadCountPatient > 0) {
      _patientConversations[idx] =
          _patientConversations[idx].copyWith(unreadCountPatient: 0);
      notifyListeners();
    }

    // 2. Tandai pesan lokal sebagai dibaca
    final localMsgs = _localMessages[chatId];
    if (localMsgs != null) {
      bool changed = false;
      for (int i = 0; i < localMsgs.length; i++) {
        final m = localMsgs[i];
        if (m.isFromDoctor && !m.isRead) {
          localMsgs[i] = m.copyWith(isRead: true, readAt: DateTime.now());
          changed = true;
        }
      }
      if (changed) notifyListeners();
    }

    // 3. Update di Firestore
    try {
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      // Reset unreadCountPatient di ringkasan dokumen chat
      await chatDocRef.set({
        'unreadCountPatient': 0,
      }, SetOptions(merge: true));

      // Update status isRead pada pesan dari dokter
      final unreadQuery = await chatDocRef
          .collection('messages')
          .where('isFromDoctor', isEqualTo: true)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadQuery.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in unreadQuery.docs) {
          batch.update(doc.reference, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('[ChatService] Gagal reset unreadCountPatient di Firestore: $e');
    }
  }

  // ── PENGIRIMAN & STREAM PESAN ──────────────────────────────────────────────

  /// Mengambil daftar pesan saat ini untuk chatId tertentu dari cache lokal
  List<ChatMessage> getMessages(String chatId) {
    return List.unmodifiable(_localMessages[chatId] ?? []);
  }

  /// Stream pesan real-time dari Cloud Firestore dengan fallback cache lokal
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    try {
      return FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final firestoreMessages = snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();

          _localMessages[chatId] = firestoreMessages;
          return firestoreMessages;
        }

        // Jika dokumen di Firestore belum ada pesan baru, gunakan cache lokal
        return _localMessages[chatId] ?? [];
      }).handleError((error) {
        debugPrint(
            '[ChatService] Firestore stream error (offline fallback): $error');
        return _localMessages[chatId] ?? [];
      });
    } catch (_) {
      // Fallback untuk testing atau jika Firebase offline
      return Stream.value(_localMessages[chatId] ?? []);
    }
  }

  /// Mengirim pesan baru ke percakapan (baik oleh dokter maupun pasien).
  ///
  /// Menyimpan pesan dengan senderId dan receiverId yang tepat,
  /// serta memperbarui ringkasan percakapan dan counter unreadCount untuk penerima.
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required bool isFromDoctor,
    String senderId = '',
    String receiverId = '',
    String senderName = '',
    String patientName = '',
    String patientId = '',
    String doctorId = '',
    String doctorName = '',
    String doctorSpecialist = '',
    String doctorImageUrl = '',
  }) async {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';
    final messageId = 'msg_${now.millisecondsSinceEpoch}';

    final effectivePatientId = patientId.isNotEmpty
        ? patientId
        : (!isFromDoctor
            ? senderId
            : (receiverId.isNotEmpty ? receiverId : ''));

    final effectiveDoctorId = doctorId.isNotEmpty
        ? doctorId
        : (isFromDoctor
            ? senderId
            : (receiverId.isNotEmpty ? receiverId : ''));

    final message = ChatMessage(
      id: messageId,
      text: text,
      time: timeStr,
      isFromDoctor: isFromDoctor,
      senderId: senderId,
      receiverId: receiverId,
      senderRole: isFromDoctor ? 'doctor' : 'patient',
      isRead: false,
      createdAt: now,
    );

    // 1. Simpan ke cache lokal
    _localMessages.putIfAbsent(chatId, () => []);
    _localMessages[chatId]!.add(message);

    // 2. Perbarui ringkasan percakapan dokter
    final idxDoc = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idxDoc >= 0) {
      final existing = _conversations[idxDoc];
      _conversations[idxDoc] = existing.copyWith(
        lastMessage: text,
        time: timeStr,
        updatedAt: now,
        unreadCount: isFromDoctor ? 0 : existing.unreadCount + 1,
        unreadCountDoctor: isFromDoctor ? 0 : existing.unreadCount + 1,
        unreadCountPatient:
            isFromDoctor ? existing.unreadCountPatient + 1 : 0,
        lastSenderRole: isFromDoctor ? 'doctor' : 'patient',
        lastSenderId: senderId,
      );
    } else {
      final pName = patientName.isNotEmpty ? patientName : 'Pasien';
      _conversations.insert(
        0,
        ConversationSummary(
          chatId: chatId,
          patientId: effectivePatientId,
          patientName: pName,
          patientInitial: pName.isNotEmpty ? pName[0].toUpperCase() : 'P',
          doctorId: effectiveDoctorId,
          doctorName: doctorName,
          doctorSpecialist: doctorSpecialist,
          doctorImageUrl: doctorImageUrl,
          lastMessage: text,
          time: timeStr,
          isOnline: true,
          unreadCount: isFromDoctor ? 0 : 1,
          unreadCountDoctor: isFromDoctor ? 0 : 1,
          unreadCountPatient: isFromDoctor ? 1 : 0,
          lastSenderRole: isFromDoctor ? 'doctor' : 'patient',
          lastSenderId: senderId,
          updatedAt: now,
        ),
      );
    }

    // 3. Perbarui ringkasan percakapan pasien
    final idxPat = _patientConversations.indexWhere((c) => c.chatId == chatId);
    if (idxPat >= 0) {
      final existing = _patientConversations[idxPat];
      _patientConversations[idxPat] = existing.copyWith(
        lastMessage: text,
        time: timeStr,
        updatedAt: now,
        unreadCountPatient:
            isFromDoctor ? existing.unreadCountPatient + 1 : 0,
        unreadCountDoctor: isFromDoctor ? 0 : existing.unreadCountDoctor + 1,
        lastSenderRole: isFromDoctor ? 'doctor' : 'patient',
        lastSenderId: senderId,
      );
    } else {
      final pName = patientName.isNotEmpty ? patientName : 'Pasien';
      _patientConversations.insert(
        0,
        ConversationSummary(
          chatId: chatId,
          patientId: effectivePatientId,
          patientName: pName,
          patientInitial: pName.isNotEmpty ? pName[0].toUpperCase() : 'P',
          doctorId: effectiveDoctorId,
          doctorName: doctorName,
          doctorSpecialist: doctorSpecialist,
          doctorImageUrl: doctorImageUrl,
          lastMessage: text,
          time: timeStr,
          isOnline: true,
          unreadCount: isFromDoctor ? 0 : 1,
          unreadCountDoctor: isFromDoctor ? 0 : 1,
          unreadCountPatient: isFromDoctor ? 1 : 0,
          lastSenderRole: isFromDoctor ? 'doctor' : 'patient',
          lastSenderId: senderId,
          updatedAt: now,
        ),
      );
    }

    notifyListeners();

    // 4. Simpan ke Cloud Firestore
    try {
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      // Simpan dokumen pesan di subkoleksi 'messages'
      await chatDocRef.collection('messages').doc(messageId).set({
        ...message.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update metadata percakapan di dokumen induk 'chats/{chatId}'
      final Map<String, dynamic> chatMeta = {
        'chatId': chatId,
        'lastMessage': text,
        'lastMessageTime': timeStr,
        'lastSenderRole': isFromDoctor ? 'doctor' : 'patient',
        'lastSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        // Jika dokter yang kirim: unreadCount dokter = 0, unreadCountPatient bertambah 1
        // Jika pasien yang kirim: unreadCount dokter bertambah 1, unreadCountPatient = 0
        'unreadCount': isFromDoctor ? 0 : FieldValue.increment(1),
        'unreadCountDoctor': isFromDoctor ? 0 : FieldValue.increment(1),
        'unreadCountPatient': isFromDoctor ? FieldValue.increment(1) : 0,
      };

      if (effectiveDoctorId.isNotEmpty) {
        chatMeta['doctorId'] = effectiveDoctorId;
      }
      if (doctorName.isNotEmpty) chatMeta['doctorName'] = doctorName;
      if (doctorSpecialist.isNotEmpty) {
        chatMeta['doctorSpecialist'] = doctorSpecialist;
      }
      if (doctorImageUrl.isNotEmpty) {
        chatMeta['doctorImageUrl'] = doctorImageUrl;
      }
      if (effectivePatientId.isNotEmpty) {
        chatMeta['patientId'] = effectivePatientId;
      }
      if (patientName.isNotEmpty) chatMeta['patientName'] = patientName;

      await chatDocRef.set(chatMeta, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[ChatService] Gagal sync ke Firestore (berjalan offline): $e');
    }
  }

  /// Inisialisasi percakapan bawaan sesuai daftar di Figma (untuk preview dokter)
  void _seedInitialConversations() {
    final seeds = [
      const ConversationSummary(
        chatId: 'chat_siti',
        patientId: 'patient_siti',
        patientName: 'Siti Rahmawati',
        patientInitial: 'S',
        doctorId: 'doc_1',
        lastMessage:
            'Dok, saya masih merasakan nyeri di bagian punggung bawah setelah latihan...',
        time: '08:20',
        isOnline: true,
        unreadCount: 2,
        unreadCountDoctor: 2,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_ahmad',
        patientId: 'patient_ahmad',
        patientName: 'Ahmad Maulana',
        patientInitial: 'A',
        doctorId: 'doc_1',
        lastMessage:
            'Apakah boleh mengonsumsi kalsium bersamaan dengan vitamin D, Dok?',
        time: '10:15',
        isOnline: false,
        unreadCount: 1,
        unreadCountDoctor: 1,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_dewi',
        patientId: 'patient_dewi',
        patientName: 'Dewi Lestari',
        patientInitial: 'D',
        doctorId: 'doc_1',
        lastMessage: 'Terima kasih atas penjelasannya, Dok 🙏',
        time: '09:40',
        isOnline: true,
        unreadCount: 0,
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_budi',
        patientId: 'patient_budi',
        patientName: 'Budi Santoso',
        patientInitial: 'B',
        doctorId: 'doc_1',
        lastMessage:
            'Dok, hasil rontgen saya sudah keluar. Berikut saya lampirkan hasilnya.',
        time: 'Kemarin',
        isOnline: false,
        unreadCount: 0,
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_maya',
        patientId: 'patient_maya',
        patientName: 'Maya Sari',
        patientInitial: 'M',
        doctorId: 'doc_1',
        lastMessage: 'Baik dok, terima kasih banyak 🙏',
        time: 'Kemarin',
        isOnline: true,
        unreadCount: 0,
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_tono',
        patientId: 'patient_tono',
        patientName: 'Tono Wirawan',
        patientInitial: 'T',
        doctorId: 'doc_1',
        lastMessage: 'Apakah latihan ini masih boleh dilakukan setiap hari?',
        time: '20 Okt',
        isOnline: false,
        unreadCount: 0,
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_rina',
        patientId: 'patient_rina',
        patientName: 'Rina Amelia',
        patientInitial: 'R',
        doctorId: 'doc_1',
        lastMessage:
            'Dok, saya ingin konsultasi mengenai pola makan untuk kesehatan tulang.',
        time: '18 Okt',
        isOnline: false,
        unreadCount: 0,
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
      ),
      const ConversationSummary(
        chatId: 'chat_fajar',
        patientId: 'patient_fajar',
        patientName: 'Fajar Pratama',
        patientInitial: 'F',
        doctorId: 'doc_1',
        lastMessage: 'Terima kasih, Dok.',
        time: '15 Okt',
        isOnline: false,
        unreadCount: 0,
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
      ),
    ];

    _conversations.addAll(seeds);

    for (final s in seeds) {
      _localMessages[s.chatId] = [
        ChatMessage(
          id: 'initial_${s.chatId}',
          text: s.lastMessage,
          time: s.time,
          isFromDoctor: false,
          senderId: s.patientId,
          receiverId: s.doctorId,
          senderRole: 'patient',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
    }
  }
}
