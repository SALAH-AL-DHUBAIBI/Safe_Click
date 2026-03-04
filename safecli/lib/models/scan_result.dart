import 'package:flutter/material.dart';

class ScanResult {
  final String id;
  final String link;
  final bool? safe;
  final int score;
  final String message;
  final List<String> details;
  final DateTime timestamp;
  final Map<String, dynamic>? rawData;
  final double responseTime;
  final String? ipAddress;
  final String? domain;
  final int? threatsCount;

  ScanResult({
    required this.id,
    required this.link,
    this.safe,
    required this.score,
    required this.message,
    required this.details,
    required this.timestamp,
    this.rawData,
    this.responseTime = 0.0,
    this.ipAddress,
    this.domain,
    this.threatsCount,
  });

  String get safetyStatus {
    if (safe == true) return 'آمن';
    if (safe == false) return 'خطير';
    return 'مشبوه';
  }

  Color get safetyColor {
    if (safe == true) return Colors.green;
    if (safe == false) return Colors.red;
    return Colors.orange;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'safe': safe,
        'score': score,
        'message': message,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
        'rawData': rawData,
        'responseTime': responseTime,
        'ipAddress': ipAddress,
        'domain': domain,
        'threatsCount': threatsCount,
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) {
  return ScanResult(
    id: json['id']?.toString() ?? 'scan_${DateTime.now().millisecondsSinceEpoch}',
    link: json['link']?.toString() ?? '',
    safe: json['safe'], // يمكن أن يكون bool أو null
    score: json['score'] is int ? json['score'] : (json['score'] as double?)?.toInt() ?? 0,
    message: json['message']?.toString() ?? json['safety_status']?.toString() ?? 'نتيجة الفحص',
    details: _parseDetails(json),
    timestamp: _parseTimestamp(json),
    rawData: json,
    responseTime: json['response_time']?.toDouble() ?? json['responseTime']?.toDouble() ?? 0.0,
    ipAddress: json['ip_address']?.toString() ?? json['ipAddress']?.toString(),
    domain: json['domain']?.toString(),
    threatsCount: json['threats_count'] is int 
        ? json['threats_count'] 
        : (json['threats_count'] as double?)?.toInt() ?? 
          (json['threatsCount'] as int?) ?? 0,
  );
}

static List<String> _parseDetails(Map<String, dynamic> json) {
  // محاولة استخراج التفاصيل من مصادر مختلفة
  if (json['details'] != null) {
    if (json['details'] is List) {
      return List<String>.from(json['details'].map((x) => x.toString()));
    } else if (json['details'] is String) {
      return [json['details'].toString()];
    }
  }
  
  // إذا كان هناك result يحتوي على details
  if (json['result'] != null && json['result']['details'] != null) {
    if (json['result']['details'] is List) {
      return List<String>.from(json['result']['details'].map((x) => x.toString()));
    }
  }
  
  return ['لا توجد تفاصيل إضافية'];
}

static DateTime _parseTimestamp(Map<String, dynamic> json) {
  if (json['timestamp'] != null) {
    try {
      return DateTime.parse(json['timestamp'].toString());
    } catch (e) {
      // تجاهل الخطأ
    }
  }
  return DateTime.now();
}
}

