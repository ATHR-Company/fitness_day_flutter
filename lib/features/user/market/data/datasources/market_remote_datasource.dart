import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import '../../domain/entities/products_page_data.dart';
import '../models/plan_details_model.dart';
import '../models/plans_model.dart';
import '../models/product_details_model.dart';
import '../models/products_page_model.dart';
import '../models/store_home_model.dart';

abstract class MarketRemoteDataSource {
  Future<StoreHomeModel> getStoreHome();
  Future<ProductsPageModel> getProducts({
    required ProductsFilter filter,
    int page = 1,
    int limit = 10,
  });
  Future<ProductDetailsModel> getProductById(String id);
  Future<PlansModel> getPlans({int page = 1, int limit = 8});
  Future<PlanDetailsModel> getPlanById(String id);
  Future<bool> toggleFavorite(String productIdentity);
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final ApiService apiService;

  MarketRemoteDataSourceImpl(this.apiService);

  @override
  Future<StoreHomeModel> getStoreHome() async {
    final response = await apiService.get(ApiEndpoints.storeHome);
    return StoreHomeModel.fromJson(response.data);
  }

  @override
  Future<ProductsPageModel> getProducts({
    required ProductsFilter filter,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};
    if (filter.type != null) {
      params['type'] = filter.type;
    } else if (filter.categoryId != null) {
      params['category'] = filter.categoryId;
    }
    final response = await apiService.get(
      ApiEndpoints.storeProducts,
      queryParameters: params,
    );
    return ProductsPageModel.fromJson(response.data);
  }

  @override
  Future<ProductDetailsModel> getProductById(String id) async {
    final response = await apiService.get(ApiEndpoints.storeProductById(id));
    return ProductDetailsModel.fromJson(response.data);
  }

  @override
  Future<PlansModel> getPlans({int page = 1, int limit = 8}) async {
    final response = await apiService.get(
      ApiEndpoints.storePlans,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PlansModel.fromJson(response.data);
  }

  @override
  Future<PlanDetailsModel> getPlanById(String id) async {
    final response = await apiService.get(ApiEndpoints.storePlanById(id));
    return PlanDetailsModel.fromJson(response.data);
  }

  @override
  Future<bool> toggleFavorite(String productIdentity) async {
    final response = await apiService.post(
      ApiEndpoints.storeFavorites,
      data: {'productIdentity': productIdentity},
    );
    return response.data['data']?['isFavorite'] ?? false;
  }
}
