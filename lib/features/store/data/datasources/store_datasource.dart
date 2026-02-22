import 'package:project_ease/features/store/data/models/store_api_model.dart';

abstract interface class IStoreRemoteDatasource {
  Future<List<StoreApiModel>> getAllStores();
  Future<StoreApiModel?> getStoreById(String id);
}
