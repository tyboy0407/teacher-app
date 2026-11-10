import 'package:flutter/material.dart';

import '../../data/curriculum_service.dart';
import '../../models/taxonomy.dart';

/// 投稿時選擇課綱學習指標;以 Navigator.pop 回傳選取的代碼清單。
class IndicatorPickerPage extends StatefulWidget {
  const IndicatorPickerPage({super.key, this.initial = const []});

  final List<String> initial;

  @override
  State<IndicatorPickerPage> createState() => _IndicatorPickerPageState();
}

class _IndicatorPickerPageState extends State<IndicatorPickerPage> {
  late final Set<String> _selected = {...widget.initial};
  LearningDomain _domain = LearningDomain.physical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goals = CurriculumService.goalsOf(_domain);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇課綱指標'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected.toList()),
            child: Text('完成(${_selected.length})'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '建議每筆資源掛 1~3 條最貼近的指標,不用求多。',
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final indicators = CurriculumService.indicatorsOf(goal.code);
                final selectedCount = indicators
                    .where((i) => _selected.contains(i.code))
                    .length;
                return ExpansionTile(
                  title: Text(
                    '${goal.code} ${goal.title}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: selectedCount > 0
                      ? Text(
                          '已選 $selectedCount 條',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final indicator in indicators)
                      CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _selected.contains(indicator.code),
                        onChanged: (checked) => setState(() {
                          if (checked ?? false) {
                            _selected.add(indicator.code);
                          } else {
                            _selected.remove(indicator.code);
                          }
                        }),
                        title: Text(
                          indicator.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                        subtitle: Text(
                          '${indicator.code}(${indicator.age?.label ?? ''})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
