import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'controllers/auth_controller.dart';
import 'controllers/scan_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/report_controller.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart'; // استيراد API service
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/main/home_screen.dart';
import 'views/main/main_screen.dart';
import 'views/scan/result_screen.dart';
import 'views/scan/history_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/profile/edit_profile_screen.dart';
import 'views/report/report_screen.dart';
import 'views/settings/settings_screen.dart';
import 'theme/app_theme.dart';
import 'models/scan_result.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة API service
  await ApiService.initialize();
  
  // تهيئة الإشعارات
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  String? _pendingLink;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      // معالجة الرابط الذي فتح به التطبيق
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        print('📱 تم فتح التطبيق عبر رابط: $initialLink');
        _pendingLink = initialLink.toString();
      }

      // الاستماع للروابط أثناء تشغيل التطبيق
      _linkSubscription = _appLinks.allUriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          print('📱 تم استقبال رابط: $uri');
          _pendingLink = uri.toString();
          if (mounted) setState(() {});
        }
      });
    } catch (e) {
      print('❌ خطأ في الروابط: $e');
    }
  }

  Future<void> _handlePendingLink(BuildContext context) async {
    if (_pendingLink == null) return;
    
    final link = _pendingLink!;
    _pendingLink = null;
    
    // التأكد من تسجيل الدخول
    final authController = Provider.of<AuthController>(context, listen: false);
    if (!authController.isAuthenticated) {
      // إذا لم يكن مسجل دخول، انتظر حتى يسجل ثم افحص الرابط
      return;
    }
    
    final scanController = Provider.of<ScanController>(context, listen: false);
    
    // عرض مؤشر تحميل
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final result = await scanController.scanLink(link);
    
    if (!context.mounted) return;
    
    // إغلاق مؤشر التحميل
    Navigator.pop(context);
    
    if (result != null) {
      // الانتقال لصفحة النتيجة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(scanResult: result),
        ),
      );
    } else {
      // عرض خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scanController.lastError ?? 'فشل فحص الرابط'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ScanController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => ReportController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return MaterialApp(
            title: 'SafeClik',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsController.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: Builder(
              builder: (context) => Consumer<AuthController>(
                builder: (context, authController, child) {
                  if (authController.isLoading) {
                    return const SplashScreen();
                  }
                  
                  // معالجة الرابط المعلق بعد تحميل الصفحة
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handlePendingLink(context);
                  });
                  
                  return authController.isAuthenticated 
                      ? const HomeScreen() 
                      : const LoginScreen();
                },
              ),
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/main': (context) => const MainScreen(),
              '/history': (context) => const HistoryScreen(),
              '/report': (context) => const ReportScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/edit_profile': (context) => const EditProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/result') {
                final scanResult = settings.arguments as ScanResult;
                return MaterialPageRoute(
                  builder: (context) => ResultScreen(scanResult: scanResult),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}