import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanService {
  final ApiService _apiService = ApiService();

  Future<ScanResult?> scanUrl(String url) async {
    try {
      // التحقق من الرابط محلياً أولاً
      final localCheck = await _checkLocalBlacklist(url);
      if (localCheck != null) {
        return localCheck;
      }

      // فحص الرابط عبر API
      final apiResult = await _apiService.scanUrl(url);

      // إنشاء نتيجة الفحص
      final result = ScanResult(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        link: url,
        safe: apiResult['safe'],
        score: apiResult['score'],
        message: apiResult['message'],
        details: List<String>.from(apiResult['details']),
        timestamp: DateTime.now(),
        rawData: apiResult,
        responseTime: apiResult['responseTime']?.toDouble() ?? 0.0,
        ipAddress: apiResult['ipAddress'],
        domain: apiResult['domain'],
        threatsCount: apiResult['threatsCount'],
      );

      // تحديث القائمة السوداء المحلية
      if (!result.safe!) {
        await _addToLocalBlacklist(url);
      }

      return result;
    } catch (e) {
      debugPrint('خطأ في فحص الرابط: $e');
      
      // في حالة الخطأ، نعيد نتيجة افتراضية
      return ScanResult(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        link: url,
        safe: null,
        score: 50,
        message: 'تعذر الفحص، يرجى المحاولة لاحقاً',
        details: ['حدث خطأ أثناء الفحص', 'قد يكون الرابط غير متاح أو هناك مشكلة في الاتصال'],
        timestamp: DateTime.now(),
      );
    }
  }

  Future<ScanResult?> _checkLocalBlacklist(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blacklist = prefs.getStringList('local_blacklist') ?? [];
      
      final domain = Uri.tryParse(url)?.host ?? url;
      
      if (blacklist.contains(domain)) {
        return ScanResult(
          id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
          link: url,
          safe: false,
          score: 0,
          message: 'الرابط محظور محلياً',
          details: ['تم الإبلاغ عن هذا الرابط سابقاً', 'يرجى توخي الحذر'],
          timestamp: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _addToLocalBlacklist(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blacklist = prefs.getStringList('local_blacklist') ?? [];
      
      final domain = Uri.tryParse(url)?.host ?? url;
      
      if (!blacklist.contains(domain)) {
        blacklist.add(domain);
        await prefs.setStringList('local_blacklist', blacklist);
      }
    } catch (e) {
      debugPrint('خطأ في إضافة الرابط للقائمة السوداء: $e');
    }
  }

  Future<bool> isUrlSafe(String url) async {
    try {
      final result = await scanUrl(url);
      return result?.safe ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> analyzeUrl(String url) async {
    try {
      // تحليل الرابط بشكل أعمق
      final uri = Uri.parse(url);
      
      return {
        'protocol': uri.scheme,
        'domain': uri.host,
        'port': uri.port,
        'path': uri.path,
        'query': uri.query,
        'hasSubdomain': uri.host.split('.').length > 2,
        'isIpAddress': RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(uri.host),
        'hasHttps': uri.scheme == 'https',
      };
    } catch (e) {
      return {};
    }
  }
}
