import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeclik/core/network/report_api.dart';
import 'package:safeclik/features/report/data/models/report_model.dart';
import 'package:safeclik/core/di/di.dart';
import 'package:flutter/foundation.dart';

final reportProvider = AsyncNotifierProvider<ReportNotifier, List<ReportModel>>(
  () => ReportNotifier(),
);

class ReportNotifier extends AsyncNotifier<List<ReportModel>> {
  final ReportApi _reportApi = sl<ReportApi>();
  String? _lastError;
  bool _isReporting = false;

  String? get lastError => _lastError;
  bool get isReporting => _isReporting;

  @override
  Future<List<ReportModel>> build() async {
    return _fetchMyReports();
  }

  Future<List<ReportModel>> _fetchMyReports() async {
    try {
      final response = await _reportApi.getMyReports();
      if (response['success'] == true) {
        final List<dynamic> reportsJson = response['reports'] ?? [];
        return reportsJson.map((json) => ReportModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب البلاغات: $e');
    }
    return [];
  }
  
  Future<bool> submitReport({
    required String link,
    required String category,
    required String description,
    required int severity,
    required String reporterName,
  }) async {
    // Phase B: Multiple Request Protection
    if (_isReporting || state.isLoading) return false;

    _isReporting = true;
    _lastError = null;
    
    try {
      debugPrint('🔵 إرسال بلاغ: $link - $category');
      
      final response = await _reportApi.createReport(
        link: link,
        category: category,
        description: description,
        severity: severity,
        isAnonymous: reporterName == 'مستخدم مجهول',
      );

      debugPrint('📥 الرد: $response');

      if (response['success'] == true) {
        // Refresh reports
        final updatedReports = await _fetchMyReports();
        state = AsyncValue.data(updatedReports);
        return true;
      } else {
        _lastError = response['message'] ?? 'فشل إرسال البلاغ';
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ: $e');
      _lastError = 'حدث خطأ في الاتصال بالخادم';
      return false;
    } finally {
      _isReporting = false;
    }
  }

  // ✅ دالة حذف بلاغ فردي
  Future<bool> deleteReport(String reportId) async {
    try {
      // تحديث حالة التحميل
      state = const AsyncValue.loading();
      
      debugPrint('🔵 حذف بلاغ: $reportId');
      
      // استدعاء API لحذف البلاغ
      final response = await _reportApi.deleteReport(reportId);
      
      debugPrint('📥 الرد: $response');
      
      if (response['success'] == true) {
        // جلب البلاغات المحدثة بعد الحذف
        final updatedReports = await _fetchMyReports();
        state = AsyncValue.data(updatedReports);
        
        return true;
      } else {
        _lastError = response['message'] ?? 'فشل حذف البلاغ';
        
        // إعادة تحميل البلاغات في حالة الفشل
        final currentReports = await _fetchMyReports();
        state = AsyncValue.data(currentReports);
        
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف البلاغ: $e');
      _lastError = 'حدث خطأ في الاتصال بالخادم';
      
      // إعادة تحميل البلاغات في حالة الخطأ
      try {
        final currentReports = await _fetchMyReports();
        state = AsyncValue.data(currentReports);
      } catch (fetchError) {
        state = AsyncValue.data([]);
      }
      
      return false;
    }
  }

  // ✅ دالة حذف جميع البلاغات
  Future<bool> clearAllReports() async {
    try {
      // تحديث حالة التحميل
      state = const AsyncValue.loading();
      
      debugPrint('🔵 حذف جميع البلاغات');
      
      // استدعاء API لحذف جميع البلاغات
      final response = await _reportApi.deleteAllReports();
      
      debugPrint('📥 الرد: $response');
      
      if (response['success'] == true) {
        // تفريغ القائمة محلياً
        state = const AsyncValue.data([]);
        return true;
      } else {
        _lastError = response['message'] ?? 'فشل حذف جميع البلاغات';
        
        // إعادة تحميل البلاغات في حالة الفشل
        final currentReports = await _fetchMyReports();
        state = AsyncValue.data(currentReports);
        
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف جميع البلاغات: $e');
      _lastError = 'حدث خطأ في الاتصال بالخادم';
      
      // إعادة تحميل البلاغات في حالة الخطأ
      try {
        final currentReports = await _fetchMyReports();
        state = AsyncValue.data(currentReports);
      } catch (fetchError) {
        state = AsyncValue.data([]);
      }
      
      return false;
    }
  }

  // ✅ دالة تحديث حالة البلاغ (اختيارية)
  Future<bool> updateReportStatus(String reportId, String newStatus) async {
    try {
      state = const AsyncValue.loading();
      
      debugPrint('🔵 تحديث حالة البلاغ: $reportId إلى $newStatus');
      
      final response = await _reportApi.updateReportStatus(reportId, newStatus);
      
      debugPrint('📥 الرد: $response');
      
      if (response['success'] == true) {
        final updatedReports = await _fetchMyReports();
        state = AsyncValue.data(updatedReports);
        return true;
      } else {
        _lastError = response['message'] ?? 'فشل تحديث حالة البلاغ';
        
        final currentReports = await _fetchMyReports();
        state = AsyncValue.data(currentReports);
        
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحديث حالة البلاغ: $e');
      _lastError = 'حدث خطأ في الاتصال بالخادم';
      
      try {
        final currentReports = await _fetchMyReports();
        state = AsyncValue.data(currentReports);
      } catch (fetchError) {
        state = AsyncValue.data([]);
      }
      
      return false;
    }
  }

  // ✅ حذف بلاغ محلياً فقط (بدون API)
void deleteReportLocally(String reportId) {
  final currentList = state.value ?? [];
  final updatedList = currentList.where((r) => r.id != reportId).toList();
  state = AsyncValue.data(updatedList);
}

// ✅ إضافة بلاغ محلياً (للتراجع)
void addReportLocally(ReportModel report) {
  final currentList = state.value ?? [];
  // التأكد من عدم وجود تكرار
  if (!currentList.any((r) => r.id == report.id)) {
    final updatedList = [report, ...currentList];
    state = AsyncValue.data(updatedList);
  }
}

// ✅ حذف جميع البلاغات محلياً (بدون API)
void clearAllReportsLocally() {
  state = const AsyncValue.data([]);
}

  // ✅ دالة تحديث البلاغات (تحديث يدوي)
  Future<void> refreshReports() async {
    try {
      state = const AsyncValue.loading();
      final reports = await _fetchMyReports();
      state = AsyncValue.data(reports);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث البلاغات: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void clearError() {
    _lastError = null;
  }
}