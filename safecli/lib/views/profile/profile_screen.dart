import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile_stats.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<ProfileController>(
        builder: (context, profileController, child) {
          final user = profileController.user;
          return profileController.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header مع خلفية متدرجة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 70),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                            Theme.of(context).colorScheme.tertiary,
                            Theme.of(context).colorScheme.tertiaryContainer,
                          ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // صورة المستخدم
                        _buildProfileImage(context, user, profileController),
                        const SizedBox(height: 15),
                        // اسم المستخدم
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // البريد الإلكتروني
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                              ),
                            ),
                            if (user.isEmailVerified)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // تاريخ الانضمام
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'منضم منذ ${_formatJoinDate(user.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // المحتوى الرئيسي (يظهر فوق الخلفية)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // الإحصائيات
                          ProfileStats(
                            scannedLinks: user.scannedLinks,
                            detectedThreats: user.detectedThreats,
                            accuracyRate: user.accuracyRate,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // خيارات الملف الشخصي
                          _buildProfileOptions(context, profileController),
                          
                          if (profileController.error != null)
                            _buildErrorWidget(context, profileController),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, user, ProfileController profileController) {
    return GestureDetector(
      onTap: () => _showImageOptions(context, profileController),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // الصورة مع حدود
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _getProfileImage(user),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _isLoadingImage
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
          ),
          // أيقونة الكاميرا
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(
    BuildContext context,
    ProfileController profileController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            context: context,
            icon: Icons.edit,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'تعديل الملف الشخصي',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _buildDivider(context),
          _buildOptionTile(
            context: context,
            icon: Icons.security,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'الأمان والخصوصية',
            onTap: () {},
          ),
          _buildDivider(context),
          _buildOptionTile(
            context: context,
            icon: Icons.notifications,
            iconColor: Theme.of(context).colorScheme.secondary,
            title: 'الإشعارات',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: Theme.of(context).colorScheme.primary,
              activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context: context,
            icon: Icons.language,
            iconColor: Theme.of(context).colorScheme.tertiary,
            title: 'اللغة',
            trailing: Text(
              'العربية',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {},
          ),
          _buildDivider(context),
          _buildOptionTile(
            context: context,
            icon: Icons.help_outline,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'المساعدة والدعم',
            onTap: () {},
          ),
          _buildDivider(context),
          _buildOptionTile(
            context: context,
            icon: Icons.logout,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'تسجيل الخروج',
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline,
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
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
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_forward_ios, 
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildErrorWidget(BuildContext context, ProfileController profileController) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              profileController.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: profileController.clearError,
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(user) {
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      try {
        return FileImage(File(user.profileImage!));
      } catch (e) {
        return const AssetImage('assets/images/default_profile.png');
      }
    }
    return const AssetImage('assets/images/default_profile.png');
  }

  void _showImageOptions(BuildContext context, ProfileController profileController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تغيير الصورة الشخصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'اختر من المعرض',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoadingImage = true);
                final image = await profileController.pickImageFromGallery();
                setState(() => _isLoadingImage = false);
                
                if (image != null && mounted) {
                  await profileController.updateProfileImage(image);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'التقاط صورة',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoadingImage = true);
                final image = await profileController.takePhoto();
                setState(() => _isLoadingImage = false);
                
                if (image != null && mounted) {
                  await profileController.updateProfileImage(image);
                }
              },
            ),
            const SizedBox(height: 10),
            if (profileController.user.profileImage != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              title: Text(
                'حذف الصورة',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                  Navigator.pop(context);
                  // حذف الصورة
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final authController = context.read<AuthController>();
              await authController.logout();
              if (context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'اليوم';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} يوم';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years سنة';
    }
  }
}
