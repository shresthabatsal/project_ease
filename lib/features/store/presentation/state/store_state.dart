import 'package:equatable/equatable.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';

enum StoreStatus { initial, loading, loaded, error }

class StoreState extends Equatable {
  final StoreStatus status;
  final List<StoreEntity> stores;
  final List<StoreEntity> nearestStores;
  final StoreEntity? selectedStore;
  final String? errorMessage;

  const StoreState({
    this.status = StoreStatus.initial,
    this.stores = const [],
    this.nearestStores = const [],
    this.selectedStore,
    this.errorMessage,
  });

  StoreState copyWith({
    StoreStatus? status,
    List<StoreEntity>? stores,
    List<StoreEntity>? nearestStores,
    StoreEntity? selectedStore,
    bool clearSelected = false,
    String? errorMessage,
  }) => StoreState(
    status: status ?? this.status,
    stores: stores ?? this.stores,
    nearestStores: nearestStores ?? this.nearestStores,
    selectedStore: clearSelected ? null : (selectedStore ?? this.selectedStore),
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    stores,
    nearestStores,
    selectedStore,
    errorMessage,
  ];
}
