import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/domain/usecases/get_all_stores_usecase.dart';
import 'package:project_ease/features/store/domain/usecases/get_nearest_store_usecase.dart';
import 'package:project_ease/features/store/presentation/state/store_state.dart';

final storeViewModelProvider = NotifierProvider<StoreViewModel, StoreState>(() {
  return StoreViewModel();
});

const _kLastStoreIdKey = 'last_selected_store_id';
const _kStoresKey = 'cached_stores';

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

    final prefs = await SharedPreferences.getInstance();
    final lastStoreId = prefs.getString(_kLastStoreIdKey);

    final result = await _getAllStores();
    result.fold(
      (f) async {
        debugPrint('🔴 fetchStores failed: ${f.message}');
        // Try loading from cache
        final cachedJson = prefs.getString(_kStoresKey);
        if (cachedJson != null) {
          try {
            final List decoded = jsonDecode(cachedJson) as List;
            final stores = decoded
                .map((e) => StoreEntity.fromJson(e as Map<String, dynamic>))
                .toList();
            if (stores.isNotEmpty) {
              final selected = lastStoreId != null
                  ? stores.firstWhere(
                      (s) => s.storeId == lastStoreId,
                      orElse: () => stores.first,
                    )
                  : stores.first;
              debugPrint(
                '📦 Stores from cache: ${stores.length}, selected: ${selected.name}',
              );
              state = state.copyWith(
                status: StoreStatus.loaded,
                stores: stores,
                selectedStore: selected,
              );
              return;
            }
          } catch (e) {
            debugPrint('❌ Store cache parse error: $e');
          }
        }
        state = state.copyWith(
          status: StoreStatus.error,
          errorMessage: f.message,
        );
      },
      (stores) async {
        if (stores.isEmpty) {
          state = state.copyWith(status: StoreStatus.loaded, stores: []);
          return;
        }

        // Save to cache
        try {
          final encoded = jsonEncode(stores.map((s) => s.toJson()).toList());
          await prefs.setString(_kStoresKey, encoded);
        } catch (e) {
          debugPrint('⚠️ Could not cache stores: $e');
        }

        final selected = lastStoreId != null
            ? stores.firstWhere(
                (s) => s.storeId == lastStoreId,
                orElse: () => stores.first,
              )
            : stores.first;

        state = state.copyWith(
          status: StoreStatus.loaded,
          stores: stores,
          selectedStore: selected,
        );
      },
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

  void selectStore(StoreEntity store) {
    state = state.copyWith(selectedStore: store);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_kLastStoreIdKey, store.storeId),
    );
  }
}
