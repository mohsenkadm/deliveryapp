// فحص حالة الاتصال بالإنترنت
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// التحقق من اتصال الجهاز بالإنترنت
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    if (results is List) {
      return !(results as List).contains(ConnectivityResult.none);
    }
    return results != ConnectivityResult.none;
  }
}
