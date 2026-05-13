import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/employee_roles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminDriversPage extends StatefulWidget {
  const AdminDriversPage({super.key});

  @override
  State<AdminDriversPage> createState() => _AdminDriversPageState();
}

class _AdminDriversPageState extends State<AdminDriversPage> {
  late final AdminRemoteDataSource _ds;
  final _drivers = <Map<String, dynamic>>[].obs;
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
      _drivers.value = await _ds.getAllDrivers();
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
        title: Text('إدارة السائقين', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _openForm(),
            tooltip: 'إضافة سائق',
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
                hintText: 'بحث باسم السائق...',
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
              final filtered = _drivers.where((d) {
                final name = (d['fullName'] ?? '').toString().toLowerCase();
                return _search.value.isEmpty || name.contains(_search.value.toLowerCase());
              }).toList();
              if (filtered.isEmpty) {
                return const EmptyState(title: 'لا يوجد سائقون', icon: Icons.delivery_dining_outlined);
              }
              return RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DriverCard(driver: filtered[i]),
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
            'roles': EmployeeRoles.driver,
            'employeeType': 'Individual',
          };
    final result =
        await Get.toNamed(AppRoutes.adminEmployeeForm, arguments: preset);
    if (result == true) _load();
  }
}

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> driver;
  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final name = driver['fullName'] ?? 'سائق';
    final phone = driver['phone'] ?? '';
    final vehicle = driver['vehicleType'] ?? '';
    final plate = driver['licensePlate'] ?? '';
    final deliveries = driver['completedDeliveries'] ?? 0;
    final isActive = driver['isActive'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.inProgress.withValues(alpha: 0.15),
            radius: 26,
            child: Icon(Icons.delivery_dining_rounded, color: AppColors.inProgress, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 15))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isActive ? AppColors.successLight : AppColors.textSecondary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isActive ? 'نشط' : 'غير نشط',
                          style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.successLight : AppColors.textSecondary)),
                    ),
                  ],
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    child: Row(children: [
                      Icon(Icons.phone_outlined, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(phone, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.primary, decoration: TextDecoration.underline)),
                    ]),
                  ),
                ],
                if (vehicle.isNotEmpty || plate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('$vehicle — $plate'.trim().trimLeft().trimRight(),
                      style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.successLight),
                  const SizedBox(width: 4),
                  Text('$deliveries توصيلة مكتملة', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
