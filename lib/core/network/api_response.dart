// نموذج الردّ الموحَّد لكل نقاط واجهة DeliverySystem.API
//
// كل استجابة من الخادم تتبع هذا الشكل:
// { "success": true|false, "messageAr": "...", "messageEn": "...", "data": <T> }
//
// الاستخدام النموذجي داخل مصدر بيانات:
//   final res = await dio.get(...);
//   final api = ApiResponse<Map<String, dynamic>>.fromJson(
//     res.data, (d) => d as Map<String, dynamic>,
//   );
//   if (!api.success) throw ApiException(message: api.messageAr);
//   return api.data!;
class ApiResponse<T> {
  final bool success;
  final String messageAr;
  final String messageEn;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.messageAr,
    required this.messageEn,
    this.data,
  });

  /// يبني الكائن من JSON. يُمرَّر `parser` لتحويل قيمة `data` للنوع المطلوب.
  /// إذا كانت الاستجابة بدون التغليف فسيُعاد success=true مع `data = parser(json)`.
  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic data) parser,
  ) {
    if (json is Map<String, dynamic> &&
        (json.containsKey('success') ||
            json.containsKey('messageAr') ||
            json.containsKey('messageEn') ||
            json.containsKey('data'))) {
      final raw = json['data'];
      return ApiResponse<T>(
        success: json['success'] as bool? ?? true,
        messageAr: (json['messageAr'] ?? '').toString(),
        messageEn: (json['messageEn'] ?? '').toString(),
        data: raw == null ? null : parser(raw),
      );
    }
    // ردّ غير ملفوف — نُعامله كنجاح
    return ApiResponse<T>(
      success: true,
      messageAr: '',
      messageEn: '',
      data: parser(json),
    );
  }

  /// رسالة بحسب اللغة المختارة (عربي افتراضياً)
  String message({String locale = 'ar'}) =>
      locale.startsWith('ar') ? messageAr : messageEn;
}

/// مساعدات قصيرة لاستخراج `data` من ردّ `ApiResponse` بدون كود مكرر.
T? unwrap<T>(dynamic body) {
  if (body is Map<String, dynamic> && body.containsKey('data')) {
    return body['data'] as T?;
  }
  return body as T?;
}

/// مساعد لاستخراج قائمة من حقل `data`.
List<Map<String, dynamic>> unwrapList(dynamic body) {
  final raw = (body is Map<String, dynamic>) ? (body['data'] ?? body) : body;
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}
