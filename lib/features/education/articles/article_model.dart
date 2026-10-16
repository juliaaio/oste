import 'package:flutter/material.dart';

/// Data model utama untuk sebuah artikel edukasi kesehatan tulang
class ArticleModel {
  final String id;
  final String title;
  final String appBarTitle;
  final String source;
  final Color sourceColor;
  final String sourceInitial;
  final String description;
  final String url;
  final String thumbnailUrl;
  final String heroAssetPath;
  final String? videoUrl;
  final String? videoBadgeText;
  final String? bannerBottomText;
  final String sourceActionLabel;
  final List<ArticleSection> sections;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.appBarTitle,
    required this.source,
    required this.sourceColor,
    required this.sourceInitial,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.heroAssetPath,
    this.videoUrl,
    this.videoBadgeText = 'Tonton Video',
    this.bannerBottomText,
    required this.sourceActionLabel,
    required this.sections,
  });
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
