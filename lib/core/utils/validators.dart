class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    // if (value.length < 6) {
    //   return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    // }
    return null;
  }

  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'هذا الحقل مطلوب';
      }
      if (value != password) {
        return 'كلمات المرور غير متطابقة';
      }
      return null;
    };
  }

  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(value) == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    return null;
  }
}
