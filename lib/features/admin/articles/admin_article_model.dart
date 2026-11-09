/// Model data artikel untuk kebutuhan manajemen konten oleh Admin
class AdminArticleItem {
  final String id;
  String title;
  String category;
  String date;
  String status; // 'Dipublikasikan' atau 'Draft'
  String imageAsset;
  String description;
  String content;
  String source;

  AdminArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.status = 'Dipublikasikan',
    required this.imageAsset,
    this.description = '',
    this.content = '',
    this.source = 'Osteo Admin',
  });

  bool get isPublished => status.toLowerCase() == 'dipublikasikan' || status.toLowerCase() == 'published';

  AdminArticleItem copyWith({
    String? id,
    String? title,
    String? category,
    String? date,
    String? status,
    String? imageAsset,
    String? description,
    String? content,
    String? source,
  }) {
    return AdminArticleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      status: status ?? this.status,
      imageAsset: imageAsset ?? this.imageAsset,
      description: description ?? this.description,
      content: content ?? this.content,
      source: source ?? this.source,
    );
  }
}

