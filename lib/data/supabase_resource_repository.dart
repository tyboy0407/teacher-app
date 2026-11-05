import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/resource.dart';
import '../models/resource_draft.dart';
import '../models/taxonomy.dart';
import 'resource_repository.dart';

/// 雲端資料來源:讀取 Supabase 的 resources / tags / resource_tags。
class SupabaseResourceRepository implements ResourceRepository {
  SupabaseResourceRepository(this._client);

  final SupabaseClient _client;

  /// 一併帶回主題標籤(resource_tags -> tags)
  static const _columns = '*, resource_tags(tags(name))';

  @override
  Future<List<Resource>> fetchResources(
      {ResourceFilter filter = const ResourceFilter()}) async {
    var query = _client.from('resources').select(_columns).eq('published', true);

    if (filter.type != null) {
      query = query.eq('type', filter.type!.code);
    }
    if (filter.ages.isNotEmpty) {
      // 標了「不限年齡」的資源,任何年齡篩選都應該出現
      query = query.overlaps('age_stages',
          [...filter.ages.map((a) => a.code), AgeStage.all.code]);
    }
    if (filter.domains.isNotEmpty) {
      query =
          query.overlaps('domains', filter.domains.map((d) => d.code).toList());
    }
    final keyword =
        filter.query.trim().replaceAll(',', ' ').replaceAll('%', '');
    if (keyword.isNotEmpty) {
      query = query.or(
          'title.ilike.%$keyword%,summary.ilike.%$keyword%,content.ilike.%$keyword%');
    }

    final rows = await query.order('created_at', ascending: false);
    var resources = rows.map(Resource.fromSupabase).toList();

    // 主題標籤在 MVP 資料量下於客戶端過濾,省去多一次關聯查詢
    if (filter.tags.isNotEmpty) {
      resources =
          resources.where((r) => r.tags.any(filter.tags.contains)).toList();
    }
    return resources;
  }

  @override
  Future<List<Resource>> fetchFeatured() async {
    final rows = await _client
        .from('resources')
        .select(_columns)
        .eq('published', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(8);
    return rows.map(Resource.fromSupabase).toList();
  }

  @override
  Future<Resource?> fetchById(String id) async {
    final row = await _client
        .from('resources')
        .select(_columns)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Resource.fromSupabase(row);
  }

  @override
  Future<List<Resource>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _client
        .from('resources')
        .select(_columns)
        .eq('published', true)
        .inFilter('id', ids)
        .order('created_at', ascending: false);
    return rows.map(Resource.fromSupabase).toList();
  }

  @override
  Future<List<String>> fetchTagNames() async {
    final rows =
        await _client.from('tags').select('name').order('name', ascending: true);
    return rows.map((row) => row['name'] as String).toList();
  }

  @override
  Future<List<Resource>> fetchByIndicator(String indicatorCode) async {
    final rows = await _client
        .from('resources')
        .select(_columns)
        .eq('published', true)
        .contains('indicator_codes', [indicatorCode])
        .order('created_at', ascending: false);
    return rows.map(Resource.fromSupabase).toList();
  }

  @override
  Future<String> submitResource(ResourceDraft draft) async {
    final id = await _client
        .rpc('submit_resource', params: {'payload': draft.toPayload()});
    return id.toString();
  }

  @override
  Future<List<Resource>> fetchMyUploads() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const [];
    final rows = await _client
        .from('resources')
        .select(_columns)
        .eq('created_by', uid)
        .order('created_at', ascending: false);
    return rows.map(Resource.fromSupabase).toList();
  }

  @override
  Future<void> deleteMyUpload(String id) async {
    await _client.from('resources').delete().eq('id', id);
  }

  @override
  Future<String> uploadImage(Uint8List bytes, String filename) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('請先登入');
    }
    final safeName = filename.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final path =
        'user-$uid/${DateTime.now().millisecondsSinceEpoch}-$safeName';
    final contentType =
        safeName.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
    await _client.storage.from('resource-images').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    return _client.storage.from('resource-images').getPublicUrl(path);
  }

  @override
  Future<bool> isAdmin() async {
    if (_client.auth.currentUser == null) return false;
    final result = await _client.rpc('is_admin');
    return result == true;
  }

  @override
  Future<List<Resource>> fetchPendingReviews() async {
    final rows = await _client
        .from('resources')
        .select(_columns)
        .eq('review_status', 'pending')
        .order('created_at', ascending: true);
    return rows.map(Resource.fromSupabase).toList();
  }

  @override
  Future<void> reviewResource(String id,
      {required bool approve, String? note}) async {
    await _client.rpc('review_resource', params: {
      'resource_id': id,
      'decision': approve ? 'approve' : 'reject',
      'note': note,
    });
  }
}
