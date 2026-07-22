import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';
import '../entities/favorites_page_data.dart';
import '../entities/store_home_data.dart';
import '../entities/products_page_data.dart';
import '../entities/product_data.dart';
import '../entities/plans_data.dart';

abstract class MarketRepository {
  Future<ApiResult<StoreHomeData>> getStoreHome();
  Future<ApiResult<ProductsPageData>> getProducts({
    required ProductsFilter filter,
    int page = 1,
    int limit = 10,
  });
  Future<ApiResult<ProductData>> getProductById(String id);
  Future<ApiResult<PlansData>> getPlans({int page = 1, int limit = 8});
  Future<ApiResult<PlanDetails>> getPlanById(String id);
  Future<ApiResult<bool>> toggleFavorite({
    required CartItemType itemType,
    required String itemIdentity,
  });

  Future<ApiResult<FavoritesPageData>> getFavorites({int page, int limit});
}
