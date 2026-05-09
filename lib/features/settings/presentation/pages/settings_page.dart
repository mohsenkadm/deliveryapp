import 'package:flutter/material.dart';

import '../widgets/role_settings_tab.dart';

/// Standalone settings route that delegates to the unified [RoleSettingsTab]
/// design used across all roles.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const RoleSettingsTab();
}
