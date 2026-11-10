import '../models/resource.dart';
import 'curriculum_service.dart';

/// 備課籃彙整:把多個活動的材料與課綱指標合併成一份清單。
class PrepSummary {
  PrepSummary(this.resources, this.ownedMaterials) {
    for (final resource in resources) {
      for (final material in resource.materials) {
        materials.putIfAbsent(material, () => []).add(resource.title);
      }
      for (final code in resource.indicatorCodes) {
        if (!indicatorCodes.contains(code)) indicatorCodes.add(code);
      }
    }
  }

  final List<Resource> resources;
  final Set<String> ownedMaterials;

  /// 材料 → 用到它的活動(依出現順序)
  final Map<String, List<String>> materials = {};

  /// 去重後的指標代碼(依出現順序)
  final List<String> indicatorCodes = [];

  List<String> get missingMaterials =>
      materials.keys.where((m) => !ownedMaterials.contains(m)).toList();

  int get ownedCount => materials.length - missingMaterials.length;

  /// 採買清單純文字(只列還缺的)
  String shoppingListText() {
    final missing = missingMaterials;
    if (missing.isEmpty) return '材料都備齊了';
    return [
      '材料採買清單(還缺 ${missing.length} 項):',
      ...missing.map((m) => '□ $m'),
    ].join('\n');
  }

  /// 指標純文字(代碼 + 全文),可直接貼進教案
  String indicatorsText() {
    return indicatorCodes
        .map((code) {
          final indicator = CurriculumService.indicator(code);
          return indicator == null
              ? code
              : '${indicator.code} ${indicator.text}';
        })
        .join('\n');
  }

  /// 整份備課摘要(分享用)
  String shareText() {
    final lines = <String>[
      '【本週備課】共 ${resources.length} 個活動',
      for (var i = 0; i < resources.length; i++)
        '${i + 1}. ${resources[i].title}(${resources[i].type.label})',
    ];
    if (materials.isNotEmpty) {
      lines
        ..add('')
        ..add(shoppingListText());
      if (ownedCount > 0) lines.add('(已備齊 $ownedCount 項)');
    }
    if (indicatorCodes.isNotEmpty) {
      lines
        ..add('')
        ..add('對應課綱指標:')
        ..add(indicatorsText());
    }
    return lines.join('\n');
  }
}
