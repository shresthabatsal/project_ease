import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/domain/usecases/get_all_stores_usecase.dart';
import 'package:project_ease/features/store/domain/usecases/get_nearest_store_usecase.dart';
import 'package:project_ease/features/store/presentation/state/store_state.dart';

final storeViewModelProvider = NotifierProvider<StoreViewModel, StoreState>(() {
  return StoreViewModel();
});

class StoreViewModel extends Notifier<StoreState> {
  late final GetAllStoresUsecase _getAllStores;
  late final GetNearestStoresUsecase _getNearestStores;

  @override
  StoreState build() {
    _getAllStores = ref.read(getAllStoresUsecaseProvider);
    _getNearestStores = ref.read(getNearestStoresUsecaseProvider);
    Future.microtask(() => fetchStores());
    return const StoreState();
  }

  Future<void> fetchStores() async {
    state = state.copyWith(status: StoreStatus.loading);
    final result = await _getAllStores();
    result.fold(
      (f) => state = state.copyWith(
        status: StoreStatus.error,
        errorMessage: f.message,
      ),
      (stores) => state = state.copyWith(
        status: StoreStatus.loaded,
        stores: stores,
        selectedStore: stores.isNotEmpty ? stores.first : null,
      ),
    );
  }

  Future<void> fetchNearestStores({
    required double latitude,
    required double longitude,
    double maxDistance = 50,
  }) async {
    state = state.copyWith(status: StoreStatus.loading);
    final result = await _getNearestStores(
      GetNearestStoresParams(
        latitude: latitude,
        longitude: longitude,
        maxDistance: maxDistance,
      ),
    );
    result.fold(
      (f) => state = state.copyWith(
        status: StoreStatus.error,
        errorMessage: f.message,
      ),
      (nearest) => state = state.copyWith(
        status: StoreStatus.loaded,
        nearestStores: nearest,
      ),
    );
  }

  void selectStore(StoreEntity store) =>
      state = state.copyWith(selectedStore: store);
}
