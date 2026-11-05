import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'data/auth_repository.dart';
import 'data/favorites_notifier.dart';
import 'data/mock_resource_repository.dart';
import 'data/resource_repository.dart';
import 'data/supabase_resource_repository.dart';
import 'models/resource.dart';
import 'models/taxonomy.dart';

export 'data/auth_repository.dart' show AppUser, AuthRepository;
export 'data/favorites_notifier.dart' show favoritesProvider;

/// 依是否設定 Supabase 自動切換資料來源。
final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  if (SupabaseConfig.isConfigured) {
    return SupabaseResourceRepository(Supabase.instance.client);
  }
  return MockResourceRepository();
});

final featuredResourcesProvider = FutureProvider<List<Resource>>(
    (ref) => ref.watch(resourceRepositoryProvider).fetchFeatured());

final latestResourcesProvider = FutureProvider<List<Resource>>((ref) async {
  final resources =
      await ref.watch(resourceRepositoryProvider).fetchResources();
  return resources.take(10).toList();
});

/// 資源庫的篩選狀態
class LibraryFilterNotifier extends Notifier<ResourceFilter> {
  @override
  ResourceFilter build() => const ResourceFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setType(ResourceType? type) => state = state.copyWith(type: () => type);

  void toggleAge(AgeStage age) {
    final ages = {...state.ages};
    if (!ages.remove(age)) ages.add(age);
    state = state.copyWith(ages: ages);
  }

  void toggleDomain(LearningDomain domain) {
    final domains = {...state.domains};
    if (!domains.remove(domain)) domains.add(domain);
    state = state.copyWith(domains: domains);
  }

  void toggleTag(String tag) {
    final tags = {...state.tags};
    if (!tags.remove(tag)) tags.add(tag);
    state = state.copyWith(tags: tags);
  }

  /// 首頁「依領域探索」入口:清空其他條件、只留該領域。
  void showDomain(LearningDomain domain) =>
      state = ResourceFilter(domains: {domain});

  void reset() => state = const ResourceFilter();
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, ResourceFilter>(
        LibraryFilterNotifier.new);

final libraryResultsProvider = FutureProvider<List<Resource>>((ref) {
  final filter = ref.watch(libraryFilterProvider);
  return ref.watch(resourceRepositoryProvider).fetchResources(filter: filter);
});

final resourceByIdProvider = FutureProvider.family<Resource?, String>(
    (ref, id) => ref.watch(resourceRepositoryProvider).fetchById(id));

final favoriteResourcesProvider = FutureProvider<List<Resource>>((ref) async {
  final ids = ref.watch(favoritesProvider).value ?? const <String>{};
  if (ids.isEmpty) return const [];
  return ref.watch(resourceRepositoryProvider).fetchByIds(ids.toList());
});

final allTagsProvider = FutureProvider<List<String>>(
    (ref) => ref.watch(resourceRepositoryProvider).fetchTagNames());

/// 指標反查:某條課綱學習指標對應的資源
final indicatorResourcesProvider = FutureProvider.family<List<Resource>, String>(
    (ref, code) =>
        ref.watch(resourceRepositoryProvider).fetchByIndicator(code));

// ---- 階段 2:帳號與投稿 ----

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (SupabaseConfig.isConfigured) {
    return SupabaseAuthRepository(Supabase.instance.client);
  }
  return AuthUnavailableRepository();
});

/// 目前登入者(未連線或未登入為 null)
final authStateProvider = StreamProvider<AppUser?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges());

/// 目前登入者的投稿列表(含待審與被退回)
final myUploadsProvider = FutureProvider<List<Resource>>((ref) {
  ref.watch(authStateProvider); // 登入/登出時重新載入
  return ref.watch(resourceRepositoryProvider).fetchMyUploads();
});

// ---- 階段 2.5:管理者審核 ----

/// 目前登入者是否為管理者(未登入為 false)
final isAdminProvider = FutureProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  return ref.watch(resourceRepositoryProvider).isAdmin();
});

/// 待審投稿(非管理者為空)
final pendingReviewsProvider = FutureProvider<List<Resource>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) return const [];
  return ref.watch(resourceRepositoryProvider).fetchPendingReviews();
});
