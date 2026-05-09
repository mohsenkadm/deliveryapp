import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/admin_remote_datasource.dart';

/// صفحة مصفوفة صلاحيات المسؤولين — قائمة بالأدمن، اختيار أحدهم لتعديل
/// صلاحياته على كل صفحة (عرض/إضافة/تعديل/حذف).
class AdminPermissionsPage extends StatefulWidget {
  const AdminPermissionsPage({super.key});

  @override
  State<AdminPermissionsPage> createState() => _AdminPermissionsPageState();
}

class _AdminPermissionsPageState extends State<AdminPermissionsPage> {
  late final AdminRemoteDataSource _ds =
      AdminRemoteDataSource(Get.find<DioClient>());

  bool _loadingAdmins = true;
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => _loadingAdmins = true);
    try {
      _admins = await _ds.getAdmins();
    } catch (e) {
      SnackbarHelper.showError('تعذر تحميل المسؤولين');
    } finally {
      if (mounted) setState(() => _loadingAdmins = false);
    }
  }

  void _openEditor(Map<String, dynamic> admin) {
    Get.to(() => _PermissionsEditor(admin: admin, ds: _ds));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صلاحيات المسؤولين',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: _loadingAdmins
          ? const Center(child: CircularProgressIndicator())
          : _admins.isEmpty
              ? Center(
                  child: Text('لا يوجد مسؤولون',
                      style: GoogleFonts.cairo()),
                )
              : RefreshIndicator(
                  onRefresh: _loadAdmins,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _admins.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final a = _admins[i];
                      final name = (a['fullName'] ?? a['name'] ?? a['username'] ?? '').toString();
                      final username = (a['username'] ?? '').toString();
                      final isActive = a['isActive'] != false;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? Colors.green.shade100
                                : Colors.grey.shade300,
                            child: Icon(
                              Icons.admin_panel_settings_rounded,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text(name.isEmpty ? username : name,
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                          subtitle: Text(username, style: GoogleFonts.cairo(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openEditor(a),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _PermissionsEditor extends StatefulWidget {
  final Map<String, dynamic> admin;
  final AdminRemoteDataSource ds;
  const _PermissionsEditor({required this.admin, required this.ds});

  @override
  State<_PermissionsEditor> createState() => _PermissionsEditorState();
}

class _PermissionsEditorState extends State<_PermissionsEditor> {
  bool _loading = true;
  bool _saving = false;
  // قائمة قابلة للتعديل: كل عنصر يحوي pageName + canView/Add/Edit/Delete
  List<Map<String, dynamic>> _perms = [];

  String get _adminId => widget.admin['id'].toString();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final fetched = await widget.ds.getAdminPermissions(_adminId);
      _perms = fetched
          .map((p) => <String, dynamic>{
                'pageName': p['pageName'] ?? p['page'] ?? '',
                'canView': p['canView'] == true,
                'canAdd': p['canAdd'] == true,
                'canEdit': p['canEdit'] == true,
                'canDelete': p['canDelete'] == true,
              })
          .toList();
    } catch (e) {
      SnackbarHelper.showError('تعذر تحميل الصلاحيات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.ds.updateAdminPermissions(_adminId, _perms);
      SnackbarHelper.showSuccess('تم حفظ الصلاحيات');
    } catch (e) {
      SnackbarHelper.showError('تعذر الحفظ');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleAll(int row, bool value) {
    setState(() {
      _perms[row]['canView'] = value;
      _perms[row]['canAdd'] = value;
      _perms[row]['canEdit'] = value;
      _perms[row]['canDelete'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.admin['fullName'] ?? widget.admin['username'] ?? '').toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('صلاحيات: $name',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          IconButton(
            tooltip: 'حفظ',
            onPressed: _saving || _loading ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _perms.isEmpty
              ? Center(
                  child: Text('لا توجد صفحات معرّفة',
                      style: GoogleFonts.cairo()))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    child: DataTable(
                      columnSpacing: 18,
                      headingTextStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      columns: const [
                        DataColumn(label: Text('الصفحة')),
                        DataColumn(label: Text('عرض')),
                        DataColumn(label: Text('إضافة')),
                        DataColumn(label: Text('تعديل')),
                        DataColumn(label: Text('حذف')),
                        DataColumn(label: Text('الكل')),
                      ],
                      rows: List.generate(_perms.length, (i) {
                        final p = _perms[i];
                        final allOn = p['canView'] == true &&
                            p['canAdd'] == true &&
                            p['canEdit'] == true &&
                            p['canDelete'] == true;
                        return DataRow(cells: [
                          DataCell(Text(p['pageName'].toString(),
                              style: GoogleFonts.cairo(fontSize: 12))),
                          DataCell(Checkbox(
                            value: p['canView'] == true,
                            onChanged: (v) => setState(() => p['canView'] = v ?? false),
                          )),
                          DataCell(Checkbox(
                            value: p['canAdd'] == true,
                            onChanged: (v) => setState(() => p['canAdd'] = v ?? false),
                          )),
                          DataCell(Checkbox(
                            value: p['canEdit'] == true,
                            onChanged: (v) => setState(() => p['canEdit'] = v ?? false),
                          )),
                          DataCell(Checkbox(
                            value: p['canDelete'] == true,
                            onChanged: (v) => setState(() => p['canDelete'] = v ?? false),
                          )),
                          DataCell(Switch(
                            value: allOn,
                            onChanged: (v) => _toggleAll(i, v),
                          )),
                        ]);
                      }),
                    ),
                  ),
                ),
    );
  }
}
