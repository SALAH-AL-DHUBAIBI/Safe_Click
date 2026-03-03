class ReportModel {
  final String id;
  final String link;
  final String category;
  final String? description;
  final String reporterId;
  final String? reporterName;
  final DateTime reportDate;
  final String status; // 'pending', 'reviewed', 'resolved', 'rejected'
  final String? trackingNumber;
  final int? severity; // 1-5
  final List<String>? attachments;

  ReportModel({
    required this.id,
    required this.link,
    required this.category,
    this.description,
    required this.reporterId,
    this.reporterName,
    required this.reportDate,
    this.status = 'pending',
    this.trackingNumber,
    this.severity,
    this.attachments,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'category': category,
        'description': description,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reportDate': reportDate.toIso8601String(),
        'status': status,
        'trackingNumber': trackingNumber,
        'severity': severity,
        'attachments': attachments,
      };

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        id: json['id'],
        link: json['link'],
        category: json['category'],
        description: json['description'],
        reporterId: json['reporterId'],
        reporterName: json['reporterName'],
        reportDate: DateTime.parse(json['reportDate']),
        status: json['status'] ?? 'pending',
        trackingNumber: json['trackingNumber'],
        severity: json['severity'],
        attachments: json['attachments'] != null
            ? List<String>.from(json['attachments'])
            : null,
      );
}
