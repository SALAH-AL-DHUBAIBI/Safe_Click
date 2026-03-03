import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return settingsController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildGeneralSection(settingsController),
                const SizedBox(height: 20),
                _buildProtectionSection(settingsController),
                const SizedBox(height: 20),
                _buildScanSettingsSection(settingsController),
                const SizedBox(height: 20),
                _buildAppearanceSection(settingsController),
                const SizedBox(height: 20),
                _buildAboutSection(context),
                const SizedBox(height: 20),
                _buildDangerZone(context, settingsController),
              ],
            );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.tertiary, Theme.of(context).colorScheme.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: Theme.of(context).colorScheme.onTertiary, size: 30),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإعدادات',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'خصص التطبيق حسب احتياجاتك',
                style: TextStyle(color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: 0.7), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(SettingsController controller) {
    return _buildSection(
      title: 'عام',
      icon: Icons.settings_applications,
      children: [
        _buildSwitchTile(
          title: 'المسح التلقائي',
          subtitle: 'فحص الروابط تلقائياً عند النسخ',
          value: controller.settings.autoScan,
          icon: Icons.auto_fix_high,
          onChanged: (value) => controller.toggleAutoScan(value),
        ),
        _buildSwitchTile(
          title: 'الإشعارات',
          subtitle: 'إشعارات عند اكتشاف روابط ضارة',
          value: controller.settings.notifications,
          icon: Icons.notifications,
          onChanged: (value) => controller.toggleNotifications(value),
        ),
        _buildSwitchTile(
          title: 'حفظ السجل',
          subtitle: 'حفظ سجل الفحوصات السابقة',
          value: controller.settings.saveHistory,
          icon: Icons.save,
          onChanged: (value) => controller.toggleSaveHistory(value),
        ),
        _buildLanguageTile(controller),
      ],
    );
  }

  Widget _buildProtectionSection(SettingsController controller) {
    return _buildSection(
      title: 'الحماية',
      icon: Icons.security,
      children: [
        _buildSwitchTile(
          title: 'التصفح الآمن',
          subtitle: 'حظر المواقع الضارة تلقائياً',
          value: controller.settings.safeBrowsing,
          icon: Icons.shield,
          onChanged: (value) => controller.toggleSafeBrowsing(value),
        ),
        _buildSwitchTile(
          title: 'التحديث التلقائي',
          subtitle: 'تحديث قواعد البيانات تلقائياً',
          value: controller.settings.autoUpdate,
          icon: Icons.update,
          onChanged: (value) => controller.toggleAutoUpdate(value),
        ),
      ],
    );
  }

  Widget _buildScanSettingsSection(SettingsController controller) {
    return _buildSection(
      title: 'إعدادات الفحص',
      icon: Icons.search,
      children: [
        _buildSliderTile(
          title: 'مهلة الفحص',
          value: controller.settings.scanTimeout.toDouble(),
          min: 10,
          max: 60,
          divisions: 5,
          onChanged: (value) => controller.setScanTimeout(value.toInt()),
        ),
        _buildScanLevelTile(controller),
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsController controller) {
    return _buildSection(
      title: 'المظهر',
      icon: Icons.palette,
      children: [
        _buildSwitchTile(
          title: 'الوضع الداكن',
          subtitle: 'تفعيل الوضع الداكن للتطبيق',
          value: controller.settings.darkMode,
          icon: Icons.dark_mode,
          onChanged: (value) => controller.toggleDarkMode(value),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: 'حول التطبيق',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          title: 'إصدار التطبيق',
          value: '1.0.0',
          icon: Icons.tag,
        ),
        _buildInfoTile(
          title: 'آخر تحديث',
          value: 'يناير 2024',
          icon: Icons.update,
        ),
        _buildActionTile(
          title: 'تقييم التطبيق',
          icon: Icons.star,
          iconColor: Theme.of(context).colorScheme.primary,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'مشاركة التطبيق',
          icon: Icons.share,
          iconColor: Theme.of(context).colorScheme.secondary,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'سياسة الخصوصية',
          icon: Icons.privacy_tip,
          iconColor: Theme.of(context).colorScheme.tertiary,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'الشروط والأحكام',
          icon: Icons.description,
          iconColor: Theme.of(context).colorScheme.primary,
          onTap: () {},
        ),
        _buildActionTile(
          title: 'الدعم الفني',
          icon: Icons.contact_support,
          iconColor: Theme.of(context).colorScheme.secondary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'منطقة الخطر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.error),
          ListTile(
            leading: Icon(Icons.restore, color: Theme.of(context).colorScheme.error),
            title: Text(
              'إعادة ضبط الإعدادات',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('إعادة جميع الإعدادات إلى الوضع الافتراضي'),
            onTap: () => _showResetDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      activeThumbColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildLanguageTile(SettingsController controller) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
      ),
      title: const Text('اللغة'),
      subtitle: Text(controller.settings.language == 'ar' ? 'العربية' : 'English'),
      trailing: DropdownButton<String>(
        value: controller.settings.language,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.changeLanguage(value);
          }
        },
      ),
    );
  }

  Widget _buildScanLevelTile(SettingsController controller) {
    Map<String, String> levelNames = {
      'basic': 'أساسي',
      'standard': 'قياسي',
      'deep': 'عميق',
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.speed, color: Theme.of(context).colorScheme.primary),
      ),
      title: const Text('مستوى الفحص'),
      subtitle: Text(levelNames[controller.settings.scanLevel] ?? 'قياسي'),
      trailing: DropdownButton<String>(
        value: controller.settings.scanLevel,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'basic', child: Text('أساسي')),
          DropdownMenuItem(value: 'standard', child: Text('قياسي')),
          DropdownMenuItem(value: 'deep', child: Text('عميق')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setScanLevel(value);
          }
        },
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text('${value.toInt()} ثانية'),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط الإعدادات'),
        content: const Text(
          'هل أنت متأكد من إعادة ضبط جميع الإعدادات إلى القيم الافتراضية؟ لا يمكن التراجع عن هذا الإجراء.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: const Text('تم إعادة ضبط الإعدادات'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('إعادة الضبط'),
          ),
        ],
      ),
    );
  }
}
