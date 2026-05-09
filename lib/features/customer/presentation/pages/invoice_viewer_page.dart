// صفحة عرض الفاتورة بصيغة HTML — WebView
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/snackbar_helper.dart';

class InvoiceViewerPage extends StatefulWidget {
  const InvoiceViewerPage({super.key});

  @override
  State<InvoiceViewerPage> createState() => _InvoiceViewerPageState();
}

class _InvoiceViewerPageState extends State<InvoiceViewerPage> {
  WebViewController? _controller;
  final _isLoading = true.obs;
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = Get.arguments as String? ?? '';
    if (_orderId.isNotEmpty) {
      _initWebView();
    } else {
      _isLoading.value = false;
    }
  }

  Future<void> _initWebView() async {
    final storage = Get.find<StorageService>();
    final token = await storage.getToken() ?? '';

    final url = '${ApiConstants.baseUrl}${ApiConstants.customerOrderInvoice(_orderId)}';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => _isLoading.value = true,
        onPageFinished: (_) => _isLoading.value = false,
      ))
      ..loadRequest(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _printAsPdf() async {
    if (_orderId.isEmpty) return;
    try {
      final pdf = await PdfService.instance.buildInvoicePdf({
        'id': _orderId,
        'invoiceNumber': _orderId,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'items': const [],
      });
      await PdfService.instance.printOrPreview(pdf, name: 'invoice_$_orderId');
    } catch (e) {
      SnackbarHelper.showError('فشل تحضير ملف الطباعة');
    }
  }

  void _showQrDialog() {
    final qrData = 'INV:$_orderId';
    Get.dialog(
      AlertDialog(
        title: const Text('رمز الفاتورة'),
        content: SizedBox(
          width: 220,
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 8),
              Text('فاتورة #$_orderId',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفاتورة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'رمز QR',
            onPressed: _orderId.isEmpty ? null : _showQrDialog,
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'طباعة / مشاركة PDF',
            onPressed: _orderId.isEmpty ? null : _printAsPdf,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_orderId.isEmpty)
            const Center(child: Text('لا يوجد رقم فاتورة'))
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
