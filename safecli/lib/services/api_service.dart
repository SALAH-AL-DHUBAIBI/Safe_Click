import '../models/report_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.safeclik.com/v1';
  static const int timeout = 30;

  Future<Map<String, dynamic>> scanUrl(String url) async {
    try {
      // محاكاة استجابة API - استبدلها بـ API حقيقي
      await Future.delayed(const Duration(seconds: 2));
      
      // محاكاة نتائج الفحص
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      
      bool isSafe = random > 30;
      int score = isSafe ? 85 + (random % 15) : 20 + (random % 30);
      
      return {
        'safe': isSafe,
        'score': score,
        'message': isSafe ? 'الرابط آمن' : 'الرابط خطير',
        'details': _generateDetails(isSafe, score),
        'threatsCount': isSafe ? 0 : 2 + (random % 5),
        'ipAddress': '192.168.1.$random',
        'domain': Uri.parse(url).host,
        'responseTime': 0.5 + (random % 10) / 10,
      };
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم');
    }
  }

  List<String> _generateDetails(bool isSafe, int score) {
    if (isSafe) {
      return [
        '✓ الشهادة الأمنية صالحة',
        '✓ لا يوجد فيروسات أو برمجيات خبيثة',
        '✓ الموقع غير مدرج في قوائم الحظر',
        '✓ السمعة جيدة',
        '✓ التصنيف العمري مناسب',
      ];
    } else {
      return [
        '⚠ تم اكتشاف برمجيات خبيثة',
        '⚠ الموقع مدرج في قوائم التصيد',
        '⚠ الشهادة الأمنية غير موثوقة',
        '⚠ تقارير سلبية من المستخدمين',
        '⚠ محتوى غير آمن',
      ];
    }
  }

  Future<bool> submitReport(ReportModel report) async {
    try {
      // محاكاة إرسال البلاغ
      await Future.delayed(const Duration(seconds: 2));
      
      // هنا يمكن إرسال البلاغ للخادم
      // final response = await http.post(
      //   Uri.parse('$baseUrl/reports'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(report.toJson()),
      // );
      
      // return response.statusCode == 201;
      
      return true;
    } catch (e) {
      throw Exception('فشل إرسال البلاغ');
    }
  }

  Future<Map<String, dynamic>> checkUrlStatus(String url) async {
    try {
      // التحقق من حالة الرابط (محدث، محظور، إلخ)
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'isBlocked': false,
        'isPhishing': false,
        'isMalware': false,
        'lastChecked': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('فشل التحقق من حالة الرابط');
    }
  }
}
