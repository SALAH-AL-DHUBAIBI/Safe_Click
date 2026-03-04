// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:8000/api'; // للتطوير المحلي
  // للتطبيق على جهاز حقيقي، استخدم عنوان IP الخاص بجهاز الكمبيوتر
  // static const String baseUrl = 'http://192.168.1.x:8000/api';
  
  // للـ Android Emulator
  static const String baseUrl = 'http://192.168.8.110:8000/api';
  
  // للـ iOS Simulator
  // static const String baseUrl = 'http://localhost:8000/api';

  static Future<void> initialize() async {
    // يمكن إضافة أي منطق تهيئة هنا إذا لزم الأمر
    print('✅ ApiService initialized with baseUrl: $baseUrl');
  }

  // ========== دوال المساعدة ==========

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getMultipartHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      // لا نضيف Content-Type للملفات المتعددة
    };
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      print('❌ API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // ========== دوال المصادقة (Auth) ==========

  // استبدل دالة register بهذا الكود (بدون agreeToTerms)
Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirm,
}) async {
  print('🔵 [REGISTER] بداية تسجيل مستخدم جديد');
  
  try {
    final requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirm': passwordConfirm,
    };
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 201 && data['success'] == true) {
      if (data.containsKey('tokens')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['tokens']['access']);
        await prefs.setString('refresh_token', data['tokens']['refresh']);
      }
      return {'success': true, 'user': data['user']};
    } else {
      String errorMessage = 'فشل التسجيل';
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          errorMessage = errors.values.join('\n');
        } else if (errors is List) {
          errorMessage = errors.join('\n');
        }
      } else if (data.containsKey('message')) {
        errorMessage = data['message'];
      }
      return {'success': false, 'message': errorMessage};
    }
  } catch (e) {
    print('❌ Register error: $e');
    return {'success': false, 'message': 'فشل الاتصال بالخادم'};
  }
}

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _handleResponse(response);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // حفظ التوكن
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['tokens']['access']);
        await prefs.setString('refresh_token', data['tokens']['refresh']);
      }

      return data;
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'فشل الاتصال بالخادم'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getHeaders();
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: headers,
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      // مسح التوكن محلياً حتى لو فشل الطلب
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Logout error: $e');
      // مسح التوكن محلياً في حالة الخطأ
      final prefs = await SharedPreferences.getInstance();Future<Map<String, dynamic>> scanLink(String link) async {
  print('🔵 [SCAN] محاولة فحص رابط: $link');
  
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/scans/scan/'),
      headers: headers,
      body: jsonEncode({'link': link}),
    );
    
    print('🟢 [SCAN] Status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    // طباعة هيكل البيانات بالكامل
    print('📊 Data structure:');
    data.forEach((key, value) {
      print('   - $key: ${value.runtimeType} = $value');
    });
    
    return data;
  } catch (e) {
    print('🔴 [SCAN] خطأ: $e');
    return {'success': false, 'message': 'فشل الاتصال بالخادم'};
  }
}
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      return {'success': true, 'message': 'تم تسجيل الخروج'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: headers,
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Get profile error: $e');
      return {'success': false, 'message': 'فشل تحميل الملف الشخصي'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
  String? name,
  String? email,
}) async {
  try {
    final headers = await _getHeaders();
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  } catch (e) {
    print('❌ Update profile error: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}

  Future<Map<String, dynamic>> updateProfileImage(String imagePath) async {
  try {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/auth/profile/'),
    );
    
    request.headers.addAll(await _getMultipartHeaders());
    request.files.add(await http.MultipartFile.fromPath('profile_image', imagePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return jsonDecode(response.body);
  } catch (e) {
    print('❌ Update profile image error: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password/'),
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        }),
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Change password error: $e');
      return {'success': false, 'message': 'فشل تغيير كلمة المرور'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Forgot password error: $e');
      return {'success': false, 'message': 'فشل إرسال بريد إعادة التعيين'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        }),
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Reset password error: $e');
      return {'success': false, 'message': 'فشل إعادة تعيين كلمة المرور'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-email/?token=$token'),
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Verify email error: $e');
      return {'success': false, 'message': 'فشل تفعيل البريد الإلكتروني'};
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/settings/'),
        headers: headers,
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Get settings error: $e');
      return {'success': false, 'message': 'فشل تحميل الإعدادات'};
    }
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/settings/'),
        headers: headers,
        body: jsonEncode(settings),
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Update settings error: $e');
      return {'success': false, 'message': 'فشل تحديث الإعدادات'};
    }
  }

  // ========== دوال فحص الروابط (Scans) ==========

  Future<Map<String, dynamic>> scanLink(String link) async {
  print('🔵 [SCAN] محاولة فحص رابط: $link');
  
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/scans/scan/'),
      headers: headers,
      body: jsonEncode({'link': link}),
    );
    
    print('🟢 [SCAN] Status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    // طباعة هيكل البيانات بالكامل
    print('📊 Data structure:');
    data.forEach((key, value) {
      print('   - $key: ${value.runtimeType} = $value');
    });
    
    return data;
  } catch (e) {
    print('🔴 [SCAN] خطأ: $e');
    return {'success': false, 'message': 'فشل الاتصال بالخادم'};
  }
}

  Future<Map<String, dynamic>> getScanHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/scans/history/'),
        headers: headers,
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Get scan history error: $e');
      return {'success': false, 'message': 'فشل تحميل سجل الفحوصات', 'history': []};
    }
  }

  Future<Map<String, dynamic>> getScanDetail(String scanId) async {
  print('🔵 [SCAN DETAIL] جلب تفاصيل الفحص: $scanId');
  
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/scans/history/$scanId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'فشل تحميل تفاصيل الفحص'};
    }
  } catch (e) {
    print('❌ Get scan detail error: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}

  Future<Map<String, dynamic>> deleteScan(String scanId) async {
  print('🔵 [DELETE SCAN] حذف فحص: $scanId');
  
  try {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/scans/history/$scanId/delete/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'فشل حذف الفحص'};
    }
  } catch (e) {
    print('❌ Delete scan error: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}

  Future<Map<String, dynamic>> clearHistory() async {
  print('🔵 [CLEAR HISTORY] مسح سجل الفحوصات');
  
  try {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/scans/history/clear/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'فشل مسح السجل'};
    }
  } catch (e) {
    print('❌ Clear history error: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}




  Future<Map<String, dynamic>> getScanStats() async {
  print('🔵 [SCAN STATS] جلب إحصائيات الفحوصات');
  
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/scans/stats/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'فشل تحميل الإحصائيات'};
    }
  } catch (e) {
    print('❌ Get scan stats error: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}
  // ========== دوال البلاغات (Reports) ==========

  Future<Map<String, dynamic>> createReport({
  required String link,
  required String category,
  String? description,
  int severity = 3,
  bool isAnonymous = false,
}) async {
  print('\n🔵 ===== إرسال بلاغ جديد =====');
  print('📍 الرابط: $link');
  print('🏷️ الفئة: $category');
  print('🌐 URL: $baseUrl/reports/create/');  // تأكد من هذا السطر
  
  try {
    final headers = await _getHeaders();
    print('🔐 Headers: $headers');
    
    final body = {
      'link': link,
      'category': category,
      'description': description ?? '',
      'severity': severity,
      'is_anonymous': isAnonymous,
    };
    
    print('📦 البيانات المرسلة: ${jsonEncode(body)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/reports/create/'),  // تأكد من هذا المسار
      headers: headers,
      body: jsonEncode(body),
    );

    print('📥 حالة الاستجابة: ${response.statusCode}');
    print('📥 محتوى الرد: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ تم إرسال البلاغ بنجاح!');
      return data;
    } else {
      print('❌ فشل إرسال البلاغ');
      return {'success': false, 'message': 'فشل إرسال البلاغ'};
    }
  } catch (e) {
    print('❌ خطأ في الاتصال: $e');
    return {'success': false, 'message': 'فشل الاتصال'};
  }
}

  Future<Map<String, dynamic>> trackReport(String trackingNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/track/$trackingNumber/'),
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Track report error: $e');
      return {'success': false, 'message': 'فشل تتبع البلاغ'};
    }
  }

  Future<Map<String, dynamic>> getMyReports() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reports/my-reports/'),
        headers: headers,
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Get my reports error: $e');
      return {'success': false, 'message': 'فشل تحميل البلاغات', 'reports': []};
    }
  }

  Future<Map<String, dynamic>> getReportDetail(String reportId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reports/$reportId/'),
        headers: headers,
      );

      _handleResponse(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Get report detail error: $e');
      return {'success': false, 'message': 'فشل تحميل تفاصيل البلاغ'};
    }
  }

  // ========== دوال فحص الروابط (Scans) - إضافة دالة scanUrl ==========

Future<Map<String, dynamic>> scanUrl(String url) async {
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/scans/scan/'),
      headers: headers,
      body: jsonEncode({'link': url}),
    );

    _handleResponse(response);
    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final result = data['result'];
      // تحويل النتيجة إلى الشكل المطلوب
      return {
        'safe': result['safe'],
        'score': result['score'],
        'message': result['message'] ?? (result['safe'] == true ? 'الرابط آمن' : 'الرابط خطير'),
        'details': result['details'] ?? [],
        'responseTime': result['response_time'] ?? 0.0,
        'ipAddress': result['ip_address'],
        'domain': result['domain'],
        'threatsCount': result['threats_count'] ?? 0,
      };
    } else {
      // إذا فشل API، نعيد نتيجة افتراضية
      return {
        'safe': null,
        'score': 50,
        'message': data['message'] ?? 'فشل الفحص',
        'details': ['تعذر الفحص عبر الخادم', 'سيتم استخدام الفحص المحلي'],
        'responseTime': 0.0,
        'ipAddress': null,
        'domain': null,
        'threatsCount': 0,
      };
    }
  } catch (e) {
    print('❌ Scan URL error: $e');
    // في حالة الخطأ، نعيد نتيجة افتراضية
    return {
      'safe': null,
      'score': 50,
      'message': 'خطأ في الاتصال بالخادم',
      'details': ['حدث خطأ في الاتصال بالخادم', 'جاري استخدام الفحص المحلي'],
      'responseTime': 0.0,
      'ipAddress': null,
      'domain': null,
      'threatsCount': 0,
    };
  }
}
}

