import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/education/articles/article_data.dart';
import 'package:oste/features/education/articles/article_detail_page.dart';
import 'package:oste/features/education/pengertian/osteoporosis_page.dart';

void main() {
  group('Article Feature Tests', () {
    test('Semua artikel terdaftar dengan data lengkap dan unik', () {
      final articles = ArticleData.articles;
      expect(articles.length, 5);

      final titles = articles.map((a) => a.title).toSet();
      expect(titles.length, 5, reason: 'Setiap artikel harus memiliki judul berbeda');

      final ids = articles.map((a) => a.id).toSet();
      expect(ids.length, 5, reason: 'Setiap artikel harus memiliki ID unik');

      for (final a in articles) {
        expect(a.title.isNotEmpty, true);
        expect(a.url.isNotEmpty, true);
        expect(a.source.isNotEmpty, true);
        expect(a.sections.isNotEmpty, true);
        expect(a.sourceActionLabel.isNotEmpty, true);
        expect(a.heroAssetPath.isNotEmpty, true);
      }
    });

    test('Artikel Mengenal Osteoporosis mencakup seluruh materi medis yang disyaratkan', () {
      final article = ArticleData.articles.firstWhere(
        (a) => a.id == 'mengenal-osteoporosis',
      );

      expect(article.source, 'Alodokter');
      expect(article.url, 'https://www.alodokter.com/osteoporosis');
      expect(article.sections.length, 9);

      final sectionTitles = article.sections.map((s) => s.title.toLowerCase()).toList();
      expect(sectionTitles.any((t) => t.contains('pengertian')), true);
      expect(sectionTitles.any((t) => t.contains('penyebab')), true);
      expect(sectionTitles.any((t) => t.contains('faktor risiko')), true);
      expect(sectionTitles.any((t) => t.contains('gejala')), true);
      expect(sectionTitles.any((t) => t.contains('kapan harus ke dokter')), true);
      expect(sectionTitles.any((t) => t.contains('diagnosis')), true);
      expect(sectionTitles.any((t) => t.contains('pengobatan')), true);
      expect(sectionTitles.any((t) => t.contains('komplikasi')), true);
      expect(sectionTitles.any((t) => t.contains('pencegahan')), true);

      // Pastikan ada kotak konsultasi dokter dan diagnosis box
      final docSec = article.sections.firstWhere((s) => s.doctorConsultation != null);
      expect(docSec.doctorConsultation!.highlightedSource, 'ALODOKTER');

      final diagSec = article.sections.firstWhere((s) => s.diagnosisBox != null);
      expect(diagSec.diagnosisBox!.procedures.isNotEmpty, true);
      expect(diagSec.diagnosisBox!.tScores.length, 3);
    });

    testWidgets('ArticleDetailPage me-render elemen visual sesuai spesifikasi desain', (tester) async {
      final article = ArticleData.articles.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleDetailPage(article: article),
        ),
      );
      await tester.pumpAndSettle();

      // Periksa Header AppBar
      expect(find.widgetWithText(AppBar, article.appBarTitle), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Periksa Judul Seksi
      expect(find.text('1.  Pengertian Osteoporosis'), findsOneWidget);
      expect(find.text('2.  Penyebab Osteoporosis'), findsOneWidget);
      expect(find.text('3.  Faktor Risiko Osteoporosis'), findsOneWidget);

      // Periksa Kartu Faktor Risiko
      expect(find.text('Faktor Risiko yang Tidak Dapat Dimodifikasi'), findsOneWidget);
      expect(find.text('Faktor Risiko yang Dapat Dimodifikasi'), findsOneWidget);

      // Periksa Tautan Sumber
      expect(find.text(article.sourceActionLabel), findsOneWidget);
    });

    testWidgets('OsteoporosisPage me-render ArticleDetailPage dengan benar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OsteoporosisPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ArticleDetailPage), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Osteoporosis'), findsOneWidget);
      expect(find.text('1.  Pengertian Osteoporosis'), findsOneWidget);
    });

    test('Artikel Holistic Bodyworks Mitos dan Fakta Osteoporosis terkonfigurasi dengan benar', () {
      final article = ArticleData.articles.firstWhere(
        (a) => a.id == 'mitos-dan-fakta-osteoporosis',
      );

      expect(article.source, 'Holistic Bodyworks');
      expect(article.title, 'Mitos dan Fakta Osteoporosis');
      expect(
        article.url,
        'https://www-holisticbodyworks-com-au.translate.goog/osteoporosis-myths-and-facts/?_x_tr_sl=en&_x_tr_tl=id&_x_tr_hl=id&_x_tr_pto=tc',
      );
      expect(article.sections.length, 5);

      final sectionTitles = article.sections.map((s) => s.title).toList();
      expect(sectionTitles[0], 'Apa Itu Osteoporosis?');
      expect(sectionTitles[1], 'Mitos 1 & 2: Jenis Kelamin dan Ras');
      expect(sectionTitles[2], 'Mitos 3 & 4: Dampak Tubuh & Risiko Fraktur');
      expect(sectionTitles[3], 'Mitos 5 & 6: Rasa Sakit & Waktu Pencegahan');
      expect(sectionTitles[4], 'Bertindak Lebih Dini Bersama Holistic Bodyworks');
    });

    test('Artikel AFMC Pencegahan Osteoporosis Sejak Usia Muda terkonfigurasi dengan benar', () {
      final article = ArticleData.articles.firstWhere(
        (a) => a.id == 'pencegahan-osteoporosis-afmc',
      );

      expect(article.source, 'AFMC');
      expect(article.title, 'Pencegahan Osteoporosis Sejak Usia Muda');
      expect(
        article.description,
        'Pelajari langkah pencegahan osteoporosis sejak dini untuk menjaga kesehatan dan kekuatan tulang.',
      );
      expect(
        article.url,
        'https://www-afmc-org.translate.goog/blog/start-young-to-prevent-osteoporosis?_x_tr_sl=en&_x_tr_tl=id&_x_tr_hl=id&_x_tr_pto=tc',
      );
      expect(article.sourceActionLabel, 'Baca Artikel Asli');
      expect(article.heroAssetPath, 'assets/images/afmc_hero.jpg');
      expect(article.sections.length, 5);

      final sectionTitles = article.sections.map((s) => s.title).toList();
      expect(sectionTitles[0], 'Mengapa Pencegahan Harus Dimulai Sejak Usia Muda?');
      expect(sectionTitles[1], 'Puncak Massa Tulang (Peak Bone Mass / PBM)');
      expect(sectionTitles[2], 'Tulang Rapuh, Risiko Fraktur & Pemulihan Lambat');
      expect(sectionTitles[3], 'Langkah Nyata Pencegahan Osteoporosis dari AFMC');
      expect(sectionTitles[4], 'Kapan Harus Menjalani Skrining Osteoporosis?');
    });

    test('Artikel RS Pondok Indah Skrining & Deteksi Osteoporosis terkonfigurasi dengan benar', () {
      final article = ArticleData.articles.firstWhere(
        (a) => a.id == 'skrining-dan-deteksi-osteoporosis-rspi',
      );

      expect(article.source, 'RS Pondok Indah');
      expect(article.title, 'Skrining & Deteksi Osteoporosis');
      expect(
        article.description,
        'Pelajari faktor risiko, skrining dini, dan pemeriksaan kepadatan tulang untuk mendeteksi osteoporosis.',
      );
      expect(
        article.url,
        'https://www.rspondokindah.co.id/id/news/deteksi-dan-cegah-osteoporosis',
      );
      expect(article.sourceActionLabel, 'Baca Artikel Asli');
      expect(article.heroAssetPath, 'assets/images/rspi_hero.jpg');
      expect(article.sections.length, 5);

      final sectionTitles = article.sections.map((s) => s.title).toList();
      expect(sectionTitles[0], 'Pengertian & Karakteristik Silent Disease');
      expect(sectionTitles[1], 'Faktor Risiko Osteoporosis');
      expect(sectionTitles[2], 'Pentingnya Skrining Dini & Frekuensi Pemeriksaan');
      expect(sectionTitles[3], 'Metode Pemeriksaan BMD / DEXA');
      expect(sectionTitles[4], 'Cara Menjaga Kesehatan Tulang & Pencegahan Fraktur');

      // Pastikan ada kotak diagnosis T-Score & konsultasi dokter RS Pondok Indah
      final bmdSec = article.sections[3];
      expect(bmdSec.diagnosisBox, isNotNull);
      expect(bmdSec.diagnosisBox!.procedures.length, 3);
      expect(bmdSec.diagnosisBox!.tScores.length, 3);

      final consultSec = article.sections[4];
      expect(consultSec.doctorConsultation, isNotNull);
      expect(consultSec.doctorConsultation!.highlightedSource, 'RS PONDOK INDAH');
    });

    test('Artikel Kemenkes Jenis Osteoporosis dan Cara Mencegahnya terkonfigurasi dengan benar', () {
      final article = ArticleData.articles.firstWhere(
        (a) => a.id == 'jenis-osteoporosis-dan-cara-mencegahnya',
      );

      expect(article.source, 'Kementerian Kesehatan RI');
      expect(article.title, 'Jenis Osteoporosis dan Cara Mencegahnya');
      expect(
        article.description,
        'Kenali jenis-jenis osteoporosis dan langkah pencegahannya untuk menjaga kesehatan tulang.',
      );
      expect(
        article.url,
        'https://keslan.kemkes.go.id/view_artikel/3179/apa-saja-jenis-osteoporosis-dan-cara-mencegahnya',
      );
      expect(article.sourceActionLabel, 'Baca Artikel Asli');
      expect(article.heroAssetPath, 'assets/images/kemenkes_hero.jpg');
      expect(article.sections.length, 5);

      final sectionTitles = article.sections.map((s) => s.title).toList();
      expect(sectionTitles[0], 'Pengertian Osteoporosis');
      expect(sectionTitles[1], 'Karakteristik Osteoporosis');
      expect(sectionTitles[2], 'Jenis Osteoporosis');
      expect(sectionTitles[3], 'Gejala Osteoporosis');
      expect(sectionTitles[4], 'Cara Mencegah Osteoporosis');

      // Pastikan tidak ada T-score / diagnosis box / doctor consultation
      for (final s in article.sections) {
        expect(s.diagnosisBox, isNull);
        expect(s.doctorConsultation, isNull);
      }

      // Pastikan ada subjudul primer & sekunder di seksi 3
      final sec3 = article.sections[2];
      expect(sec3.paragraphs.any((p) => p.contains('1. Osteoporosis Primer')), true);
      expect(sec3.paragraphs.any((p) => p.contains('2. Osteoporosis Sekunder')), true);

      // Pastikan ada daftar bernomor di seksi 4
      final sec4 = article.sections[3];
      expect(sec4.paragraphs.any((p) => p.contains('1.  Tinggi badan berkurang')), true);
      expect(sec4.paragraphs.any((p) => p.contains('2.  Bungkuk atau bentuk tubuh berubah')), true);
      expect(sec4.paragraphs.any((p) => p.contains('3.  Patah tulang')), true);
      expect(sec4.paragraphs.any((p) => p.contains('4.  Nyeri bila ada patah tulang')), true);
    });

    testWidgets('ArticleDetailPage me-render subjudul dan daftar bernomor Kemenkes dengan benar', (tester) async {
      final article = ArticleData.articles.firstWhere(
        (a) => a.id == 'jenis-osteoporosis-dan-cara-mencegahnya',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleDetailPage(article: article),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1.  Pengertian Osteoporosis'), findsOneWidget);
      expect(find.text('2.  Karakteristik Osteoporosis'), findsOneWidget);
      expect(find.text('3.  Jenis Osteoporosis'), findsOneWidget);
      expect(find.text('4.  Gejala Osteoporosis'), findsOneWidget);
      expect(find.text('5.  Cara Mencegah Osteoporosis'), findsOneWidget);

      // Subjudul
      expect(find.text('1. Osteoporosis Primer'), findsOneWidget);
      expect(find.text('2. Osteoporosis Sekunder'), findsOneWidget);

      // Daftar bernomor
      expect(find.text('Tinggi badan berkurang.'), findsOneWidget);
      expect(find.text('Bungkuk atau bentuk tubuh berubah.'), findsOneWidget);
      expect(find.text('Patah tulang.'), findsOneWidget);
      expect(find.text('Nyeri bila ada patah tulang.'), findsOneWidget);

      // Tombol Baca Artikel Asli
      expect(find.text('Baca Artikel Asli'), findsOneWidget);
    });

    test('Ketiga artikel (Kemenkes, AFMC, Holistic Bodyworks) memiliki asset gambar yang sesuai dan tidak tertukar', () {
      final kemenkes = ArticleData.articles.firstWhere((a) => a.id == 'jenis-osteoporosis-dan-cara-mencegahnya');
      final afmc = ArticleData.articles.firstWhere((a) => a.id == 'pencegahan-osteoporosis-afmc');
      final mitos = ArticleData.articles.firstWhere((a) => a.id == 'mitos-dan-fakta-osteoporosis');

      expect(kemenkes.heroAssetPath, 'assets/images/kemenkes_hero.jpg');
      expect(afmc.heroAssetPath, 'assets/images/afmc_hero.jpg');
      expect(mitos.heroAssetPath, 'assets/images/mitos_fakta_hero.jpg');
    });
  });
}
