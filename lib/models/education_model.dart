import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model materi edukasi Osteo.
/// Digunakan untuk pengelolaan materi latihan, nutrisi, dan vitamin.
class EducationModel {
  final String id;
  final String title;
  final String category; // 'Latihan', 'Nutrisi', 'Vitamin'
  final String imageUrl;
  final String description;
  final String content;
  final String author;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EducationModel({
    required this.id,
    required this.title,
    required this.category,
    this.imageUrl = '',
    this.description = '',
    this.content = '',
    this.author = 'Tim Medis Osteo',
    this.createdAt,
    this.updatedAt,
  });

  /// Factory dari Firestore DocumentSnapshot
  factory EducationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EducationModel.fromMap(doc.id, data);
  }

  /// Factory dari Map generik
  factory EducationModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return EducationModel(
      id: id,
      title: data['title']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Latihan',
      imageUrl: data['imageUrl']?.toString() ??
          data['thumbnail']?.toString() ??
          data['image']?.toString() ??
          '',
      description: data['description']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      author: data['author']?.toString() ?? 'Tim Medis Osteo',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  /// Konversi ke Map Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'content': content,
      'author': author,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  EducationModel copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    String? description,
    String? content,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Data awal materi edukasi sesuai dengan acuan screenshot menu Kelola Edukasi
const List<EducationModel> initialEducationList = [
  EducationModel(
    id: 'edu_1',
    title: 'Latihan Penguatan Tulang',
    category: 'Latihan',
    imageUrl: 'assets/images/bone_peak_exercise.png',
    description:
        'Panduan latihan fisik dan gerakan beban tubuh untuk meningkatkan kepadatan tulang dan mencegah pengeroposan sejak dini.',
    content:
        'Latihan penguatan tulang berfokus pada aktivitas menahan beban (weight-bearing) seperti berjalan cepat, squat ringan, dan latihan kekuatan otot secara bertahap untuk merangsang pembentukan massa tulang baru.',
    author: 'Tim Fisioterapi Osteo',
  ),
  EducationModel(
    id: 'edu_2',
    title: 'Asupan Nutrisi untuk Tulang Sehat',
    category: 'Nutrisi',
    imageUrl: 'assets/images/calcium_rich_foods.png',
    description:
        'Pola makan bergizi seimbang kaya kalsium, magnesium, dan protein untuk mendukung struktur tulang yang kuat.',
    content:
        'Nutrisi penting bagi tulang meliputi makanan kaya kalsium seperti susu rendah lemak, sayuran hijau, tahu, tempe, serta ikan salmon atau sarden yang mudah diserap oleh tubuh.',
    author: 'Tim Gizi Klinis Osteo',
  ),
  EducationModel(
    id: 'edu_3',
    title: 'Rekomendasi Vitamin D',
    category: 'Vitamin',
    imageUrl: 'assets/images/sun_vitamin_d_bone.png',
    description:
        'Kebutuhan harian vitamin D dan manfaat paparan sinar matahari pagi untuk optimalisasi penyerapan kalsium.',
    content:
        'Vitamin D berfungsi sebagai kunci penyerapan kalsium di usus halus. Paparan sinar matahari pagi selama 10-15 menit dan suplemen vitamin D sesuai anjuran medis sangat efektif menjaga kesehatan matriks tulang.',
    author: 'Tim Dokter Spesialis Osteo',
  ),
];

