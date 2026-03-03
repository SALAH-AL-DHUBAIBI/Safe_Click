import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/local_storage_service.dart';

class ReportController extends ChangeNotifier {
  List<ReportModel> _reports = [];
  bool _isReporting = false;
  bool _isLoading = false;
  String? _lastError;

  final LocalStorageService _storageService = LocalStorageService();

  List<ReportModel> get reports => List.unmodifiable(_reports);
  bool get isReporting => _isReporting;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  ReportController() {
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      final savedReports = await _storageService.getReports();
      _reports = savedReports;
    } catch (e) {
      _lastError = 'خطأ في تحميل البلاغات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport(ReportModel report) async {
    try {
      _isReporting = true;
      _lastError = null;
      notifyListeners();

      // إنشاء معرف فريد ورقم تتبع
      final reportWithId = ReportModel(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        link: report.link,
        category: report.category,
        description: report.description,
        reporterId: report.reporterId,
        reporterName: report.reporterName,
        reportDate: DateTime.now(),
        status: 'pending',
        trackingNumber: _generateTrackingNumber(),
        severity: report.severity ?? _calculateSeverity(report),
      );

      // محاكاة إرسال البلاغ
      await Future.delayed(const Duration(seconds: 2));

      // إضافة البلاغ للقائمة
      _reports.insert(0, reportWithId);
      
      // حفظ البلاغات
      await _storageService.saveReports(_reports);

      return true;
    } catch (e) {
      _lastError = 'حدث خطأ أثناء إرسال البلاغ';
      return false;
    } finally {
      _isReporting = false;
      notifyListeners();
    }
  }

  String _generateTrackingNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = 'RPT-';
    for (int i = 0; i < 8; i++) {
      result += chars[(random + i) % chars.length];
    }
    return result;
  }

  int _calculateSeverity(ReportModel report) {
    // حساب درجة الخطورة بناءً على التصنيف
    if (report.category.contains('فيروسات') || report.category.contains('تصيد')) {
      return 5;
    } else if (report.category.contains('احتيال')) {
      return 4;
    } else if (report.category.contains('غير لائق')) {
      return 3;
    } else if (report.category.contains('بريد عشوائي')) {
      return 2;
    }
    return 1;
  }

  Future<List<ReportModel>> getUserReports(String userId) async {
    return _reports.where((report) => report.reporterId == userId).toList();
  }

  Future<ReportModel?> getReportByTrackingNumber(String trackingNumber) async {
    try {
      return _reports.firstWhere(
        (report) => report.trackingNumber == trackingNumber,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshReports() async {
    await _loadReports();
  }

  Map<String, dynamic> getStats() {
    int pending = _reports.where((r) => r.status == 'pending').length;
    int reviewed = _reports.where((r) => r.status == 'reviewed').length;
    int resolved = _reports.where((r) => r.status == 'resolved').length;

    return {
      'total': _reports.length,
      'pending': pending,
      'reviewed': reviewed,
      'resolved': resolved,
    };
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
