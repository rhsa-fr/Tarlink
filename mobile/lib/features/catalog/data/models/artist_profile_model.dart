import 'package:mobile/core/utils/phone_masker.dart';

class ArtistProfileModel {
  final String id;
  final String userId;
  final String displayName;
  final String category;
  final String baseCity;
  final String? baseDistrict;
  final double? baseLat;
  final double? baseLng;
  final List<String> coverageCities;
  final String? description;
  final bool autoAccept;
  final int priceMin;
  final int priceMax;
  final double ratingAvg;
  final int totalJob;
  final List<String> videoUrls;
  final String status;
  final String? rawPhone;
  final String? avatarUrl;

  const ArtistProfileModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.category,
    required this.baseCity,
    this.baseDistrict,
    this.baseLat,
    this.baseLng,
    this.coverageCities = const [],
    this.description,
    this.autoAccept = false,
    this.priceMin = 0,
    this.priceMax = 0,
    this.ratingAvg = 0.0,
    this.totalJob = 0,
    this.videoUrls = const [],
    this.status = 'pending',
    this.rawPhone,
    this.avatarUrl,
  });

  String get maskedPhone => PhoneMasker.maskPhone(rawPhone ?? '', isDpPaid: false);

  String get categoryDisplay {
    switch (category) {
      case 'sandiwara-full':
        return 'Sandiwara Pantura Full';
      case 'tarling-dangdut':
        return 'Tarling Dangdut Kombinasi';
      case 'organ-tunggal':
        return 'Organ Tunggal / Mini';
      case 'biduan-solo':
        return 'Biduan Solo';
      case 'mc-pranatacara':
        return 'MC / Pranata Cara';
      default:
        return category;
    }
  }

  factory ArtistProfileModel.fromJson(Map<String, dynamic> json) {
    return ArtistProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      category: json['category'] as String,
      baseCity: json['base_city'] as String,
      baseDistrict: json['base_district'] as String?,
      baseLat: json['base_lat'] != null ? (json['base_lat'] as num).toDouble() : null,
      baseLng: json['base_lng'] != null ? (json['base_lng'] as num).toDouble() : null,
      coverageCities: (json['coverage_cities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description'] as String?,
      autoAccept: json['auto_accept'] as bool? ?? false,
      priceMin: json['price_min'] as int? ?? 0,
      priceMax: json['price_max'] as int? ?? 0,
      ratingAvg: json['rating_avg'] != null ? (json['rating_avg'] as num).toDouble() : 0.0,
      totalJob: json['total_job'] as int? ?? 0,
      videoUrls: (json['video_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String? ?? 'pending',
      rawPhone: json['phone'] as String? ?? json['masked_phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
