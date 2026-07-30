import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/payment_data.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<PaymentInitiation>> initiate(String orderIdentity) async {
    try {
      final model = await remoteDataSource.initiate(orderIdentity);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<PaymentStatusData>> getStatus(String orderIdentity) async {
    try {
      final model = await remoteDataSource.getStatus(orderIdentity);
      return Success(model.toEntity());
    } catch (e) {
      // The caller distinguishes a dropped connection (NetworkFailure — keep
      // polling) from a real rejection, so the raw failure is passed through.
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
