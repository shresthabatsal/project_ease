import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/store/data/repositories/store_repository.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/domain/repositories/store_repository.dart';

final getNearestStoresUsecaseProvider = Provider<GetNearestStoresUsecase>(
  (ref) =>
      GetNearestStoresUsecase(repository: ref.read(storeRepositoryProvider)),
);

class GetNearestStoresParams extends Equatable {
  final double latitude;
  final double longitude;
  final double maxDistance;

  const GetNearestStoresParams({
    required this.latitude,
    required this.longitude,
    this.maxDistance = 50,
  });

  @override
  List<Object?> get props => [latitude, longitude, maxDistance];
}

class GetNearestStoresUsecase
    implements UsecaseWithParams<List<StoreEntity>, GetNearestStoresParams> {
  final IStoreRepository _repository;
  GetNearestStoresUsecase({required IStoreRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<StoreEntity>>> call(
    GetNearestStoresParams params,
  ) => _repository.getNearestStores(
    latitude: params.latitude,
    longitude: params.longitude,
    maxDistance: params.maxDistance,
  );
}
