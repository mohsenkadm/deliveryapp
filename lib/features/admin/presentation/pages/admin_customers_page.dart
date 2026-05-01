import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/admin_controllers.dart';

class AdminCustomersPage extends GetView<AdminCustomersController> {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final search = ''.obs;
    final tabIndex = 0.obs;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text('إدارة العملاء',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          bottom: TabBar(
            onTap: (i) => tabIndex.value = i,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'جميع العملاء'),
              Tab(text: 'طلبات الموافقة'),
            ],
          ),
        ),
        body: Column(
          children: [
            // ── شريط البحث ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (v) => search.value = v,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو الهاتف...',
                  hintStyle:
                      GoogleFonts.cairo(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(() => search.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => search.value = '')
                      : const SizedBox.shrink()),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                ),
              ),
            ),

            // ── محتوى التبويبات ──
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const LoadingIndicator();

                return TabBarView(
                  children: [
                    // ── تبويب كل العملاء ──
                    _CustomersList(
                      customers: controller.customers
                          .where((c) {
                            final q = search.value.toLowerCase();
                            if (q.isEmpty) return true;
                            final name =
                                (c['fullName'] ?? '').toString().toLowerCase();
                            final phone =
                                (c['phone'] ?? '').toString().toLowerCase();
                            return name.contains(q) || phone.contains(q);
                          })
                          .toList(),
                      onRefresh: controller.loadCustomers,
                      onStatement: (c) => Get.toNamed(
                          AppRoutes.customerStatement,
                          arguments: c),
                    ),

                    // ── تبويب طلبات الموافقة ──
                    _PendingList(
                      pending: controller.pendingApprovals
                          .where((c) {
                            final q = search.value.toLowerCase();
                            if (q.isEmpty) return true;
                            final name =
                                (c['fullName'] ?? '').toString().toLowerCase();
                            final phone =
                                (c['phone'] ?? '').toString().toLowerCase();
                            return name.contains(q) || phone.contains(q);
                          })
                          .toList(),
                      onRefresh: controller.loadCustomers,
                      onApprove: (id) => controller.approveCustomer(id),
                      onReject: (id) => controller.rejectCustomer(id),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// قائمة العملاء
// ──────────────────────────────────────────────────────
class _CustomersList extends StatelessWidget {
  final List<Map<String, dynamic>> customers;
  final Future<void> Function() onRefresh;
  final void Function(Map<String, dynamic>) onStatement;

  const _CustomersList({
    required this.customers,
    required this.onRefresh,
    required this.onStatement,
  });

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return const EmptyState(
          title: 'لا يوجد عملاء', icon: Icons.people_outline);
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _CustomerCard(
          customer: customers[i],
          onStatement: () => onStatement(customers[i]),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// قائمة طلبات الموافقة
// ──────────────────────────────────────────────────────
class _PendingList extends StatelessWidget {
  final List<Map<String, dynamic>> pending;
  final Future<void> Function() onRefresh;
  final void Function(String) onApprove;
  final void Function(String) onReject;

  const _PendingList({
    required this.pending,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) {
      return const EmptyState(
          title: 'لا توجد طلبات معلقة',
          subtitle: 'جميع الطلبات تمت معالجتها',
          icon: Icons.check_circle_outline);
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _PendingCard(
          customer: pending[i],
          onApprove: () => onApprove(pending[i]['id'].toString()),
          onReject: () => onReject(pending[i]['id'].toString()),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// بطاقة العميل
// ──────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onStatement;

  const _CustomerCard({required this.customer, required this.onStatement});

  @override
  Widget build(BuildContext context) {
    final name = customer['fullName'] ?? customer['name'] ?? 'عميل';
    final phone = customer['phone'] ?? '';
    final store = customer['storeName'] ?? '';
    final email = customer['email'] ?? '';
    final initial = name.isNotEmpty ? name[0] : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
            child: Text(initial,
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.cairo(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                if (store.isNotEmpty)
                  Text(store,
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                if (phone.isNotEmpty)
                  Row(children: [
                    Icon(Icons.phone_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(phone,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ]),
                if (email.isNotEmpty)
                  Row(children: [
                    Icon(Icons.email_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(email,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ]),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onStatement,
            icon: const Icon(Icons.receipt_long_outlined, size: 16),
            label: Text('كشف حساب', style: GoogleFonts.cairo(fontSize: 12)),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// بطاقة طلب الموافقة
// ──────────────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingCard(
      {required this.customer,
      required this.onApprove,
      required this.onReject});

  @override
  Widget build(BuildContext context) {
    final name = customer['fullName'] ?? customer['name'] ?? 'عميل';
    final phone = customer['phone'] ?? '';
    final store = customer['storeName'] ?? '';
    final email = customer['email'] ?? '';
    final address = customer['address'] ?? '';
    final region = customer['region'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.warningLight.withValues(alpha: 0.4),
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.warningLight.withValues(alpha: 0.15),
                child: const Icon(Icons.person_outline,
                    color: AppColors.warningLight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    if (store.isNotEmpty)
                      Text(store,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('معلق',
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warningLight)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (phone.isNotEmpty)
            _InfoRow(Icons.phone_outlined, phone),
          if (email.isNotEmpty)
            _InfoRow(Icons.email_outlined, email),
          if (address.isNotEmpty)
            _InfoRow(Icons.location_on_outlined, address),
          if (region.isNotEmpty)
            _InfoRow(Icons.map_outlined, region),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text('رفض', style: GoogleFonts.cairo()),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorLight,
                      side: BorderSide(
                          color:
                              AppColors.errorLight.withValues(alpha: 0.5))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text('موافقة', style: GoogleFonts.cairo()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successLight,
                      foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
