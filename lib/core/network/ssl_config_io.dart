import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// تهيئة شهادات SSL الموثوقة — يحل مشكلة Let's Encrypt على Android 7.x
Future<void> configureTrustedCertificates() async {
  try {
    final data = await rootBundle.load('assets/ca/isrg-root-x1.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      data.buffer.asUint8List(),
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[SSL] failed to load trusted CA: $e');
    }
  }
}
