import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../constants/storage_keys.dart';
import '../utils/snackbar_helper.dart';
import 'api_exception.dart';

/// عميل Dio المركزي — يُدير التوكن والاعتراضات وأخطاء الشبكة
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_authInterceptor());

    // تفعيل سجل الطلبات في وضع التطوير فقط
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
      ));
    }
  }

  /// اعتراض المصادقة — إضافة التوكن + معالجة 401 و 403
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: StorageKeys.accessToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // محاولة تحديث التوكن
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _secureStorage.read(key: StorageKeys.accessToken);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } else {
            // فشل التحديث — تسجيل الخروج والتوجيه لصفحة الأدوار
            await _secureStorage.deleteAll();
            Get.offAllNamed('/role-selection');
          }
        } else if (error.response?.statusCode == 403) {
          // عرض رسالة عدم الصلاحية
          SnackbarHelper.showError('ليس لديك صلاحية للقيام بهذا الإجراء');
        }
        return handler.next(error);
      },
    );
  }

  /// تحديث التوكن باستخدام refreshToken
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(baseUrl: ApiConstants.baseUrl),
      ).post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _secureStorage.write(
          key: StorageKeys.accessToken,
          value: response.data['accessToken'],
        );
        await _secureStorage.write(
          key: StorageKeys.refreshToken,
          value: response.data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── طرق HTTP ──

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// طلب PATCH — يُستخدم لتحديث حالة الفاتورة
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// معالجة أخطاء Dio وتحويلها إلى ApiException
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionException(message: 'انتهت مهلة الاتصال');
      case DioExceptionType.connectionError:
        return ConnectionException();
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      default:
        return ApiException(message: 'حدث خطأ غير متوقع');
    }
  }

  /// معالجة أخطاء الاستجابة حسب رمز الحالة
  ApiException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final message = response?.data is Map
        ? (response?.data['messageAr'] ?? response?.data['message'] ?? response?.data['title'] ?? 'حدث خطأ')
        : 'حدث خطأ';

    switch (statusCode) {
      case 400:
        return ApiException(message: message, statusCode: 400, data: response?.data);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ApiException(message: 'ليس لديك صلاحية للقيام بهذا الإجراء', statusCode: 403);
      case 404:
        return NotFoundException(message: message);
      case 422:
        return ApiException(message: message, statusCode: 422, data: response?.data);
      case 500:
        return ServerException();
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }
}
