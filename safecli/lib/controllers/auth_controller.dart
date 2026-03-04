import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart'; // استيراد API service

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  final LocalStorageService _storageService = LocalStorageService();
  final ApiService _apiService = ApiService();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthController() {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
  try {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      final response = await _apiService.getProfile();
      
      // تعديل هنا: استخدم == true
      if (response['success'] == true && response.containsKey('user')) {
        _currentUser = UserModel.fromJson(response['user']);
        _isAuthenticated = true;
      } else {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      }
    }
  } catch (e) {
    print('خطأ في تحميل المستخدم: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<bool> login(String email, String password) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiService.login(email: email, password: password);

    // تعديل هنا: استخدم == true
    if (response['success'] == true) {
      _currentUser = UserModel.fromJson(response['user']);
      _isAuthenticated = true;
      return true;
    } else {
      _error = response['message'];
      return false;
    }
  } catch (e) {
    _error = 'حدث خطأ في الاتصال';
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // استبدل دالة register بهذا الكود (بدون agreeToTerms)
// في auth_controller.dart
Future<bool> register(
  String name, 
  String email, 
  String password, 
  {required bool agreeToTerms}  // أضف هذا
) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!agreeToTerms) {  // تحقق من الموافقة
      _error = 'يجب الموافقة على الشروط والأحكام';
      return false;
    }

    if (password.length < 6) {
      _error = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      return false;
    }

    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirm: password,
    );

    if (response['success'] == true) {
      _currentUser = UserModel.fromJson(response['user']);
      _isAuthenticated = true;
      return true;
    } else {
      _error = response['message'];
      return false;
    }
  } catch (e) {
    _error = 'حدث خطأ في الاتصال';
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.logout();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.forgotPassword(email);

      if (response['success']) {
        return true;
      } else {
        _error = response['message'] ?? 'فشل إرسال بريد إعادة التعيين';
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ في الاتصال بالخادم';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? name, String? email}) async {
  try {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.updateProfile(name: name, email: email);

    if (response['success'] == true && response.containsKey('user')) {
      _currentUser = UserModel.fromJson(response['user']);
      return true;
    } else {
      _error = response['message'] ?? 'فشل تحديث البيانات';
      return false;
    }
  } catch (e) {
    _error = 'حدث خطأ في الاتصال';
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<bool> updateProfileImage(String imagePath) async {
  try {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.updateProfileImage(imagePath);

    if (response['success'] == true && response.containsKey('user')) {
      _currentUser = UserModel.fromJson(response['user']);
      return true;
    } else {
      _error = response['message'] ?? 'فشل تحديث الصورة';
      return false;
    }
  } catch (e) {
    _error = 'حدث خطأ في الاتصال';
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );

      if (response['success']) {
        return true;
      } else {
        _error = response['message'] ?? 'فشل تغيير كلمة المرور';
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ في الاتصال بالخادم';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  // أضف هذه الدوال المساعدة في نهاية الكلاس
String? get userProfileImage => _currentUser?.profileImage;
String get userName => _currentUser?.name ?? '';
String get userEmail => _currentUser?.email ?? '';
int get userScansCount => _currentUser?.scannedLinks ?? 0;
int get userThreatsCount => _currentUser?.detectedThreats ?? 0;
double get userAccuracyRate => _currentUser?.accuracyRate ?? 0.0;
bool get isEmailVerified => _currentUser?.isEmailVerified ?? false;
String get welcomeMessage => _isAuthenticated ? 'مرحباً، ${_currentUser?.name ?? ''}' : 'مرحباً بك';
}