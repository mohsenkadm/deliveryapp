// نموذج طلب تسجيل الدخول
// يدعم تسجيل الدخول بـ username (موظفون) أو phone (عملاء)
class LoginRequest {
  final String? username;
  final String? phone;
  final String password;

  LoginRequest({this.username, this.phone, required this.password})
      : assert(username != null || phone != null,
            'Either username or phone must be provided');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'password': password};
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (username != null && username!.isNotEmpty) map['username'] = username;
    return map;
  }
}
