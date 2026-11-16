import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:oste/models/doctor_review_model.dart';

/// Layanan singleton reaktif untuk mengelola ulasan dokter dengan Firebase Firestore
class DoctorReviewService extends ChangeNotifier {
  static final DoctorReviewService _instance = DoctorReviewService._internal();

  factory DoctorReviewService() => _instance;

  DoctorReviewService._internal();

  final List<DoctorReview> _reviews = [];
  final Map<String, List<DoctorReview>> _reviewsByDoctor = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _subscriptions = {};

  /// Referensi subcollection reviews pada Firestore:
  /// doctors/{doctorId}/reviews
  CollectionReference<Map<String, dynamic>> _reviewsRef(String doctorId) {
    return FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('reviews');
  }

  /// Berlangganan data ulasan dokter secara realtime dari Firestore
  void subscribeToDoctorReviews(String doctorId) {
    if (_subscriptions.containsKey(doctorId)) return;

    try {
      final sub = _reviewsRef(doctorId).snapshots().listen((snapshot) {
        final List<DoctorReview> firestoreReviews = snapshot.docs
            .map((doc) => DoctorReview.fromFirestore(doc, doctorId))
            .toList();

        firestoreReviews.sort((a, b) {
          final dateA = a.updatedAt ?? a.createdAt;
          final dateB = b.updatedAt ?? b.createdAt;
          return dateB.compareTo(dateA);
        });

        _reviewsByDoctor[doctorId] = firestoreReviews;

        // Sinkronisasi dengan list global _reviews
        _reviews.removeWhere((r) => r.doctorId == doctorId);
        _reviews.addAll(firestoreReviews);

        notifyListeners();
      }, onError: (e) {
        // Abaikan error saat offline/testing, tetap gunakan data lokal
      });

      _subscriptions[doctorId] = sub;
    } catch (_) {}
  }

  /// Stream realtime ulasan dokter dari Firestore
  Stream<List<DoctorReview>> streamReviews(String doctorId) {
    subscribeToDoctorReviews(doctorId);

    try {
      return _reviewsRef(doctorId).snapshots().map((snapshot) {
        final List<DoctorReview> firestoreReviews = snapshot.docs
            .map((doc) => DoctorReview.fromFirestore(doc, doctorId))
            .toList();

        firestoreReviews.sort((a, b) {
          final dateA = a.updatedAt ?? a.createdAt;
          final dateB = b.updatedAt ?? b.createdAt;
          return dateB.compareTo(dateA);
        });

        _reviewsByDoctor[doctorId] = firestoreReviews;
        _reviews.removeWhere((r) => r.doctorId == doctorId);
        _reviews.addAll(firestoreReviews);

        notifyListeners();
        return firestoreReviews;
      }).handleError((_) {
        return getReviewsForDoctor(doctorId);
      });
    } catch (_) {
      return Stream.value(getReviewsForDoctor(doctorId));
    }
  }

  /// Mengambil data ulasan pengguna tertentu untuk dokter tertentu dari Firestore
  Future<DoctorReview?> getUserReview(String doctorId, String userId) async {
    if (userId.isEmpty) return null;

    try {
      final doc = await _reviewsRef(doctorId).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return DoctorReview.fromFirestore(doc, doctorId);
      }
    } catch (_) {
      final cached = _reviewsByDoctor[doctorId]
          ?.where((r) => r.userId == userId)
          .firstOrNull;
      if (cached != null) return cached;
    }
    return null;
  }

  /// Menyimpan ulasan baru (set) jika belum ada, atau memperbarui ulasan (update) jika sudah ada.
  ///
  /// Mengembalikan `true` jika review baru dibuat, atau `false` jika review lama diperbarui.
  Future<bool> saveOrUpdateReview({
    required String doctorId,
    required String userId,
    required String userName,
    String? userPhoto,
    required double rating,
    required String comment,
  }) async {
    final now = DateTime.now();

    try {
      final docRef = _reviewsRef(doctorId).doc(userId);
      final docSnap = await docRef.get();
      final bool isExisting = docSnap.exists;

      if (!isExisting) {
        // Buat document baru dengan userId sebagai document ID
        await docRef.set({
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'userId': userId,
          'userName': userName,
          'userPhoto': userPhoto,
        });

        final newReview = DoctorReview(
          userId: userId,
          doctorId: doctorId,
          userName: userName,
          userPhoto: userPhoto,
          rating: rating,
          comment: comment,
          createdAt: now,
          updatedAt: now,
        );

        _reviewsByDoctor.putIfAbsent(doctorId, () => []);
        _reviewsByDoctor[doctorId]!.removeWhere((r) => r.userId == userId);
        _reviewsByDoctor[doctorId]!.insert(0, newReview);

        _reviews
            .removeWhere((r) => r.doctorId == doctorId && r.userId == userId);
        _reviews.insert(0, newReview);

        notifyListeners();
        return true;
      } else {
        // Update document yang sudah ada tanpa membuat document baru
        await docRef.update({
          'rating': rating,
          'comment': comment,
          'updatedAt': FieldValue.serverTimestamp(),
          'userName': userName,
          if (userPhoto != null) 'userPhoto': userPhoto,
        });

        final updatedReview = DoctorReview(
          userId: userId,
          doctorId: doctorId,
          userName: userName,
          userPhoto: userPhoto,
          rating: rating,
          comment: comment,
          createdAt: now,
          updatedAt: now,
        );

        if (_reviewsByDoctor.containsKey(doctorId)) {
          final idx = _reviewsByDoctor[doctorId]!
              .indexWhere((r) => r.userId == userId);
          if (idx != -1) {
            _reviewsByDoctor[doctorId]![idx] = updatedReview;
          } else {
            _reviewsByDoctor[doctorId]!.insert(0, updatedReview);
          }
        }

        final globalIdx = _reviews
            .indexWhere((r) => r.doctorId == doctorId && r.userId == userId);
        if (globalIdx != -1) {
          _reviews[globalIdx] = updatedReview;
        } else {
          _reviews.insert(0, updatedReview);
        }

        notifyListeners();
        return false;
      }
    } catch (e) {
      // Fallback jika Firebase tidak tersedia (misal offline atau testing)
      final existingIndex = _reviewsByDoctor[doctorId]
              ?.indexWhere((r) => r.userId == userId) ??
          -1;
      final bool isExisting = existingIndex != -1;

      final review = DoctorReview(
        userId: userId,
        doctorId: doctorId,
        userName: userName,
        userPhoto: userPhoto,
        rating: rating,
        comment: comment,
        createdAt: now,
        updatedAt: now,
      );

      _reviewsByDoctor.putIfAbsent(doctorId, () => []);
      if (!isExisting) {
        _reviewsByDoctor[doctorId]!.insert(0, review);
        _reviews.insert(0, review);
        notifyListeners();
        return true;
      } else {
        _reviewsByDoctor[doctorId]![existingIndex] = review;
        final gIdx = _reviews
            .indexWhere((r) => r.doctorId == doctorId && r.userId == userId);
        if (gIdx != -1) _reviews[gIdx] = review;
        notifyListeners();
        return false;
      }
    }
  }

  /// Mengambil semua ulasan untuk dokter tertentu, diurutkan dari yang terbaru
  List<DoctorReview> getReviewsForDoctor(String doctorId) {
    subscribeToDoctorReviews(doctorId);
    final list = _reviewsByDoctor[doctorId] ??
        _reviews.where((r) => r.doctorId == doctorId).toList();
    list.sort((a, b) {
      final dateA = a.updatedAt ?? a.createdAt;
      final dateB = b.updatedAt ?? b.createdAt;
      return dateB.compareTo(dateA);
    });
    return List<DoctorReview>.from(list);
  }

  /// Mengambil jumlah ulasan untuk dokter tertentu
  int getReviewCount(String doctorId) {
    return getReviewsForDoctor(doctorId).length;
  }

  /// Menghitung rating rata-rata untuk dokter tertentu (skala 0.0 - 5.0)
  double getAverageRating(String doctorId) {
    final doctorReviews = getReviewsForDoctor(doctorId);
    if (doctorReviews.isEmpty) return 0.0;
    final total = doctorReviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    final avg = total / doctorReviews.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  /// Menghitung persentase distribusi bintang 1-5 untuk dokter tertentu
  Map<int, double> getStarDistributionPercentages(String doctorId) {
    final doctorReviews = getReviewsForDoctor(doctorId);
    if (doctorReviews.isEmpty) {
      return {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
    }

    final total = doctorReviews.length;
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in doctorReviews) {
      final roundedStar = review.rating.round().clamp(1, 5);
      counts[roundedStar] = (counts[roundedStar] ?? 0) + 1;
    }

    final Map<int, double> percentages = {};
    counts.forEach((star, count) {
      percentages[star] = (count / total) * 100.0;
    });

    return percentages;
  }

  /// Menambahkan ulasan baru (in-memory helper / backwards compatibility)
  void addReview(DoctorReview review) {
    _reviewsByDoctor.putIfAbsent(review.doctorId, () => []);
    _reviewsByDoctor[review.doctorId]!
        .removeWhere((r) => r.userId == review.userId);
    _reviewsByDoctor[review.doctorId]!.insert(0, review);

    _reviews.removeWhere(
        (r) => r.doctorId == review.doctorId && r.userId == review.userId);
    _reviews.insert(0, review);

    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
