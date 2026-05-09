// نموذج طلب تسجيل الدخول
//
// الواجهة الموحّدة الجديدة تستقبل دائماً { username, password }
// لجميع نقاط الدخول الثلاث (admin / customer / employee).
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}
