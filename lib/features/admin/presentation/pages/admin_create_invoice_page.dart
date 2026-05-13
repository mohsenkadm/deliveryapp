// صفحة إنشاء فاتورة للأدمن — POST /api/invoices
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminCreateInvoicePage extends StatefulWidget {
  const AdminCreateInvoicePage({super.key});

  @override
  State<AdminCreateInvoicePage> createState() => _AdminCreateInvoicePageState();
}

class _AdminCreateInvoicePageState extends State<AdminCreateInvoicePage> {
  late final AdminRemoteDataSource _ds;

  bool _loading = true;
  bool _submitting = false;

  List<Map<String, dynamic>> _customers = const [];
  List<Map<String, dynamic>> _products = const [];
  List<Map<String, dynamic>> _employees = const [];

  String? _customerId;
  String? _employeeId;
  int _scheduleType = 0; // 0 = Immediate, 1 = Scheduled
  DateTime? _scheduledDate;
  final _promoCtrl = TextEditingController();

  final List<_LineItem> _lines = [];

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    _load();
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _ds.getAllCustomers(),
        _ds.getAllProducts(),
        _ds.getAllRepresentatives(),
      ]);
      _customers = results[0];
      _products = results[1];
      _employees = results[2];
    } catch (_) {
      SnackbarHelper.showError('فشل تحميل البيانات');
    }
    if (mounted) setState(() => _loading = false);
  }

  double get _total => _lines.fold(
      0.0,
      (sum, l) => sum + (l.unitPrice * l.quantity) - l.discount);

  void _addLine() {
    setState(() => _lines.add(_LineItem()));
  }

  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _submit() async {
    if (_customerId == null) {
      SnackbarHelper.showError('اختر العميل');
      return;
    }
    if (_lines.isEmpty || _lines.any((l) => l.productId == null || l.quantity <= 0)) {
      SnackbarHelper.showError('أضف بنوداً صحيحة (منتج + كمية)');
      return;
    }
    if (_scheduleType == 1 && _scheduledDate == null) {
      SnackbarHelper.showError('حدّد تاريخ التسليم المجدول');
      return;
    }

    setState(() => _submitting = true);
    try {
      final payload = <String, dynamic>{
        'customerId': int.tryParse(_customerId!) ?? _customerId,
        if (_employeeId != null)
          'employeeId': int.tryParse(_employeeId!) ?? _employeeId,
        'invoiceSource': 0, // Customer source (admin acting on behalf)
        'deliveryScheduleType': _scheduleType,
        if (_scheduleType == 1 && _scheduledDate != null)
          'scheduledDeliveryDate': _scheduledDate!.toIso8601String(),
        if (_promoCtrl.text.trim().isNotEmpty)
          'promoCode': _promoCtrl.text.trim(),
        'details': _lines
            .map((l) => {
                  'productId': int.tryParse(l.productId!) ?? l.productId,
                  'quantity': l.quantity,
                  'unitPrice': l.unitPrice,
                  'discount': l.discount,
                })
            .toList(),
      };

      await _ds.createInvoice(payload);
      SnackbarHelper.showSuccess('تم إنشاء الفاتورة');
      if (mounted) Get.back(result: true);
    } catch (_) {
      SnackbarHelper.showError('فشل إنشاء الفاتورة');
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إنشاء فاتورة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── العميل ──
                  _label('العميل'),
                  DropdownButtonFormField<String>(
                    value: _customerId,
                    isExpanded: true,
                    decoration: _decoration('اختر العميل', Icons.person_outline),
                    items: _customers
                        .map((c) => DropdownMenuItem(
                              value: c['id']?.toString(),
                              child: Text(
                                  (c['fullName'] ?? c['storeName'] ?? '')
                                      .toString(),
                                  style: GoogleFonts.cairo(),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _customerId = v),
                  ),

                  const SizedBox(height: 16),
                  // ── الموظف (اختياري) ──
                  _label('الموظف (اختياري)'),
                  DropdownButtonFormField<String>(
                    value: _employeeId,
                    isExpanded: true,
                    decoration:
                        _decoration('بدون موظف', Icons.badge_outlined),
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('— بدون —')),
                      ..._employees.map((e) => DropdownMenuItem(
                            value: e['id']?.toString(),
                            child: Text((e['fullName'] ?? '').toString(),
                                style: GoogleFonts.cairo(),
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (v) => setState(() => _employeeId = v),
                  ),

                  const SizedBox(height: 16),
                  _label('نوع التسليم'),
                  Row(children: [
                    ChoiceChip(
                      label: const Text('فوري'),
                      selected: _scheduleType == 0,
                      onSelected: (_) =>
                          setState(() => _scheduleType = 0),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('مجدول'),
                      selected: _scheduleType == 1,
                      onSelected: (_) =>
                          setState(() => _scheduleType = 1),
                    ),
                    const SizedBox(width: 12),
                    if (_scheduleType == 1)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickScheduledDate,
                          icon: const Icon(Icons.event),
                          label: Text(
                              _scheduledDate == null
                                  ? 'اختر التاريخ'
                                  : Formatters.date(_scheduledDate!),
                              style: GoogleFonts.cairo()),
                        ),
                      ),
                  ]),

                  const SizedBox(height: 16),
                  _label('كود ترويجي (اختياري)'),
                  TextField(
                    controller: _promoCtrl,
                    decoration:
                        _decoration('كود الخصم', Icons.local_offer_outlined),
                  ),

                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                      child: Text('بنود الفاتورة',
                          style: GoogleFonts.cairo(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                    TextButton.icon(
                      onPressed: _addLine,
                      icon: const Icon(Icons.add),
                      label: Text('إضافة بند',
                          style: GoogleFonts.cairo()),
                    ),
                  ]),

                  if (_lines.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: Center(
                        child: Text('لا توجد بنود — اضغط "إضافة بند"',
                            style: GoogleFonts.cairo(
                                color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    ..._lines.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final line = entry.value;
                      return _LineItemRow(
                        key: ValueKey('line_$idx'),
                        index: idx,
                        line: line,
                        products: _products,
                        onChanged: () => setState(() {}),
                        onRemove: () => setState(() {
                          line.dispose();
                          _lines.removeAt(idx);
                        }),
                      );
                    }),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الإجمالي',
                            style: GoogleFonts.cairo(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(Formatters.currency(_total),
                            style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'إنشاء الفاتورة',
                    onPressed: _submit,
                    isLoading: _submitting,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.cairo(
                fontSize: 13, fontWeight: FontWeight.w700)),
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}

// ─── Line item state ───
class _LineItem {
  String? productId;
  int quantity = 1;
  double unitPrice = 0;
  double discount = 0;
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController priceCtrl = TextEditingController(text: '0');
  final TextEditingController discountCtrl = TextEditingController(text: '0');

  void dispose() {
    qtyCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
  }
}

class _LineItemRow extends StatelessWidget {
  final int index;
  final _LineItem line;
  final List<Map<String, dynamic>> products;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _LineItemRow({
    super.key,
    required this.index,
    required this.line,
    required this.products,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('بند ${index + 1}',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
            ),
          ]),
          DropdownButtonFormField<String>(
            value: line.productId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'اختر المنتج',
              hintStyle: GoogleFonts.cairo(),
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
            ),
            items: products
                .map((p) => DropdownMenuItem(
                      value: p['id']?.toString(),
                      child: Text((p['name'] ?? '').toString(),
                          style: GoogleFonts.cairo(),
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) {
              line.productId = v;
              // Auto-fill price from product (retailPrice)
              final product =
                  products.firstWhere((p) => p['id']?.toString() == v,
                      orElse: () => const {});
              final price = product['retailPrice'] ?? product['price'] ?? 0;
              if (price is num && line.priceCtrl.text == '0') {
                line.unitPrice = price.toDouble();
                line.priceCtrl.text = price.toString();
              }
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: line.qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الكمية',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                onChanged: (v) {
                  line.quantity = int.tryParse(v) ?? 0;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: line.priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'السعر',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                onChanged: (v) {
                  line.unitPrice = double.tryParse(v) ?? 0;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: line.discountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'خصم',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                onChanged: (v) {
                  line.discount = double.tryParse(v) ?? 0;
                  onChanged();
                },
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'المجموع: ${Formatters.currency((line.unitPrice * line.quantity) - line.discount)}',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
