import 'package:flutter/material.dart';

/// 三維分類體系:成長階段 × 六大領域 × 資源類型。
/// code 對應 Supabase 中儲存的字串,勿隨意更動。

/// 成長階段(依台灣幼兒園班級年齡劃分)
enum AgeStage {
  toddler('toddler', '幼幼班', '2-3歲'),
  k1('k1', '小班', '3-4歲'),
  k2('k2', '中班', '4-5歲'),
  k3('k3', '大班', '5-6歲'),
  all('all', '不限年齡', '');

  const AgeStage(this.code, this.label, this.ageRange);

  final String code;
  final String label;
  final String ageRange;

  String get fullLabel => ageRange.isEmpty ? label : '$label $ageRange';

  static AgeStage? fromCode(String? code) {
    for (final stage in values) {
      if (stage.code == code) return stage;
    }
    return null;
  }
}

/// 發展領域(對齊台灣《幼兒園教保活動課程大綱》六大領域)
/// [shortCode] 為課綱代碼中的領域縮寫(如「認-中-1-1-1」的「認」)。
enum LearningDomain {
  // 六色蠟筆:飽和度一致,放在圖畫紙底色上都站得住
  physical('physical', '身體動作與健康', '身', Icons.directions_run, Color(0xFF4C8C4A)),
  cognitive('cognitive', '認知', '認', Icons.lightbulb_outline, Color(0xFFD9922B)),
  language('language', '語文', '語', Icons.menu_book, Color(0xFF3E6DB5)),
  social('social', '社會', '社', Icons.groups, Color(0xFF2C8C8A)),
  emotional('emotional', '情緒', '情', Icons.favorite_border, Color(0xFFD5567A)),
  aesthetic('aesthetic', '美感', '美', Icons.palette, Color(0xFF8F5BB8));

  const LearningDomain(this.code, this.label, this.shortCode, this.icon, this.color);

  final String code;
  final String label;
  final String shortCode;
  final IconData icon;
  final Color color;

  static LearningDomain? fromCode(String? code) {
    for (final domain in values) {
      if (domain.code == code) return domain;
    }
    return null;
  }

  static LearningDomain? fromShortCode(String? shortCode) {
    for (final domain in values) {
      if (domain.shortCode == shortCode) return domain;
    }
    return null;
  }
}

/// 資源類型
enum ResourceType {
  craft('craft', '教具製作', Icons.build_circle_outlined),
  play('play', '教具玩法', Icons.extension_outlined),
  product('product', '成品教玩具', Icons.toys),
  lessonPlan('lesson_plan', '教案', Icons.assignment_outlined),
  worksheet('worksheet', '學習單', Icons.description_outlined),
  routine('routine', '常規救急', Icons.waving_hand),
  article('article', '文章', Icons.article_outlined);

  const ResourceType(this.code, this.label, this.icon);

  final String code;
  final String label;
  final IconData icon;

  static ResourceType? fromCode(String? code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }
}

/// 資源庫的篩選條件
class ResourceFilter {
  const ResourceFilter({
    this.query = '',
    this.type,
    this.ages = const {},
    this.domains = const {},
    this.tags = const {},
    this.theme,
  });

  final String query;
  final ResourceType? type;
  final Set<AgeStage> ages;
  final Set<LearningDomain> domains;
  final Set<String> tags;

  /// 主題/節慶代碼(見 theme_catalog.dart),單選
  final String? theme;

  bool get isEmpty =>
      query.trim().isEmpty &&
      type == null &&
      ages.isEmpty &&
      domains.isEmpty &&
      tags.isEmpty &&
      theme == null;

  /// [type]、[theme] 需要能「清成 null」,所以用函式包一層:
  /// copyWith(type: () => null) 清除、copyWith(type: () => t) 設定。
  ResourceFilter copyWith({
    String? query,
    ResourceType? Function()? type,
    Set<AgeStage>? ages,
    Set<LearningDomain>? domains,
    Set<String>? tags,
    String? Function()? theme,
  }) {
    return ResourceFilter(
      query: query ?? this.query,
      type: type != null ? type() : this.type,
      ages: ages ?? this.ages,
      domains: domains ?? this.domains,
      tags: tags ?? this.tags,
      theme: theme != null ? theme() : this.theme,
    );
  }
}
