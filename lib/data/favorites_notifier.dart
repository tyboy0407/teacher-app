import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 收藏清單:階段 1 僅存在裝置本地(shared_preferences),不需帳號。
/// 階段 2 加入登入後,改為同步到雲端。
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  static const _prefsKey = 'favorite_resource_ids';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? const []).toSet();
  }

  Future<void> toggle(String resourceId) async {
    final current = {...state.valueOrNull ?? const <String>{}};
    if (!current.remove(resourceId)) {
      current.add(resourceId);
    }
    await _save(current);
  }

  /// 放回收藏(「復原」用)
  Future<void> add(String resourceId) async {
    await _save({...state.valueOrNull ?? const <String>{}, resourceId});
  }

  Future<void> _save(Set<String> current) async {
    state = AsyncData(current);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, current.toList());
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
