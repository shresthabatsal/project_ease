import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final String storeId;
  final String name;
  final String? description;
  final String? logo;

  const StoreEntity({
    required this.storeId,
    required this.name,
    this.description,
    this.logo,
  });

  @override
  List<Object?> get props => [storeId, name, description, logo];
}
