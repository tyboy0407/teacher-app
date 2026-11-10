import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/navigation.dart';
import '../../core/share.dart';
import '../../core/theme.dart';
import '../../data/curriculum_service.dart';
import '../../data/resource_repository.dart' show ModerationAction;
import '../../data/theme_catalog.dart';
import '../../models/resource.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/bounce_icon_button.dart';
import '../../widgets/chips.dart';
import '../../widgets/cover_hero.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/resource_cover.dart';
import '../../widgets/review_status_chip.dart';

class ResourceDetailPage extends ConsumerWidget {
  const ResourceDetailPage({super.key, required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceByIdProvider(resourceId));
    return resourceAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: ErrorRetry(
          onRetry: () => ref.invalidate(resourceByIdProvider(resourceId)),
        ),
      ),
      data: (resource) {
        if (resource == null) {
          return Scaffold(
            appBar: AppBar(leading: const AppBackButton()),
            body: const EmptyState(
              icon: Icons.search_off,
              title: '找不到這筆資源',
              subtitle: '它可能已經下架了',
            ),
          );
        }
        return _DetailView(resource: resource);
      },
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.resource});

  final Resource resource;

  /// 封面上的圓形按鈕:直徑 44(觸控最小尺寸)
  static const _coverButtonRadius = 22.0;

  /// 按鈕底色:白色圖示在淺色封面上也要有 3:1 以上的對比
  static const _coverButtonScrim = Colors.black45;

  String get _contentTitle {
    switch (resource.type) {
      case ResourceType.craft:
        return '延伸與備註';
      case ResourceType.play:
        return '玩法說明';
      case ResourceType.product:
        return '挑選與玩法';
      case ResourceType.lessonPlan:
        return '教案內容';
      case ResourceType.worksheet:
        return '內容與使用建議';
      case ResourceType.routine:
        return '玩法與口令';
      case ResourceType.article:
        return '內文';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // 管理者看未核准的投稿時,底部多一條審核操作列
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final reviewing = isAdmin && resource.reviewStatus != 'approved';
    // 管理者看已通過的內容時,底部改為下架/刪除操作列
    final moderating = isAdmin && !reviewing;
    final basket = ref.watch(prepBasketProvider).valueOrNull;
    final inBasket = basket?.contains(resource.id) ?? false;
    final basketCount = basket?.ids.length ?? 0;
    return Scaffold(
      bottomNavigationBar: reviewing
          ? _ReviewBar(resource: resource)
          : moderating
          ? _ModerationBar(resource: resource)
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                radius: _coverButtonRadius,
                backgroundColor: _coverButtonScrim,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '返回',
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => popPage(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CircleAvatar(
                  radius: _coverButtonRadius,
                  backgroundColor: _coverButtonScrim,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: '分享',
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => showShareSheet(
                      context,
                      title: resource.title,
                      text: [
                        resource.title,
                        resource.summary,
                      ].where((s) => s.isNotEmpty).join('\n'),
                      url: resourceShareUrl(resource.id),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CircleAvatar(
                  radius: _coverButtonRadius,
                  backgroundColor: _coverButtonScrim,
                  // 產品的高潮時刻:按下會彈一下、有觸覺,角落顯示籃子裡有幾個
                  child: BounceIconButton(
                    compact: true,
                    haptic: true,
                    badgeCount: basketCount,
                    tooltip: inBasket ? '移出備課籃' : '加入備課',
                    icon: Icon(
                      inBasket ? Icons.playlist_add_check : Icons.playlist_add,
                      color: inBasket ? AppColors.crayonYellow : Colors.white,
                      size: 22,
                    ),
                    onPressed: () async {
                      final notifier = ref.read(prepBasketProvider.notifier);
                      final previousIndex =
                          basket?.ids.indexOf(resource.id) ?? -1;
                      await notifier.toggle(resource.id);
                      if (!context.mounted) return;
                      final countAfter =
                          ref
                              .read(prepBasketProvider)
                              .valueOrNull
                              ?.ids
                              .length ??
                          0;
                      // 回饋隨重複遞減:第一次進籃說明會幫忙整理,之後只說已加入
                      final String message;
                      if (inBasket) {
                        message = '已從備課籃移除';
                      } else if (countAfter == 1) {
                        message = '已加入本週備課,備課頁會幫你整理材料與課綱指標';
                      } else {
                        message = '已加入本週備課($countAfter 個活動)';
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(message),
                            action: inBasket
                                ? SnackBarAction(
                                    label: '復原',
                                    onPressed: () => notifier.insertAt(
                                      resource.id,
                                      previousIndex,
                                    ),
                                  )
                                : SnackBarAction(
                                    label: '查看',
                                    onPressed: () => context.push('/prep'),
                                  ),
                          ),
                        );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 10, 6),
                child: CircleAvatar(
                  radius: _coverButtonRadius,
                  backgroundColor: _coverButtonScrim,
                  child: FavoriteButton(
                    resourceId: resource.id,
                    compact: true,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CoverHero(
                resource: resource,
                child: ResourceCover(resource: resource, iconSize: 56),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reviewing) ...[
                    _ReviewBanner(resource: resource),
                    const SizedBox(height: 14),
                  ],
                  if (moderating && !resource.published) ...[
                    const _UnpublishedBanner(),
                    const SizedBox(height: 14),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TypeBadge(type: resource.type),
                      if (resource.difficulty != null)
                        SmallInfoChip(
                          label: '難度 ${'★' * resource.difficulty!}',
                        ),
                      if (resource.durationMinutes != null)
                        SmallInfoChip(
                          icon: Icons.schedule,
                          label: '${resource.durationMinutes} 分鐘',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resource.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...resource.ages.map(
                        (age) => SmallInfoChip(
                          icon: Icons.child_care,
                          label: age.fullLabel,
                        ),
                      ),
                      ...resource.domains.map(
                        (domain) => SmallInfoChip(
                          dotColor: domain.color,
                          label: domain.label,
                        ),
                      ),
                      ...resource.tags.map(
                        (tag) => SmallInfoChip(label: '#$tag'),
                      ),
                      ...resource.themes.map(
                        (code) => SmallInfoChip(
                          icon: themeByCode(code)?.icon ?? Icons.label_outline,
                          label: themeByCode(code)?.label ?? code,
                        ),
                      ),
                    ],
                  ),
                  if (resource.videoUrl != null &&
                      resource.videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () => launchUrl(
                          Uri.parse(resource.videoUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('觀看示範影片'),
                      ),
                    ),
                  ],
                  if (resource.summary.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        resource.summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (resource.indicatorCodes.isNotEmpty)
                    _IndicatorSection(codes: resource.indicatorCodes),
                  if (resource.materials.isNotEmpty)
                    _Section(
                      title: '材料清單',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: resource.materials
                            .map(
                              (material) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        material,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (resource.steps.isNotEmpty)
                    _Section(
                      title: '製作步驟',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < resource.steps.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resource.steps[i].title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (resource
                                            .steps[i]
                                            .description
                                            .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              resource.steps[i].description,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    height: 1.5,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (resource.content.isNotEmpty)
                    _Section(
                      title: _contentTitle,
                      child: Text(
                        resource.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                        ),
                      ),
                    ),
                  if (resource.sourceName != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      '資料來源:${resource.sourceName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 管理者審核時,內容最上方的狀態提示。
class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = resource.createdAt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 18,
                color: theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              ReviewStatusChip(resource: resource),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${created.year}/${created.month}/${created.day} 投稿',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          if (resource.isRejected && (resource.reviewNote?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '退回原因:${resource.reviewNote}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 審核操作列:退回(需填原因)/ 通過並上架(先列出審核重點)。
class _ReviewBar extends ConsumerStatefulWidget {
  const _ReviewBar({required this.resource});

  final Resource resource;

  @override
  ConsumerState<_ReviewBar> createState() => _ReviewBarState();
}

class _ReviewBarState extends ConsumerState<_ReviewBar> {
  bool _busy = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  static const _checklist = [
    '分類合理:類型/年齡/領域選得對,指標沒有硬湊',
    '含小物件、繩線、磁鐵、刀具的內容有「小提醒」安全段落',
    '無版權疑慮:非翻拍、非盜圖、無完整歌詞、無卡通角色',
    '照片沒有拍到孩子的臉',
    '文字通順、看得懂、照著做得出來',
  ];

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通過並上架'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('上架前請確認:'),
              const SizedBox(height: 8),
              for (final item in _checklist)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('再看看'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確定通過'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _submit(approve: true);
  }

  Future<void> _reject() async {
    _noteController.clear();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退回投稿'),
        content: TextField(
          controller: _noteController,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '退回原因(老師會看到)',
            hintText: '例如:缺少安全提醒、照片拍到孩子的臉',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_noteController.text.trim()),
            child: const Text('退回'),
          ),
        ],
      ),
    );
    if (note == null) return;
    if (note.isEmpty) {
      _showMessage('退回時請填寫原因,老師才知道要改什麼');
      return;
    }
    await _submit(approve: false, note: note);
  }

  Future<void> _submit({required bool approve, String? note}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(resourceRepositoryProvider)
          .reviewResource(widget.resource.id, approve: approve, note: note);
      ref.invalidate(pendingReviewsProvider);
      ref.invalidate(resourceByIdProvider(widget.resource.id));
      ref.invalidate(libraryResultsProvider);
      ref.invalidate(latestResourcesProvider);
      ref.invalidate(featuredResourcesProvider);
      ref.invalidate(myUploadsProvider);
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(approve ? '已通過並上架' : '已退回給投稿老師');
      popPage(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage('審核失敗:$error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy || widget.resource.isRejected
                      ? null
                      : _reject,
                  icon: const Icon(Icons.undo),
                  label: const Text('退回'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _approve,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('通過並上架'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 已下架內容的提示(只有管理者看得到這一頁)。
class _UnpublishedBanner extends StatelessWidget {
  const _UnpublishedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '這筆內容已下架,老師們看不到;可在下方重新上架或刪除',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 管理者對已上架內容的操作列:下架 / 重新上架,以及永久刪除。
class _ModerationBar extends ConsumerStatefulWidget {
  const _ModerationBar({required this.resource});

  final Resource resource;

  @override
  ConsumerState<_ModerationBar> createState() => _ModerationBarState();
}

class _ModerationBarState extends ConsumerState<_ModerationBar> {
  bool _busy = false;

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
    bool destructive = false,
  }) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _run(ModerationAction action, String doneMessage) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(resourceRepositoryProvider)
          .moderateResource(widget.resource.id, action);
      ref.invalidate(resourceByIdProvider(widget.resource.id));
      ref.invalidate(unpublishedResourcesProvider);
      ref.invalidate(libraryResultsProvider);
      ref.invalidate(latestResourcesProvider);
      ref.invalidate(featuredResourcesProvider);
      ref.invalidate(favoriteResourcesProvider);
      ref.invalidate(prepBasketResourcesProvider);
      ref.invalidate(myUploadsProvider);
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(doneMessage)));
      if (action == ModerationAction.delete) popPage(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失敗:$error')));
    }
  }

  Future<void> _toggleVisibility() async {
    final title = widget.resource.title;
    if (widget.resource.published) {
      final ok = await _confirm(
        title: '下架「$title」',
        body: '下架後老師們會看不到這筆內容,但資料會保留,隨時可以重新上架。',
        action: '下架',
      );
      if (ok) await _run(ModerationAction.unpublish, '已下架');
    } else {
      final ok = await _confirm(
        title: '重新上架「$title」',
        body: '上架後所有老師都能再次看到這筆內容。',
        action: '重新上架',
      );
      if (ok) await _run(ModerationAction.publish, '已重新上架');
    }
  }

  Future<void> _delete() async {
    final ok = await _confirm(
      title: '永久刪除「${widget.resource.title}」',
      body:
          '刪除後無法復原,其他老師的收藏與備課籃裡也會找不到它。'
          '只是暫時不想公開的話,請改用「下架」。',
      action: '永久刪除',
      destructive: true,
    );
    if (ok) await _run(ModerationAction.delete, '已刪除');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final published = widget.resource.published;
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: _busy ? null : _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('刪除'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.tonalIcon(
                  onPressed: _busy ? null : _toggleVisibility,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          published
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                  label: Text(published ? '下架' : '重新上架'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 對應課綱學習指標區塊:顯示代碼與全文,一鍵複製後可直接貼進教案。
class _IndicatorSection extends StatelessWidget {
  const _IndicatorSection({required this.codes});

  final List<String> codes;

  String get _copyText {
    return codes
        .map((code) {
          final indicator = CurriculumService.indicator(code);
          return indicator == null
              ? code
              : '${indicator.code} ${indicator.text}';
        })
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '對應課綱學習指標',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _copyText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已複製 ${codes.length} 條指標,可直接貼進教案'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('複製'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final code in codes)
            Builder(
              builder: (context) {
                final indicator = CurriculumService.indicator(code);
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: indicator == null
                      ? Text(code, style: theme.textTheme.bodyMedium)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (indicator.domain != null) ...[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: indicator.domain!.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  indicator.code,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  indicator.age?.label ?? '',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              indicator.text,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
