import 'package:fitness_day/core/network/api_result.dart';
import '../entities/store_home_data.dart';
import '../repositories/market_repository.dart';

class GetStoreHomeUseCase {
  final MarketRepository repository;

  GetStoreHomeUseCase(this.repository);

  Future<ApiResult<StoreHomeData>> call() => repository.getStoreHome();
}
