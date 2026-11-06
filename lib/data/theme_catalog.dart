import 'package:flutter/material.dart';

/// 主題/節慶目錄:老師找素材的第一個入口通常是「主題」(秋天、過年、母親節),
/// 不是六大領域;領域是寫教案時才對應的分類。
///
/// [code] 會存進資料庫(resources.themes),勿隨意更動;顯示文字可改。
class ThemeTopic {
  const ThemeTopic(this.code, this.label, this.icon, {this.months = const []});

  final String code;
  final String label;
  /// 向量圖示(不用 emoji:各平台字型渲染不一致,也無法跟著主題配色)
  final IconData icon;

  /// 行事曆上通常進行的月份;空代表全年通用主題。
  final List<int> months;

  bool get isSeasonal => months.isNotEmpty;

}

const List<ThemeTopic> themeTopics = [
  // 行事曆主題(依月份)
  ThemeTopic('school_start', '開學適應', Icons.backpack_outlined, months: [8, 9]),
  ThemeTopic('moon_festival', '中秋節', Icons.nightlight_outlined, months: [9, 10]),
  ThemeTopic('autumn', '秋天', Icons.eco_outlined, months: [10, 11]),
  ThemeTopic('halloween', '萬聖節', Icons.celebration_outlined, months: [10]),
  ThemeTopic('winter', '冬天', Icons.ac_unit, months: [12, 1]),
  ThemeTopic('christmas', '聖誕節', Icons.park_outlined, months: [12]),
  ThemeTopic('lunar_new_year', '過年', Icons.redeem_outlined, months: [1, 2]),
  ThemeTopic('spring', '春天', Icons.local_florist_outlined, months: [3, 4]),
  ThemeTopic('childrens_day', '兒童節', Icons.toys_outlined, months: [4]),
  ThemeTopic('mothers_day', '母親節', Icons.favorite_outline, months: [5]),
  ThemeTopic('dragon_boat', '端午節', Icons.rowing, months: [5, 6]),
  ThemeTopic('graduation', '畢業', Icons.school_outlined, months: [6, 7]),
  ThemeTopic('summer', '夏天', Icons.wb_sunny_outlined, months: [6, 7, 8]),
  ThemeTopic('fathers_day', '父親節', Icons.face_outlined, months: [8]),
  // 全年主題
  ThemeTopic('my_body', '我的身體', Icons.accessibility_new),
  ThemeTopic('family', '家庭', Icons.home_outlined),
  ThemeTopic('animals', '動物', Icons.pets),
  ThemeTopic('plants', '植物', Icons.grass),
  ThemeTopic('food', '食物', Icons.restaurant_outlined),
  ThemeTopic('vehicles', '交通工具', Icons.directions_bus_outlined),
  ThemeTopic('community', '社區', Icons.location_city_outlined),
  ThemeTopic('colors_shapes', '顏色與形狀', Icons.palette_outlined),
  ThemeTopic('emotions', '情緒', Icons.emoji_emotions_outlined),
  ThemeTopic('recycling', '環保回收', Icons.recycling),
  ThemeTopic('ocean', '海洋', Icons.water_outlined),
  ThemeTopic('weather', '天氣', Icons.cloud_outlined),
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
