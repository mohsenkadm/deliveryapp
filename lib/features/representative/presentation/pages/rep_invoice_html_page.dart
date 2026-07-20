// عرض فاتورة المندوب HTML من السيرفر — WebView + طباعة
// السيرفر يعيد الاسم الكامل والتاريخ — لا قصّ في العميل.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/snackbar_helper.dart';

class RepInvoiceHtmlPage extends StatefulWidget {
  const RepInvoiceHtmlPage({super.key});

  @override
  State<RepInvoiceHtmlPage> createState() => _RepInvoiceHtmlPageState();
}

class _RepInvoiceHtmlPageState extends State<RepInvoiceHtmlPage> {
  WebViewController? _controller;
  final _isLoading = true.obs;
  late final String _invoiceId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _invoiceId = args['id']?.toString() ?? '';
    } else {
      _invoiceId = args?.toString() ?? '';
    }
    if (_invoiceId.isNotEmpty) {
      _initWebView();
    } else {
      _isLoading.value = false;
    }
  }

  Future<void> _initWebView() async {
    final storage = Get.find<StorageService>();
    final token = await storage.getToken() ?? '';
    final url =
        '${ApiConstants.baseUrl}${ApiConstants.repInvoiceHtml(_invoiceId)}';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => _isLoading.value = true,
        onPageFinished: (_) => _isLoading.value = false,
        onWebResourceError: (_) {
          _isLoading.value = false;
          SnackbarHelper.showError('تعذّر تحميل الفاتورة للطباعة');
        },
      ))
      ..loadRequest(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  /// يطلب من صفحة HTML استدعاء طباعة المتصفح إن وُجدت.
  Future<void> _printHtml() async {
    if (_controller == null) return;
    try {
      await _controller!.runJavaScript(
        'window.print && window.print();',
      );
      SnackbarHelper.showSuccess(
        'إن لم يظهر حوار الطباعة، استخدم زر الطباعة الحرارية من تفاصيل الفاتورة.',
      );
    } catch (_) {
      SnackbarHelper.showError(
        'تعذّر تشغيل الطباعة من WebView. استخدم الطباعة الحرارية من التفاصيل.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _invoiceId.isEmpty ? 'الفاتورة' : 'فاتورة #$_invoiceId',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'طباعة',
            onPressed: _invoiceId.isEmpty ? null : _printHtml,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_invoiceId.isEmpty)
            Center(
              child: Text('لا يوجد رقم فاتورة', style: GoogleFonts.cairo()),
            )
          else if (_controller != null)
            WebViewWidget(controller: _controller!),
          Obx(() => _isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
