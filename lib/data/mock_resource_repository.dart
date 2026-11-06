import 'dart:typed_data';

import '../models/resource.dart';
import '../models/resource_draft.dart';
import '../models/taxonomy.dart';
import 'resource_repository.dart';
import 'seed_data.dart';

/// 內建示範資料的資料來源:未設定 Supabase 時使用。
class MockResourceRepository implements ResourceRepository {
  /// 模擬一點網路延遲,讓載入狀態看得見。
  static const _latency = Duration(milliseconds: 250);

  Future<T> _withLatency<T>(T Function() body) => Future.delayed(_latency, body);

  List<Resource> get _sortedByNewest =>
      [...seedResources]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<Resource>> fetchResources(
      {ResourceFilter filter = const ResourceFilter()}) {
    return _withLatency(
        () => _sortedByNewest.where((r) => _matches(r, filter)).toList());
  }

  bool _matches(Resource resource, ResourceFilter filter) {
    if (filter.type != null && resource.type != filter.type) return false;
    if (filter.ages.isNotEmpty &&
        !resource.ages.contains(AgeStage.all) &&
        !resource.ages.any(filter.ages.contains)) {
      return false;
    }
    if (filter.domains.isNotEmpty &&
        !resource.domains.any(filter.domains.contains)) {
      return false;
    }
    if (filter.tags.isNotEmpty && !resource.tags.any(filter.tags.contains)) {
      return false;
    }
    if (filter.theme != null && !resource.themes.contains(filter.theme)) {
      return false;
    }
    final query = filter.query.trim().toLowerCase();
    if (query.isNotEmpty) {
      final haystack = [
        resource.title,
        resource.summary,
        resource.content,
        ...resource.tags,
        ...resource.materials,
      ].join('\n').toLowerCase();
      if (!haystack.contains(query)) return false;
    }
    return true;
  }

  @override
  Future<List<Resource>> fetchFeatured() {
    return _withLatency(
        () => _sortedByNewest.where((r) => r.isFeatured).toList());
  }

  @override
  Future<Resource?> fetchById(String id) {
    return _withLatency(() {
      for (final resource in seedResources) {
        if (resource.id == id) return resource;
      }
      return null;
    });
  }

  @override
  Future<List<Resource>> fetchByIds(List<String> ids) {
    return _withLatency(() =>
        seedResources.where((r) => ids.contains(r.id)).toList());
  }

  @override
  Future<List<String>> fetchTagNames() {
    return _withLatency(() {
      final names = <String>{for (final r in seedResources) ...r.tags};
      return names.toList()..sort();
    });
  }

  @override
  Future<List<Resource>> fetchByIndicator(String indicatorCode) {
    return _withLatency(() => _sortedByNewest
        .where((r) => r.indicatorCodes.contains(indicatorCode))
        .toList());
  }

  // 投稿功能需要雲端;UI 在未連線時不會走到這裡
  Never _needsSupabase() => throw StateError('需要連線 Supabase 才能投稿');

  @override
  Future<String> submitResource(ResourceDraft draft) async => _needsSupabase();

  @override
  Future<List<Resource>> fetchMyUploads() async => const [];

  @override
  Future<void> deleteMyUpload(String id) async => _needsSupabase();

  @override
  Future<String> uploadImage(Uint8List bytes, String filename) async =>
      _needsSupabase();

  @override
  Future<bool> isAdmin() async => false;

  @override
  Future<List<Resource>> fetchPendingReviews() async => const [];

  @override
  Future<void> reviewResource(String id,
          {required bool approve, String? note}) async =>
      _needsSupabase();
}
