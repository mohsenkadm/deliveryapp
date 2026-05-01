// نموذج طلب التسجيل
class RegisterRequest {
  final String fullName;
  final String username;
  final String password;
  final String phone;
  final String address;
  final String? representativeId;

  RegisterRequest({
    required this.fullName,
    required this.username,
    required this.password,
    required this.phone,
    required this.address,
    this.representativeId,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'username': username,
        'password': password,
        'phone': phone,
        'address': address,
        if (representativeId != null) 'representativeId': representativeId,
      };
}
