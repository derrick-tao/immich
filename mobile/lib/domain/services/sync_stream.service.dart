import 'dart:async';

import 'package:immich_mobile/domain/models/sync_event.model.dart';
import 'package:immich_mobile/infrastructure/repositories/sync_api.repository.dart';
import 'package:immich_mobile/infrastructure/repositories/sync_stream.repository.dart';
import 'package:logging/logging.dart';
import 'package:openapi/api.dart';

class SyncStreamService {
  final Logger _logger = Logger('SyncStreamService');

  final SyncApiRepository _syncApiRepository;
  final SyncStreamRepository _syncStreamRepository;
  final bool Function()? _cancelChecker;

  SyncStreamService({
    required SyncApiRepository syncApiRepository,
    required SyncStreamRepository syncStreamRepository,
    bool Function()? cancelChecker,
  })  : _syncApiRepository = syncApiRepository,
        _syncStreamRepository = syncStreamRepository,
        _cancelChecker = cancelChecker;

  bool get isCancelled => _cancelChecker?.call() ?? false;

  Future<void> sync() => _syncApiRepository.streamChanges(_handleEvents);

  Future<void> _handleEvents(List<SyncEvent> events, Function() abort) async {
    List<SyncEvent> items = [];
    for (final event in events) {
      if (isCancelled) {
        _logger.warning("Sync stream cancelled");
        abort();
        return;
      }

      if (event.type != items.firstOrNull?.type) {
        await _processBatch(items);
      }

      items.add(event);
    }

    await _processBatch(items);
  }

  Future<void> _processBatch(List<SyncEvent> batch) async {
    if (batch.isEmpty) {
      return;
    }

    final type = batch.first.type;
    await _handleSyncData(type, batch.map((e) => e.data));
    await _syncApiRepository.ack([batch.last.ack]);
    batch.clear();
  }

  Future<void> _handleSyncData(
    SyncEntityType type,
    Iterable<Object> data,
  ) async {
    _logger.fine("Processing sync data for $type of length ${data.length}");
    switch (type) {
      case SyncEntityType.userV1:
        return _syncStreamRepository.updateUsersV1(data.cast());
      case SyncEntityType.userDeleteV1:
        return _syncStreamRepository.deleteUsersV1(data.cast());
      case SyncEntityType.partnerV1:
        return _syncStreamRepository.updatePartnerV1(data.cast());
      case SyncEntityType.partnerDeleteV1:
        return _syncStreamRepository.deletePartnerV1(data.cast());
      case SyncEntityType.assetV1:
        return _syncStreamRepository.updateAssetsV1(data.cast());
      case SyncEntityType.assetDeleteV1:
        return _syncStreamRepository.deleteAssetsV1(data.cast());
      case SyncEntityType.assetExifV1:
        return _syncStreamRepository.updateAssetsExifV1(data.cast());
      case SyncEntityType.partnerAssetV1:
        return _syncStreamRepository.updatePartnerAssetsV1(data.cast());
      case SyncEntityType.partnerAssetDeleteV1:
        return _syncStreamRepository.deletePartnerAssetsV1(data.cast());
      case SyncEntityType.partnerAssetExifV1:
        return _syncStreamRepository.updatePartnerAssetsExifV1(data.cast());
      default:
        _logger.warning("Unknown sync data type: $type");
    }
  }
}
