import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/undo.dart';
import '../../models/resource.dart';
import '../../providers.dart';
import '../../widgets/collapsible_row.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';

/// 我的收藏:在這頁點掉愛心,卡片會收合消失,5 秒內可復原。
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  /// 正在收合的卡片:id → (資源, 原本的位置);動畫結束前仍留在列表裡
  final _collapsing = <String, (Resource, int)>{};

  /// 剛復原、要播展開動畫的資源
  String? _appearing;

  List<Resource> _lastShown = const [];

  void _onFavoritesChanged(
    AsyncValue<Set<String>>? previous,
    AsyncValue<Set<String>> next,
  ) {
    final before = previous?.valueOrNull;
    final after = next.valueOrNull;
    if (before == null || after == null) return;
    for (final id in before.difference(after)) {
      final index = _lastShown.indexWhere((r) => r.id == id);
      if (index < 0) continue;
      final resource = _lastShown[index];
      setState(() => _collapsing[id] = (resource, index));
      showUndoSnackBar(
        context,
        message: '已移除收藏「${resource.title}」',
        onUndo: () {
          setState(() => _appearing = id);
          ref.read(favoritesProvider.notifier).add(id);
        },
      );
    }
  }

  /// 把正在收合的卡片放回它原本的位置,列表才不會瞬間跳動
  List<Resource> _merge(List<Resource> current) {
    if (_collapsing.isEmpty) return current;
    final merged = [...current];
    final entries = _collapsing.values.toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    for (final (resource, index) in entries) {
      if (merged.any((r) => r.id == resource.id)) continue;
      merged.insert(index.clamp(0, merged.length), resource);
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesProvider, _onFavoritesChanged);
    final favorites = ref.watch(favoriteResourcesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: favorites.when(
        skipLoadingOnReload: true,
        data: (resources) {
          final shown = _merge(resources);
          _lastShown = shown;
          if (shown.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: '還沒有收藏任何資源',
              subtitle: '瀏覽時點擊卡片上的愛心,就會收進這裡',
              action: FilledButton.tonalIcon(
                onPressed: () => context.go('/library'),
                icon: const Icon(Icons.category_outlined),
                label: const Text('去資源庫逛逛'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: shown.length,
            itemBuilder: (_, index) {
              final resource = shown[index];
              return CollapsibleRow(
                key: ValueKey(resource.id),
                removing: _collapsing.containsKey(resource.id),
                appearing: _appearing == resource.id,
                onCollapsed: () => setState(() {
                  _collapsing.remove(resource.id);
                  _appearing = null;
                }),
                child: ResourceCard(resource: resource),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorRetry(
          onRetry: () => ref.invalidate(favoriteResourcesProvider),
        ),
      ),
    );
  }
}
