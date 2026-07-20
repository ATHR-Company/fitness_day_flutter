import '../../domain/entities/address_data.dart';

class AddressModel {
  final String id;
  final String title;
  final String district;
  final String street;
  final String postalCode;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.district,
    required this.street,
    required this.postalCode,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      district: json['district'] ?? '',
      street: json['street'] ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] ?? false,
    );
  }

  AddressData toEntity() {
    return AddressData(
      id: id,
      title: title,
      district: district,
      street: street,
      postalCode: postalCode,
      lat: lat,
      lng: lng,
      isDefault: isDefault,
    );
  }
}
