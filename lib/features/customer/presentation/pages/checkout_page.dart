import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/customer_controllers.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _promoController = TextEditingController();

  /// 'Immediate' أو 'Scheduled'
  String _scheduleType = 'Immediate';
  DateTime? _scheduledDate;

  bool _checkingPromo = false;
  String? _appliedPromo;
  double _promoDiscount = 0;
  String? _promoMessage;

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _checkingPromo = true;
      _promoMessage = null;
    });
    try {
      final dio = Get.find<DioClient>();
      final res = await dio.get(
        ApiConstants.offersValidatePromo,
        queryParameters: {'promoCode': code},
      );
      final body = res.data;
      final ok = body is Map && (body['success'] == true);
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
      if (ok && data.isNotEmpty) {
        final discount = (data['discountValue'] ?? data['value'] ?? 0);
        setState(() {
          _appliedPromo = code;
          _promoDiscount = (discount is num) ? discount.toDouble() : 0;
          _promoMessage = 'تم تطبيق الكود ✓';
        });
      } else {
        setState(() {
          _appliedPromo = null;
          _promoDiscount = 0;
          _promoMessage = (body is Map ? body['messageAr'] : null)?.toString()
              ?? 'كود غير صالح';
        });
      }
    } catch (e) {
      setState(() {
        _appliedPromo = null;
        _promoDiscount = 0;
        _promoMessage = 'تعذر التحقق من الكود';
      });
    } finally {
      if (mounted) setState(() => _checkingPromo = false);
    }
  }

  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledDate ?? now.add(const Duration(hours: 2)),
      ),
    );
    if (time == null) return;
    setState(() {
      _scheduledDate = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ملخص المنتجات ──
            Text('المنتجات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...cartController.cartItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} × ${item.quantity}',
                                  style: GoogleFonts.cairo(fontSize: 14),
                                ),
                              ),
                              Text(
                                Formatters.currency(item.total),
                                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        if (i < cartController.cartItems.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── الإجماليات ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row('المجموع الفرعي', Formatters.currency(cartController.subtotal)),
                  const SizedBox(height: 8),
                  _row('رسوم التوصيل', Formatters.currency(cartController.deliveryFee)),
                  if (_appliedPromo != null && _promoDiscount > 0) ...[
                    const SizedBox(height: 8),
                    _row('خصم الكود', '- ${Formatters.currency(_promoDiscount)}'),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.dividerLight),
                  ),
                  _row(
                    'الإجمالي',
                    Formatters.currency(
                      (cartController.total - _promoDiscount)
                          .clamp(0, double.infinity),
                    ),
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── جدولة التسليم ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      Text('وقت التسليم',
                          style: GoogleFonts.cairo(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'Immediate',
                        label: Text('فوري', style: GoogleFonts.cairo()),
                        icon: const Icon(Icons.flash_on),
                      ),
                      ButtonSegment(
                        value: 'Scheduled',
                        label: Text('مجدول', style: GoogleFonts.cairo()),
                        icon: const Icon(Icons.event),
                      ),
                    ],
                    selected: {_scheduleType},
                    onSelectionChanged: (s) => setState(() {
                      _scheduleType = s.first;
                      if (_scheduleType == 'Immediate') _scheduledDate = null;
                    }),
                  ),
                  if (_scheduleType == 'Scheduled') ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickScheduledDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _scheduledDate == null
                            ? 'اختر تاريخ ووقت التسليم'
                            : Formatters.dateTime(_scheduledDate!),
                        style: GoogleFonts.cairo(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── العنوان (اختياري) ──
            CustomTextField(
              label: 'عنوان التوصيل (اختياري)',
              hint: 'أدخل عنوان التوصيل',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // ── كود الخصم ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('كود الخصم',
                          style: GoogleFonts.cairo(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'أدخل الكود',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _checkingPromo ? null : _applyPromo,
                        child: _checkingPromo
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('تطبيق', style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                  if (_promoMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _promoMessage!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _appliedPromo != null
                            ? AppColors.successLight
                            : AppColors.errorLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── ملاحظات ──
            CustomTextField(
              label: 'ملاحظات (اختياري)',
              hint: 'أضف ملاحظات للطلب...',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // ── زر التأكيد ──
            Obx(() => CustomButton(
                  text: 'تأكيد الطلب',
                  icon: Icons.check_circle_outline,
                  isLoading: cartController.isSubmitting.value,
                  onPressed: () {
                    if (_scheduleType == 'Scheduled' &&
                        _scheduledDate == null) {
                      Get.snackbar('خطأ', 'الرجاء اختيار تاريخ ووقت التسليم');
                      return;
                    }
                    cartController.checkout(
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                      address: _addressController.text.trim().isEmpty
                          ? null
                          : _addressController.text.trim(),
                      promoCode: _appliedPromo,
                      deliveryScheduleType: _scheduleType,
                      scheduledDeliveryDate: _scheduledDate,
                    );
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: isBold ? AppColors.primary : null)),
      ],
    );
  }
}
