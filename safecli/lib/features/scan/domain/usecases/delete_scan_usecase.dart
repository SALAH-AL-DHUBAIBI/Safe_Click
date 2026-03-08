// lib/features/scan/domain/usecases/delete_scan_usecase.dart

import '../repositories/scan_repository.dart';

class DeleteScanUseCase {
  final ScanRepository _repository;
  DeleteScanUseCase(this._repository);

  /// Soft delete a scan (hide from user only)
  Future<bool> call(String id) => _repository.softDeleteScan(id);
}