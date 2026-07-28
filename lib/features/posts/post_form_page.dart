import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/catalog_providers.dart';
import 'package:safed_prixod/features/posts/post_detail_page.dart';

class PostFormPage extends ConsumerStatefulWidget {
  const PostFormPage({super.key, this.postId});

  final int? postId;

  bool get isEdit => postId != null;

  @override
  ConsumerState<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends ConsumerState<PostFormPage> {
  static const _langs = ['uz', 'ru', 'en'];

  final _formKey = GlobalKey<FormState>();
  final _titleCtrls = {for (final l in _langs) l: TextEditingController()};
  final _contentCtrls = {for (final l in _langs) l: TextEditingController()};

  bool _isActive = true;
  bool _loading = false;
  bool _saving = false;
  List<String> _existingImageUrls = const [];
  List<int> _existingImageIds = const [];
  final List<XFile> _newImages = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _load();
  }

  @override
  void dispose() {
    for (final c in _titleCtrls.values) {
      c.dispose();
    }
    for (final c in _contentCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ref.read(adminPostsApiProvider).fetch(widget.postId!);
      _isActive = p['is_active'] != false;
      final tr = p['translations'];
      if (tr is Map) {
        for (final lang in _langs) {
          final block = tr[lang];
          if (block is Map) {
            _titleCtrls[lang]!.text = block['title']?.toString() ?? '';
            _contentCtrls[lang]!.text = block['content']?.toString() ?? '';
          }
        }
      }
      final imgs = p['images'] ?? p['post_images'];
      if (imgs is List) {
        _existingImageUrls = imgs
            .map(
              (e) => e is Map
                  ? (e['image'] ?? e['url'] ?? e['file'])?.toString()
                  : null,
            )
            .whereType<String>()
            .toList();
        _existingImageIds = imgs
            .map((e) => e is Map ? e['id'] as int? : null)
            .whereType<int>()
            .toList();
      }
    } catch (e) {
      showApiError(ref, e);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _translationsPayload() {
    final out = <String, dynamic>{};
    for (final lang in _langs) {
      final title = _titleCtrls[lang]!.text.trim();
      final content = _contentCtrls[lang]!.text.trim();
      if (title.isNotEmpty || content.isNotEmpty) {
        out[lang] = {'title': title, 'content': content};
      }
    }
    return out;
  }

  Future<FormData> _buildFormData({required bool includeImages}) async {
    final map = <String, dynamic>{
      'translations': jsonEncode(_translationsPayload()),
      'is_active': _isActive ? 'true' : 'false',
    };
    final fd = FormData.fromMap(map);
    if (includeImages) {
      for (final file in _newImages) {
        fd.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }
    return fd;
  }

  Future<void> _pickImages() async {
    final total = _existingImageUrls.length + _newImages.length;
    if (total >= 8) {
      ref.read(appToastProvider.notifier).warning('Максимум 8 изображений');
      return;
    }
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      for (final f in picked) {
        if (_existingImageUrls.length + _newImages.length >= 8) break;
        _newImages.add(f);
      }
    });
  }

  Future<void> _deleteExistingImage(int index) async {
    if (index >= _existingImageIds.length) return;
    try {
      await ref
          .read(adminPostsApiProvider)
          .deleteImage(_existingImageIds[index]);
      setState(() {
        _existingImageUrls = List.of(_existingImageUrls)..removeAt(index);
        _existingImageIds = List.of(_existingImageIds)..removeAt(index);
      });
      showApiSuccess(ref, 'Rasm o\'chirildi');
    } catch (e) {
      showApiError(ref, e);
    }
  }

  Future<void> _save() async {
    if (_translationsPayload().isEmpty) {
      ref
          .read(appToastProvider.notifier)
          .warning('Kamida bitta til uchun sarlavha yoki matn kiriting');
      return;
    }

    setState(() => _saving = true);
    try {
      final api = ref.read(adminPostsApiProvider);
      if (widget.isEdit) {
        final fd = await _buildFormData(includeImages: false);
        await api.update(widget.postId!, fd);
        if (_newImages.isNotEmpty) {
          final imgFd = FormData();
          imgFd.fields.add(MapEntry('post', '${widget.postId}'));
          for (final file in _newImages) {
            imgFd.files.add(
              MapEntry(
                'images',
                await MultipartFile.fromFile(file.path, filename: file.name),
              ),
            );
          }
          await api.addImages(widget.postId!, imgFd);
        }
        ref.invalidate(postDetailProvider(widget.postId!));
        showApiSuccess(ref, 'Saqlandi');
      } else {
        final fd = await _buildFormData(includeImages: true);
        await api.create(fd);
        showApiSuccess(ref, 'Post yaratildi');
      }
      if (mounted) context.pop();
    } catch (e) {
      showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final horizontalPadding = compact ? 12.0 : 16.0;

    return SafedScaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Редактировать пост' : 'Новый пост'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(horizontalPadding),
                children: [
                  SwitchListTile(
                    title: const Text('Активен'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const Divider(height: 24),
                  ..._langs.map((lang) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleCtrls[lang],
                            decoration: InputDecoration(
                              labelText: 'Заголовок ($lang)',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contentCtrls[lang],
                            decoration: InputDecoration(
                              labelText: 'Текст ($lang)',
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    );
                  }),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Изображения',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Добавить'),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _existingImageUrls.length; i++)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _existingImageUrls[i],
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(28, 28),
                                ),
                                iconSize: 16,
                                onPressed: () => _deleteExistingImage(i),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ],
                        ),
                      for (final file in _newImages)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file.path),
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isEdit ? 'Сохранить' : 'Создать'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
