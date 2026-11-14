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
  final bool isAdminChat;
  final String consultationStatus; // 'unread' | 'active' | 'completed'

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
    this.isAdminChat = false,
    this.consultationStatus = 'unread',
  }) : unreadCountDoctor = unreadCountDoctor ?? unreadCount;

  /// Helper untuk mengecek apakah percakapan berasal dari Admin
  bool get isFromAdmin =>
      isAdminChat ||
      lastSenderRole.toLowerCase() == 'admin' ||
      patientName.toLowerCase().contains('admin') ||
      patientId.toLowerCase().startsWith('admin');

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
    isAdminChat: false,
    consultationStatus: 'unread',
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
    bool? isAdminChat,
    String? consultationStatus,
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
      isAdminChat: isAdminChat ?? this.isAdminChat,
      consultationStatus: consultationStatus ?? this.consultationStatus,
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

    final isAdminChat = (data['isAdminChat'] as bool? ?? false) ||
        (data['lastSenderRole']?.toString().toLowerCase() == 'admin') ||
        (pName.toLowerCase().contains('admin')) ||
        (data['patientId']?.toString().toLowerCase().contains('admin') ?? false);

    final String consultationStatus = data['consultationStatus']?.toString() ?? 'unread';

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
      isAdminChat: isAdminChat,
      consultationStatus: consultationStatus,
    );
  }
}

/// Layanan singleton untuk mengelola penyimpanan chat Firestore & lokal
class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  ChatService._internal() {
    purgeAllDummyChats();
  }

  /// Kumpulan ID percakapan dummy yang dihapus secara permanen
  static const Set<String> dummyChatIds = {
    'chat_siti',
    'chat_ahmad',
    'chat_dewi',
    'chat_budi',
    'chat_maya',
    'chat_tono',
    'chat_rina',
    'chat_fajar',
  };

  /// Kumpulan nama pasien dummy yang dihapus secara permanen
  static const Set<String> dummyPatientNames = {
    'siti rahmawati',
    'ahmad maulana',
    'dewi lestari',
    'budi santoso',
    'maya sari',
    'tono wirawan',
    'rina amelia',
    'fajar pratama',
  };

  /// Fungsi verifikasi apakah sebuah percakapan merupakan akun dummy
  static bool isDummyConversation(String chatId, String patientName) {
    final id = chatId.trim().toLowerCase();
    final name = patientName.trim().toLowerCase();
    if (dummyChatIds.contains(id)) return true;
    for (final dummyId in dummyChatIds) {
      if (id.contains(dummyId)) return true;
    }
    for (final dummyName in dummyPatientNames) {
      if (name.contains(dummyName)) return true;
    }
    return false;
  }

  /// Menghapus seluruh percakapan dan pesan dummy dari Cloud Firestore dan memori lokal
  Future<void> purgeAllDummyChats() async {
    // 1. Hapus percakapan berdasarkan ID dokumen dummy dari Firestore
    for (final id in dummyChatIds) {
      try {
        final docRef =
            FirebaseFirestore.instance.collection('chats').doc(id);
        final msgs = await docRef.collection('messages').get();
        for (final m in msgs.docs) {
          await m.reference.delete();
        }
        await docRef.delete();
      } catch (_) {}
    }

    // 2. Scan koleksi chats Firestore untuk menghapus dokumen dengan nama pasien dummy
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('chats').get();
      for (final doc in snapshot.docs) {
        final pName = doc.data()['patientName']?.toString() ?? '';
        if (isDummyConversation(doc.id, pName)) {
          final msgs = await doc.reference.collection('messages').get();
          for (final m in msgs.docs) {
            await m.reference.delete();
          }
          await doc.reference.delete();
        }
      }
    } catch (_) {}

    // 3. Bersihkan memori lokal
    _conversations.removeWhere(
        (c) => isDummyConversation(c.chatId, c.patientName));
    _patientConversations.removeWhere(
        (c) => isDummyConversation(c.chatId, c.patientName));
    _localMessages.removeWhere(
        (key, _) => isDummyConversation(key, ''));
    notifyListeners();
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
  final List<StreamSubscription<QuerySnapshot>> _doctorConversationsSubscriptions = [];
  StreamSubscription<QuerySnapshot>? _patientConversationsSubscription;

  List<ConversationSummary> get conversations =>
      List.unmodifiable(_conversations);

  List<ConversationSummary> get patientConversations =>
      List.unmodifiable(_patientConversations);

  // ── SISI DOKTER ────────────────────────────────────────────────────────────

  /// Mulai memantau daftar percakapan milik dokter dari Firestore secara real-time.
  /// Mendukung doctorId autentikasi, linkedDoctorId (misal doc_1), dan ID dokter tambahan.
  void startListeningDoctorConversations(
    String doctorId, {
    List<String>? additionalDoctorIds,
    String? linkedDoctorId,
  }) {
    stopListeningDoctorConversations();

    final Set<String> targetIds = {};
    if (doctorId.trim().isNotEmpty) targetIds.add(doctorId.trim());
    if (linkedDoctorId != null && linkedDoctorId.trim().isNotEmpty) {
      targetIds.add(linkedDoctorId.trim());
    }
    if (additionalDoctorIds != null) {
      for (final id in additionalDoctorIds) {
        if (id.trim().isNotEmpty) targetIds.add(id.trim());
      }
    }

    if (targetIds.isEmpty) return;

    for (final id in targetIds) {
      try {
        final sub = FirebaseFirestore.instance
            .collection('chats')
            .where('doctorId', isEqualTo: id)
            .snapshots(includeMetadataChanges: true)
            .listen((snapshot) {
          for (final doc in snapshot.docs) {
            final summary = ConversationSummary.fromFirestore(doc);
            // Abaikan dan hapus percakapan dummy secara permanen dari Cloud Firestore
            if (isDummyConversation(summary.chatId, summary.patientName)) {
              doc.reference.delete().catchError((_) {});
              continue;
            }
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
          debugPrint('[ChatService] Error memantau percakapan dokter ($id): $e');
        });
        _doctorConversationsSubscriptions.add(sub);
      } catch (e) {
        debugPrint('[ChatService] Gagal memulai listener percakapan dokter ($id): $e');
      }
    }
  }

  /// Hentikan pemantauan daftar percakapan dokter
  void stopListeningDoctorConversations() {
    for (final sub in _doctorConversationsSubscriptions) {
      sub.cancel();
    }
    _doctorConversationsSubscriptions.clear();
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
    String targetStatus = 'active';
    if (idx >= 0) {
      final currentStatus = _conversations[idx].consultationStatus;
      // Jika statusnya sudah 'completed', jangan ubah menjadi 'active'
      // saat dokter hanya membuka untuk melihat riwayat percakapan
      if (currentStatus == 'completed') {
        targetStatus = 'completed';
      } else {
        targetStatus = 'active';
      }

      _conversations[idx] = _conversations[idx].copyWith(
        unreadCount: 0,
        unreadCountDoctor: 0,
        consultationStatus: targetStatus,
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

      final Map<String, dynamic> updateData = {
        'unreadCount': 0,
        'unreadCountDoctor': 0,
      };
      if (targetStatus == 'active') {
        updateData['consultationStatus'] = 'active';
      }

      await chatDocRef.set(updateData, SetOptions(merge: true));

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
          .snapshots(includeMetadataChanges: true)
          .listen((snapshot) {
        _patientConversations.clear();
        for (final doc in snapshot.docs) {
          final summary = ConversationSummary.fromFirestore(doc);
          if (isDummyConversation(summary.chatId, summary.patientName)) {
            doc.reference.delete().catchError((_) {});
            continue;
          }
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
          .snapshots(includeMetadataChanges: true)
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
    String? senderRole,
  }) async {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';
    final messageId = 'msg_${now.millisecondsSinceEpoch}';

    final currentUser = UserService().currentUser;
    final bool isAdminSender =
        currentUser?.isAdmin == true || senderRole == 'admin';
    final effectiveSenderRole = senderRole ??
        (isAdminSender ? 'admin' : (isFromDoctor ? 'doctor' : 'patient'));

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

    final effectivePatientName = patientName.isNotEmpty
        ? patientName
        : (isAdminSender ? 'Admin Osteo' : 'Pasien');

    final message = ChatMessage(
      id: messageId,
      text: text,
      time: timeStr,
      isFromDoctor: isFromDoctor,
      senderId: senderId,
      receiverId: receiverId,
      senderRole: effectiveSenderRole,
      isRead: false,
      createdAt: now,
    );

    // 1. Simpan ke cache lokal
    _localMessages.putIfAbsent(chatId, () => []);
    _localMessages[chatId]!.add(message);

    // 2. Perbarui ringkasan percakapan dokter
    final idxDoc = _conversations.indexWhere((c) => c.chatId == chatId);
    final idxPat = _patientConversations.indexWhere((c) => c.chatId == chatId);
    // Capture existing status before modification (for Firestore write logic below)
    final String? existingStatusBeforeUpdate = idxDoc >= 0
        ? _conversations[idxDoc].consultationStatus
        : (idxPat >= 0
            ? _patientConversations[idxPat].consultationStatus
            : null);
    if (idxDoc >= 0) {
      final existing = _conversations[idxDoc];
      // Determine new consultationStatus
      final String newStatus = isFromDoctor
          ? (existing.consultationStatus == 'completed'
              ? 'active'
              : existing.consultationStatus)
          : (existing.consultationStatus == 'completed'
              ? 'unread'
              : existing.consultationStatus);
      _conversations[idxDoc] = existing.copyWith(
        lastMessage: text,
        time: timeStr,
        updatedAt: now,
        unreadCount: isFromDoctor ? 0 : existing.unreadCount + 1,
        unreadCountDoctor: isFromDoctor ? 0 : existing.unreadCount + 1,
        unreadCountPatient:
            isFromDoctor ? existing.unreadCountPatient + 1 : 0,
        lastSenderRole: effectiveSenderRole,
        lastSenderId: senderId,
        isAdminChat: isAdminSender || existing.isAdminChat,
        consultationStatus: newStatus,
      );
    } else {
      _conversations.insert(
        0,
        ConversationSummary(
          chatId: chatId,
          patientId: effectivePatientId,
          patientName: effectivePatientName,
          patientInitial: effectivePatientName.isNotEmpty
              ? effectivePatientName[0].toUpperCase()
              : 'P',
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
          lastSenderRole: effectiveSenderRole,
          lastSenderId: senderId,
          updatedAt: now,
          isAdminChat: isAdminSender,
          consultationStatus: isFromDoctor ? 'active' : 'unread',
        ),
      );
    }

    // 3. Perbarui ringkasan percakapan pasien
    if (idxPat >= 0) {
      final existing = _patientConversations[idxPat];
      final String newStatus = isFromDoctor
          ? (existing.consultationStatus == 'completed'
              ? 'active'
              : existing.consultationStatus)
          : (existing.consultationStatus == 'completed'
              ? 'unread'
              : existing.consultationStatus);
      _patientConversations[idxPat] = existing.copyWith(
        lastMessage: text,
        time: timeStr,
        updatedAt: now,
        unreadCountPatient:
            isFromDoctor ? existing.unreadCountPatient + 1 : 0,
        unreadCountDoctor: isFromDoctor ? 0 : existing.unreadCountDoctor + 1,
        lastSenderRole: effectiveSenderRole,
        lastSenderId: senderId,
        isAdminChat: isAdminSender || existing.isAdminChat,
        consultationStatus: newStatus,
      );
    } else {
      _patientConversations.insert(
        0,
        ConversationSummary(
          chatId: chatId,
          patientId: effectivePatientId,
          patientName: effectivePatientName,
          patientInitial: effectivePatientName.isNotEmpty
              ? effectivePatientName[0].toUpperCase()
              : 'P',
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
          lastSenderRole: effectiveSenderRole,
          lastSenderId: senderId,
          updatedAt: now,
          isAdminChat: isAdminSender,
        ),
      );
    }

    notifyListeners();

    // 4. Simpan ke Cloud Firestore
    try {
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      // Metadata percakapan di dokumen induk 'chats/{chatId}'
      final Map<String, dynamic> chatMeta = {
        'chatId': chatId,
        'lastMessage': text,
        'lastMessageTime': timeStr,
        'lastSenderRole': effectiveSenderRole,
        'lastSenderId': senderId,
        'isAdminChat': isAdminSender,
        'updatedAt': FieldValue.serverTimestamp(),
        // Jika dokter yang kirim: unreadCount dokter = 0, unreadCountPatient bertambah 1
        // Jika pasien/admin yang kirim: unreadCount dokter bertambah 1, unreadCountPatient = 0
        'unreadCount': isFromDoctor ? 0 : FieldValue.increment(1),
        'unreadCountDoctor': isFromDoctor ? 0 : FieldValue.increment(1),
        'unreadCountPatient': isFromDoctor ? FieldValue.increment(1) : 0,
      };

      // Sinkronisasi consultationStatus ke Firestore:
      // - Pasien mengirim pesan pada chat 'completed' -> reset ke 'unread'
      // - Pasien mengirim pesan pada chat 'active' -> tetap 'active'
      // - Pasien mengirim pesan pada chat baru -> 'unread'
      // - Dokter mengirim pesan -> selalu 'active'
      final String firestoreStatus = isFromDoctor
          ? 'active'
          : (existingStatusBeforeUpdate == 'completed'
              ? 'unread'
              : (existingStatusBeforeUpdate != null &&
                      existingStatusBeforeUpdate.isNotEmpty
                  ? existingStatusBeforeUpdate
                  : 'unread'));
      chatMeta['consultationStatus'] = firestoreStatus;

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
      if (effectivePatientName.isNotEmpty) {
        chatMeta['patientName'] = effectivePatientName;
      }

      // Simpan dokumen induk chats/{chatId} terlebih dahulu agar aturan keamanan Firestore
      // dapat memverifikasi keberadaan dan hak akses percakapan untuk subkoleksi messages
      await chatDocRef.set(chatMeta, SetOptions(merge: true));

      // Simpan dokumen pesan di subkoleksi 'messages'
      await chatDocRef.collection('messages').doc(messageId).set({
        ...message.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      debugPrint('[ChatService] Gagal sync ke Firestore (berjalan offline): $e\n$stack');
    }
  }

  /// Menyelesaikan konsultasi: mengubah status percakapan menjadi 'completed'.
  /// Dipanggil ketika dokter menekan tombol "Selesaikan Konsultasi".
  Future<void> completeConsultation(String chatId) async {
    final idx = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idx >= 0) {
      _conversations[idx] = _conversations[idx].copyWith(
        consultationStatus: 'completed',
      );
      notifyListeners();
    }
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({'consultationStatus': 'completed'}, SetOptions(merge: true));
      debugPrint('[ChatService] Konsultasi $chatId diselesaikan.');
    } catch (e) {
      debugPrint('[ChatService] Gagal menyelesaikan konsultasi: $e');
    }
  }

  /// Filter percakapan berdasarkan status konsultasi (bebas dari akun dummy)
  List<ConversationSummary> get unreadConversations => List.unmodifiable(
      _conversations.where((c) =>
          !isDummyConversation(c.chatId, c.patientName) &&
          c.consultationStatus == 'unread'));

  List<ConversationSummary> get activeConversations => List.unmodifiable(
      _conversations.where((c) =>
          !isDummyConversation(c.chatId, c.patientName) &&
          c.consultationStatus == 'active'));

  List<ConversationSummary> get completedConversations => List.unmodifiable(
      _conversations.where((c) =>
          !isDummyConversation(c.chatId, c.patientName) &&
          c.consultationStatus == 'completed'));
}
