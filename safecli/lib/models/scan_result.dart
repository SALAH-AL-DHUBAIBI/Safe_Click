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

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'],
        link: json['link'],
        safe: json['safe'],
        score: json['score'],
        message: json['message'],
        details: List<String>.from(json['details']),
        timestamp: DateTime.parse(json['timestamp']),
        rawData: json['rawData'],
        responseTime: json['responseTime']?.toDouble() ?? 0.0,
        ipAddress: json['ipAddress'],
        domain: json['domain'],
        threatsCount: json['threatsCount'],
      );
}

