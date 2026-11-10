import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation.dart';
import '../../data/curriculum_service.dart';
import '../../models/taxonomy.dart';

/// 課綱指標瀏覽:六大領域 → 課程目標 → 分齡學習指標,
/// 點任一條指標可反查對應的資源。
class IndicatorBrowserPage extends StatefulWidget {
  const IndicatorBrowserPage({super.key});

  @override
  State<IndicatorBrowserPage> createState() => _IndicatorBrowserPageState();
}

class _IndicatorBrowserPageState extends State<IndicatorBrowserPage> {
  LearningDomain _domain = LearningDomain.physical;
  final Set<AgeStage> _ages = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goals = CurriculumService.goalsOf(_domain);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('課綱指標查詢'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '《幼兒園教保活動課程大綱》六大領域學習指標,點指標可查對應資源。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final domain in LearningDomain.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: ChoiceChip(
                        avatar: _domain == domain
                            ? null
                            : Icon(domain.icon, size: 16, color: domain.color),
                        label: Text(domain.label),
                        selected: _domain == domain,
                        onSelected: (_) => setState(() => _domain = domain),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '年齡',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                for (final age in AgeStage.values)
                  if (age != AgeStage.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: FilterChip(
                          label: Text(age.label),
                          selected: _ages.contains(age),
                          onSelected: (_) => setState(() {
                            if (!_ages.remove(age)) _ages.add(age);
                          }),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final indicators = CurriculumService.indicatorsOf(
                  goal.code,
                ).where((i) => _ages.isEmpty || _ages.contains(i.age)).toList();
                if (indicators.isEmpty) return const SizedBox.shrink();
                return ExpansionTile(
                  title: Text(
                    '${goal.code} ${goal.title}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final indicator in indicators)
                      ListTile(
                        dense: true,
                        title: Text(
                          indicator.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                        subtitle: Text(
                          '${indicator.code}(${indicator.age?.label ?? ''})'
                          '${indicator.continued ? ',承上' : ''}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => context.push(
                          '/indicators/${Uri.encodeComponent(indicator.code)}',
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
