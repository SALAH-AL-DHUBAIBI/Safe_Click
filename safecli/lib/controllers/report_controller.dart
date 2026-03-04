// lib/controllers/report_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/report_model.dart';

class ReportController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ReportModel> _reports = [];
  bool _isReporting = false;
  String? _lastError;

  List<ReportModel> get reports => List.unmodifiable(_reports);
  bool get isReporting => _isReporting;
  String? get lastError => _lastError;

  // دالة جديدة تستقبل بيانات منفصلة
  Future<bool> submitReport({
    required String link,
    required String category,
    required String description,
    required int severity,
    required String reporterName,
  }) async {
    _isReporting = true;
    _lastError = null;
    notifyListeners();

    try {
      print('🔵 إرسال بلاغ: $link - $category');
      
      final response = await _apiService.createReport(
        link: link,
        category: category,
        description: description,
        severity: severity,
        isAnonymous: reporterName == 'مستخدم مجهول',
      );

      print('📥 الرد: $response');

      if (response['success'] == true) {
        // إضافة البلاغ إلى القائمة
        if (response['report'] != null) {
          final newReport = ReportModel.fromJson(response['report']);
          _reports.insert(0, newReport);
        }
        
        // جلب البلاغات المحدثة
        await fetchMyReports();
        
        return true;
      } else {
        _lastError = response['message'] ?? 'فشل إرسال البلاغ';
        return false;
      }
    } catch (e) {
      print('❌ خطأ: $e');
      _lastError = 'حدث خطأ في الاتصال بالخادم';
      return false;
    } finally {
      _isReporting = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyReports() async {
    try {
      final response = await _apiService.getMyReports();
      if (response['success'] == true) {
        final List<dynamic> reportsJson = response['reports'] ?? [];
        _reports = reportsJson.map((json) => ReportModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ خطأ في جلب البلاغات: $e');
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}