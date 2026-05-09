// خدمة الإشعارات الفورية عبر SignalR
//
// تتصل بـ /hubs/notifications من DeliverySystem.API. يتم إرسال JWT عبر
// `accessTokenFactory` (الطريقة الموصى بها في الوثائق).
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

  /// تهيئة الاتصال بـ SignalR — يجب استدعاؤها بعد نجاح تسجيل الدخول.
  Future<void> connect() async {
    try {
      final token = await _storage.read(key: StorageKeys.accessToken);
      if (token == null || token.isEmpty) return;

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
