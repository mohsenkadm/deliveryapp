import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

/// وسيطات شاشة اختيار منتجات النقل/الإرجاع.
class RepTransferPickerArgs {
  final bool isReturn;

  const RepTransferPickerArgs({required this.isReturn});
}

/// اختيار منتجات من المستودع الرئيسي (طلب) أو الفرعي (إرجاع) ثم إرسال الطلب.
class RepTransferProductPickerPage extends StatefulWidget {
  const RepTransferProductPickerPage({super.key});

  @override
  State<RepTransferProductPickerPage> createState() =>
      _RepTransferProductPickerPageState();
}

class _TransferLine {
  final String productId;
  final String name;
  final int maxStock;
  int qty;

  _TransferLine({
    required this.productId,
    required this.name,
    required this.maxStock,
    this.qty = 1,
  });
}

class _RepTransferProductPickerPageState
    extends State<RepTransferProductPickerPage> {
  late final bool _isReturn;
  String _query = '';
  final _lines = <String, _TransferLine>{};
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  final _notesCtrl = TextEditingController();

  RepresentativeHomeController get _ctrl =>
      Get.find<RepresentativeHomeController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _isReturn = args is RepTransferPickerArgs ? args.isReturn : false;
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _ctrl.ensureWarehouseRoutingIds();
      final list = await _ctrl.fetchInventoryLinesForTransfer(_isReturn);
      setState(() => _items = list);
    } catch (_) {
      setState(() => _items = const []);
    }
    if (mounted) setState(() => _loading = false);
  }

  String _pid(Map<String, dynamic> it) =>
      (it['productId'] ?? it['id'] ?? '').toString();

  int _stock(Map<String, dynamic> it) {
    final q = it['quantity'] ??
        it['mainWarehouseStock'] ??
        it['stockQuantity'] ??
        0;
    if (q is num) return q.toInt();
    final stocks = it['stocksByWarehouse'];
    if (stocks is List) {
      var sum = 0;
      for (final e in stocks) {
        if (e is Map) {
          final sq = e['quantity'];
          if (sq is num) sum += sq.toInt();
        }
      }
      if (sum > 0) return sum;
    }
    return int.tryParse(q.toString()) ?? 0;
  }

  String _name(Map<String, dynamic> it) =>
      (it['productName'] ?? it['name'] ?? '').toString();

  void _addOrInc(Map<String, dynamic> it) {
    final id = _pid(it);
    if (id.isEmpty) return;
    final stock = _stock(it);
    if (stock <= 0) {
      SnackbarHelper.showError(
        _isReturn
            ? 'لا يوجد رصيد في مستودعك لهذا المنتج'
            : 'المنتج غير متوفر في المستودع الرئيسي',
      );
      return;
    }
    final existing = _lines[id];
    if (existing != null) {
      if (existing.qty + 1 > stock) {
        SnackbarHelper.showError('الحد الأقصى للكمية: $stock');
        return;
      }
      setState(() => existing.qty++);
      return;
    }
    setState(() {
      _lines[id] = _TransferLine(
        productId: id,
        name: _name(it),
        maxStock: stock,
        qty: 1,
      );
    });
  }

  Future<void> _submit() async {
    if (_lines.isEmpty) {
      SnackbarHelper.showError('أضف منتجاً واحداً على الأقل');
      return;
    }
    final details = _lines.values
        .map((e) => {
              'productId': int.tryParse(e.productId) ?? 0,
              'requestedQuantity': e.qty,
            })
        .where((m) =>
            (m['productId'] as int) > 0 && (m['requestedQuantity'] as int) > 0)
        .toList();
    if (details.isEmpty) return;
    await _ctrl.submitStockTransfer(
      isReturn: _isReturn,
      details: details,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _query.toLowerCase();
    return _items.where((it) {
      if (q.isEmpty) return true;
      final n = _name(it).toLowerCase();
      final code =
          (it['productCode'] ?? it['code'] ?? '').toString().toLowerCase();
      return n.contains(q) || code.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = _isReturn
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)];
    final list = _filtered;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 18,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        _isReturn ? 'إرجاع للرئيسي' : 'طلب من الرئيسي',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Text(
                    _isReturn
                        ? 'اختر ما تريد إرجاعه من مستودعك إلى المستودع الرئيسي'
                        : 'تصفّح مخزون المستودع الرئيسي وأضف ما تحتاجه لمستودعك',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.4,
                    ),
                  ),
                ),
                if (Get.find<AuthService>().isIndividualRepresentative) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Text(
                      'المندوب المفرد: يحدّد الخادم مستودعات النقل تلقائياً من قاعدة البيانات عند الإرسال.',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث باسم المنتج أو الكود…',
                hintStyle: GoogleFonts.cairo(),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingIndicator()
                : list.isEmpty
                    ? EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'لا توجد منتجات',
                        subtitle: _isReturn
                            ? 'لا يوجد مخزون في مستودعك الفرعي'
                            : 'لا يوجد مخزون متاح في المستودع الرئيسي',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final it = list[i];
                          final stock = _stock(it);
                          final id = _pid(it);
                          final line = _lines[id];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap:
                                    id.isEmpty ? null : () => _addOrInc(it),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary
                                                  .withValues(alpha: 0.12),
                                              AppColors.secondaryLight
                                                  .withValues(alpha: 0.1),
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.inventory_rounded,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _name(it),
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'متاح: $stock',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: stock > 0
                                                    ? AppColors.success
                                                    : AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (line != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: line.qty > 1
                                                    ? () => setState(
                                                        () => line.qty--)
                                                    : () => setState(() =>
                                                        _lines.remove(id)),
                                                child: Icon(
                                                  line.qty > 1
                                                      ? Icons.remove_rounded
                                                      : Icons.delete_outline,
                                                  size: 20,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Text(
                                                  '${line.qty}',
                                                  style: GoogleFonts.cairo(
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: line.qty < line.maxStock
                                                    ? () => setState(
                                                        () => line.qty++)
                                                    : null,
                                                child: Icon(
                                                  Icons.add_rounded,
                                                  size: 20,
                                                  color: line.qty <
                                                          line.maxStock
                                                      ? AppColors.primary
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        FilledButton.tonal(
                                          onPressed: id.isEmpty ||
                                                  stock <= 0
                                              ? null
                                              : () => _addOrInc(it),
                                          child: Text(
                                            'إضافة',
                                            style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                style: GoogleFonts.cairo(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'ملاحظات (اختياري)',
                  hintStyle: GoogleFonts.cairo(),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_lines.length} صنف',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'الكمية: ${_lines.values.fold<int>(0, (a, b) => a + b.qty)}',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => CustomButton(
                        text: _isReturn ? 'إرسال الإرجاع' : 'إرسال الطلب',
                        isLoading: _ctrl.isActing.value,
                        onPressed: _lines.isEmpty ? null : _submit,
                        width: 168,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
