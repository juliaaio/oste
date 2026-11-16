import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/education/articles/article_data.dart';
import '../features/education/articles/article_model.dart';

/// Single source of truth untuk manajemen artikel Osteo.
/// Digunakan bersama oleh POV Admin (CRUD) dan POV Pasien (membaca).
/// Mendukung sinkronisasi realtime melalui Cloud Firestore `articles`
/// sekaligus reaktif lokal via [ChangeNotifier].
class ArticleRepository extends ChangeNotifier {
  static final ArticleRepository _instance = ArticleRepository._internal();
  factory ArticleRepository() => _instance;

  ArticleRepository._internal() {
    _initLocalArticles();
    _initFirestoreListener();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _articlesRef =>
      _firestore?.collection('articles');

  final List<ArticleModel> _articles = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  // ===========================================================================
  // GETTERS UNTUK ADMIN & PASIEN
  // ===========================================================================

  /// Daftar semua artikel (Admin: mencakup artikel Dipublikasikan dan Draft)
  List<ArticleModel> get allArticles => List.unmodifiable(_articles);

  /// Kompatibilitas untuk kode Admin yang memanggil `.articles`
  List<ArticleModel> get articles => allArticles;

  /// Daftar artikel yang dipublikasikan (Pasien: hanya menampilkan yang publish)
  List<ArticleModel> get publishedArticles =>
      List.unmodifiable(_articles.where((a) => a.isPublished).toList());

  /// Metrik artikel untuk Dashboard Admin
  int get totalCount => _articles.length;
  int get publishedCount => _articles.where((a) => a.isPublished).length;
  int get draftCount => _articles.where((a) => !a.isPublished).length;

  // ===========================================================================
  // INISIALISASI & SINKRONISASI
  // ===========================================================================

  /// Memuat artikel awal dari [ArticleData.initialArticles] tanpa duplikasi definisi
  void _initLocalArticles() {
    _articles.clear();
    _articles.addAll(ArticleData.initialArticles);
  }

  /// Mendengarkan perubahan Firestore secara realtime
  void _initFirestoreListener() {
    _subscription?.cancel();
    final ref = _articlesRef;
    if (ref == null) return;

    try {
      _subscription = ref.snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<ArticleModel> remoteArticles = [];

          // Urutkan dokumen: terbaru di atas berdasarkan createdAt
          final docs = snapshot.docs.toList()
            ..sort((a, b) {
              final ca = a.data()['createdAt'];
              final cb = b.data()['createdAt'];
              if (ca is Timestamp && cb is Timestamp) {
                return cb.compareTo(ca);
              }
              return 0;
            });

          for (final doc in docs) {
            final data = doc.data();

            // Cocokkan dengan artikel bawaan untuk mempertahankan sections lengkap jika ada
            ArticleModel? defaultMatch;
            try {
              defaultMatch = ArticleData.initialArticles.firstWhere(
                (a) =>
                    a.id == doc.id ||
                    a.title.trim().toLowerCase() ==
                        (data['title'] ?? '').toString().trim().toLowerCase(),
              );
            } catch (_) {}

            final item = ArticleModel.fromFirestore(
              doc,
              fallbackSections: defaultMatch?.sections,
            );
            remoteArticles.add(item);
          }

          _articles.clear();
          _articles.addAll(remoteArticles);
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('[ArticleRepository] Firestore snapshot error: $e');
      });
    } catch (e) {
      debugPrint('[ArticleRepository] Listener init error: $e');
    }
  }

  // ===========================================================================
  // OPERASI CRUD ADMIN (TERHUBUNG KE FIRESTORE DAN LOKAL REAKTIF)
  // ===========================================================================

  /// Menambah artikel baru (Admin)
  Future<String> addArticle(ArticleModel article) async {
    final ref = _articlesRef;
    final finalId = article.id.isNotEmpty
        ? article.id
        : (ref != null
            ? ref.doc().id
            : 'art_${DateTime.now().millisecondsSinceEpoch}');
    final toSave = article.copyWith(id: finalId);

    // 1. Tambahkan ke memori lokal seketika agar UI Admin & Pasien merespons langsung
    _articles.removeWhere((a) => a.id == finalId);
    _articles.insert(0, toSave);
    notifyListeners();

    // 2. Simpan ke koleksi Firestore `articles` jika aktif
    if (ref != null) {
      try {
        await ref.doc(finalId).set({
          ...toSave.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('[ArticleRepository] Error saving to Firestore: $e');
      }
    }
    return finalId;
  }

  /// Memperbarui artikel (Admin)
  Future<void> updateArticle(ArticleModel updated) async {
    // 1. Perbarui di memori lokal seketika
    final index = _articles.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _articles[index] = updated;
      notifyListeners();
    }

    // 2. Perbarui dokumen di Firestore jika aktif
    final ref = _articlesRef;
    if (ref != null) {
      try {
        await ref.doc(updated.id).set({
          ...updated.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[ArticleRepository] Error updating in Firestore: $e');
      }
    }
  }

  /// Menghapus artikel (Admin)
  Future<void> deleteArticle(String id) async {
    // 1. Hapus dari memori lokal seketika
    _articles.removeWhere((a) => a.id == id);
    notifyListeners();

    // 2. Hapus dokumen dari Firestore jika aktif
    final ref = _articlesRef;
    if (ref != null) {
      try {
        await ref.doc(id).delete();
      } catch (e) {
        debugPrint('[ArticleRepository] Error deleting in Firestore: $e');
      }
    }
  }

  /// Mengambil artikel berdasarkan ID
  ArticleModel? getArticleById(String id) {
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi awal artikel default ke Firestore jika koleksi masih kosong
  Future<void> seedDefaultArticlesIfEmpty() async {
    final ref = _articlesRef;
    final fs = _firestore;
    if (ref == null || fs == null) return;

    try {
      final snapshot = await ref.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      final batch = fs.batch();
      for (final item in ArticleData.initialArticles) {
        final docRef = ref.doc(item.id);
        batch.set(docRef, {
          ...item.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('[ArticleRepository] Seeded default articles to Firestore.');
    } catch (e) {
      debugPrint('[ArticleRepository] Error seeding default articles: $e');
    }
  }

  /// Stream daftar artikel dipublikasikan untuk widget yang membutuhkan Stream
  Stream<List<ArticleModel>> streamPublishedArticles() {
    final ref = _articlesRef;
    if (ref == null) {
      return Stream.value(publishedArticles);
    }
    return ref.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return publishedArticles;
      }
      return publishedArticles;
    }).handleError((_) => publishedArticles);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

