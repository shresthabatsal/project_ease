import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/domain/usecases/get_all_stores_usecase.dart';
import 'package:project_ease/features/store/presentation/state/store_state.dart';

final storeViewModelProvider = NotifierProvider<StoreViewModel, StoreState>(() {
  return StoreViewModel();
});

class StoreViewModel extends Notifier<StoreState> {
  late final GetAllStoresUsecase _getAllStoresUsecase;

  @override
  StoreState build() {
    _getAllStoresUsecase = ref.read(getAllStoresUsecaseProvider);
    Future.microtask(() => fetchStores());
    return const StoreState();
  }

  Future<void> fetchStores() async {
    state = state.copyWith(status: StoreStatus.loading);
    final result = await _getAllStoresUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: StoreStatus.error,
        errorMessage: failure.message,
      ),
      (stores) {
        state = state.copyWith(
          status: StoreStatus.loaded,
          stores: stores,
          selectedStore: stores.isNotEmpty ? stores.first : null,
        );
      },
    );
  }

  void selectStore(StoreEntity store) {
    state = state.copyWith(selectedStore: store);
  }
}
