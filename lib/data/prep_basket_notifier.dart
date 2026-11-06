import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 備課籃內容:要用的活動(有順序)與「我已經有」的材料。
class PrepBasket {
  const PrepBasket({this.ids = const [], this.ownedMaterials = const {}});

  final List<String> ids;
  final Set<String> ownedMaterials;

  bool contains(String id) => ids.contains(id);
  bool get isEmpty => ids.isEmpty;

  PrepBasket copyWith({List<String>? ids, Set<String>? ownedMaterials}) =>
      PrepBasket(
        ids: ids ?? this.ids,
        ownedMaterials: ownedMaterials ?? this.ownedMaterials,
      );
}

/// 備課籃:老師把這週要用的資源收進來,App 自動彙整材料採買清單與課綱指標。
/// 存在裝置本地,不需帳號。
class PrepBasketNotifier extends AsyncNotifier<PrepBasket> {
  static const _idsKey = 'prep_basket_ids';
  static const _ownedKey = 'prep_owned_materials';

  @override
  Future<PrepBasket> build() async {
    final prefs = await SharedPreferences.getInstance();
    return PrepBasket(
      ids: prefs.getStringList(_idsKey) ?? const [],
      ownedMaterials: (prefs.getStringList(_ownedKey) ?? const []).toSet(),
    );
  }

  PrepBasket get _current => state.value ?? const PrepBasket();

  Future<void> toggle(String id) async {
    final ids = [..._current.ids];
    if (!ids.remove(id)) ids.add(id);
    await _save(_current.copyWith(ids: ids));
  }

  Future<void> remove(String id) async {
    await _save(_current.copyWith(ids: [..._current.ids]..remove(id)));
  }

  /// [newIndex] 是移除舊位置後的目標索引(對應 ReorderableListView.onReorderItem)
  Future<void> reorder(int oldIndex, int newIndex) async {
    final ids = [..._current.ids];
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex.clamp(0, ids.length), id);
    await _save(_current.copyWith(ids: ids));
  }

  Future<void> clear() async {
    await _save(const PrepBasket());
  }

  /// 勾選「我已經有」的材料(以材料文字為單位,跨資源共用)
  Future<void> toggleMaterial(String material) async {
    final owned = {..._current.ownedMaterials};
    if (!owned.remove(material)) owned.add(material);
    await _save(_current.copyWith(ownedMaterials: owned));
  }

  Future<void> _save(PrepBasket basket) async {
    state = AsyncData(basket);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, basket.ids);
    await prefs.setStringList(_ownedKey, basket.ownedMaterials.toList());
  }
}

final prepBasketProvider =
    AsyncNotifierProvider<PrepBasketNotifier, PrepBasket>(
        PrepBasketNotifier.new);
