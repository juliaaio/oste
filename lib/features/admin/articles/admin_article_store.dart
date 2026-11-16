import '../../../services/article_repository.dart';
export '../../../services/article_repository.dart';

/// Store artikel admin yang menggunakan [ArticleRepository] tunggal.
/// Menghubungkan secara langsung CRUD Admin dengan data yang dibaca oleh Pasien.
typedef AdminArticleStore = ArticleRepository;
