import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/scan_controller.dart';
import '../views/scan/result_screen.dart';
import '../models/scan_result.dart';

class DeepLinkService {
  // معالجة الرابط عند فتح التطبيق من خلال رابط
  static Future<void> handleInitialLink(BuildContext context, String link) async {
    if (link.isEmpty) return;
    
    print('📱 معالجة الرابط الأولي: $link');
    
    // تأخير بسيط للتأكد من تحميل الصفحات
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!context.mounted) return;
    
    // فحص الرابط تلقائياً
    final scanController = context.read<ScanController>();
    
    // عرض حوار التحميل
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // فحص الرابط
    final result = await scanController.scanLink(link);
    
    if (!context.mounted) return;
    
    // إغلاق حوار التحميل
    Navigator.pop(context);
    
    if (result != null) {
      print('✅ تم فحص الرابط بنجاح');
      // الانتقال إلى صفحة النتيجة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(scanResult: result),
        ),
      );
    } else {
      print('❌ فشل فحص الرابط');
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل فحص الرابط: $link'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // معالجة الرابط أثناء تشغيل التطبيق
  static Future<void> handleLinkWhileRunning(BuildContext context, String link) async {
    print('📱 معالجة رابط أثناء التشغيل: $link');
    
    if (!context.mounted) return;
    
    // عرض حوار التأكيد
    final shouldScan = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فتح الرابط'),
        content: Text('هل تريد فحص الرابط: $link؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('فحص'),
          ),
        ],
      ),
    );
    
    if (!shouldScan || !context.mounted) return;
    
    final scanController = context.read<ScanController>();
    final result = await scanController.scanLink(link);
    
    if (result != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(scanResult: result),
        ),
      );
    }
  }
}