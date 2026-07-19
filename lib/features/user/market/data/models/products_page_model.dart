import '../../domain/entities/products_page_data.dart';
import '../../domain/entities/store_home_data.dart';
import 'store_home_model.dart';

class ProductsPageModel {
  final List<StoreProductItem> products;
  final int total;
  final int page;
  final int limit;

  ProductsPageModel({
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ProductsPageModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? {};
    final list = outer['data'] as List? ?? [];

    return ProductsPageModel(
      products: StoreHomeModel.parseProductsList(list),
      total: outer['total'] as int? ?? 0,
      page: outer['page'] as int? ?? 1,
      limit: outer['limit'] as int? ?? 10,
    );
  }

  ProductsPageData toEntity() {
    return ProductsPageData(
      products: products,
      total: total,
      page: page,
      limit: limit,
    );
  }
}
