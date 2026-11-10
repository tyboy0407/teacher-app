import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/supabase_config.dart';
import '../../core/app_update.dart';
import '../../core/constants.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connected = SupabaseConfig.isConfigured;
    final auth = ref.watch(authRepositoryProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final pendingCount = ref.watch(pendingReviewsProvider).valueOrNull?.length;
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  user != null ? Icons.person : Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                user != null ? (user.email ?? '已登入') : '尚未登入',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                !auth.isAvailable
                    ? '連線 Supabase 後開放帳號與投稿功能'
                    : (user != null ? '投稿與審核狀態請見「發布」頁' : '登入後即可投稿教具與教案'),
              ),
              trailing: !auth.isAvailable
                  ? null
                  : (user != null
                        ? TextButton(
                            onPressed: () async {
                              await auth.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已登出')),
                                );
                              }
                            },
                            child: const Text('登出'),
                          )
                        : TextButton(
                            onPressed: () => context.push('/login'),
                            child: const Text('登入'),
                          )),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.fact_check_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                title: const Text(
                  '審核投稿',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  pendingCount == null
                      ? '管理者專用'
                      : (pendingCount == 0 ? '目前沒有待審投稿' : '待審 $pendingCount 筆'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin/review'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.school,
                      size: 30,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appTagline,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // 老師不需要知道後端叫什麼,只要知道內容會不會更新
                        Text(
                          connected ? '內容來自雲端,隨時更新' : '目前為內建示範資料',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _GroupLabel('工具'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.rule),
                  title: const Text('課綱指標查詢'),
                  subtitle: const Text('六大領域學習指標,可反查對應資源'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/indicators'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.shopping_basket_outlined),
                  title: const Text('本週備課'),
                  subtitle: const Text('彙整這週活動的材料採買清單與指標'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/prep'),
                ),
              ],
            ),
          ),
          const _GroupLabel('說明'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_tree_outlined),
                  title: const Text('分類體系說明'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTaxonomyDialog(context),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: const Text('開發路線圖'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRoadmapDialog(context),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('關於'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: appName,
                    applicationVersion: AppUpdater.buildId.isEmpty
                        ? appVersion
                        : '$appVersion (${AppUpdater.shortBuildId})',
                    children: [
                      if (AppUpdater.enabled)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _checkForUpdate(context),
                            icon: const Icon(Icons.system_update_alt, size: 18),
                            label: const Text('檢查更新'),
                          ),
                        ),
                      const Text('把分散在網路各處的教具、教案與教學新知整理在一起,讓老師備課更輕鬆。'),
                      const SizedBox(height: 12),
                      Text(
                        connected
                            ? '資料來源:雲端(Supabase)'
                            : '資料來源:內建示範資料。執行時加上 --dart-define 的 '
                                  'SUPABASE_URL 與 SUPABASE_ANON_KEY 即可切換為雲端內容,'
                                  '設定步驟見專案內的 SUPABASE_SETUP.md。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
    );
  }

  /// 手動檢查:老師懷疑自己看到舊畫面時,不用等自動檢查
  Future<void> _checkForUpdate(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await AppUpdater.instance.check(force: true);
    final String message;
    if (result == true) {
      message = '已是最新版本';
    } else if (result == null) {
      message = '目前無法檢查,請確認網路後再試';
    } else {
      message = '發現新版本,更新中…';
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _showTaxonomyDialog(BuildContext context) {
    final ages = AgeStage.values
        .where((age) => age != AgeStage.all)
        .map((age) => age.fullLabel)
        .join('\n');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('三維分類體系'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DialogSubtitle('成長階段'),
              Text(ages),
              const _DialogSubtitle('發展領域(六大領域)'),
              const Text('對齊台灣《幼兒園教保活動課程大綱》:\n身體動作與健康、認知、語文、社會、情緒、美感'),
              const _DialogSubtitle('資源類型'),
              Text(ResourceType.values.map((type) => type.label).join('、')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showRoadmapDialog(BuildContext context) {
    const items = [
      ('階段 1 只讀資源庫', '瀏覽、搜尋、收藏', true),
      ('階段 1.5 課綱指標庫', '指標對應與反查、常規救急', true),
      ('階段 2 帳號與投稿', '登入、上傳、審核(目前階段)', true),
      ('階段 2.1 互動', '評論、按讚、收藏雲端同步', false),
      ('階段 3 個人化', '依班級年齡推薦、學習專欄', false),
      ('階段 4 商業化探索', '材料包、付費內容', false),
    ];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('開發路線圖'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.$3
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: item.$3
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              item.$2,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

/// 卡片群組的小標題:把每天用的「工具」和偶爾看的「說明」分開
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DialogSubtitle extends StatelessWidget {
  const _DialogSubtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
