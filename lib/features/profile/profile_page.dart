import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/supabase_config.dart';
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
    final user = ref.watch(authStateProvider).value;
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
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appTagline,
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
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    connected ? Icons.cloud_done : Icons.cloud_off,
                    color: connected
                        ? Colors.green
                        : theme.colorScheme.outline,
                  ),
                  title: const Text('資料來源'),
                  subtitle: Text(
                    connected ? '已連線 Supabase' : '內建示範資料(尚未連線 Supabase)',
                  ),
                ),
                if (!connected)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      '執行時加上 --dart-define=SUPABASE_URL 與 SUPABASE_ANON_KEY '
                      '即可切換為雲端內容,設定步驟見專案內的 SUPABASE_SETUP.md。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                    applicationVersion: appVersion,
                    children: const [
                      Text('把分散在網路各處的教具、教案與教學新知整理在一起,讓老師備課更輕鬆。'),
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
              const Text(
                '對齊台灣《幼兒園教保活動課程大綱》:\n身體動作與健康、認知、語文、社會、情緒、美感',
              ),
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
                        color: item.$3 ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              item.$2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
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

class _DialogSubtitle extends StatelessWidget {
  const _DialogSubtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
