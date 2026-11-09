import 'package:flutter/material.dart';
import 'admin_article_model.dart';

/// Store in-memory singleton untuk mengelola daftar artikel Admin selama sesi aktif
/// Tanpa mengubah Firebase ataupun membuat data palsu permanen
class AdminArticleStore extends ChangeNotifier {
  static final AdminArticleStore _instance = AdminArticleStore._internal();
  factory AdminArticleStore() => _instance;

  AdminArticleStore._internal() {
    _initDefaultArticles();
  }

  final List<AdminArticleItem> _articles = [];

  List<AdminArticleItem> get articles => List.unmodifiable(_articles);

  int get totalCount => _articles.length;
  int get publishedCount => _articles.where((a) => a.isPublished).length;
  int get draftCount => _articles.where((a) => !a.isPublished).length;

  void _initDefaultArticles() {
    _articles.addAll([
      AdminArticleItem(
        id: '1',
        title: 'Mengenal Osteoporosis',
        category: 'Edukasi Tulang',
        date: '12 Okt 2026',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/osteoporosis_hero.jpg',
        source: 'Alodokter',
        description:
            'Kenali penyebab, gejala, faktor risiko, dan cara mencegah osteoporosis sedini mungkin.',
        content:
            'Osteoporosis adalah kondisi ketika kepadatan tulang berkurang sehingga tulang menjadi keropos dan mudah patah. Kondisi ini sering tidak menimbulkan gejala sehingga biasanya baru terdiagnosis ketika penderitanya mengalami jatuh atau cedera yang menyebabkan patah tulang.',
      ),
      AdminArticleItem(
        id: '2',
        title: 'Jenis Osteoporosis dan Cara Mencegahnya',
        category: 'Pencegahan',
        date: '15 Okt 2026',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/kemenkes_hero.jpg',
        source: 'Kemenkes RI',
        description:
            'Memahami berbagai tipe osteoporosis serta langkah pencegahannya sejak dini.',
        content:
            'Osteoporosis terbagi menjadi tipe primer dan sekunder. Upaya pencegahan dapat dilakukan melalui asupan kalsium yang cukup, vitamin D harian, serta aktivitas fisik teratur yang menopang berat badan.',
      ),
      AdminArticleItem(
        id: '3',
        title: 'Pencegahan Osteoporosis Sejak Usia Muda',
        category: 'Gaya Hidup',
        date: '18 Okt 2026',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/afmc_hero.jpg',
        source: 'AFMC',
        description:
            'Kiat menjaga kepadatan tulang dan kebiasaan sehat bagi usia muda.',
        content:
            'Massa puncak tulang dicapai pada rentang usia 20-30 tahun. Membangun fondasi tulang yang kuat di masa muda adalah investasi terbaik untuk mencegah pengeroposan di hari tua.',
      ),
      AdminArticleItem(
        id: '4',
        title: 'Mitos dan Fakta Osteoporosis',
        category: 'Fakta Medis',
        date: '20 Okt 2026',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/mitos_fakta_hero.jpg',
        source: 'Holistic Bodyworks',
        description:
            'Meluruskan berbagai kesalahpahaman umum mengenai kesehatan tulang.',
        content:
            'Banyak orang mengira osteoporosis hanya menyerang lansia atau wanita saja. Faktanya, pria juga memiliki risiko mengalami pengeroposan tulang apabila memiliki gaya hidup sedenter atau defisiensi nutrisi.',
      ),
      AdminArticleItem(
        id: '5',
        title: 'Skrining & Deteksi Osteoporosis',
        category: 'Diagnosis',
        date: '22 Okt 2026',
        status: 'Dipublikasikan',
        imageAsset: 'assets/images/rspi_hero.jpg',
        source: 'RS Pondok Indah',
        description:
            'Pemeriksaan kepadatan tulang (DEXA scan) dan deteksi risiko fraktur.',
        content:
            'Dual-Energy X-ray Absorptiometry (DEXA scan) adalah baku emas untuk mengukur densitas massa tulang secara akurat dan menentukan tingkat risiko keparahan osteoporosis.',
      ),
    ]);
  }

  void addArticle(AdminArticleItem item) {
    _articles.insert(0, item);
    notifyListeners();
  }

  void updateArticle(AdminArticleItem updated) {
    final index = _articles.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _articles[index] = updated;
      notifyListeners();
    }
  }

  void deleteArticle(String id) {
    _articles.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  AdminArticleItem? getArticleById(String id) {
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

