import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/scan_controller.dart';
import '../../models/scan_result.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // إضافة مستمع لتتبع تغيير التبويب
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        print('🔄 تغيير التبويب إلى: ${_tabController.index}');
        setState(() {
          // تحديث الواجهة عند تغيير التبويب
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // للتصحيح
    print('🔄 إعادة بناء الصفحة - التبويب: ${_tabController.index}');
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('سجل الفحوصات'),
        centerTitle: true,
        actions: [
          Consumer<ScanController>(
            builder: (context, scanController, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildAppBarActions(scanController),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          indicatorWeight: 3,
          onTap: (index) {
            // تحديث الواجهة عند النقر على التبويب
            setState(() {});
            print('👆 تم النقر على التبويب: $index');
          },
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'آمن'),
            Tab(text: 'خطير'),
          ],
        ),
      ),
      body: Consumer<ScanController>(
        builder: (context, scanController, child) {
          // عرض مؤشر التحميل إذا كان جاري الفحص
          if (scanController.isScanning) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // عرض حالة فارغة إذا لم يكن هناك فحوصات
          if (scanController.scanHistory.isEmpty) {
            return _buildEmptyState();
          }
          
          // عرض قائمة الفحوصات مع الفلترة
          return _buildHistoryList(scanController);
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(ScanController scanController) {
    List<Widget> actions = [];

    // زر البحث
    if (!_isSearching) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
            Future.delayed(const Duration(milliseconds: 100), () {
              _searchFocusNode.requestFocus();
            });
          },
          tooltip: 'بحث',
        ),
      );
    }

    // قائمة الخيارات (إذا كان هناك فحوصات وليس في وضع البحث)
    if (scanController.scanHistory.isNotEmpty && !_isSearching) {
      actions.add(
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'clear':
                _showClearHistoryDialog(context, scanController);
                break;
              case 'export':
                _exportHistory(context, scanController);
                break;
              case 'stats':
                _showStatsDialog(context, scanController);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'stats',
              child: Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('إحصائيات'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, color: Colors.green),
                  SizedBox(width: 8),
                  Text('تصدير السجل'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  const Text('مسح السجل'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // زر إلغاء البحث
    if (_isSearching) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
          tooltip: 'إلغاء البحث',
        ),
      );
    }

    return actions;
  }

  Widget _buildSearchField() {
    return TextField(
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'ابحث في السجل...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'لا توجد فحوصات سابقة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ابدأ بفحص أول رابط الآن',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // العودة للصفحة الرئيسية
              },
              icon: const Icon(Icons.add),
              label: const Text('فحص رابط جديد'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(ScanController scanController) {
    // الحصول على القائمة المفلترة
    final filteredList = _getFilteredList(scanController);

    // عرض رسالة إذا لم توجد نتائج للبحث
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد نتائج للبحث',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'حاول بكلمات بحث مختلفة أو اختر تبويباً آخر',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // شريط معلومات عدد النتائج (إذا كان في وضع البحث)
        if (_searchQuery.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              'نتائج البحث: ${filteredList.length}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // قائمة النتائج
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return _buildHistoryItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  // ========== الحل النهائي لمشكلة الفلترة ==========
  List<ScanResult> _getFilteredList(ScanController scanController) {
    // الحصول على جميع الفحوصات
    List<ScanResult> allScans = scanController.scanHistory;
    
    // قائمة النتائج المفلترة
    List<ScanResult> filteredByTab = [];

    // فلترة حسب التبويب المحدد
    switch (_tabController.index) {
      case 0: // التبويب الأول: الكل
        filteredByTab = List.from(allScans);
        print('📋 التبويب 0 (الكل): ${filteredByTab.length} نتيجة');
        break;
        
      case 1: // التبويب الثاني: آمن فقط
        filteredByTab = allScans.where((scan) => scan.safe == true).toList();
        print('✅ التبويب 1 (آمن): ${filteredByTab.length} نتيجة');
        break;
        
      case 2: // التبويب الثالث: خطير فقط
        filteredByTab = allScans.where((scan) => scan.safe == false).toList();
        print('⚠️ التبويب 2 (خطير): ${filteredByTab.length} نتيجة');
        break;
        
      default:
        filteredByTab = List.from(allScans);
    }

    // تطبيق البحث إذا كان موجوداً
    if (_searchQuery.isNotEmpty) {
      filteredByTab = filteredByTab.where((scan) {
        final linkMatch = scan.link.toLowerCase().contains(_searchQuery);
        final statusMatch = scan.safetyStatus.toLowerCase().contains(_searchQuery);
        final messageMatch = scan.message.toLowerCase().contains(_searchQuery);
        
        return linkMatch || statusMatch || messageMatch;
      }).toList();
      print('🔍 بعد البحث: ${filteredByTab.length} نتيجة');
    }

    return filteredByTab;
  }

  Widget _buildHistoryItem(BuildContext context, ScanResult item) {
    // تحديد اللون حسب حالة الأمان
    Color itemColor;
    if (item.safe == true) {
      itemColor = Theme.of(context).colorScheme.tertiary; // أخضر/أزرق للآمن
    } else if (item.safe == false) {
      itemColor = Theme.of(context).colorScheme.error; // أحمر للخطير
    } else {
      itemColor = Colors.orange; // برتقالي للمشبوه
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(scanResult: item),
            ),
          );
        },
        onLongPress: () {
          _showItemOptions(context, item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // أيقونة الحالة مع خلفية دائرية
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      itemColor,
                      itemColor.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.safe == true
                      ? Icons.check_circle
                      : item.safe == false
                          ? Icons.cancel
                          : Icons.warning,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // معلومات الرابط
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _extractDomain(item.link),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // النسبة المئوية والحالة
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: itemColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: itemColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${item.score}%',
                      style: TextStyle(
                        color: itemColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: itemColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.safetyStatus,
                      style: TextStyle(
                        color: itemColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemOptions(BuildContext context, ScanResult item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('عرض التفاصيل'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(scanResult: item),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('مشاركة النتيجة'),
              onTap: () {
                Navigator.pop(context);
                _shareResult(context, item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult(BuildContext context, ScanResult item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم مشاركة نتيجة فحص ${_extractDomain(item.link)}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ScanResult item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفحص'),
        content: Text('هل أنت متأكد من حذف فحص ${_extractDomain(item.link)}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final scanController = context.read<ScanController>();
              scanController.deleteScanResult(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم حذف الفحص'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, ScanController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text(
          'هل أنت متأكد من مسح جميع سجلات الفحوصات؟ لا يمكن التراجع عن هذا الإجراء.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم مسح السجل بنجاح'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _exportHistory(BuildContext context, ScanController scanController) {
    final jsonData = scanController.exportHistoryAsJson();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير السجل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تم تصدير السجل بنجاح'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                jsonData.length > 100 ? '${jsonData.substring(0, 100)}...' : jsonData,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ السجل في الملفات'),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, ScanController scanController) {
    final stats = scanController.getAdvancedStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إحصائيات متقدمة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('إجمالي الفحوصات', '${stats['total']}'),
              _buildStatRow('الروابط الآمنة', '${stats['safe']} (${stats['safePercentage']}%)'),
              _buildStatRow('الروابط الخطيرة', '${stats['dangerous']} (${stats['dangerousPercentage']}%)'),
              _buildStatRow('الروابط المشبوهة', '${stats['suspicious']} (${stats['suspiciousPercentage']}%)'),
              _buildStatRow('متوسط النتيجة', '${stats['averageScore']}%'),
              if (stats['mostScannedDay'] != null)
                _buildStatRow('أكثر يوم نشاط', stats['mostScannedDay']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'اليوم ${DateFormat('HH:mm').format(date)}';
    } else if (dateDay == yesterday) {
      return 'أمس ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isEmpty ? url : uri.host;
    } catch (e) {
      // إذا كان الرابط بدون بروتوكول، نحاول إضافة https://
      try {
        final uri = Uri.parse('https://$url');
        return uri.host.isEmpty ? url : uri.host;
      } catch (e) {
        return url;
      }
    }
  }
}