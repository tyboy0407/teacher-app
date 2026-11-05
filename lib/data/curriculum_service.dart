import '../models/curriculum.dart';
import '../models/taxonomy.dart';
import 'curriculum_data.dart';

/// 課綱資料查詢。資料內建於 App(curriculum_data.dart),離線可用;
/// 雲端的 curriculum_* 表僅作為後台參照,App 不讀取。
class CurriculumService {
  CurriculumService._();

  static final Map<String, CurriculumIndicator> _indicatorByCode = {
    for (final indicator in curriculumIndicators) indicator.code: indicator,
  };

  static final Map<String, CurriculumGoal> _goalByCode = {
    for (final goal in curriculumGoals) goal.code: goal,
  };

  static CurriculumIndicator? indicator(String code) => _indicatorByCode[code];

  static CurriculumGoal? goal(String code) => _goalByCode[code];

  static List<CurriculumGoal> goalsOf(LearningDomain domain) => [
        for (final goal in curriculumGoals)
          if (goal.domainShortCode == domain.shortCode) goal,
      ];

  static List<CurriculumIndicator> indicatorsOf(String goalCode) => [
        for (final indicator in curriculumIndicators)
          if (indicator.goalCode == goalCode) indicator,
      ];
}
