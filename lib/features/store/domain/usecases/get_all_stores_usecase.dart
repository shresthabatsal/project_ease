import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/store/data/repositories/store_repository.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/domain/repositories/store_repository.dart';

final getAllStoresUsecaseProvider = Provider<GetAllStoresUsecase>(
  (ref) => GetAllStoresUsecase(repository: ref.read(storeRepositoryProvider)),
);

class GetAllStoresUsecase implements UsecaseWithoutParams<List<StoreEntity>> {
  final IStoreRepository _repository;
  GetAllStoresUsecase({required IStoreRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<StoreEntity>>> call() =>
      _repository.getAllStores();
}
