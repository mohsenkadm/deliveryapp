import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class BranchesController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final branches = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final search = ''.obs;

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final regionCtrl = TextEditingController();
  final isActive = true.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    regionCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      branches.value = await _ds.getBranches(search: search.value);
    } catch (_) {
      branches.clear();
    }
    isLoading.value = false;
  }

  void clearForm() {
    nameCtrl.clear();
    addressCtrl.clear();
    phoneCtrl.clear();
    regionCtrl.clear();
    isActive.value = true;
  }

  void fill(Map<String, dynamic> b) {
    nameCtrl.text = (b['name'] ?? '').toString();
    addressCtrl.text = (b['address'] ?? '').toString();
    phoneCtrl.text = (b['phone'] ?? '').toString();
    regionCtrl.text = (b['region'] ?? '').toString();
    isActive.value = (b['isActive'] as bool?) ?? true;
  }

  Map<String, dynamic> _payload({bool includeActive = false}) => {
        'name': nameCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'region': regionCtrl.text.trim(),
        if (includeActive) 'isActive': isActive.value,
      };

  Future<bool> create() async {
    if (!formKey.currentState!.validate()) return false;
    isSubmitting.value = true;
    try {
      await _ds.createBranch(_payload());
      SnackbarHelper.showSuccess('تم إضافة الفرع');
      await load();
      return true;
    } catch (_) {
      SnackbarHelper.showError('فشلت الإضافة');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> save(String id) async {
    if (!formKey.currentState!.validate()) return false;
    isSubmitting.value = true;
    try {
      await _ds.updateBranch(id, _payload(includeActive: true));
      SnackbarHelper.showSuccess('تم تحديث الفرع');
      await load();
      return true;
    } catch (_) {
      SnackbarHelper.showError('فشل التحديث');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _ds.deleteBranch(id);
      SnackbarHelper.showSuccess('تم حذف الفرع');
      await load();
    } catch (_) {
      SnackbarHelper.showError('فشل الحذف');
    }
  }
}
