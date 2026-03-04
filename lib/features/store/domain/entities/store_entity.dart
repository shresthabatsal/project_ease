import 'package:equatable/equatable.dart';

class StoreCoordinates extends Equatable {
  final double latitude;
  final double longitude;

  const StoreCoordinates({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class StoreEntity extends Equatable {
  final String storeId;
  final String name;
  final String? description;
  final String? logo;
  final StoreCoordinates? coordinates;
  final String? pickupInstructions;
  final double? distance;

  const StoreEntity({
    required this.storeId,
    required this.name,
    this.description,
    this.logo,
    this.coordinates,
    this.pickupInstructions,
    this.distance,
  });

  @override
  List<Object?> get props => [
    storeId,
    name,
    description,
    logo,
    coordinates,
    distance,
  ];
}
