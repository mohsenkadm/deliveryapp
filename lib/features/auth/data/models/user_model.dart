// نموذج المستخدم واستجابة المصادقة — تحويل JSON
//
// ملاحظات:
// - الموظف الواحد قد يحمل عدة أدوار في نفس الوقت (Roles: "Driver,Representative").
// - استجابة `AuthResponseDto` تحتوي على:
//     userId, username, fullName, role (الدور الأساسي), roles[] (الكامل), token
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.role,
    super.roles,
    super.address,
    super.isApproved,
    super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final roles = <String>[];
    if (rolesRaw is List) {
      roles.addAll(rolesRaw.map((e) => e.toString()));
    } else if (rolesRaw is String && rolesRaw.isNotEmpty) {
      roles.addAll(rolesRaw.split(',').map((e) => e.trim()));
    }
    final primaryRole = (json['role']?.toString() ??
            (roles.isNotEmpty ? roles.first : ''))
        .toString();
    if (roles.isEmpty && primaryRole.isNotEmpty) roles.add(primaryRole);

    return UserModel(
      id: (json['id'] ?? json['userId'])?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      role: primaryRole,
      roles: roles,
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
        'roles': roles,
        'address': address,
        'isApproved': isApproved,
        'profileImage': profileImage,
      };
}

/// استجابة `AuthResponseDto` كما يُرجعها الخادم.
///
/// شكل الاستجابة:
/// { userId, username, fullName, role, roles:[...], token }
/// لا يوجد `refreshToken` في هذه الواجهة — التوكن صالح 7 أيام.
class AuthResponse {
  final String accessToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // قد تكون البيانات داخل `data` أو منبسطة في الجذر
    final src = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final token = (src['token'] ?? src['accessToken'] ?? '').toString();
    final username = (src['username'] ?? '').toString();
    return AuthResponse(
      accessToken: token,
      user: UserModel.fromJson({
        ...src,
        // مرّر username كـ phone احتياطياً للحفاظ على واجهة User القديمة
        'phone': src['phone'] ?? src['phoneNumber'] ?? username,
      }),
    );
  }
}
