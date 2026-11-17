import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/models/doctor_review_model.dart';
import 'package:oste/services/doctor_review_service.dart';
import 'package:oste/services/user_service.dart';

/// Halaman untuk mengirimkan atau memperbarui ulasan kepada dokter
class WriteReviewPage extends StatefulWidget {
  final Doctor doctor;
  final DoctorReview? existingReview;

  const WriteReviewPage({
    super.key,
    required this.doctor,
    this.existingReview,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  double _selectedRating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoadingInitial = false;

  static const Color _butterYellow = Color(0xFFF7C948);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _background = Color(0xFFFFF9EF);

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _selectedRating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
      _isEditing = true;
      _isLoadingInitial = false;
    } else {
      _checkExistingReview();
    }
  }

  /// Cek ke Firestore apakah reviews/{userId} sudah ada
  Future<void> _checkExistingReview() async {
    final currentUser = UserService().currentUser;
    User? firebaseUser;
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
    } catch (_) {}

    final userId = currentUser?.uid ?? firebaseUser?.uid;
    if (userId == null || userId.isEmpty) return;

    if (widget.existingReview == null) {
      setState(() => _isLoadingInitial = true);
    }

    try {
      final existing = await DoctorReviewService().getUserReview(
        widget.doctor.id,
        userId,
      );
      if (existing != null && mounted) {
        setState(() {
          _selectedRating = existing.rating;
          _commentController.text = existing.comment;
          _isEditing = true;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    // 1. Validasi rating
    if (_selectedRating <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih rating (1–5 bintang) terlebih dahulu.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final comment = _commentController.text.trim();

    // 2. Validasi komentar minimal 10 karakter
    if (comment.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar ulasan minimal 10 karakter.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Validasi komentar maksimal 500 karakter
    if (comment.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar ulasan maksimal 500 karakter.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Cegah double submit jika proses sedang berlangsung
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final currentUser = UserService().currentUser;
    User? firebaseUser;
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
    } catch (_) {}

    final String userId =
        currentUser?.uid ?? firebaseUser?.uid ?? 'patient_current';
    final String userName =
        (currentUser != null && currentUser.name.trim().isNotEmpty)
            ? currentUser.name.trim()
            : (firebaseUser?.displayName?.trim().isNotEmpty == true
                ? firebaseUser!.displayName!.trim()
                : 'Pengguna');

    String? userPhoto = firebaseUser?.photoURL;
    if (userPhoto == null || userPhoto.trim().isEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          final docPhoto = data['userPhoto'] ?? data['photoUrl'] ?? data['photoURL'];
          if (docPhoto != null && docPhoto.toString().trim().isNotEmpty) {
            userPhoto = docPhoto.toString().trim();
          }
        }
      } catch (_) {}
    }

    try {
      final bool isNew = await DoctorReviewService().saveOrUpdateReview(
        doctorId: widget.doctor.id,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        rating: _selectedRating,
        comment: comment,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isNew
                ? 'Ulasan berhasil disimpan.'
                : 'Ulasan berhasil diperbarui.',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan ulasan: ${e.toString()}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textDark,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          _isEditing ? 'Perbarui Ulasan' : 'Beri Ulasan',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingInitial
            ? const Center(
                child: CircularProgressIndicator(
                  color: _butterYellow,
                ),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Card ringkasan dokter
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              widget.doctor.imageUrl,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 54,
                                height: 54,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctor.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.doctor.specialist,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pemilihan Bintang
                    Text(
                      _isEditing
                          ? 'Perbarui rating pengalaman Anda'
                          : 'Bagaimana pengalaman konsultasi Anda?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = (index + 1).toDouble();
                        final isFilled = starVal <= _selectedRating;
                        return IconButton(
                          iconSize: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            setState(() {
                              _selectedRating = starVal;
                            });
                          },
                          icon: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Input Komentar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Ubah Ulasan' : 'Tulis Ulasan',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            maxLines: 5,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textDark,
                              height: 1.4,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'Ceritakan pengalaman Anda mengenai pelayanan, penjelasan, dan keramahan dokter...',
                              hintStyle: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Simpan / Perbarui Ulasan
                    Opacity(
                      opacity: _isSubmitting ? 0.7 : 1.0,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _butterYellow,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _butterYellow.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _isSubmitting ? null : _submitReview,
                            child: Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(_textDark),
                                      ),
                                    )
                                  : Text(
                                      _isEditing ? 'Perbarui Ulasan' : 'Simpan',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
