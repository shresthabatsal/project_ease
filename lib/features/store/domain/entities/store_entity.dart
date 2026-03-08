import 'package:equatable/equatable.dart';

class StoreCoordinates extends Equatable {
  final double latitude;
  final double longitude;

  const StoreCoordinates({required this.latitude, required this.longitude});

  factory StoreCoordinates.fromJson(Map<String, dynamic> json) {
    return StoreCoordinates(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };

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
  final String? paymentQrCode;

  const StoreEntity({
    required this.storeId,
    required this.name,
    this.description,
    this.logo,
    this.coordinates,
    this.pickupInstructions,
    this.distance,
    this.paymentQrCode,
  });

  factory StoreEntity.fromJson(Map<String, dynamic> json) {
    return StoreEntity(
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logo: json['logo'],
      coordinates: json['coordinates'] != null
          ? StoreCoordinates.fromJson(
              json['coordinates'] as Map<String, dynamic>,
            )
          : null,
      pickupInstructions: json['pickupInstructions'],
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      paymentQrCode: json['paymentQrCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'name': name,
    if (description != null) 'description': description,
    if (logo != null) 'logo': logo,
    if (coordinates != null) 'coordinates': coordinates!.toJson(),
    if (pickupInstructions != null) 'pickupInstructions': pickupInstructions,
    if (distance != null) 'distance': distance,
    if (paymentQrCode != null) 'paymentQrCode': paymentQrCode,
  };

  @override
  List<Object?> get props => [
    storeId,
    name,
    description,
    logo,
    coordinates,
    distance,
    paymentQrCode,
  ];
}
