import 'taxonomy.dart';

/// 課綱課程目標,如「認-1-1 蒐集生活環境中的數學訊息」。
class CurriculumGoal {
  const CurriculumGoal({
    required this.code,
    required this.domainShortCode,
    required this.title,
  });

  final String code;
  final String domainShortCode;
  final String title;

  LearningDomain? get domain => LearningDomain.fromShortCode(domainShortCode);
}

/// 課綱分齡學習指標,如「認-中-1-1-1」。
class CurriculumIndicator {
  const CurriculumIndicator({
    required this.code,
    required this.goalCode,
    required this.ageCode,
    required this.text,
    this.continued = false,
  });

  final String code;
  final String goalCode;

  /// AgeStage 代碼:toddler / k1 / k2 / k3
  final String ageCode;
  final String text;

  /// 課綱表格中以箭頭「延續前一年齡」的指標,文字沿用前一年齡。
  final bool continued;

  AgeStage? get age => AgeStage.fromCode(ageCode);

  LearningDomain? get domain =>
      LearningDomain.fromShortCode(code.split('-').first);
}
