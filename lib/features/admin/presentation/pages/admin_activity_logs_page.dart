import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminActivityLogsPage extends StatefulWidget {
  const AdminActivityLogsPage({super.key});

  @override
  State<AdminActivityLogsPage> createState() => _AdminActivityLogsPageState();
}

class _AdminActivityLogsPageState extends State<AdminActivityLogsPage> {
  late final AdminRemoteDataSource _ds;
  final _logs = <Map<String, dynamic>>[].obs;
  final _isLoading = true.obs;
  final _selectedType = 'الكل'.obs;

  static const _types = ['الكل', 'تسجيل دخول', 'إنشاء', 'تعديل', 'حذف', 'موافقة', 'رفض'];
  static const _typeKeys = ['', 'Login', 'Create', 'Update', 'Delete', 'Approve', 'Reject'];

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    _load();
  }

  Future<void> _load() async {
    _isLoading.value = true;
    try {
      _logs.value = await _ds.getActivityLogs();
    } catch (_) {
      // If API not available, show empty
    }
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('سجل النشاط', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Obx(() => SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = _selectedType.value == _types[i];
                return GestureDetector(
                  onTap: () => _selectedType.value = _types[i],
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.dividerLight),
                    ),
                    child: Text(_types[i],
                        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          )),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) return const LoadingIndicator();
        final typeKey = _typeKeys[_types.indexOf(_selectedType.value)];
        final filtered = typeKey.isEmpty
            ? _logs
            : _logs.where((l) => (l['action'] ?? '').toString().contains(typeKey)).toList();
        if (filtered.isEmpty) {
          return const EmptyState(title: 'لا توجد سجلات', icon: Icons.history_rounded);
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _LogItem(log: filtered[i]),
          ),
        );
      }),
    );
  }
}

class _LogItem extends StatelessWidget {
  final Map<String, dynamic> log;
  const _LogItem({required this.log});

  static IconData _icon(String? action) {
    if (action == null) return Icons.info_outline;
    if (action.contains('Login')) return Icons.login_rounded;
    if (action.contains('Create')) return Icons.add_circle_outline;
    if (action.contains('Update') || action.contains('Edit')) return Icons.edit_outlined;
    if (action.contains('Delete')) return Icons.delete_outline;
    if (action.contains('Approve')) return Icons.check_circle_outline;
    if (action.contains('Reject')) return Icons.cancel_outlined;
    return Icons.circle_notifications_outlined;
  }

  static Color _color(String? action) {
    if (action == null) return AppColors.primaryLight;
    if (action.contains('Login')) return AppColors.primaryLight;
    if (action.contains('Create')) return AppColors.successLight;
    if (action.contains('Update') || action.contains('Edit')) return AppColors.warningLight;
    if (action.contains('Delete')) return AppColors.errorLight;
    if (action.contains('Approve')) return AppColors.accentLight;
    if (action.contains('Reject')) return AppColors.errorLight;
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final action = log['action']?.toString();
    final user = log['userName'] ?? log['performedBy'] ?? 'مستخدم';
    final details = log['details'] ?? log['description'] ?? '';
    final createdAt = log['createdAt'] != null ? DateTime.tryParse(log['createdAt'].toString()) : null;
    final color = _color(action);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon(action), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(action ?? 'نشاط', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    if (createdAt != null)
                      Text(Formatters.timeAgo(createdAt),
                          style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                Text(user, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.primary)),
                if (details.toString().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(details.toString(),
                      style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
