import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';

class _EditableImageItem {
  final String? existingUrl;
  String? fileId;
  final Uint8List? bytes;
  final String? fileName;
  final String contentType;

  _EditableImageItem.existing({
    required String this.existingUrl,
    required String this.fileId,
  })  : bytes = null,
        fileName = null,
        contentType = 'image/jpeg';

  _EditableImageItem.picked({
    required Uint8List this.bytes,
    required String this.fileName,
    required this.contentType,
  })  : existingUrl = null,
        fileId = null;
}

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  static const int _maxImages = 6;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<_EditableImageItem> _images = [];
  DateTime _publishDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await ApiClient.instance.getProduct(widget.productId);
      if (!mounted) return;

      _nameController.text = product.name;
      _priceController.text = product.price == product.price.roundToDouble()
          ? product.price.toInt().toString()
          : product.price.toStringAsFixed(2);
      _phoneController.text = product.phone;
      _descriptionController.text = product.description ?? '';

      final sortedImages = [...product.images]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      setState(() {
        _images
          ..clear()
          ..addAll(
            sortedImages
                .where((img) => img.fileId.isNotEmpty)
                .map(
                  (img) => _EditableImageItem.existing(
                    existingUrl: img.url,
                    fileId: img.fileId,
                  ),
                ),
          );
        final parsedExpiry = DateTime.tryParse(product.expiryDate);
        if (parsedExpiry != null) {
          _expiryDate = parsedExpiry.toLocal();
        }
        final parsedPublish = DateTime.tryParse(product.publishDate);
        if (parsedPublish != null) {
          _publishDate = parsedPublish.toLocal();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _detectContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickImages() async {
    final locale = context.read<LocaleProvider>();
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale.locale == 'ar'
                ? 'يمكنك إضافة 6 صور كحد أقصى'
                : 'Vous pouvez ajouter jusqu\'à 6 images maximum',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 82);
      if (pickedFiles.isEmpty) return;

      final toAdd = pickedFiles.take(remaining);
      final loaded = <_EditableImageItem>[];
      for (final xFile in toAdd) {
        final bytes = await xFile.readAsBytes();
        final name = xFile.name.trim().isNotEmpty
            ? xFile.name.trim()
            : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        loaded.add(
          _EditableImageItem.picked(
            bytes: bytes,
            fileName: name,
            contentType: _detectContentType(name),
          ),
        );
      }

      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _images.addAll(loaded);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _removeImage(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _images.removeAt(index);
    });
  }

  void _moveImage(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= _images.length) return;
    HapticFeedback.selectionClick();
    setState(() {
      final item = _images.removeAt(fromIndex);
      _images.insert(toIndex, item);
    });
  }

  void _applyQuickDuration(int days) {
    HapticFeedback.selectionClick();
    setState(() {
      _expiryDate = DateTime(
        _publishDate.year,
        _publishDate.month,
        _publishDate.day,
        23,
        59,
        59,
      ).add(Duration(days: days));
    });
  }

  Future<void> _pickPublishDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _publishDate = DateTime(picked.year, picked.month, picked.day);
        if (!_expiryDate.isAfter(_publishDate)) {
          _expiryDate = _publishDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final firstDate = _publishDate;
    final initial = _expiryDate.isAfter(firstDate)
        ? _expiryDate
        : firstDate.add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _expiryDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
          59,
        );
      });
    }
  }

  String _formatDate(DateTime date, String locale) {
    try {
      return DateFormat('yyyy/MM/dd', locale == 'ar' ? 'ar' : 'fr').format(date);
    } catch (_) {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleSubmit() async {
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';

    final name = _nameController.text.trim();
    final priceRaw = _priceController.text.trim().replaceAll(',', '.');
    final phone = _phoneController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(priceRaw);

    if (name.isEmpty ||
        price == null ||
        price <= 0 ||
        phone.isEmpty ||
        _images.isEmpty) {
      setState(() {
        _error = locale.t('fillRequiredFields');
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final fileIds = <String>[];
      for (final img in _images) {
        if (img.fileId != null && img.fileId!.isNotEmpty) {
          fileIds.add(img.fileId!);
        } else if (img.bytes != null) {
          final uploadedId = await ApiClient.instance.uploadImageBytes(
            bytes: img.bytes!,
            fileName: img.fileName ?? 'product.jpg',
            contentType: img.contentType,
          );
          img.fileId = uploadedId;
          fileIds.add(uploadedId);
        }
      }

      await ApiClient.instance.updateProduct(
        widget.productId,
        name: name,
        price: price,
        phone: phone,
        description: description,
        expiryDate: _expiryDate,
        publishDate: _publishDate,
        imageFileIds: fileIds,
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تم تحديث المنتج بنجاح'
                : 'Produit mis à jour avec succès',
          ),
          backgroundColor: AppColors.action,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildImageWidget(_EditableImageItem item) {
    if (item.bytes != null) {
      return Image.memory(item.bytes!, fit: BoxFit.cover);
    }
    if (item.existingUrl != null && item.existingUrl!.isNotEmpty) {
      return Image.network(
        item.existingUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.surfaceElevated,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Container(color: AppColors.surfaceElevated);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.locale == 'ar';
    final durationDays = _expiryDate
        .difference(
          DateTime(_publishDate.year, _publishDate.month, _publishDate.day),
        )
        .inDays
        .clamp(1, 999);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(
              title: locale.t('editProduct'),
              showBack: true,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          FadeSlideEntry(
                            index: 0,
                            child: _buildPhotoStudioBento(locale, isAr),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FadeSlideEntry(
                            index: 1,
                            child: _buildProductDetailsBento(locale, isAr),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FadeSlideEntry(
                            index: 2,
                            child: _buildDatesBento(locale, isAr, durationDays),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          FadeSlideEntry(
                            index: 3,
                            child: _buildSubmitButton(locale),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoStudioBento(LocaleProvider locale, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.goldHero,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.camera_enhance_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.t('selectImages'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      isAr
                          ? 'الصورة الأولى هي الرئيسية • حتى 6 صور'
                          : 'La 1ère photo est principale • Jusqu\'à 6 photos',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${_images.length} / $_maxImages',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_images.isEmpty)
            BouncyTap(
              onTap: _isSubmitting ? null : _pickImages,
              child: Container(
                height: 168,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      locale.t('selectImages'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageWidget(_images.first),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppGradients.goldHero,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: AppShadows.goldGlow,
                        ),
                        child: Text(
                          isAr ? 'الصورة الرئيسية' : 'Photo principale',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount:
                    _images.length + (_images.length < _maxImages ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return BouncyTap(
                      onTap: _isSubmitting ? null : _pickImages,
                      child: Container(
                        width: 96,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isAr ? '+ صور' : '+ Photos',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final item = _images[index];
                  final isFirst = index == 0;
                  return Container(
                    width: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isFirst
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        width: isFirst ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md - 2),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImageWidget(item),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: GestureDetector(
                              onTap: _isSubmitting
                                  ? null
                                  : () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(
                                    alpha: 0.92,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: AppColors.surface.withValues(alpha: 0.9),
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: index > 0 && !_isSubmitting
                                        ? () => _moveImage(index, index - 1)
                                        : null,
                                    child: Icon(
                                      Icons.chevron_left_rounded,
                                      size: 18,
                                      color: index > 0
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary
                                              .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: index < _images.length - 1 &&
                                            !_isSubmitting
                                        ? () => _moveImage(index, index + 1)
                                        : null,
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: index < _images.length - 1
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary
                                              .withValues(alpha: 0.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductDetailsBento(LocaleProvider locale, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('${locale.t('productName')} *'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            enabled: !_isSubmitting,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: _inputDecoration(
              hint: isAr ? 'مثال: زيت زيتون بكر ممتاز' : 'Ex: Huile d\'olive vierge',
              prefixIcon: Icons.shopping_bag_outlined,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(
                      '${locale.t('price')} (${locale.t('tnd')}) *',
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _priceController,
                      enabled: !_isSubmitting,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _inputDecoration(
                        hint: '0.00',
                        prefixIcon: Icons.sell_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('${locale.t('phone')} *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _inputDecoration(
                        hint: '+216 ...',
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInputLabel(locale.t('description')),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            enabled: !_isSubmitting,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: isAr
                  ? 'أضف تفاصيل العرض والمواصفات...'
                  : 'Détails et caractéristiques du produit...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesBento(
    LocaleProvider locale,
    bool isAr,
    int durationDays,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'صلاحية العرض' : 'Période de validité',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.action.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$durationDays ${locale.t('days')}',
                  style: const TextStyle(
                    color: AppColors.action,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildDateSelectorTile(
                  label: locale.t('publishDate'),
                  value: _formatDate(_publishDate, locale.locale),
                  icon: Icons.calendar_today_outlined,
                  onTap: _isSubmitting ? null : _pickPublishDate,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildDateSelectorTile(
                  label: locale.t('expiryDate'),
                  value: _formatDate(_expiryDate, locale.locale),
                  icon: Icons.event_available_outlined,
                  onTap: _isSubmitting ? null : _pickExpiryDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [7, 14, 30, 60].map((days) {
              final selected = durationDays == days;
              return BouncyTap(
                onTap: _isSubmitting ? null : () => _applyQuickDuration(days),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color:
                          selected ? AppColors.primary : AppColors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    '$days ${locale.t('days')}',
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
          : null,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildSubmitButton(LocaleProvider locale) {
    return BouncyTap(
      onTap: _isSubmitting ? null : _handleSubmit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppGradients.goldHero,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.goldGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSubmitting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              _isSubmitting ? locale.t('loading') : locale.t('save'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
