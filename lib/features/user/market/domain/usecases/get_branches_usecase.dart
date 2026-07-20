import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_data.dart';
import '../repositories/checkout_repository.dart';

class GetBranchesUseCase {
  final CheckoutRepository repository;
  GetBranchesUseCase(this.repository);

  Future<ApiResult<List<BranchData>>> call() => repository.getBranches();
}
