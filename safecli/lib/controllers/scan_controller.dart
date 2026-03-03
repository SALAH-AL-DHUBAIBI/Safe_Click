import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/scan_service.dart';
import '../services/local_storage_service.dart';
import '../services/virustotal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanController extends ChangeNotifier {
  List<ScanResult> _scanHistory = [];
  bool _isScanning = false;
  String? _lastError;
  int _dangerousScans = 0;
  
  final ScanService _scanService = ScanService();
  final LocalStorageService _storageService = LocalStorageService();
  late VirusTotalService _virusTotalService;
  
  bool _useVirusTotal = true;

  List<ScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  bool get isScanning => _isScanning;
  String? get lastError => _lastError;
  int get dangerousScans => _dangerousScans;
  bool get useVirusTotal => _useVirusTotal;

  ScanController() {
    // مفتاح API الخاص بك
    const String apiKey = '4bde4430fb04771d949a891c0502c6b4bbfad977404644654511bdb5b6fec127';
    _virusTotalService = VirusTotalService(apiKey);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _storageService.getScanHistory();
      _scanHistory = history;
      _calculateDangerousScans();
      notifyListeners();
    } catch (e) {
      _lastError = 'خطأ في تحميل السجل';
    }
  }

  void _calculateDangerousScans() {
    _dangerousScans = _scanHistory.where((scan) => scan.safe == false).length;
  }

  Future<ScanResult?> scanLink(String link) async {
    try {
      _isScanning = true;
      _lastError = null;
      notifyListeners();

      // تنظيف الرابط
      link = link.trim();
      
      if (link.isEmpty) {
        throw Exception('الرجاء إدخال رابط للفحص');
      }

      // تنسيق الرابط (إضافة https:// إذا لزم الأمر)
      String formattedLink = _virusTotalService.formatUrl(link);

      // التحقق من صحة الرابط
      if (!_virusTotalService.isValidUrl(formattedLink)) {
        throw Exception('الرابط غير صحيح. مثال: google.com');
      }

      print('🔍 جاري فحص الرابط: $formattedLink');
      
      // الفحص باستخدام VirusTotal
      ScanResult? result = await _virusTotalService.scanUrl(formattedLink);
      
      // إذا فشل VirusTotal، استخدم الخدمة المحلية كبديل
      if (result == null || (result.score == 0 && result.details.contains('⚠️'))) {
        print('⚠️ استخدام الخدمة المحلية كبديل');
        result = await _scanService.scanUrl(formattedLink);
      }

      // حفظ النتيجة في السجل
      if (result != null) {
        _scanHistory.insert(0, result);
        await _saveHistory();
        _calculateDangerousScans();
        print('✅ تم حفظ نتيجة الفحص في السجل');
      } else {
        throw Exception('فشل الفحص - يرجى المحاولة مرة أخرى');
      }

      return result;
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _lastError = errorMessage;
      print('❌ خطأ في الفحص: $errorMessage');
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<ScanResult?> scanLinkWithProgress(String link, Function(double) onProgress) async {
    try {
      _isScanning = true;
      _lastError = null;
      notifyListeners();

      link = link.trim();
      
      if (link.isEmpty) {
        throw Exception('الرجاء إدخال رابط للفحص');
      }

      String formattedLink = _virusTotalService.formatUrl(link);

      if (!_virusTotalService.isValidUrl(formattedLink)) {
        throw Exception('الرابط غير صحيح');
      }

      onProgress(0.2); // بدأ الفحص
      print('🔍 جاري فحص الرابط: $formattedLink');
      
      ScanResult? result = await _virusTotalService.scanUrl(formattedLink);
      onProgress(0.8); // اكتمل الفحص تقريباً

      if (result == null || (result.score == 0 && result.details.contains('⚠️'))) {
        result = await _scanService.scanUrl(formattedLink);
      }

      if (result != null) {
        _scanHistory.insert(0, result);
        await _saveHistory();
        _calculateDangerousScans();
      }

      onProgress(1.0); // اكتمل
      return result;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _scanHistory.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('scanHistory', historyJson);
    } catch (e) {
      print('خطأ في حفظ السجل: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      _scanHistory.clear();
      _dangerousScans = 0;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scanHistory');
      
      notifyListeners();
    } catch (e) {
      _lastError = 'خطأ في مسح السجل';
    }
  }

  Future<void> deleteScanResult(String id) async {
    try {
      _scanHistory.removeWhere((scan) => scan.id == id);
      _calculateDangerousScans();
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      _lastError = 'خطأ في حذف الفحص';
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  ScanResult? getScanById(String id) {
    try {
      return _scanHistory.firstWhere((scan) => scan.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ScanResult> getScansByDate(DateTime date) {
    return _scanHistory.where((scan) {
      return scan.timestamp.year == date.year &&
             scan.timestamp.month == date.month &&
             scan.timestamp.day == date.day;
    }).toList();
  }

  Map<String, int> getStats() {
    int safe = _scanHistory.where((scan) => scan.safe == true).length;
    int dangerous = _scanHistory.where((scan) => scan.safe == false).length;
    int suspicious = _scanHistory.where((scan) => scan.safe == null).length;

    return {
      'total': _scanHistory.length,
      'safe': safe,
      'dangerous': dangerous,
      'suspicious': suspicious,
    };
  }

  // تصدير السجل بتنسيق JSON
  String exportHistoryAsJson() {
    try {
      final List<Map<String, dynamic>> exportData = _scanHistory.map((scan) {
        return {
          'id': scan.id,
          'link': scan.link,
          'safe': scan.safe,
          'score': scan.score,
          'message': scan.message,
          'details': scan.details,
          'timestamp': scan.timestamp.toIso8601String(),
          'threatsCount': scan.threatsCount,
        };
      }).toList();
      
      return jsonEncode(exportData);
    } catch (e) {
      print('خطأ في تصدير السجل: $e');
      return '[]';
    }
  }

  // الحصول على إحصائيات متقدمة
  Map<String, dynamic> getAdvancedStats() {
    final total = _scanHistory.length;
    if (total == 0) {
      return {
        'total': 0,
        'safe': 0,
        'dangerous': 0,
        'suspicious': 0,
        'safePercentage': 0,
        'dangerousPercentage': 0,
        'suspiciousPercentage': 0,
        'averageScore': 0,
        'mostScannedDay': null,
        'maxScansInDay': 0,
        'recentActivity': [],
      };
    }

    final safe = _scanHistory.where((s) => s.safe == true).length;
    final dangerous = _scanHistory.where((s) => s.safe == false).length;
    final suspicious = _scanHistory.where((s) => s.safe == null).length;
    
    final averageScore = _scanHistory.map((s) => s.score).reduce((a, b) => a + b) / total;
    
    final Map<String, int> scansByDay = {};
    for (var scan in _scanHistory) {
      final dayKey = '${scan.timestamp.year}-${scan.timestamp.month}-${scan.timestamp.day}';
      scansByDay[dayKey] = (scansByDay[dayKey] ?? 0) + 1;
    }
    
    String? mostScannedDay;
    int maxScans = 0;
    scansByDay.forEach((day, count) {
      if (count > maxScans) {
        maxScans = count;
        mostScannedDay = day;
      }
    });

    return {
      'total': total,
      'safe': safe,
      'dangerous': dangerous,
      'suspicious': suspicious,
      'safePercentage': (safe / total * 100).roundToDouble(),
      'dangerousPercentage': (dangerous / total * 100).roundToDouble(),
      'suspiciousPercentage': (suspicious / total * 100).roundToDouble(),
      'averageScore': averageScore.roundToDouble(),
      'mostScannedDay': mostScannedDay,
      'maxScansInDay': maxScans,
    };
  }

  List<ScanResult> searchInHistory(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _scanHistory.where((scan) {
      return scan.link.toLowerCase().contains(lowerQuery) ||
             scan.message.toLowerCase().contains(lowerQuery) ||
             scan.details.any((d) => d.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  void enableVirusTotal(bool enable) {
    _useVirusTotal = enable;
    notifyListeners();
  }
}