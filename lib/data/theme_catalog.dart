/// 主題/節慶目錄:老師找素材的第一個入口通常是「主題」(秋天、過年、母親節),
/// 不是六大領域;領域是寫教案時才對應的分類。
///
/// [code] 會存進資料庫(resources.themes),勿隨意更動;顯示文字可改。
class ThemeTopic {
  const ThemeTopic(this.code, this.label, this.emoji, {this.months = const []});

  final String code;
  final String label;
  final String emoji;

  /// 行事曆上通常進行的月份;空代表全年通用主題。
  final List<int> months;

  bool get isSeasonal => months.isNotEmpty;

  String get display => '$emoji $label';
}

const List<ThemeTopic> themeTopics = [
  // 行事曆主題(依月份)
  ThemeTopic('school_start', '開學適應', '🎒', months: [8, 9]),
  ThemeTopic('moon_festival', '中秋節', '🥮', months: [9, 10]),
  ThemeTopic('autumn', '秋天', '🍂', months: [10, 11]),
  ThemeTopic('halloween', '萬聖節', '🎃', months: [10]),
  ThemeTopic('winter', '冬天', '❄️', months: [12, 1]),
  ThemeTopic('christmas', '聖誕節', '🎄', months: [12]),
  ThemeTopic('lunar_new_year', '過年', '🧧', months: [1, 2]),
  ThemeTopic('spring', '春天', '🌸', months: [3, 4]),
  ThemeTopic('childrens_day', '兒童節', '🎈', months: [4]),
  ThemeTopic('mothers_day', '母親節', '💐', months: [5]),
  ThemeTopic('dragon_boat', '端午節', '🐉', months: [5, 6]),
  ThemeTopic('graduation', '畢業', '🎓', months: [6, 7]),
  ThemeTopic('summer', '夏天', '☀️', months: [6, 7, 8]),
  ThemeTopic('fathers_day', '父親節', '👔', months: [8]),
  // 全年主題
  ThemeTopic('my_body', '我的身體', '🧒'),
  ThemeTopic('family', '家庭', '🏠'),
  ThemeTopic('animals', '動物', '🐾'),
  ThemeTopic('plants', '植物', '🌱'),
  ThemeTopic('food', '食物', '🍎'),
  ThemeTopic('vehicles', '交通工具', '🚌'),
  ThemeTopic('community', '社區', '🏘️'),
  ThemeTopic('colors_shapes', '顏色與形狀', '🔺'),
  ThemeTopic('emotions', '情緒', '💛'),
  ThemeTopic('recycling', '環保回收', '♻️'),
  ThemeTopic('ocean', '海洋', '🐟'),
  ThemeTopic('weather', '天氣', '🌦️'),
];

ThemeTopic? themeByCode(String code) {
  for (final topic in themeTopics) {
    if (topic.code == code) return topic;
  }
  return null;
}

/// 某個月份行事曆上的主題(首頁「本月主題」用)。
List<ThemeTopic> themesForMonth(int month) =>
    themeTopics.where((topic) => topic.months.contains(month)).toList();
