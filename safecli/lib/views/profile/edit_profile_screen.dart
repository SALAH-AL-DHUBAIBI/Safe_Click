import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profileController = context.read<ProfileController>();
    final user = profileController.user;

    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: '');

    _nameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final profileController = context.read<ProfileController>();
    final user = profileController.user;

    final nameChanged = _nameController.text != user.name;
    final emailChanged = _emailController.text != user.email;

    if (_hasChanges != (nameChanged || emailChanged)) {
      setState(() {
        _hasChanges = nameChanged || emailChanged;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.read<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : () => _saveProfile(profileController),
              child: Text(
                'حفظ',
                style: TextStyle(
                  color: _isLoading 
                      ? Colors.white.withValues(alpha: 0.5) 
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileImage(profileController),
                    const SizedBox(height: 30),
                    _buildForm(),
                    const SizedBox(height: 30),
                    _buildSaveButton(profileController),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImage(ProfileController profileController) {
    return GestureDetector(
      onTap: () => _showImageOptions(context, profileController),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary, 
                width: 3
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundImage: _getProfileImage(profileController.user),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _profileImage == null && profileController.user.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الاسم مطلوب';
              }
              if (value.length < 3) {
                return 'الاسم قصير جداً';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'البريد الإلكتروني مطلوب';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف (اختياري)',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          icon, 
          color: Theme.of(context).colorScheme.primary
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary, 
            width: 2
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSaveButton(ProfileController profileController) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _hasChanges && !_isLoading
            ? () => _saveProfile(profileController)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          'حفظ التغييرات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(user) {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
                final image = await profileController.pickImageFromGallery();
                if (image != null && mounted) {
                  setState(() {
                    _profileImage = image;
                    _hasChanges = true;
                  });
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.secondary,
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
                final image = await profileController.takePhoto();
                if (image != null && mounted) {
                  setState(() {
                    _profileImage = image;
                    _hasChanges = true;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            if (_profileImage != null || profileController.user.profileImage != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
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
                  setState(() {
                    _profileImage = null;
                    _hasChanges = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(ProfileController profileController) async {
    setState(() => _isLoading = true);

    bool success = true;
    String? errorMessage;

    // تحديث الاسم إذا تغير
    if (_nameController.text != profileController.user.name) {
      success = await profileController.updateName(_nameController.text.trim());
      if (!success) errorMessage = 'فشل تحديث الاسم';
    }

    // تحديث البريد الإلكتروني إذا تغير ونجحت العملية السابقة
    if (success && _emailController.text != profileController.user.email) {
      success = await profileController.updateEmail(_emailController.text.trim());
      if (!success) errorMessage = 'فشل تحديث البريد الإلكتروني';
    }

    // تحديث الصورة إذا تغيرت ونجحت العمليات السابقة
    if (success && _profileImage != null) {
      success = await profileController.updateProfileImage(_profileImage!);
      if (!success) errorMessage = 'فشل تحديث الصورة';
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'حدث خطأ أثناء الحفظ'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showExitDialog(BuildContext context) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'تجاهل التغييرات؟',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            'لديك تغييرات غير محفوظة. هل تريد تجاهلها؟',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('تجاهل'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
