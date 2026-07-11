/// رسائل أخطاء الشبكة — بدون استيراد dart:io ليتوافق مع الويب.
String connectionErrorMessage(Object? error) {
  if (error == null) {
    return 'خطأ في الاتصال بالإنترنت';
  }

  final details = error.toString();

  if (details.contains('HandshakeException') ||
      details.contains('CERTIFICATE_VERIFY_FAILED') ||
      details.contains('unable to get local issuer certificate')) {
    return 'فشل الاتصال الآمن بالخادم. يرجى المحاولة لاحقاً أو تحديث نظام الجهاز';
  }

  if (details.contains('SocketException') ||
      details.contains('Failed host lookup') ||
      details.contains('Network is unreachable')) {
    return 'تعذّر الوصول للخادم. تحقق من اتصال الإنترنت وحاول مجدداً';
  }

  if (details.contains('Connection refused') ||
      details.contains('Connection reset')) {
    return 'الخادم غير متاح حالياً. يرجى المحاولة بعد قليل';
  }

  return 'خطأ في الاتصال بالإنترنت';
}
