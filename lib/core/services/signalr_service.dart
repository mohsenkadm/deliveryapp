// خدمة الإشعارات الفورية عبر SignalR
//
// تتصل بـ /hubs/notifications من DeliverySystem.API. يتم إرسال JWT عبر
// `accessTokenFactory` (الطريقة الموصى بها في الوثائق).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../utils/snackbar_helper.dart';

class SignalRService extends GetxService {
  static SignalRService get to => Get.find<SignalRService>();

  HubConnection? _connection;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final isConnected = false.obs;
  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  // Manual capped retry — exponential backoff capped at 30s, max 5 attempts.
  static const _maxRetries = 5;
  int _retryCount = 0;
  Timer? _retryTimer;
  bool _disposed = false;

  /// تهيئة الاتصال بـ SignalR — يجب استدعاؤها بعد نجاح تسجيل الدخول.
  Future<void> connect() async {
    if (_disposed) return;
    try {
      final token = await _storage.read(key: StorageKeys.accessToken);
      if (token == null || token.isEmpty) {
        debugPrint('[SignalR] no token — skipping connect');
        return;
      }

      final hubUrl = '${ApiConstants.baseUrl}${ApiConstants.signalRHub}';

      _connection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              logMessageContent: false,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // الحدث الرسمي من الواجهة الجديدة
      _connection!.on('ReceiveNotification', _onNotification);

      _connection!.onclose(({error}) {
        debugPrint('[SignalR] closed: $error');
        isConnected.value = false;
        _scheduleReconnect();
      });
      _connection!.onreconnecting(({error}) {
        debugPrint('[SignalR] reconnecting: $error');
        isConnected.value = false;
      });
      _connection!.onreconnected(({connectionId}) {
        debugPrint('[SignalR] reconnected: $connectionId');
        isConnected.value = true;
        _retryCount = 0;
      });

      await _connection!.start();
      isConnected.value = true;
      _retryCount = 0;
      debugPrint('[SignalR] connected');
    } catch (e, st) {
      debugPrint('[SignalR] connect failed: $e');
      debugPrintStack(stackTrace: st);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    if (_retryCount >= _maxRetries) {
      debugPrint('[SignalR] giving up after $_maxRetries attempts');
      return;
    }
    final delaySeconds = math.min(30, math.pow(2, _retryCount).toInt());
    _retryCount++;
    debugPrint(
        '[SignalR] reconnecting in ${delaySeconds}s (attempt $_retryCount/$_maxRetries)');
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), connect);
  }

  void _onNotification(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final raw = args[0];
    if (raw is! Map) return;
    final data = Map<String, dynamic>.from(raw);

    notifications.insert(0, data);
    unreadCount.value++;

    final title = (data['title'] ?? 'إشعار جديد').toString();
    final body = (data['body'] ?? '').toString();
    SnackbarHelper.showInfo('$title\n$body');
  }

  void markAllRead() {
    unreadCount.value = 0;
  }

  Future<void> disconnect() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    try {
      await _connection?.stop();
    } catch (e) {
      debugPrint('[SignalR] disconnect error: $e');
    }
    isConnected.value = false;
  }

  @override
  void onClose() {
    _disposed = true;
    disconnect();
    super.onClose();
  }
}
