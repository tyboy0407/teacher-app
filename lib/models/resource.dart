import 'taxonomy.dart';

/// 製作步驟
class ResourceStep {
  const ResourceStep({
    required this.title,
    this.description = '',
    this.imageUrl,
  });

  final String title;
  final String description;

  /// 這個步驟的圖示(選填);網址格式見 ResourceImage
  final String? imageUrl;

  factory ResourceStep.fromJson(Map<String, dynamic> json) => ResourceStep(
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    imageUrl: json['image'] as String?,
  );
}

/// 教學資源:教具製作 / 教具玩法 / 成品教玩具 / 教案 / 學習單 / 文章 共用同一模型
class Resource {
  const Resource({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    this.summary = '',
    this.ages = const [],
    this.domains = const [],
    this.tags = const [],
    this.coverUrl,
    this.imageUrls = const [],
    this.videoUrl,
    this.materials = const [],
    this.steps = const [],
    this.content = '',
    this.indicatorCodes = const [],
    this.themes = const [],
    this.sourceName,
    this.sourceUrl,
    this.difficulty,
    this.durationMinutes,
    this.isFeatured = false,
    this.createdBy,
    this.reviewStatus = 'approved',
    this.reviewNote,
    this.published = true,
  });

  final String id;
  final String title;
  final String summary;
  final ResourceType type;
  final List<AgeStage> ages;
  final List<LearningDomain> domains;
  final List<String> tags;
  final String? coverUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> materials;
  final List<ResourceStep> steps;
  final String content;

  /// 對應的課綱學習指標代碼,如「認-中-1-1-1」
  final List<String> indicatorCodes;

  /// 主題/節慶代碼(見 theme_catalog.dart),如「spring」「mothers_day」
  final List<String> themes;
  final String? sourceName;
  final String? sourceUrl;
  final int? difficulty;
  final int? durationMinutes;
  final bool isFeatured;
  final DateTime createdAt;

  /// 投稿者(後台錄入的內容為 null)
  final String? createdBy;

  /// 審核狀態:pending / approved / rejected
  final String reviewStatus;

  /// 審核備註(退回原因)
  final String? reviewNote;

  /// 是否上架(管理者控制的顯示開關)
  final bool published;

  /// 有真正的封面照片(沒有時封面只是色紙 + 類型圖示,版面應該讓位給文字)
  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;

  bool get isPendingReview => reviewStatus == 'pending';
  bool get isRejected => reviewStatus == 'rejected';

  /// 解析 Supabase 回傳的資料列(含內嵌的 resource_tags -> tags)
  factory Resource.fromSupabase(Map<String, dynamic> json) {
    return Resource(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      type:
          ResourceType.fromCode(json['type'] as String?) ??
          ResourceType.article,
      ages: _stringList(
        json['age_stages'],
      ).map(AgeStage.fromCode).whereType<AgeStage>().toList(),
      domains: _stringList(
        json['domains'],
      ).map(LearningDomain.fromCode).whereType<LearningDomain>().toList(),
      tags: _embeddedTagNames(json['resource_tags']),
      coverUrl: json['cover_url'] as String?,
      imageUrls: _stringList(json['image_urls']),
      videoUrl: json['video_url'] as String?,
      materials: _stringList(json['materials']),
      steps: _steps(json['steps']),
      content: json['content'] as String? ?? '',
      indicatorCodes: _stringList(json['indicator_codes']),
      themes: _stringList(json['themes']),
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime(2026),
      createdBy: json['created_by'] as String?,
      reviewStatus: json['review_status'] as String? ?? 'approved',
      reviewNote: json['review_note'] as String?,
      published: json['published'] as bool? ?? true,
    );
  }

  static List<String> _stringList(dynamic value) =>
      value is List ? value.map((e) => e.toString()).toList() : const [];

  static List<ResourceStep> _steps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((step) => ResourceStep.fromJson(Map<String, dynamic>.from(step)))
        .toList();
  }

  static List<String> _embeddedTagNames(dynamic links) {
    if (links is! List) return const [];
    final names = <String>[];
    for (final link in links) {
      if (link is Map) {
        final tag = link['tags'];
        if (tag is Map && tag['name'] is String) {
          names.add(tag['name'] as String);
        }
      }
    }
    return names;
  }
}
