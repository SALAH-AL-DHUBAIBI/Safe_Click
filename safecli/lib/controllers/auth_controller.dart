import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  final LocalStorageService _storageService = LocalStorageService();

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

      final startTime = DateTime.now();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('authToken');

      if (userId != null && token != null) {
        // يمكن التحقق من صحة التوكن هنا
        _isAuthenticated = true;
        // تحميل بيانات المستخدم
        await loadUserData(userId);
      }

      final elapsed = DateTime.now().difference(startTime);
      const minDuration = Duration(milliseconds: 2500);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
    } catch (e) {
      _error = 'خطأ في تحميل بيانات المستخدم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserData(String userId) async {
    try {
      final userData = await _storageService.getUser(userId);
      if (userData != null) {
        _currentUser = userData;
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'خطأ في تحميل بيانات المستخدم';
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // محاكاة تسجيل الدخول - استبدلها بـ API حقيقي
      await Future.delayed(const Duration(seconds: 2));

      // التحقق من المدخلات
      if (email.isEmpty || password.isEmpty) {
        throw Exception('البريد الإلكتروني وكلمة المرور مطلوبان');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      // محاكاة مستخدم
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email,
        createdAt: DateTime.now(),
      );

      _isAuthenticated = true;

      // حفظ بيانات المستخدم محلياً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);
      await prefs.setString('authToken', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      
      await _storageService.saveUser(_currentUser!);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('جميع الحقول مطلوبة');
      }

      if (!email.contains('@')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);
      await prefs.setString('authToken', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      
      await _storageService.saveUser(_currentUser!);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('authToken');

      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'خطأ في تسجيل الخروج';
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

      await Future.delayed(const Duration(seconds: 2));

      if (email.isEmpty || !email.contains('@')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      // محاكاة إرسال بريد إعادة تعيين كلمة المرور
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
}
