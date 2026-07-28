import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/catalog_providers.dart';
import 'package:safed_prixod/features/products/product_detail_page.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.productId});

  final int? productId;

  bool get isEdit => productId != null;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  static const _langs = ['uz', 'ru', 'en'];

  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '0');
  final _shelfCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _nameCtrls = {for (final l in _langs) l: TextEditingController()};
  final _descCtrls = {for (final l in _langs) l: TextEditingController()};

  int? _categoryId;
  int? _badgeId;
  int? _unitId;
  bool _isActive = true;
  bool _isDiscount = false;
  bool _loading = false;
  bool _saving = false;
  int? _barcodeRecordId;
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
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _shelfCtrl.dispose();
    _barcodeCtrl.dispose();
    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    for (final c in _descCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ref
          .read(adminProductsApiProvider)
          .fetch(widget.productId!);
      _categoryId = p['category'] is Map
          ? p['category']['id'] as int?
          : p['category'] as int?;
      _badgeId = p['badge'] is Map
          ? p['badge']['id'] as int?
          : p['badge'] as int?;
      _unitId = p['unit'] is Map ? p['unit']['id'] as int? : p['unit'] as int?;
      _isActive = p['is_active'] != false;
      _isDiscount = p['is_discount'] == true;
      _priceCtrl.text = p['price']?.toString() ?? '';
      _qtyCtrl.text = '${p['quantity'] ?? 0}';
      _shelfCtrl.text = p['shelf_location']?.toString() ?? '';

      final tr = p['translations'];
      if (tr is Map) {
        for (final lang in _langs) {
          final block = tr[lang];
          if (block is Map) {
            _nameCtrls[lang]!.text = block['name']?.toString() ?? '';
            _descCtrls[lang]!.text = block['description']?.toString() ?? '';
          }
        }
      }

      final barcodes = p['barcodes'];
      if (barcodes is List && barcodes.isNotEmpty && barcodes.first is Map) {
        final first = Map<String, dynamic>.from(barcodes.first as Map);
        _barcodeRecordId = first['id'] as int?;
        _barcodeCtrl.text = first['barcode']?.toString() ?? '';
      }

      final imgs = p['images'];
      if (imgs is List) {
        _existingImageUrls = imgs
            .map((e) => e is Map ? (e['image'] ?? e['url'])?.toString() : null)
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
      final name = _nameCtrls[lang]!.text.trim();
      final desc = _descCtrls[lang]!.text.trim();
      if (name.isNotEmpty || desc.isNotEmpty) {
        out[lang] = {'name': name, 'description': desc};
      }
    }
    return out;
  }

  Future<FormData> _buildFormData() async {
    final fd = FormData.fromMap({
      'translations': jsonEncode(_translationsPayload()),
      if (_categoryId != null) 'category': '$_categoryId',
      if (_badgeId != null) 'badge': '$_badgeId',
      if (_unitId != null) 'unit': '$_unitId',
      'quantity': _qtyCtrl.text.trim().isEmpty ? '0' : _qtyCtrl.text.trim(),
      'price': _priceCtrl.text.trim(),
      'is_discount': _isDiscount ? 'true' : 'false',
      'is_active': _isActive ? 'true' : 'false',
      if (_shelfCtrl.text.trim().isNotEmpty)
        'shelf_location': _shelfCtrl.text.trim(),
    });

    final bc = _barcodeCtrl.text.trim();
    final skipBarcode = widget.isEdit && _barcodeRecordId != null;
    if (bc.isNotEmpty && !skipBarcode) {
      fd.fields.add(MapEntry('barcode_number', bc));
    }

    for (final file in _newImages) {
      fd.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(file.path, filename: file.name),
        ),
      );
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
    final imageId = _existingImageIds[index];
    try {
      await ref.read(adminProductsApiProvider).deleteImage(imageId);
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
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ref.read(appToastProvider.notifier).warning('Выберите категорию');
      return;
    }
    if (_translationsPayload().isEmpty) {
      ref
          .read(appToastProvider.notifier)
          .warning('Введите название хотя бы на одном языке');
      return;
    }

    setState(() => _saving = true);
    try {
      final fd = await _buildFormData();
      final api = ref.read(adminProductsApiProvider);
      if (widget.isEdit) {
        await api.update(widget.productId!, fd);
        final bc = _barcodeCtrl.text.trim();
        if (_barcodeRecordId != null && bc.isNotEmpty) {
          await api.updateBarcode(_barcodeRecordId!, bc);
        }
        ref.invalidate(productDetailProvider(widget.productId!));
        showApiSuccess(ref, 'Saqlandi');
      } else {
        await api.create(fd);
        showApiSuccess(ref, 'Товар создан');
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
    final categoriesAsync = ref.watch(leafCategoriesProvider);
    final badgesAsync = ref.watch(badgesListProvider);
    final unitsAsync = ref.watch(unitsListProvider);
    final compact = MediaQuery.sizeOf(context).width < 380;
    final horizontalPadding = compact ? 12.0 : 16.0;
    final badgeField = badgesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) => DropdownButtonFormField<int?>(
        initialValue: _badgeId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Badge',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('—')),
          ...items.map(
            (b) => DropdownMenuItem<int?>(
              value: b['id'] as int,
              child: Text(
                localizedFromMap(b['name']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (v) => setState(() => _badgeId = v),
      ),
    );
    final unitField = unitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) => DropdownButtonFormField<int?>(
        initialValue: _unitId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Единица',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('—')),
          ...items.map(
            (u) => DropdownMenuItem<int?>(
              value: u['id'] as int,
              child: Text(
                localizedFromMap(u['name']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (v) => setState(() => _unitId = v),
      ),
    );

    return SafedScaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Редактировать товар' : 'Новый товар'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(horizontalPadding),
                children: [
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(messageFromObject(e)),
                    data: (cats) => DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Категория *',
                        border: OutlineInputBorder(),
                      ),
                      items: cats
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(
                                c['label']?.toString() ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (compact)
                    Column(
                      children: [
                        badgeField,
                        const SizedBox(height: 12),
                        unitField,
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: badgeField),
                        const SizedBox(width: 12),
                        Expanded(child: unitField),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Цена *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Введите цену'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Количество',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shelfCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Полка (shelf_location)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _barcodeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Штрих-код',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Активен'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  SwitchListTile(
                    title: const Text('Скидка'),
                    value: _isDiscount,
                    onChanged: (v) => setState(() => _isDiscount = v),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Tarjimalar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  ..._langs.map((lang) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
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
                            controller: _nameCtrls[lang],
                            decoration: InputDecoration(
                              labelText: 'Название ($lang)',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descCtrls[lang],
                            decoration: InputDecoration(
                              labelText: 'Описание ($lang)',
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Rasmlar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Добавить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
