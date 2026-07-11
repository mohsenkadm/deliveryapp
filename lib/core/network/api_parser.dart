import 'package:dio/dio.dart';
import 'api_exception.dart';
import 'api_response.dart';

ApiException _apiException(Response response, ApiResponse<dynamic> api) {
  return ApiException(
    message: api.messageAr.isNotEmpty
        ? api.messageAr
        : (api.messageEn.isNotEmpty ? api.messageEn : 'حدث خطأ'),
    statusCode: response.statusCode,
  );
}

/// يستخرج `data` من ردّ ApiResponse الموحّد ويتحقق من `success`.
T parseApi<T>(Response response, T Function(dynamic data) parser) {
  final api = ApiResponse<T>.fromJson(response.data, parser);
  if (!api.success) {
    throw _apiException(response, api);
  }
  if (api.data == null) {
    throw ApiException(
      message: api.messageAr.isNotEmpty ? api.messageAr : 'لا توجد بيانات',
      statusCode: response.statusCode,
    );
  }
  return api.data as T;
}

/// مثل [parseApi] لكن يسمح بـ data = null (مثلاً POST بدون جسم راجع).
void parseApiVoid(Response response) {
  if (response.data is Map<String, dynamic>) {
    final json = response.data as Map<String, dynamic>;
    if (json.containsKey('success') && json['success'] == false) {
      throw ApiException(
        message: (json['messageAr'] ?? json['messageEn'] ?? 'حدث خطأ')
            .toString(),
        statusCode: response.statusCode,
      );
    }
  }
}

/// يستخرج قائمة من `data` مع التحقق من success.
/// يعامل `data: null` كقائمة فارغة.
List<Map<String, dynamic>> parseApiList(Response response) {
  final api = ApiResponse<List<Map<String, dynamic>>>.fromJson(
    response.data,
    (data) {
      if (data == null) return const <Map<String, dynamic>>[];
      if (data is! List) return const <Map<String, dynamic>>[];
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    },
  );
  if (!api.success) {
    throw _apiException(response, api);
  }
  return api.data ?? const [];
}

/// يستخرج خريطة من `data` مع التحقق من success.
Map<String, dynamic> parseApiMap(Response response) {
  return parseApi<Map<String, dynamic>>(response, (data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  });
}
