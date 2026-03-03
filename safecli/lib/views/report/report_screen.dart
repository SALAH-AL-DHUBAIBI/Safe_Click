import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  int _selectedSeverity = 3;
  late AnimationController _animationController;

  final List<String> _categories = [
    'رابط تصيد احتيالي (Phishing)',
    'رابط ضار (Malware)',
    'رابط احتيال مالي',
    'محتوى غير لائق',
    'بريد عشوائي (Spam)',
    'انتهاك خصوصية',
    'أخرى',
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {'value': 1, 'label': 'منخفض'},
    {'value': 2, 'label': 'متوسط'},
    {'value': 3, 'label': 'عالي'},
    {'value': 4, 'label': 'خطير'},
    {'value': 5, 'label': 'حرج'},
  ];

  Color _getSeverityColor(BuildContext context, int severity) {
    switch (severity) {
      case 1: return Theme.of(context).colorScheme.tertiary;
      case 2: return Theme.of(context).colorScheme.primary;
      case 3: return Theme.of(context).colorScheme.secondary;
      case 4: return Theme.of(context).colorScheme.error;
      case 5: return Theme.of(context).colorScheme.error;
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildForm(context),
              const SizedBox(height: 20),
              _buildGuidelines(context),
              const SizedBox(height: 20),
              _buildErrorWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ساعد في حماية المجتمع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإبلاغ عن الروابط الضارة يساعد في حماية الآخرين',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل البلاغ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildLinkField(context),
            const SizedBox(height: 20),
            _buildCategoryField(context),
            const SizedBox(height: 20),
            _buildSeverityField(),
            const SizedBox(height: 20),
            _buildDescriptionField(context),
            // const SizedBox(height: 20),
            // _buildAnonymousOption(isDarkMode),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الرابط المشبوه *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _linkController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: () => _linkController.clear(),
            ),
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع التهديد *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: Text(
                'اختر نوع التهديد',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'درجة الخطورة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: _severityLevels.map((level) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSeverity = level['value'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedSeverity == level['value']
                        ? _getSeverityColor(context, level['value'])
                        : _getSeverityColor(context, level['value']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedSeverity == level['value']
                          ? _getSeverityColor(context, level['value'])
                          : _getSeverityColor(context, level['value']).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        level['value'].toString(),
                        style: TextStyle(
                          color: _selectedSeverity == level['value']
                              ? Theme.of(context).colorScheme.surface
                              : _getSeverityColor(context, level['value']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        level['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: _selectedSeverity == level['value']
                              ? Theme.of(context).colorScheme.surface
                              : _getSeverityColor(context, level['value']),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف إضافي (اختياري)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: const InputDecoration(
            hintText: 'أضف أي تفاصيل إضافية عن الرابط...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // Widget _buildAnonymousOption(bool isDarkMode) {
  //   return Row(
  //     children: [
  //       Checkbox(
  //         value: false,
  //         onChanged: (value) {},
  //         fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //           if (states.contains(WidgetState.selected)) {
  //             return isDarkMode ? Colors.orange.shade300 : Colors.orange;
  //           }
  //           return isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
  //         }),
  //       ),
  //       Text(
  //         'الإبلاغ بشكل مجهول',
  //         style: TextStyle(
  //           color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSubmitButton() {
    return Consumer<ReportController>(
      builder: (context, reportController, child) {
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: reportController.isReporting
                ? null
                : () => _submitReport(reportController),
            icon: const Icon(Icons.send),
            label: reportController.isReporting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
                : const Text(
                    'إرسال البلاغ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidelines(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'إرشادات الإبلاغ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGuidelineItem(context, 'تأكد من صحة الرابط قبل الإبلاغ'),
          _buildGuidelineItem(context, 'الإبلاغ الكاذب قد يعرضك للمساءلة'),
          _buildGuidelineItem(context, 'سيتم مراجعة البلاغ خلال 24 ساعة'),
          _buildGuidelineItem(context, 'يمكنك متابعة حالة البلاغ عبر رقم التتبع'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Consumer<ReportController>(
      builder: (context, reportController, child) {
        if (reportController.lastError == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reportController.lastError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: reportController.clearError,
          ),
        ],
      ),
    );
      },
    );
  }

  Future<void> _submitReport(ReportController reportController) async {
    if (_linkController.text.trim().isEmpty) {
      showSnackBar('يرجى إدخال الرابط المشبوه', Theme.of(context).colorScheme.error);
      return;
    }

    if (_selectedCategory == null) {
      showSnackBar('يرجى اختيار نوع التهديد', Theme.of(context).colorScheme.error);
      return;
    }

    // التحقق من صحة الرابط
    if (!_isValidUrl(_linkController.text)) {
      showSnackBar('الرابط غير صحيح', Theme.of(context).colorScheme.error);
      return;
    }

    final authController = context.read<AuthController>();

    final report = ReportModel(
      id: '',
      link: _linkController.text.trim(),
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      reporterId: authController.currentUser?.id ?? 'anonymous',
      reporterName: authController.currentUser?.name ?? 'مستخدم مجهول',
      reportDate: DateTime.now(),
      severity: _selectedSeverity,
    );

    final success = await reportController.submitReport(report);

    if (success && mounted) {
      showSuccessDialog(reportController, report);
      clearForm();
    }
  }

  bool _isValidUrl(String url) {
    final urlPattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    final regex = RegExp(urlPattern, caseSensitive: false);
    return regex.hasMatch(url);
  }

  void clearForm() {
    _linkController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedSeverity = 3;
    });
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showSuccessDialog(ReportController reportController, ReportModel report) {
    final trackingNumber = reportController.reports.first.trackingNumber ?? 'غير متوفر';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تم استلام البلاغ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.tertiary,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'شكراً لك على المساهمة في حماية المجتمع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'رقم تتبع البلاغ:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    trackingNumber,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('مشاركة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void showReportsHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة سجل البلاغات قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'معلومات الإبلاغ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'الإبلاغ عن الروابط الضارة يساعد في حماية المجتمع الرقمي. يتم مراجعة جميع البلاغات من قبل فريق متخصص. يمكنك متابعة حالة بلاغك باستخدام رقم التتبع.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
