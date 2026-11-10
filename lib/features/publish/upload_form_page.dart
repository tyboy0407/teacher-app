import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/motion.dart';
import '../../core/navigation.dart';
import '../../data/curriculum_service.dart';
import '../../data/theme_catalog.dart';
import '../../models/resource.dart';
import '../../models/resource_draft.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/animated_checkmark.dart';
import 'indicator_picker_page.dart';

class _PickedImage {
  const _PickedImage({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

class _StepFields {
  _StepFields()
    : title = TextEditingController(),
      description = TextEditingController();

  final TextEditingController title;
  final TextEditingController description;

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

/// 投稿表單:送出後進入待審狀態。
class UploadFormPage extends ConsumerStatefulWidget {
  const UploadFormPage({super.key});

  @override
  ConsumerState<UploadFormPage> createState() => _UploadFormPageState();
}

class _UploadFormPageState extends ConsumerState<UploadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _durationController = TextEditingController();
  final _tagInputController = TextEditingController();

  ResourceType _type = ResourceType.craft;
  final Set<AgeStage> _ages = {};
  final Set<LearningDomain> _domains = {};
  final Set<String> _themes = {};
  final List<String> _tags = [];
  List<String> _indicatorCodes = [];
  int? _difficulty;
  final List<TextEditingController> _materialControllers = [];
  final List<_StepFields> _steps = [];
  final List<_PickedImage> _images = [];
  bool _submitting = false;

  /// 送出成功後顯示成功頁(表單的「結尾」)
  bool _submitted = false;

  /// 送出失敗過一次後,欄位邊打邊驗證,錯誤會隨修正消失
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// 年齡、領域這兩組 chip 不是 Form 欄位,錯誤自己管;顯示在該區塊下方
  String? _ageError;
  String? _domainError;

  final _titleFocus = FocusNode();
  final _scroll = ScrollController();
  final _ageSectionKey = GlobalKey();
  final _domainSectionKey = GlobalKey();

  bool get _needsCraftFields => _type == ResourceType.craft;

  bool get _needsMaterials =>
      _type == ResourceType.craft || _type == ResourceType.play;

  @override
  void dispose() {
    _titleFocus.dispose();
    _scroll.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _durationController.dispose();
    _tagInputController.dispose();
    for (final controller in _materialControllers) {
      controller.dispose();
    }
    for (final step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _addTagFromInput() {
    final tag = _tagInputController.text.trim().replaceAll('#', '');
    if (tag.isEmpty) return;
    setState(() {
      if (!_tags.contains(tag)) _tags.add(tag);
      _tagInputController.clear();
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(maxWidth: 1600, imageQuality: 82);
    if (files.isEmpty) return;
    for (final file in files) {
      if (_images.length >= 6) break;
      final bytes = await file.readAsBytes();
      _images.add(_PickedImage(bytes: bytes, name: file.name));
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickIndicators() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => IndicatorPickerPage(initial: _indicatorCodes),
      ),
    );
    if (result != null && mounted) {
      setState(() => _indicatorCodes = result);
    }
  }

  /// 捲到出錯的區塊,老師不用自己找哪裡沒填
  Future<void> _revealError(GlobalKey key) async {
    final reduced = AppMotion.reduced(context);
    if (key.currentContext == null && _scroll.hasClients) {
      // 表單是延遲建構的清單,區塊捲出畫面後就不存在:先捲回頂端讓它建起來
      // (年齡、領域都在表單前段)
      await _scroll.animateTo(
        0,
        duration: reduced ? const Duration(milliseconds: 1) : AppMotion.slow,
        curve: AppMotion.standard,
      );
      await WidgetsBinding.instance.endOfFrame;
    }
    final target = key.currentContext;
    if (target == null || !target.mounted) return;
    await Scrollable.ensureVisible(
      target,
      alignment: 0.1,
      duration: reduced ? Duration.zero : AppMotion.slow,
      curve: AppMotion.standard,
    );
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _ageError = _ages.isEmpty ? '請選擇適用年齡' : null;
      _domainError = _domains.isEmpty ? '請選擇至少一個領域' : null;
    });
    if (!formValid) {
      // 標題是唯一的必填文字欄位:聚焦它,輸入框會自己捲進畫面
      _titleFocus.requestFocus();
      return;
    }
    if (_ageError != null) {
      await _revealError(_ageSectionKey);
      return;
    }
    if (_domainError != null) {
      await _revealError(_domainSectionKey);
      return;
    }

    setState(() => _submitting = true);
    final repo = ref.read(resourceRepositoryProvider);
    try {
      final imageUrls = <String>[];
      for (final image in _images) {
        imageUrls.add(await repo.uploadImage(image.bytes, image.name));
      }
      final materials = [
        for (final controller in _materialControllers)
          if (controller.text.trim().isNotEmpty) controller.text.trim(),
      ];
      final steps = [
        for (final step in _steps)
          if (step.title.text.trim().isNotEmpty)
            ResourceStep(
              title: step.title.text.trim(),
              description: step.description.text.trim(),
            ),
      ];
      final draft = ResourceDraft(
        title: _titleController.text.trim(),
        type: _type,
        summary: _summaryController.text.trim(),
        ages: _ages.toList(),
        domains: _domains.toList(),
        tags: _tags,
        indicatorCodes: _indicatorCodes,
        themes: _themes.toList(),
        coverUrl: imageUrls.isEmpty ? null : imageUrls.first,
        imageUrls: imageUrls,
        videoUrl: _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
        materials: _needsMaterials ? materials : const [],
        steps: _needsCraftFields ? steps : const [],
        content: _contentController.text.trim(),
        difficulty: _needsCraftFields ? _difficulty : null,
        durationMinutes: int.tryParse(_durationController.text.trim()),
      );
      await repo.submitResource(draft);
      ref.invalidate(myUploadsProvider);
      if (!mounted) return;
      // 老師付出最多的時刻,值得一個完整的結尾:整頁成功畫面,不是一個小對話框
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } catch (error) {
      if (!mounted) return;
      // 失敗要有回復路徑:直接給「重試」,填好的內容都還在
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('送出失敗,請檢查網路後再試一次'),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(label: '重試', onPressed: _submit),
          ),
        );
    } finally {
      if (mounted && _submitting) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('已送出'),
        ),
        body: _SubmitSuccessView(
          title: _titleController.text.trim(),
          onDone: () => popPage(context),
          // 換一張乾淨的表單:用取代而不是再推一層,返回仍回到「我的投稿」
          onAgain: () => context.pushReplacement('/publish/new'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('新增投稿')),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            TextFormField(
              controller: _titleController,
              focusNode: _titleFocus,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: '標題 *',
                hintText: '例:瓶蓋顏色分類盒',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? '請填標題' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _summaryController,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: '一句話簡介',
                hintText: '這個資源能幫老師解決什麼?',
                border: OutlineInputBorder(),
              ),
            ),
            _SectionLabel('類型 *'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in ResourceType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            _SectionLabel('適用年齡 *', key: _ageSectionKey),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final age in AgeStage.values)
                  FilterChip(
                    label: Text(age.label),
                    selected: _ages.contains(age),
                    onSelected: (_) => setState(() {
                      if (!_ages.remove(age)) _ages.add(age);
                      _ageError = null;
                    }),
                  ),
              ],
            ),
            _FieldError(_ageError),
            _SectionLabel('發展領域 *(最多 2~3 個)', key: _domainSectionKey),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final domain in LearningDomain.values)
                  FilterChip(
                    avatar: _domains.contains(domain)
                        ? null
                        : Icon(domain.icon, size: 16, color: domain.color),
                    label: Text(domain.label),
                    selected: _domains.contains(domain),
                    onSelected: (_) => setState(() {
                      if (!_domains.remove(domain)) _domains.add(domain);
                      _domainError = null;
                    }),
                  ),
              ],
            ),
            _FieldError(_domainError),
            _SectionLabel('主題 / 節慶(選填,老師常用主題搜尋)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final topic in themeTopics)
                  FilterChip(
                    avatar: Icon(topic.icon, size: 16),
                    label: Text(topic.label),
                    selected: _themes.contains(topic.code),
                    onSelected: (_) => setState(() {
                      if (!_themes.remove(topic.code)) _themes.add(topic.code);
                    }),
                  ),
              ],
            ),
            _SectionLabel('課綱學習指標(建議 1~3 條)'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final code in _indicatorCodes)
                  InputChip(
                    label: Text(code),
                    tooltip: CurriculumService.indicator(code)?.text,
                    onDeleted: () =>
                        setState(() => _indicatorCodes.remove(code)),
                  ),
                OutlinedButton.icon(
                  onPressed: _pickIndicators,
                  icon: const Icon(Icons.rule, size: 18),
                  label: Text(_indicatorCodes.isEmpty ? '選擇指標' : '調整指標'),
                ),
              ],
            ),
            _SectionLabel('照片(最多 6 張,第一張為封面)'),
            SizedBox(
              height: 92,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < _images.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _images[i].bytes,
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () => setState(() => _images.removeAt(i)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_images.length < 6)
                    OutlinedButton(
                      onPressed: _pickImages,
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size(92, 92),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _videoUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: '示範影片連結(選填)',
                hintText: 'YouTube 不公開影片網址',
                border: OutlineInputBorder(),
              ),
            ),
            if (_needsMaterials) ...[
              _SectionLabel('材料清單'),
              for (var i = 0; i < _materialControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _materialControllers[i],
                          decoration: InputDecoration(
                            labelText: '材料 ${i + 1}',
                            hintText: '例:各色瓶蓋 20~30 個',
                            isDense: true,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '移除這項材料',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(
                          () => _materialControllers.removeAt(i).dispose(),
                        ),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(
                    () => _materialControllers.add(TextEditingController()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新增材料'),
                ),
              ),
            ],
            if (_needsCraftFields) ...[
              _SectionLabel('製作步驟'),
              for (var i = 0; i < _steps.length; i++)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _steps[i].title,
                                decoration: const InputDecoration(
                                  hintText: '步驟標題,例:準備分類格',
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: '移除這個步驟',
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  setState(() => _steps.removeAt(i).dispose()),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _steps[i].description,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: '做法說明(一兩句)',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _steps.add(_StepFields())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新增步驟'),
                ),
              ),
              _SectionLabel('製作難度'),
              Wrap(
                spacing: 8,
                children: [
                  for (var level = 1; level <= 3; level++)
                    ChoiceChip(
                      label: Text('★' * level),
                      selected: _difficulty == level,
                      onSelected: (selected) =>
                          setState(() => _difficulty = selected ? level : null),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '所需時間(分鐘,選填)',
                border: OutlineInputBorder(),
              ),
            ),
            _SectionLabel('內文(玩法說明 / 教案內容 / 使用建議)'),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText:
                    '把另一位老師看了就能照做的細節寫進來;'
                    '含小物件或工具時,記得在結尾加「小提醒」安全說明。',
                border: OutlineInputBorder(),
              ),
            ),
            _SectionLabel('標籤'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in _tags)
                  InputChip(
                    label: Text('#$tag'),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tagInputController,
              decoration: InputDecoration(
                hintText: '輸入標籤後按 Enter,例:轉換時間',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: '加入標籤',
                  icon: const Icon(Icons.add),
                  onPressed: _addTagFromInput,
                ),
              ),
              onFieldSubmitted: (_) => _addTagFromInput(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_submitting ? '送出中…' : '送出審核'),
            ),
            const SizedBox(height: 8),
            Text(
              '送出即代表內容為原創或已取得授權,照片不含孩子的臉。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// chip 群組的錯誤訊息:顯示在該區塊正下方,和輸入框的錯誤同一種樣子
class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      alignment: Alignment.topLeft,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// 送出成功的結尾:勾勾畫出來、說清楚接下來會發生什麼、給兩個明確的下一步。
class _SubmitSuccessView extends StatelessWidget {
  const _SubmitSuccessView({
    required this.title,
    required this.onDone,
    required this.onAgain,
  });

  final String title;
  final VoidCallback onDone;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedCheckmark(),
              const SizedBox(height: 24),
              Text(
                '送出了!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title.isEmpty
                    ? '審核通過後會出現在資源庫,你可以在「發布」頁追蹤狀態。'
                    : '「$title」已進入審核。通過後會出現在資源庫,你可以在「發布」頁追蹤狀態。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onDone,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('回到我的投稿'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAgain,
                  icon: const Icon(Icons.add),
                  label: const Text('再投一篇'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
