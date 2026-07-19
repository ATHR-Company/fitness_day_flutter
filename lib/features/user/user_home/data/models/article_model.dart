import 'package:intl/intl.dart';
import '../../domain/entities/article_data.dart';

class ArticleModel {
  final String id;
  final String title;
  final String mainPhoto;
  final List<dynamic> details;
  final String? publishedAt;
  final int viewsCount;
  final bool isSaved;
  final List<dynamic> relatedArticles;
  final List<dynamic> media;

  ArticleModel({
    required this.id,
    required this.title,
    required this.mainPhoto,
    required this.details,
    this.publishedAt,
    this.viewsCount = 0,
    this.isSaved = false,
    this.relatedArticles = const [],
    this.media = const [],
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      mainPhoto: json['mainPhoto'] ?? '',
      details: json['details'] ?? [],
      publishedAt: json['publishedAt'],
      viewsCount: json['viewsCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
      relatedArticles: json['relatedArticles'] ?? [],
      media: json['media'] ?? [],
    );
  }

  ArticleData toEntity() {
    String formattedDate = '';
    if (publishedAt != null && publishedAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(publishedAt!).toLocal();
        // E.g., '2026-07-05'
        formattedDate = DateFormat('yyyy-MM-dd', 'en').format(dt);
      } catch (e) {
        formattedDate = publishedAt!;
      }
    }

    final List<ArticleDetail> mappedDetails = details.map((e) {
      return ArticleDetail(
        title: e['title'] ?? '',
        description: e['description'] ?? '',
        order: e['order'] ?? 0,
      );
    }).toList();
    mappedDetails.sort((a, b) => a.order.compareTo(b.order));

    final List<ArticleData> mappedRelated = relatedArticles.map((e) {
      return ArticleData(
        id: e['id'] ?? '',
        title: e['title'] ?? '',
        imageUrl: e['mainPhoto'] ?? '',
        date: '',
        views: 0,
        isSaved: false,
        details: [],
        relatedArticles: [],
      );
    }).toList();

    final List<ArticleMediaItem> mappedMedia = media.map((e) {
      return ArticleMediaItem(
        url: e['url'] ?? '',
        type: e['type'] ?? 'PHOTO',
      );
    }).toList();

    return ArticleData(
      id: id,
      imageUrl: mainPhoto,
      date: formattedDate.isEmpty ? 'غير متوفر' : formattedDate,
      views: viewsCount,
      title: title,
      isSaved: isSaved,
      details: mappedDetails,
      relatedArticles: mappedRelated,
      media: mappedMedia,
    );
  }
}

class ArticleResponseModel {
  final List<ArticleModel> data;

  ArticleResponseModel({required this.data});

  factory ArticleResponseModel.fromJson(Map<String, dynamic> json) {
    return ArticleResponseModel(
      data: json['data'] != null 
          ? (json['data'] as List).map((e) => ArticleModel.fromJson(e)).toList() 
          : [],
    );
  }
}
