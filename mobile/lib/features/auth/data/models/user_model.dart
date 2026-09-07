/// App user model supporting multi-role access (customer, artist_owner, admin).
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role; // 'customer', 'artist_owner', 'admin'
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = 'customer',
    this.avatarUrl,
    this.isVerified = false,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isArtistOwner => role == 'artist_owner' || role == 'group_leader';
  bool get isCustomer => role == 'customer';
  String get fullName => name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Pengguna',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'customer',
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
