import 'package:project_ease/features/store/domain/entities/store_entity.dart';

class StoreApiModel {
  final String id;
  final String name;
  final String? description;
  final String? logo;

  StoreApiModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
  });

  factory StoreApiModel.fromJson(Map<String, dynamic> json) {
    return StoreApiModel(
      id: json['_id'] ?? '',
      name: json['storeName'] ?? '',
      description: json['description'],
      logo: json['logo'],
    );
  }

  StoreEntity toEntity() {
    return StoreEntity(
      storeId: id,
      name: name,
      description: description,
      logo: logo,
    );
  }
}
