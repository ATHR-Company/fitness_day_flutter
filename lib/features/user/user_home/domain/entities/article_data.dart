class ArticleDetail {
  final String title;
  final String description;
  final int order;

  const ArticleDetail({
    required this.title,
    required this.description,
    required this.order,
  });
}

class ArticleData {
  final String id;
  final String imageUrl;
  final String date;
  final int views;
  final String title;
  final bool isSaved;
  final List<ArticleDetail> details;
  final List<ArticleData> relatedArticles;

  const ArticleData({
    required this.id,
    required this.imageUrl,
    required this.date,
    required this.views,
    required this.title,
    required this.isSaved,
    required this.details,
    this.relatedArticles = const [],
  });

  String get body => details.map((e) => e.description).join('\n\n');
}
