import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class ProfileController extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  final LocalStorageService _storageService = LocalStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  UserModel get user {
    _user ??= UserModel(
        id: 'user_123',
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        scannedLinks: 150,
        detectedThreats: 23,
        accuracyRate: 98.5,
        isEmailVerified: true,
      );
    return _user!;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileController() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final savedUser = await _storageService.getUser('current_user');
      if (savedUser != null) {
        _user = savedUser;
      }
    } catch (e) {
      _error = 'خطأ في تحميل بيانات المستخدم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'خطأ في اختيار الصورة';
      notifyListeners();
      return null;
    }
  }

  Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'خطأ في التقاط الصورة';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProfileImage(File image) async {
    try {
      _isLoading = true;
      notifyListeners();

      // حفظ الصورة في التخزين المحلي
      final imagePath = await _storageService.saveProfileImage(image, user.id);
      
      _user = user.copyWith(profileImage: imagePath);
      await _storageService.saveUser(_user!);

      return true;
    } catch (e) {
      _error = 'خطأ في تحديث الصورة';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateName(String newName) async {
    try {
      if (newName.isEmpty) {
        throw Exception('الاسم لا يمكن أن يكون فارغاً');
      }

      _isLoading = true;
      notifyListeners();

      _user = user.copyWith(name: newName);
      await _storageService.saveUser(_user!);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    try {
      if (newEmail.isEmpty || !newEmail.contains('@')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      _isLoading = true;
      notifyListeners();

      _user = user.copyWith(email: newEmail, isEmailVerified: false);
      await _storageService.saveUser(_user!);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementScannedLinks() async {
    _user = user.copyWith(scannedLinks: user.scannedLinks + 1);
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> incrementDetectedThreats() async {
    final newThreats = user.detectedThreats + 1;
    final newAccuracy = _calculateAccuracy(user.scannedLinks + 1, newThreats);
    
    _user = user.copyWith(
      detectedThreats: newThreats,
      accuracyRate: newAccuracy,
    );
    
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  double _calculateAccuracy(int scanned, int threats) {
    if (scanned == 0) return 100.0;
    return ((scanned - threats) / scanned * 100).clamp(0, 100);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
