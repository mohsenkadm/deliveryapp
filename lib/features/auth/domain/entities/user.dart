// كيان المستخدم — طبقة المجال (Domain Layer)
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;

  /// الدور الأساسي (أول قيمة من قائمة `roles`)
  final String role;

  /// قائمة كل أدوار المستخدم — موظف واحد قد يحمل عدة أدوار في نفس الوقت
  final List<String> roles;

  final String? address;
  final bool isApproved;
  final String? profileImage;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.roles = const [],
    this.address,
    this.isApproved = true,
    this.profileImage,
  });

  /// هل يحمل المستخدم الدور المحدّد (بغضّ النظر عن باقي الأدوار)
  bool hasRole(String r) =>
      role.toLowerCase() == r.toLowerCase() ||
      roles.any((e) => e.toLowerCase() == r.toLowerCase());

  bool get isMultiRole => roles.length > 1;

  @override
  List<Object?> get props => [id, email, role, roles];
}
