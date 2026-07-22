import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/cart_data.dart';
import '../../domain/entities/favorites_page_data.dart';
import '../../domain/entities/product_data.dart';
import '../../domain/entities/products_page_data.dart';
import '../../domain/entities/store_home_data.dart';
import '../../domain/entities/plans_data.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_datasource.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;

  MarketRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<StoreHomeData>> getStoreHome() async {
    try {
      final model = await remoteDataSource.getStoreHome();
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch store home data'));
    }
  }

  @override
  Future<ApiResult<ProductsPageData>> getProducts({
    required ProductsFilter filter,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final model = await remoteDataSource.getProducts(
        filter: filter,
        page: page,
        limit: limit,
      );
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch products'));
    }
  }

  @override
  Future<ApiResult<ProductData>> getProductById(String id) async {
    try {
      final model = await remoteDataSource.getProductById(id);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch product details'));
    }
  }

  @override
  Future<ApiResult<PlansData>> getPlans({int page = 1, int limit = 8}) async {
    try {
      final model = await remoteDataSource.getPlans(page: page, limit: limit);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch plans'));
    }
  }

  @override
  Future<ApiResult<PlanDetails>> getPlanById(String id) async {
    try {
      final model = await remoteDataSource.getPlanById(id);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch plan details'));
    }
  }

  @override
  Future<ApiResult<bool>> toggleFavorite({
    required CartItemType itemType,
    required String itemIdentity,
  }) async {
    try {
      final isFavorite = await remoteDataSource.toggleFavorite(
        itemType: itemType,
        itemIdentity: itemIdentity,
      );
      return Success(isFavorite);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to toggle favourite'));
    }
  }

  @override
  Future<ApiResult<FavoritesPageData>> getFavorites({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final model = await remoteDataSource.getFavorites(page: page, limit: limit);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to load favourites'));
    }
  }
}
