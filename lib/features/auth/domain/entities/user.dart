// كيان المستخدم — طبقة المجال (Domain Layer)
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? address;
  final bool isApproved;
  final String? profileImage;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.isApproved = true,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, email, role];
}
