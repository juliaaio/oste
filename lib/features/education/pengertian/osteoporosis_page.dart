import 'package:flutter/material.dart';
import '../articles/article_data.dart';
import '../articles/article_detail_page.dart';

/// Halaman detail osteoporosis yang menggunakan template [ArticleDetailPage]
/// untuk mencegah duplikasi kode di dalam folder education.
class OsteoporosisPage extends StatelessWidget {
  const OsteoporosisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleDetailPage(
      article: ArticleData.articles.firstWhere(
        (a) => a.id == 'mengenal-osteoporosis',
        orElse: () => ArticleData.articles.first,
      ),
    );
  }
}
