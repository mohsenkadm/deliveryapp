// خدمة الإشعارات الفورية عبر SignalR
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

  static const _maxRetries = 5;
  int _retryCount = 0;
  Timer? _retryTimer;
  bool _disposed = false;

  final _refreshCallbacks = <Future<void> Function()>[];

  /// تسجيل دالة تحديث تُستدعى عند وصول إشعار (من المتحكمات النشطة).
  void registerRefresh(Future<void> Function() callback) {
    if (!_refreshCallbacks.contains(callback)) {
      _refreshCallbacks.add(callback);
    }
  }

  void unregisterRefresh(Future<void> Function() callback) {
    _refreshCallbacks.remove(callback);
  }

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
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), connect);
  }

  void _onNotification(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final Map<String, dynamic> data;
    if (args[0] is Map) {
      data = Map<String, dynamic>.from(args[0] as Map);
    } else if (args.length >= 2) {
      data = {
        'title': args[0]?.toString() ?? 'إشعار جديد',
        'body': args[1]?.toString() ?? '',
      };
    } else {
      data = {
        'title': args[0]?.toString() ?? 'إشعار جديد',
        'body': '',
      };
    }

    notifications.insert(0, data);
    unreadCount.value++;

    final title = (data['title'] ?? 'إشعار جديد').toString();
    final body = (data['body'] ?? '').toString();
    SnackbarHelper.showInfo(body.isNotEmpty ? '$title\n$body' : title);

    _triggerRefresh();
  }

  Future<void> _triggerRefresh() async {
    for (final cb in List.of(_refreshCallbacks)) {
      try {
        await cb();
      } catch (e) {
        debugPrint('[SignalR] refresh callback error: $e');
      }
    }
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
    _refreshCallbacks.clear();
    disconnect();
    super.onClose();
  }
}
