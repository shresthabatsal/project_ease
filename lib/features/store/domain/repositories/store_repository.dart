import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';

abstract interface class IStoreRepository {
  Future<Either<Failure, List<StoreEntity>>> getAllStores();
}
