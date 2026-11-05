import 'dart:typed_data';

import '../models/resource.dart';
import '../models/resource_draft.dart';
import '../models/taxonomy.dart';

/// 資源資料來源介面。
/// 有兩套實作:MockResourceRepository(內建示範資料)與
/// SupabaseResourceRepository(雲端),依 SupabaseConfig 是否設定自動切換。
abstract class ResourceRepository {
  /// 依篩選條件取得資源,依建立時間新到舊排序。
  Future<List<Resource>> fetchResources({ResourceFilter filter = const ResourceFilter()});

  /// 首頁精選。
  Future<List<Resource>> fetchFeatured();

  Future<Resource?> fetchById(String id);

  /// 收藏頁用:一次取回多筆。
  Future<List<Resource>> fetchByIds(List<String> ids);

  /// 所有主題標籤名稱(篩選列用)。
  Future<List<String>> fetchTagNames();

  /// 指標反查:找出對應某條課綱學習指標的資源。
  Future<List<Resource>> fetchByIndicator(String indicatorCode);

  // ---- 階段 2:投稿(僅 Supabase 模式可用,Mock 模式會擲出 StateError)----

  /// 送出投稿,進入待審狀態;回傳新資源 id。
  Future<String> submitResource(ResourceDraft draft);

  /// 目前登入者的所有投稿(含待審與被退回)。
  Future<List<Resource>> fetchMyUploads();

  /// 刪除自己的未核准投稿。
  Future<void> deleteMyUpload(String id);

  /// 上傳圖片到雲端,回傳公開網址。
  Future<String> uploadImage(Uint8List bytes, String filename);

  // ---- 階段 2.5:管理者審核(僅 Supabase 模式可用)----

  /// 目前登入者是否為管理者。
  Future<bool> isAdmin();

  /// 待審投稿,投稿時間舊到新(先來先審)。
  Future<List<Resource>> fetchPendingReviews();

  /// 審核:通過即上架;退回必須附原因。
  Future<void> reviewResource(String id, {required bool approve, String? note});
}
