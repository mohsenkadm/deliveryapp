import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/employee_roles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminRepresentativesPage extends StatefulWidget {
  const AdminRepresentativesPage({super.key});

  @override
  State<AdminRepresentativesPage> createState() => _AdminRepresentativesPageState();
}

class _AdminRepresentativesPageState extends State<AdminRepresentativesPage> {
  late final AdminRemoteDataSource _ds;
  final _reps = <Map<String, dynamic>>[].obs;
  final _isLoading = true.obs;
  final _search = ''.obs;

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    _load();
  }

  Future<void> _load() async {
    _isLoading.value = true;
    try {
      _reps.value = await _ds.getAllRepresentatives();
    } catch (_) {
      SnackbarHelper.showError('فشل تحميل البيانات');
    }
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إدارة المندوبين', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _openForm(),
            tooltip: 'إضافة مندوب',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => _search.value = v,
              style: GoogleFonts.cairo(),
              decoration: InputDecoration(
                hintText: 'بحث باسم المندوب...',
                hintStyle: GoogleFonts.cairo(),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) return const LoadingIndicator();
              final filtered = _reps.where((r) {
                final name = (r['fullName'] ?? '').toString().toLowerCase();
                return _search.value.isEmpty || name.contains(_search.value.toLowerCase());
              }).toList();
              if (filtered.isEmpty) {
                return const EmptyState(title: 'لا يوجد مندوبون', icon: Icons.support_agent_outlined);
              }
              return RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _RepCard(rep: filtered[i], onReload: _load, ds: _ds),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final preset = existing != null
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{
            'roles': EmployeeRoles.representative,
            'employeeType': 'Representative',
            'representativeType': 'Individual',
          };
    final result =
        await Get.toNamed(AppRoutes.adminEmployeeForm, arguments: preset);
    if (result == true) _load();
  }
}

class _RepCard extends StatelessWidget {
  final Map<String, dynamic> rep;
  final VoidCallback onReload;
  final AdminRemoteDataSource ds;

  const _RepCard({required this.rep, required this.onReload, required this.ds});

  @override
  Widget build(BuildContext context) {
    final name = rep['fullName'] ?? 'مندوب';
    final phone = rep['phone'] ?? '';
    final region = rep['region'] ?? '';
    final customersCount = rep['customersCount'] ?? 0;
    final invoicesCount = rep['invoicesCount'] ?? 0;
    final isActive = rep['isActive'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                radius: 24,
                child: Text(name.isNotEmpty ? name[0] : '?', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 15)),
                    if (phone.isNotEmpty) Text(phone, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.successLight : AppColors.textSecondary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isActive ? 'نشط' : 'غير نشط',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.successLight : AppColors.textSecondary)),
              ),
            ],
          ),
          if (region.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(region, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(icon: Icons.people_rounded, label: 'العملاء', value: '$customersCount', color: AppColors.primaryLight),
              const SizedBox(width: 8),
              _Stat(icon: Icons.receipt_long_rounded, label: 'الفواتير', value: '$invoicesCount', color: AppColors.successLight),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
              Text(label, style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary)),
            ]),
          ],
        ),
      ),
    );
  }
}
