// صفحة ديون العملاء — المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

enum _DebtSort { amountDesc, amountAsc, nameAsc, invoiceCountDesc }

class RepDebtsPage extends StatefulWidget {
  const RepDebtsPage({super.key});

  @override
  State<RepDebtsPage> createState() => _RepDebtsPageState();
}

class _RepDebtsPageState extends State<RepDebtsPage> {
  _DebtSort _sort = _DebtSort.amountDesc;
  String _search = '';
  double? _minAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.find<RepresentativeHomeController>().loadDebts());
  }

  List<Map<String, dynamic>> _apply(List<Map<String, dynamic>> input) {
    var list = input.where((d) {
      final name = (d['fullName'] ?? '').toString().toLowerCase();
      final store = (d['storeName'] ?? '').toString().toLowerCase();
      final phone = (d['phone'] ?? '').toString().toLowerCase();
      final amount = ((d['totalDebt'] as num?) ?? 0).toDouble();
      final q = _search.toLowerCase();
      final matchesSearch =
          q.isEmpty || name.contains(q) || store.contains(q) || phone.contains(q);
      final matchesAmount = _minAmount == null || amount >= _minAmount!;
      return matchesSearch && matchesAmount;
    }).toList();
    list.sort((a, b) {
      double ad = ((a['totalDebt'] as num?) ?? 0).toDouble();
      double bd = ((b['totalDebt'] as num?) ?? 0).toDouble();
      int ac = (a['invoiceCount'] as num?)?.toInt() ?? 0;
      int bc = (b['invoiceCount'] as num?)?.toInt() ?? 0;
      switch (_sort) {
        case _DebtSort.amountDesc:
          return bd.compareTo(ad);
        case _DebtSort.amountAsc:
          return ad.compareTo(bd);
        case _DebtSort.nameAsc:
          return (a['fullName'] ?? '')
              .toString()
              .compareTo((b['fullName'] ?? '').toString());
        case _DebtSort.invoiceCountDesc:
          return bc.compareTo(ac);
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RepresentativeHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ديون العملاء'),
        actions: [
          IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'فلاتر',
              onPressed: _showFilters),
          IconButton(icon: const Icon(Icons.refresh), onPressed: ctrl.loadDebts),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingDebts.value) return const LoadingIndicator();
        if (ctrl.debts.isEmpty) {
          return const EmptyState(
            icon: Icons.money_off_csred_outlined,
            title: 'لا توجد ديون',
            subtitle: 'جميع عملاؤك سدّدوا مستحقاتهم',
          );
        }

        final filtered = _apply(ctrl.debts.toList());
        final totalDebt = filtered.fold<double>(
            0, (s, d) => s + ((d['totalDebt'] as num?) ?? 0).toDouble());

        return Column(
          children: [
            // شريط بحث
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم العميل أو الهاتف...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            // ترقيم الفلاتر النشطة
            if (_minAmount != null || _sort != _DebtSort.amountDesc)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        if (_minAmount != null)
                          Chip(
                            label: Text(
                                'حد أدنى: ${Formatters.formatCurrency(_minAmount!)}'),
                            onDeleted: () =>
                                setState(() => _minAmount = null),
                          ),
                        Chip(
                          label: Text('ترتيب: ${_sortLabel(_sort)}'),
                          onDeleted: () => setState(
                              () => _sort = _DebtSort.amountDesc),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // ملخص إجمالي
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي الديون (${filtered.length}):',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  Text(Formatters.formatCurrency(totalDebt),
                      style: GoogleFonts.cairo(
                          color: AppColors.error,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'لا نتائج للفلتر',
                      subtitle: 'جرّب تعديل البحث أو الفلاتر',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final d = filtered[i];
                        final debt =
                            ((d['totalDebt'] as num?) ?? 0).toDouble();
                        final count = d['invoiceCount'] ?? 0;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.error.withValues(alpha: 0.15),
                              child: Icon(Icons.person_outline,
                                  color: AppColors.error),
                            ),
                            title: Text(d['fullName'] ?? '',
                                style: AppTextStyles.titleSmall),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (d['storeName'] != null)
                                  Text(d['storeName'],
                                      style: AppTextStyles.bodySmall),
                                Text('${d['phone'] ?? ''} • $count فاتورة',
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                            trailing: Text(
                              Formatters.formatCurrency(debt),
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  String _sortLabel(_DebtSort s) {
    switch (s) {
      case _DebtSort.amountDesc:
        return 'الأعلى مديونية';
      case _DebtSort.amountAsc:
        return 'الأدنى مديونية';
      case _DebtSort.nameAsc:
        return 'الاسم (أبجدي)';
      case _DebtSort.invoiceCountDesc:
        return 'عدد الفواتير';
    }
  }

  void _showFilters() {
    final amountCtrl = TextEditingController(
        text: _minAmount?.toStringAsFixed(0) ?? '');
    var localSort = _sort;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setSt) => Container(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('فلاتر الديون',
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'حد أدنى للمديونية',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Text('الترتيب',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _DebtSort.values
                    .map((s) => ChoiceChip(
                          label: Text(_sortLabel(s)),
                          selected: localSort == s,
                          onSelected: (_) => setSt(() => localSort = s),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minAmount = null;
                          _sort = _DebtSort.amountDesc;
                          _search = '';
                        });
                        Get.back();
                      },
                      child: const Text('مسح الكل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minAmount =
                              double.tryParse(amountCtrl.text.trim());
                          _sort = localSort;
                        });
                        Get.back();
                      },
                      child: const Text('تطبيق'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
