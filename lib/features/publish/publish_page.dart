import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/resource.dart';
import '../../providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_cover.dart';

/// 發布分頁:未連線 → 連線引導;未登入 → 登入引導;已登入 → 我的投稿列表。
class PublishPage extends ConsumerWidget {
  const PublishPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final user = ref.watch(authStateProvider).value;

    if (!auth.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('發布')),
        body: const EmptyState(
          icon: Icons.cloud_off,
          title: '投稿功能需要連線雲端',
          subtitle: '完成 Supabase 設定後(見專案內 SUPABASE_SETUP.md),'
              '即可註冊帳號、上傳你的教具與教案',
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('發布')),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: '登入後即可投稿',
          subtitle: '上傳你的教具、教案,審核通過後與所有老師分享',
          action: FilledButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login),
            label: const Text('登入 / 註冊'),
          ),
        ),
      );
    }

    final uploads = ref.watch(myUploadsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的投稿')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/publish/new'),
        icon: const Icon(Icons.add),
        label: const Text('新增投稿'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myUploadsProvider);
          await ref.read(myUploadsProvider.future);
        },
        child: uploads.when(
          data: (resources) => resources.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    EmptyState(
                      icon: Icons.upload_file,
                      title: '還沒有投稿',
                      subtitle: '按右下角「新增投稿」,分享你的第一個作品吧',
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  itemCount: resources.length,
                  itemBuilder: (_, index) =>
                      _UploadCard(resource: resources[index]),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              ErrorRetry(onRetry: () => ref.invalidate(myUploadsProvider)),
        ),
      ),
    );
  }
}

class _UploadCard extends ConsumerWidget {
  const _UploadCard({required this.resource});

  final Resource resource;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除投稿'),
        content: Text('確定要刪除「${resource.title}」嗎?此動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(resourceRepositoryProvider).deleteMyUpload(resource.id);
      ref.invalidate(myUploadsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已刪除')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('刪除失敗,請稍後再試')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/resource/${resource.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: ResourceCover(resource: resource, iconSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusChip(resource: resource),
                        const SizedBox(width: 8),
                        Text(
                          '${resource.createdAt.year}/${resource.createdAt.month}/${resource.createdAt.day}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (resource.isRejected &&
                        (resource.reviewNote?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '退回原因:${resource.reviewNote}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (resource.reviewStatus != 'approved')
                IconButton(
                  tooltip: '刪除投稿',
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.outline),
                  onPressed: () => _confirmDelete(context, ref),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (resource.reviewStatus) {
      'pending' => ('審核中', Colors.orange),
      'rejected' => ('未通過', Colors.red),
      _ => resource.published ? ('已上架', Colors.green) : ('已下架', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
