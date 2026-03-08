// lib/features/scan/data/repositories/scan_repository_impl.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:safeclik/core/utils/scan_cache_service.dart';
import 'package:safeclik/core/utils/local_storage_service.dart';
import 'package:safeclik/features/scan/data/models/scan_result.dart';
import 'package:safeclik/features/scan/data/datasources/remote_scan_datasource.dart';
import '../../domain/entities/scan_entity.dart';
import '../../domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final RemoteScanDataSource _remote;
  final ScanCacheService _cache;
  final LocalStorageService _localStorage;

  // مفتاح لتخزين IDs المحذوفة محلياً
  static const String _deletedIdsKey = 'soft_deleted_scan_ids';

  ScanRepositoryImpl({
    required RemoteScanDataSource remote,
    required ScanCacheService cache,
    required LocalStorageService localStorage,
  })  : _remote = remote,
        _cache = cache,
        _localStorage = localStorage;

  ScanEntity _toEntity(ScanResult r) => ScanEntity(
        id: r.id,
        link: r.link,
        safe: r.safe,
        score: r.score,
        message: r.message,
        details: r.details,
        timestamp: r.timestamp,
        rawData: r.rawData,
        responseTime: r.responseTime,
        ipAddress: r.ipAddress,
        domain: r.domain,
        threatsCount: r.threatsCount,
      );

  ScanResult _toModel(ScanEntity e) => ScanResult(
        id: e.id,
        link: e.link,
        safe: e.safe,
        score: e.score,
        message: e.message,
        details: e.details,
        timestamp: e.timestamp,
        rawData: e.rawData,
        responseTime: e.responseTime,
        ipAddress: e.ipAddress,
        domain: e.domain,
        threatsCount: e.threatsCount,
      );

  /// الحصول على قائمة IDs المحذوفة
  Future<Set<String>> _getDeletedIds() async {
    try {
      final stored = await _localStorage.getString(_deletedIdsKey);
      if (stored != null && stored.isNotEmpty) {
        return Set.from(jsonDecode(stored));
      }
    } catch (e) {
      debugPrint('⚠️ Error reading deleted IDs: $e');
    }
    return {};
  }

  /// حفظ قائمة IDs المحذوفة
  Future<void> _saveDeletedIds(Set<String> ids) async {
    try {
      await _localStorage.setString(_deletedIdsKey, jsonEncode(ids.toList()));
    } catch (e) {
      debugPrint('⚠️ Error saving deleted IDs: $e');
    }
  }

  /// تصفية العناصر المحذوفة (Soft Delete)
  Future<List<T>> _filterDeleted<T>(List<T> items, String Function(T) getId) async {
    final deletedIds = await _getDeletedIds();
    return items.where((item) => !deletedIds.contains(getId(item))).toList();
  }

  /// يحافظ على آخر 50 عنصر فقط (FIFO)
  List<T> _limitHistory<T>(List<T> history) {
    if (history.length <= ScanRepository.maxHistoryItems) {
      return history;
    }
    return history.sublist(0, ScanRepository.maxHistoryItems);
  }

  @override
  Future<ScanEntity?> scanLink(String link) async {
    link = link.trim();
    if (link.isEmpty) throw Exception('الرجاء إدخال رابط للفحص');

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
    }

    try {
      final uri = Uri.parse(link);
      final host = uri.host;
      if (host.isEmpty || !host.contains('.')) {
        throw Exception('الرجاء إدخال رابط صالح');
      }
    } catch (e) {
      throw Exception('الرجاء إدخال رابط صالح');
    }

    debugPrint('🌐 [API] Calling SafeClick backend for $link');
    try {
      final response = await _remote.scanLink(link);

      if (response['success'] == true && response['result'] != null) {
        final resultData = response['result'];
        final scanResult = ScanResult.fromJson(resultData);
        return _toEntity(scanResult);
      } else {
        final message = response['message']?.toString() ?? 'فشل الفحص';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('🔴 [API] Backend error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ScanEntity>> getScanHistory() async {
    try {
      // 1. Load local history
      final localHistory = await _localStorage.getScanHistory();
      debugPrint('📦 [History] Local records before filter: ${localHistory.length}');
      
      // 2. Filter out soft-deleted items
      final filteredHistory = await _filterDeleted<ScanResult>(
        localHistory, 
        (item) => item.id
      );
      
      debugPrint('📦 [History] Local records after filter: ${filteredHistory.length}');
      
      // 3. Apply limit
      final limitedHistory = _limitHistory(filteredHistory);
      
      // 4. Save filtered history back (to clean up)
      if (limitedHistory.length != localHistory.length) {
        await _localStorage.saveScanHistory(limitedHistory);
        debugPrint('📦 [History] Saved filtered history: ${limitedHistory.length} records');
      }
      
      return limitedHistory.map(_toEntity).toList();
    } catch (e) {
      debugPrint('📦 [History] Local read error: $e');
      return [];
    }
  }

  @override
  Future<List<ScanEntity>> syncHistoryFromRemote() async {
    try {
      final response = await _remote.getScanHistory();
      if (response['success'] == true) {
        final List<dynamic> historyData = response['history'] ?? [];
        final entities = historyData
            .map((data) => _toEntity(ScanResult.fromJson(data)))
            .toList();
        
        // Convert to models for storage
        final models = entities.map(_toModel).toList();
        
        // Filter out deleted items
        final filteredModels = await _filterDeleted<ScanResult>(
          models, 
          (item) => item.id
        );
        
        // Apply limit
        final limitedModels = _limitHistory(filteredModels);
        
        // Save to local storage
        await _localStorage.saveScanHistory(limitedModels);
        debugPrint('🔄 [History] Synced ${limitedModels.length} records from server');
        
        return limitedModels.map(_toEntity).toList();
      }
    } catch (e) {
      debugPrint('🔴 [History] Remote sync failed: $e');
    }
    return [];
  }

  @override
  Future<bool> softDeleteScan(String id) async {
    try {
      // 1. Add to deleted IDs set
      final deletedIds = await _getDeletedIds();
      deletedIds.add(id);
      await _saveDeletedIds(deletedIds);
      
      // 2. Remove from local storage (optional, but good for cleanup)
      final currentHistory = await _localStorage.getScanHistory();
      final updatedHistory = currentHistory.where((s) => s.id != id).toList();
      await _localStorage.saveScanHistory(updatedHistory);
      
      debugPrint('✅ [SoftDelete] Scan hidden from user: $id');
      return true;
    } catch (e) {
      debugPrint('🔴 [SoftDelete] Failed: $e');
      return false;
    }
  }

  @override
  Future<bool> clearUserHistory() async {
    try {
      // 1. Get all current history IDs
      final currentHistory = await _localStorage.getScanHistory();
      final ids = currentHistory.map((s) => s.id).toList();
      
      // 2. Add all IDs to deleted set
      final deletedIds = await _getDeletedIds();
      deletedIds.addAll(ids);
      await _saveDeletedIds(deletedIds);
      
      // 3. Clear local storage
      await _localStorage.saveScanHistory([]);
      await _cache.clearAll();
      
      debugPrint('✅ [SoftDelete] All scans hidden from user');
      return true;
    } catch (e) {
      debugPrint('🔴 [SoftDelete] Clear failed: $e');
      return false;
    }
  }

  @override
  Future<void> saveHistory(List<ScanEntity> history) async {
    try {
      // Filter out deleted items before saving
      final models = history.map(_toModel).toList();
      final filteredModels = await _filterDeleted<ScanResult>(
        models, 
        (item) => item.id
      );
      
      final limitedModels = _limitHistory(filteredModels);
      await _localStorage.saveScanHistory(limitedModels);
      debugPrint('💾 [Save] Saved ${limitedModels.length} records to local storage');
    } catch (e) {
      debugPrint('🔴 [Save] Failed to save history: $e');
      rethrow;
    }
  }
}