class PackageModel {
  final String id;
  final String artistId;
  final String name;
  final int? durationHours;
  final int price; // Integer Rupiah
  final String? includes;
  final bool isActive;

  const PackageModel({
    required this.id,
    required this.artistId,
    required this.name,
    this.durationHours,
    required this.price,
    this.includes,
    this.isActive = true,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String,
      artistId: json['artist_id'] as String,
      name: json['name'] as String,
      durationHours: json['duration_hours'] as int?,
      price: json['price'] as int? ?? 0,
      includes: json['includes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class ZonePriceModel {
  final String id;
  final String packageId;
  final String zone; // Ring 1, Ring 2, Ring 3, Luar Kota
  final double? maxKm;
  final int extraPrice;

  const ZonePriceModel({
    required this.id,
    required this.packageId,
    required this.zone,
    this.maxKm,
    required this.extraPrice,
  });

  factory ZonePriceModel.fromJson(Map<String, dynamic> json) {
    return ZonePriceModel(
      id: json['id'] as String,
      packageId: json['package_id'] as String,
      zone: json['zone'] as String,
      maxKm: json['max_km'] != null ? (json['max_km'] as num).toDouble() : null,
      extraPrice: json['extra_price'] as int? ?? 0,
    );
  }
}
