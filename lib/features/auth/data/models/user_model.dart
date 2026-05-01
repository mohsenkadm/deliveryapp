// نموذج المستخدم واستجابة المصادقة — تحويل JSON
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.role,
    super.address,
    super.isApproved,
    super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      address: json['address'],
      isApproved: json['isApproved'] ?? true,
      profileImage: json['profileImage'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'address': address,
        'isApproved': isApproved,
        'profileImage': profileImage,
      };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? json),
    );
  }
}
