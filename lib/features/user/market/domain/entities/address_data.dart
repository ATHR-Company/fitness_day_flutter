class AddressData {
  final String id;
  final String title;
  final String district;
  final String street;
  final String postalCode;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressData({
    required this.id,
    required this.title,
    required this.district,
    required this.street,
    required this.postalCode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });
}

/// Payload for creating/updating an address — no [id] since the server
/// assigns/keeps it.
class AddressInput {
  final String title;
  final String district;
  final String street;
  final String postalCode;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressInput({
    required this.title,
    required this.district,
    required this.street,
    required this.postalCode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });
}
