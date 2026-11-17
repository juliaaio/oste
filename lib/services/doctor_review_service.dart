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
  final Map<String, double> _doctorAverageRatings = {};
  final Map<String, int> _doctorReviewCounts = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _subscriptions = {};
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
      _doctorDocSubscriptions = {};

  /// Referensi subcollection reviews pada Firestore:
  /// doctors/{doctorId}/reviews
  CollectionReference<Map<String, dynamic>> _reviewsRef(String doctorId) {
    return FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('reviews');
  }

  /// Referensi dokumen dokter pada Firestore:
  /// doctors/{doctorId}
  DocumentReference<Map<String, dynamic>> _doctorDocRef(String doctorId) {
    return FirebaseFirestore.instance.collection('doctors').doc(doctorId);
  }

  /// Berlangganan data ulasan dan dokumen dokter secara realtime dari Firestore
  void subscribeToDoctorReviews(String doctorId) {
    // 1. Subscribe ke subcollection reviews
    if (!_subscriptions.containsKey(doctorId)) {
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

          // Update cached stats jika belum ada dari doc dokter
          if (!_doctorReviewCounts.containsKey(doctorId)) {
            _doctorReviewCounts[doctorId] = firestoreReviews.length;
            if (firestoreReviews.isNotEmpty) {
              final total = firestoreReviews.fold<double>(
                  0.0, (sum, r) => sum + r.rating);
              _doctorAverageRatings[doctorId] = double.parse(
                  (total / firestoreReviews.length).toStringAsFixed(1));
            } else {
              _doctorAverageRatings[doctorId] = 0.0;
            }
          }

          notifyListeners();
        }, onError: (e) {
          // Abaikan error saat offline/testing, tetap gunakan data lokal
        });

        _subscriptions[doctorId] = sub;
      } catch (_) {}
    }

    // 2. Subscribe ke dokumen doctors/{doctorId} untuk statistik (averageRating & reviewCount)
    if (!_doctorDocSubscriptions.containsKey(doctorId)) {
      try {
        final docSub = _doctorDocRef(doctorId).snapshots().listen((docSnap) {
          if (docSnap.exists && docSnap.data() != null) {
            final data = docSnap.data()!;
            if (data.containsKey('averageRating')) {
              _doctorAverageRatings[doctorId] =
                  (data['averageRating'] as num).toDouble();
            }
            if (data.containsKey('reviewCount')) {
              _doctorReviewCounts[doctorId] =
                  (data['reviewCount'] as num).toInt();
            }
            notifyListeners();
          }
        }, onError: (_) {});
        _doctorDocSubscriptions[doctorId] = docSub;
      } catch (_) {}
    }
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
  /// Menggunakan Firestore Transaction / Batch untuk memperbarui dokumen ulasan
  /// sekaligus menghitung dan menyimpan statistik `averageRating` & `reviewCount`
  /// pada dokumen `doctors/{doctorId}`.
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
      final firestore = FirebaseFirestore.instance;
      final reviewDocRef = _reviewsRef(doctorId).doc(userId);
      final doctorRef = _doctorDocRef(doctorId);

      // Gunakan Transaction agar data konsisten (ACID)
      final bool isNew = await firestore.runTransaction<bool>((transaction) async {
        final reviewSnap = await transaction.get(reviewDocRef);
        final bool isExisting = reviewSnap.exists;

        // Ambil semua review untuk dokter ini guna menghitung statistik baru secara akurat
        final allReviewsSnap = await _reviewsRef(doctorId).get();

        double totalRating = 0.0;
        int count = 0;
        bool foundUserReviewInQuery = false;

        for (final doc in allReviewsSnap.docs) {
          if (doc.id == userId) {
            foundUserReviewInQuery = true;
            totalRating += rating; // gunakan rating baru
            count++;
          } else {
            final data = doc.data();
            final r = (data['rating'] as num?)?.toDouble() ?? 0.0;
            totalRating += r;
            count++;
          }
        }

        if (!foundUserReviewInQuery) {
          totalRating += rating;
          count++;
        }

        final double newAvgRating = count > 0
            ? double.parse((totalRating / count).toStringAsFixed(1))
            : 0.0;

        if (!isExisting) {
          // 1. Simpan dokumen review baru
          transaction.set(reviewDocRef, {
            'rating': rating,
            'comment': comment,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'userId': userId,
            'userName': userName,
            'userPhoto': userPhoto,
          });
        } else {
          // 2. Perbarui dokumen review yang ada
          transaction.update(reviewDocRef, {
            'rating': rating,
            'comment': comment,
            'updatedAt': FieldValue.serverTimestamp(),
            'userName': userName,
            if (userPhoto != null) 'userPhoto': userPhoto,
          });
        }

        // 3. Simpan statistik rating pada dokumen doctors/{doctorId}
        transaction.set(
          doctorRef,
          {
            'averageRating': newAvgRating,
            'reviewCount': count,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        return !isExisting;
      });

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
      if (isNew) {
        _reviewsByDoctor[doctorId]!.removeWhere((r) => r.userId == userId);
        _reviewsByDoctor[doctorId]!.insert(0, review);
        _reviews.removeWhere((r) => r.doctorId == doctorId && r.userId == userId);
        _reviews.insert(0, review);
      } else {
        final idx = _reviewsByDoctor[doctorId]!.indexWhere((r) => r.userId == userId);
        if (idx != -1) {
          _reviewsByDoctor[doctorId]![idx] = review;
        } else {
          _reviewsByDoctor[doctorId]!.insert(0, review);
        }
        final gIdx = _reviews.indexWhere((r) => r.doctorId == doctorId && r.userId == userId);
        if (gIdx != -1) {
          _reviews[gIdx] = review;
        } else {
          _reviews.insert(0, review);
        }
      }

      // Update local cached statistics
      final list = _reviewsByDoctor[doctorId] ?? [];
      _doctorReviewCounts[doctorId] = list.length;
      if (list.isNotEmpty) {
        final total = list.fold<double>(0.0, (sum, r) => sum + r.rating);
        _doctorAverageRatings[doctorId] =
            double.parse((total / list.length).toStringAsFixed(1));
      } else {
        _doctorAverageRatings[doctorId] = 0.0;
      }

      notifyListeners();
      return isNew;
    } catch (e) {
      // Fallback jika Firebase tidak tersedia (misal offline atau unit testing)
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
      } else {
        _reviewsByDoctor[doctorId]![existingIndex] = review;
        final gIdx = _reviews
            .indexWhere((r) => r.doctorId == doctorId && r.userId == userId);
        if (gIdx != -1) _reviews[gIdx] = review;
      }

      final list = _reviewsByDoctor[doctorId] ?? [];
      _doctorReviewCounts[doctorId] = list.length;
      if (list.isNotEmpty) {
        final total = list.fold<double>(0.0, (sum, r) => sum + r.rating);
        _doctorAverageRatings[doctorId] =
            double.parse((total / list.length).toStringAsFixed(1));
      } else {
        _doctorAverageRatings[doctorId] = 0.0;
      }

      notifyListeners();
      return !isExisting;
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

  /// Mengambil jumlah ulasan untuk dokter tertentu dari dokumen doctors/{doctorId} atau cache
  int getReviewCount(String doctorId) {
    if (_doctorReviewCounts.containsKey(doctorId)) {
      return _doctorReviewCounts[doctorId]!;
    }
    return getReviewsForDoctor(doctorId).length;
  }

  /// Menghitung / mengambil rating rata-rata untuk dokter tertentu (skala 0.0 - 5.0)
  /// dari dokumen doctors/{doctorId} atau cache
  double getAverageRating(String doctorId) {
    if (_doctorAverageRatings.containsKey(doctorId)) {
      return _doctorAverageRatings[doctorId]!;
    }
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
    for (final sub in _doctorDocSubscriptions.values) {
      sub.cancel();
    }
    _doctorDocSubscriptions.clear();
    super.dispose();
  }
}
