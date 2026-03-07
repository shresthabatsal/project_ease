import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final submitReceiptUsecaseProvider = Provider<SubmitReceiptUsecase>(
  (ref) => SubmitReceiptUsecase(ref.read(orderRepositoryProvider)),
);

class SubmitReceiptParams {
  final String orderId;
  final String receiptImagePath;
  final String? paymentMethod;
  final String? notes;
  const SubmitReceiptParams({
    required this.orderId,
    required this.receiptImagePath,
    this.paymentMethod,
    this.notes,
  });
}

class SubmitReceiptUsecase
    implements UsecaseWithParams<void, SubmitReceiptParams> {
  final IOrderRepository _repo;
  SubmitReceiptUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(SubmitReceiptParams params) =>
      _repo.submitReceipt(
        orderId: params.orderId,
        receiptImagePath: params.receiptImagePath,
        paymentMethod: params.paymentMethod,
        notes: params.notes,
      );
}
