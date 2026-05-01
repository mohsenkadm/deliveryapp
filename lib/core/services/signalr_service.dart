// خدمة الإشعارات الفورية عبر SignalR
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import '../utils/snackbar_helper.dart';

class SignalRService extends GetxService {
  static SignalRService get to => Get.find<SignalRService>();

  HubConnection? _connection;
  final _storage = const FlutterSecureStorage();

  final isConnected = false.obs;
  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  /// تهيئة الاتصال بـ SignalR
  Future<void> connect() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) return;

      final hubUrl =
          '${ApiConstants.baseUrl}${ApiConstants.signalRHub}?access_token=$token';

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

      // استماع لإشعارات الطلبات
      _connection!.on('ReceiveNotification', _onNotification);
      _connection!.on('OrderStatusChanged', _onOrderStatusChanged);
      _connection!.on('NewOrder', _onNewOrder);

      _connection!.onclose(({error}) {
        isConnected.value = false;
      });

      _connection!.onreconnecting(({error}) {
        isConnected.value = false;
      });

      _connection!.onreconnected(({connectionId}) {
        isConnected.value = true;
      });

      await _connection!.start();
      isConnected.value = true;
    } catch (_) {
      // تجاهل أخطاء الاتصال بصمت
    }
  }

  void _onNotification(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    notifications.insert(0, data);
    unreadCount.value++;

    final title = data['title']?.toString() ?? 'إشعار جديد';
    final body = data['body']?.toString() ?? '';
    SnackbarHelper.showInfo('$title\n$body');
  }

  void _onOrderStatusChanged(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final status = data['status']?.toString() ?? '';
    final orderId = data['orderId']?.toString() ?? '';
    SnackbarHelper.showInfo('تحديث الطلب #$orderId\nالحالة: $status');
  }

  void _onNewOrder(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    SnackbarHelper.showInfo('طلب جديد - تم استلام طلب جديد');
  }

  void markAllRead() {
    unreadCount.value = 0;
  }

  Future<void> disconnect() async {
    try {
      await _connection?.stop();
    } catch (_) {}
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
