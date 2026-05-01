// صفحة عرض الفاتورة بصيغة HTML — WebView
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/storage_service.dart';

class InvoiceViewerPage extends StatefulWidget {
  const InvoiceViewerPage({super.key});

  @override
  State<InvoiceViewerPage> createState() => _InvoiceViewerPageState();
}

class _InvoiceViewerPageState extends State<InvoiceViewerPage> {
  late final WebViewController _controller;
  final _isLoading = true.obs;
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = Get.arguments as String? ?? '';
    _initWebView();
  }

  Future<void> _initWebView() async {
    final storage = Get.find<StorageService>();
    final token = await storage.getToken() ?? '';

    final url = '${ApiConstants.baseUrl}${ApiConstants.customerOrderInvoice(_orderId)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => _isLoading.value = true,
        onPageFinished: (_) => _isLoading.value = false,
      ))
      ..loadRequest(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفاتورة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_orderId.isNotEmpty) WebViewWidget(controller: _controller),
          Obx(() => _isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
