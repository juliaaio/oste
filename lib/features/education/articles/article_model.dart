import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Data model tunggal dan terpadu untuk sebuah artikel edukasi kesehatan tulang.
/// Digunakan bersama oleh POV Admin (manajemen konten/CRUD) dan POV Pasien (baca edukasi).
class ArticleModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String status; // 'Dipublikasikan' atau 'Draft'
  final String imageAsset;
  final String description;
  final String _content;
  final String source;
  final String url;
  final String? _thumbnailUrl;
  final String? videoUrl;
  final String? videoBadgeText;
  final String? bannerBottomText;
  final String? _sourceActionLabel;
  final Color? _sourceColor;
  final String? _sourceInitial;
  final List<ArticleSection> sections;

  const ArticleModel({
    required this.id,
    required this.title,
    String? category,
    String? appBarTitle,
    this.date = '',
    this.status = 'Dipublikasikan',
    String? imageAsset,
    String? heroAssetPath,
    this.description = '',
    String content = '',
    this.source = 'Osteo Admin',
    this.url = '',
    String? thumbnailUrl,
    this.videoUrl,
    this.videoBadgeText = 'Tonton Video',
    this.bannerBottomText,
    String? sourceActionLabel,
    Color? sourceColor,
    String? sourceInitial,
    this.sections = const [],
  })  : category = category ?? appBarTitle ?? 'Edukasi Tulang',
        imageAsset = imageAsset ??
            heroAssetPath ??
            'assets/images/osteoporosis_hero.jpg',
        _content = content,
        _thumbnailUrl = thumbnailUrl,
        _sourceActionLabel = sourceActionLabel,
        _sourceColor = sourceColor,
        _sourceInitial = sourceInitial;

  // ===========================================================================
  // GETTER UNTUK KOMPATIBILITAS TAMPILAN PASIEN & ADMIN
  // ===========================================================================

  /// Judul yang tampil pada AppBar di halaman detail artikel
  String get appBarTitle =>
      category.isNotEmpty ? category : 'Artikel Osteoporosis';

  /// Path atau URL gambar hero artikel
  String get heroAssetPath => imageAsset;

  /// URL thumbnail gambar artikel dengan fallback cerdas
  String get thumbnailUrl {
    if (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty) {
      return _thumbnailUrl!;
    }
    return imageAsset.startsWith('http') ? imageAsset : '';
  }

  /// Warna badge sumber artikel
  Color get sourceColor => _sourceColor ?? getSourceColor(source);

  /// Inisial huruf sumber artikel
  String get sourceInitial {
    if (_sourceInitial != null && _sourceInitial!.isNotEmpty) {
      return _sourceInitial!;
    }
    final trimmed = source.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'O';
  }

  /// Label tombol aksi membaca artikel di sumber resmi
  String get sourceActionLabel {
    if (_sourceActionLabel != null && _sourceActionLabel!.isNotEmpty) {
      return _sourceActionLabel!;
    }
    return url.isNotEmpty
        ? 'Baca artikel lengkap di $source'
        : 'Baca artikel lengkap di Osteo';
  }

  /// Status apakah artikel dipublikasikan (terlihat oleh Pasien)
  bool get isPublished {
    final s = status.trim().toLowerCase();
    return s == 'dipublikasikan' || s == 'published';
  }

  /// Isi teks lengkap artikel (jika _content kosong, disusun dari seluruh paragraphs sections)
  String get content {
    if (_content.isNotEmpty) return _content;
    if (sections.isNotEmpty) {
      final buffer = StringBuffer();
      for (final sec in sections) {
        if (sec.title.isNotEmpty) {
          buffer.writeln(sec.title);
        }
        for (final p in sec.paragraphs) {
          buffer.writeln(p);
        }
        buffer.writeln();
      }
      return buffer.toString().trim();
    }
    return description;
  }

  // ===========================================================================
  // COPYWITH, TO MAP, & FACTORY CONSTRUCTORS
  // ===========================================================================

  ArticleModel copyWith({
    String? id,
    String? title,
    String? category,
    String? date,
    String? status,
    String? imageAsset,
    String? description,
    String? content,
    String? source,
    String? url,
    String? thumbnailUrl,
    String? videoUrl,
    String? videoBadgeText,
    String? bannerBottomText,
    String? sourceActionLabel,
    Color? sourceColor,
    String? sourceInitial,
    List<ArticleSection>? sections,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      status: status ?? this.status,
      imageAsset: imageAsset ?? this.imageAsset,
      description: description ?? this.description,
      content: content ?? _content,
      source: source ?? this.source,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? _thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoBadgeText: videoBadgeText ?? this.videoBadgeText,
      bannerBottomText: bannerBottomText ?? this.bannerBottomText,
      sourceActionLabel: sourceActionLabel ?? _sourceActionLabel,
      sourceColor: sourceColor ?? _sourceColor,
      sourceInitial: sourceInitial ?? _sourceInitial,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'status': status,
      'imageAsset': imageAsset,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'content': content,
      'source': source,
      'url': url,
    };
  }

  factory ArticleModel.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<ArticleSection>? fallbackSections,
  }) {
    final title = (map['title'] as String? ?? '').trim();
    final rawContent = (map['content'] as String? ?? '').trim();
    final desc = (map['description'] as String? ?? rawContent).trim();

    List<ArticleSection> parsedSections;
    if (fallbackSections != null && fallbackSections.isNotEmpty) {
      parsedSections = fallbackSections;
    } else if (rawContent.isNotEmpty) {
      final paragraphs = rawContent
          .split(RegExp(r'\n+'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      parsedSections = [
        ArticleSection(
          number: 1,
          title: title.isNotEmpty ? title : 'Informasi Edukasi',
          paragraphs: paragraphs.isNotEmpty ? paragraphs : [desc],
        ),
      ];
    } else {
      parsedSections = const [];
    }

    final image = (map['imageAsset'] as String? ??
            map['heroAssetPath'] as String? ??
            'assets/images/osteoporosis_hero.jpg')
        .trim();

    return ArticleModel(
      id: id,
      title: title,
      category: (map['category'] as String? ??
              map['appBarTitle'] as String? ??
              'Edukasi Tulang')
          .trim(),
      date: (map['date'] as String? ?? '').trim(),
      status: (map['status'] as String? ?? 'Dipublikasikan').trim(),
      imageAsset: image,
      thumbnailUrl: (map['thumbnailUrl'] as String? ?? '').trim(),
      description: desc,
      content: rawContent,
      source: (map['source'] as String? ?? 'Osteo Admin').trim(),
      url: (map['url'] as String? ?? '').trim(),
      sections: parsedSections,
    );
  }

  factory ArticleModel.fromFirestore(
    DocumentSnapshot doc, {
    List<ArticleSection>? fallbackSections,
  }) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ArticleModel.fromMap(
      doc.id,
      data,
      fallbackSections: fallbackSections,
    );
  }

  static Color getSourceColor(String source) {
    final s = source.toLowerCase();
    if (s.contains('alo')) return const Color(0xFF0A7AFF);
    if (s.contains('kemenkes') || s.contains('kementerian')) {
      return const Color(0xFF00897B);
    }
    if (s.contains('afmc')) return const Color(0xFF0055B7);
    if (s.contains('holistic')) return const Color(0xFF018AAC);
    if (s.contains('rspi') || s.contains('pondok indah')) {
      return const Color(0xFF358888);
    }
    return const Color(0xFFF59E0B);
  }
}

/// Bagian / Bab bernomor di dalam artikel (misal: "1. Pengertian Osteoporosis")
class ArticleSection {
  final int number;
  final String title;
  final List<String> paragraphs;
  final List<ArticleInfoCard> infoCards;
  final ArticleDoctorConsultation? doctorConsultation;
  final ArticleDiagnosisBox? diagnosisBox;

  const ArticleSection({
    required this.number,
    required this.title,
    this.paragraphs = const [],
    this.infoCards = const [],
    this.doctorConsultation,
    this.diagnosisBox,
  });
}

/// Kartu informasi berlatar kuning/krim atau alert (misal: faktor risiko, tanda bahaya)
class ArticleInfoCard {
  final String? title;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final List<String> bulletPoints;
  final bool isAlert;

  const ArticleInfoCard({
    this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.iconBgColor,
    this.bulletPoints = const [],
    this.isAlert = false,
  });
}

/// Bagian konsultasi dokter (misal: Kapan harus ke dokter)
class ArticleDoctorConsultation {
  final String text;
  final String highlightedSource;
  final String? consultationUrl;

  const ArticleDoctorConsultation({
    required this.text,
    required this.highlightedSource,
    this.consultationUrl,
  });
}

/// Bagian diagnosis dengan list pemeriksaan penunjang dan tabel interpretasi T-score
class ArticleDiagnosisBox {
  final String introText;
  final List<DiagnosisItem> procedures;
  final List<TScoreItem> tScores;

  const ArticleDiagnosisBox({
    required this.introText,
    this.procedures = const [],
    this.tScores = const [],
  });
}

class DiagnosisItem {
  final String name;
  final String description;

  const DiagnosisItem({
    required this.name,
    required this.description,
  });
}

class TScoreItem {
  final String scoreRange;
  final String status;

  const TScoreItem({
    required this.scoreRange,
    required this.status,
  });
}
