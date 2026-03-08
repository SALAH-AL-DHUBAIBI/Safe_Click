// lib/features/scan/presentation/controllers/scan_state.dart

import 'package:safeclik/features/scan/data/models/scan_result.dart';

class ScanState {
  final List<ScanResult> scanHistory;
  final bool isScanning;
  final String? lastError;
  final int dangerousScans;
  final bool isLoading; // Added for delete/clear operations

  const ScanState({
    this.scanHistory = const [],
    this.isScanning = false,
    this.lastError,
    this.dangerousScans = 0,
    this.isLoading = false,
  });

  ScanState copyWith({
    List<ScanResult>? scanHistory,
    bool? isScanning,
    String? lastError,
    int? dangerousScans,
    bool? isLoading,
    bool clearError = false,
  }) {
    return ScanState(
      scanHistory: scanHistory ?? this.scanHistory,
      isScanning: isScanning ?? this.isScanning,
      lastError: clearError ? null : (lastError ?? this.lastError),
      dangerousScans: dangerousScans ?? this.dangerousScans,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}