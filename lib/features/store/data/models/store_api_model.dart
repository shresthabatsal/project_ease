import 'package:project_ease/features/store/domain/entities/store_entity.dart';

class StoreApiModel {
  final String id;
  final String name;
  final String? location;
  final String? logo;
  final double? latitude;
  final double? longitude;
  final String? pickupInstructions;
  final double? distance;
  final String? paymentQrCode;

  StoreApiModel({
    required this.id,
    required this.name,
    this.location,
    this.logo,
    this.latitude,
    this.longitude,
    this.pickupInstructions,
    this.distance,
    this.paymentQrCode,
  });

  factory StoreApiModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>?;
    return StoreApiModel(
      id: json['_id'] ?? '',
      name: json['storeName'] ?? json['name'] ?? '',
      location: json['location'],
      logo: json['storeImage'] ?? json['logo'],
      latitude: (coords?['latitude'] as num?)?.toDouble(),
      longitude: (coords?['longitude'] as num?)?.toDouble(),
      pickupInstructions: json['pickupInstructions'],
      distance: (json['distance'] as num?)?.toDouble(),
      paymentQrCode: json['paymentQRCode'],
    );
  }

  StoreEntity toEntity() => StoreEntity(
    storeId: id,
    name: name,
    description: location,
    logo: logo,
    coordinates: (latitude != null && longitude != null)
        ? StoreCoordinates(latitude: latitude!, longitude: longitude!)
        : null,
    pickupInstructions: pickupInstructions,
    distance: distance,
    paymentQrCode: paymentQrCode,
  );
}
