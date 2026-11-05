import 'resource.dart';
import 'taxonomy.dart';

/// 投稿草稿:上傳表單收集的欄位,送交 submit_resource 函式。
class ResourceDraft {
  const ResourceDraft({
    required this.title,
    required this.type,
    this.summary = '',
    this.ages = const [],
    this.domains = const [],
    this.tags = const [],
    this.indicatorCodes = const [],
    this.coverUrl,
    this.imageUrls = const [],
    this.videoUrl,
    this.materials = const [],
    this.steps = const [],
    this.content = '',
    this.difficulty,
    this.durationMinutes,
  });

  final String title;
  final ResourceType type;
  final String summary;
  final List<AgeStage> ages;
  final List<LearningDomain> domains;
  final List<String> tags;
  final List<String> indicatorCodes;
  final String? coverUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> materials;
  final List<ResourceStep> steps;
  final String content;
  final int? difficulty;
  final int? durationMinutes;

  Map<String, dynamic> toPayload() => {
        'title': title,
        'summary': summary,
        'type': type.code,
        'age_stages': ages.map((age) => age.code).toList(),
        'domains': domains.map((domain) => domain.code).toList(),
        'indicator_codes': indicatorCodes,
        'tags': tags,
        if (coverUrl != null) 'cover_url': coverUrl,
        'image_urls': imageUrls,
        if (videoUrl != null) 'video_url': videoUrl,
        'materials': materials,
        'steps': [
          for (final step in steps)
            {'title': step.title, 'description': step.description},
        ],
        'content': content,
        if (difficulty != null) 'difficulty': difficulty.toString(),
        if (durationMinutes != null)
          'duration_minutes': durationMinutes.toString(),
      };
}
