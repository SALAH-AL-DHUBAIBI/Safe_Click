class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final int scannedLinks;
  final int detectedThreats;
  final double accuracyRate;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.scannedLinks = 0,
    this.detectedThreats = 0,
    this.accuracyRate = 0.0,
    this.isEmailVerified = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'createdAt': createdAt.toIso8601String(),
        'scannedLinks': scannedLinks,
        'detectedThreats': detectedThreats,
        'accuracyRate': accuracyRate,
        'isEmailVerified': isEmailVerified,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profileImage: json['profileImage'],
        createdAt: DateTime.parse(json['createdAt']),
        scannedLinks: json['scannedLinks'] ?? 0,
        detectedThreats: json['detectedThreats'] ?? 0,
        accuracyRate: json['accuracyRate']?.toDouble() ?? 0.0,
        isEmailVerified: json['isEmailVerified'] ?? false,
      );

  UserModel copyWith({
    String? name,
    String? email,
    String? profileImage,
    int? scannedLinks,
    int? detectedThreats,
    double? accuracyRate,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      scannedLinks: scannedLinks ?? this.scannedLinks,
      detectedThreats: detectedThreats ?? this.detectedThreats,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
