import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteResourcesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: favorites.when(
        data: (resources) => resources.isEmpty
            ? EmptyState(
                icon: Icons.favorite_border,
                title: '還沒有收藏任何資源',
                subtitle: '瀏覽時點擊卡片上的愛心,就會收進這裡',
                action: FilledButton.tonalIcon(
                  onPressed: () => context.go('/library'),
                  icon: const Icon(Icons.category_outlined),
                  label: const Text('去資源庫逛逛'),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: resources.length,
                itemBuilder: (_, index) =>
                    ResourceCard(resource: resources[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorRetry(
          onRetry: () => ref.invalidate(favoriteResourcesProvider),
        ),
      ),
    );
  }
}
