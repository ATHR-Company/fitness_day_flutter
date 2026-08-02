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

class ArticleMediaItem {
  final String url;
  final String type; // 'PHOTO' or 'VIDEO'

  const ArticleMediaItem({required this.url, required this.type});

  bool get isVideo => type.toUpperCase() == 'VIDEO';
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
  final List<ArticleMediaItem> media;

  const ArticleData({
    required this.id,
    required this.imageUrl,
    required this.date,
    required this.views,
    required this.title,
    required this.isSaved,
    required this.details,
    this.relatedArticles = const [],
    this.media = const [],
  });

  String get body => details.map((e) => e.description).join('\n\n');

  /// Only the two fields that change after the article is first loaded — the
  /// view count the details screen increments, and the bookmark.
  ArticleData copyWith({int? views, bool? isSaved}) {
    return ArticleData(
      id: id,
      imageUrl: imageUrl,
      date: date,
      views: views ?? this.views,
      title: title,
      isSaved: isSaved ?? this.isSaved,
      details: details,
      relatedArticles: relatedArticles,
      media: media,
    );
  }
}
