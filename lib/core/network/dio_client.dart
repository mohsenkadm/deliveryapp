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

/// عميل Dio المركزي — يُدير التوكن واعتراضات المصادقة وأخطاء الشبكة.
///
/// متوافق مع DeliverySystem.API:
/// - JWT يُحقن في الترويسة `Authorization: Bearer ...`.
/// - لا يوجد refresh token. عند 401 يتم مسح الجلسة والتوجيه لشاشة تسجيل الدخول.
/// - الأخطاء تُحوَّل إلى `ApiException` مع قراءة `messageAr` من الردّ الموحَّد.
/// - يدعم 410 (نقطة دخول مهملة بديلة).
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_authInterceptor());

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

  /// اعتراض المصادقة — حقن التوكن + معالجة 401 / 403 / 410
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await _secureStorage.read(key: StorageKeys.accessToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        if (status == 401) {
          // التوكن منتهٍ أو غير صالح — مسح الجلسة والعودة لشاشة الدخول
          await _secureStorage.deleteAll();
          if (Get.currentRoute != '/login') {
            Get.offAllNamed('/login');
          }
        } else if (status == 403) {
          SnackbarHelper.showError('ليس لديك صلاحية للقيام بهذا الإجراء');
        } else if (status == 410) {
          SnackbarHelper.showError(
              'هذه الخدمة لم تعد متاحة. يرجى تحديث التطبيق');
        }
        return handler.next(error);
      },
    );
  }

  Dio get raw => _dio;

  // ── طرق HTTP ──

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path,
          queryParameters: queryParameters, options: options);
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
      return await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
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
      return await _dio.put(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// طلب PATCH — مستخدَم لتحديث حالة الفاتورة وتعليم الإشعار كمقروء
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(path,
          data: data, queryParameters: queryParameters, options: options);
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
      return await _dio.delete(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// تحويل أخطاء Dio إلى `ApiException`
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

  /// قراءة `messageAr` من ردّ ApiResponse الموحّد
  ApiException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    String message = 'حدث خطأ';
    if (response?.data is Map) {
      final m = response!.data as Map;
      message = (m['messageAr'] ??
              m['message'] ??
              m['title'] ??
              m['messageEn'] ??
              'حدث خطأ')
          .toString();
    }

    switch (statusCode) {
      case 400:
        return ApiException(
            message: message, statusCode: 400, data: response?.data);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ApiException(
            message: 'ليس لديك صلاحية للقيام بهذا الإجراء', statusCode: 403);
      case 404:
        return NotFoundException(message: message);
      case 410:
        return ApiException(
            message: 'هذه الخدمة لم تعد متاحة', statusCode: 410);
      case 422:
        return ApiException(
            message: message, statusCode: 422, data: response?.data);
      case 500:
        return ServerException();
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }
}
