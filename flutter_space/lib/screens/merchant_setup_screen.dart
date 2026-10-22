import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';

class MerchantSetupScreen extends StatefulWidget {
  final bool isEdit;

  const MerchantSetupScreen({super.key, this.isEdit = false});

  @override
  State<MerchantSetupScreen> createState() => _MerchantSetupScreenState();
}

class _MerchantSetupScreenState extends State<MerchantSetupScreen> {
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();

  String? _tradeType;
  String? _governorateId;
  String? _delegationId;
  String? _logoFileId;
  String? _logoUrl;
  Uint8List? _localLogoBytes;

  List<GovernorateModel> _governorates = [];
  List<DelegationModel> _delegations = [];

  bool _initialLoading = false;
  bool _uploadingLogo = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shopNameFocus.addListener(_onFocusChange);
    _phoneFocus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _shopNameFocus.removeListener(_onFocusChange);
    _phoneFocus.removeListener(_onFocusChange);
    _shopNameFocus.dispose();
    _phoneFocus.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isEditMode(AuthProvider auth) {
    return widget.isEdit || (auth.user?.merchantSetupComplete == true);
  }

  Future<void> _initializeData() async {
    final auth = context.read<AuthProvider>();
    final shouldPrefill = _isEditMode(auth);

    setState(() {
      _initialLoading = true;
      _errorMessage = null;
    });

    try {
      final govFuture = ApiClient.instance.getGovernorates();
      MerchantModel? existingMerchant;
      if (shouldPrefill) {
        try {
          existingMerchant = await ApiClient.instance.getMerchantMe();
        } catch (_) {
          existingMerchant = null;
        }
      }

      final govs = await govFuture;
      List<DelegationModel> dels = [];

      final preGovId = existingMerchant?.governorateId;
      if (preGovId != null && preGovId.isNotEmpty) {
        try {
          dels = await ApiClient.instance.getDelegations(preGovId);
        } catch (_) {
          dels = [];
        }
      }

      if (!mounted) return;
      setState(() {
        _governorates = govs;
        _delegations = dels;
        if (existingMerchant != null) {
          _shopNameController.text = existingMerchant.shopName ?? '';
          _phoneController.text = existingMerchant.phone ?? '';
          _tradeType = existingMerchant.tradeType;
          _governorateId = existingMerchant.governorateId;
          _delegationId = existingMerchant.delegationId;
          _logoFileId = existingMerchant.logoFileId;
          _logoUrl = existingMerchant.logoUrl;
        } else if (_phoneController.text.isEmpty) {
          _phoneController.text = '+216 ';
        }
        _initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onSelectGovernorate(String govId) async {
    if (_governorateId == govId) return;
    setState(() {
      _governorateId = govId;
      _delegationId = null;
      _delegations = [];
    });
    try {
      final dels = await ApiClient.instance.getDelegations(govId);
      if (!mounted || _governorateId != govId) return;
      setState(() {
        _delegations = dels;
      });
    } catch (_) {}
  }

  String _detectContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickAndUploadLogo() async {
    if (_uploadingLogo) return;
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xFile == null) return;

      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name.trim().isNotEmpty
          ? xFile.name.trim()
          : 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final contentType = _detectContentType(fileName);

      if (!mounted) return;
      setState(() {
        _localLogoBytes = bytes;
        _uploadingLogo = true;
        _errorMessage = null;
      });

      final fileId = await ApiClient.instance.uploadImageBytes(
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );

      if (!mounted) return;
      setState(() {
        _logoFileId = fileId;
        _uploadingLogo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadingLogo = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    final locale = context.read<LocaleProvider>();
    final auth = context.read<AuthProvider>();
    final isAr = locale.locale == 'ar';

    final shopName = _shopNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (shopName.isEmpty ||
        phone.isEmpty ||
        _tradeType == null ||
        _tradeType!.isEmpty ||
        _governorateId == null ||
        _governorateId!.isEmpty ||
        _delegationId == null ||
        _delegationId!.isEmpty) {
      setState(() {
        _errorMessage = isAr
            ? 'الرجاء ملء جميع الحقول المطلوبة'
            : 'Veuillez remplir tous les champs obligatoires';
      });
      return;
    }

    if (_uploadingLogo) {
      setState(() {
        _errorMessage = isAr
            ? 'يرجى الانتظار حتى يكتمل رفع الشعار'
            : 'Veuillez patienter pendant le téléchargement du logo';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      if (_isEditMode(auth)) {
        await ApiClient.instance.updateMerchantMe(
          shopName: shopName,
          tradeType: _tradeType!,
          governorateId: _governorateId!,
          delegationId: _delegationId!,
          phone: phone,
          logoFileId: _logoFileId,
        );
      } else {
        await ApiClient.instance.setupMerchant(
          shopName: shopName,
          tradeType: _tradeType!,
          governorateId: _governorateId!,
          delegationId: _delegationId!,
          phone: phone,
          logoFileId: _logoFileId,
        );
      }

      await auth.refreshUser();

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    final hasFocus = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: hasFocus ? AppColors.surface : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: hasFocus ? AppColors.primary : AppColors.borderSubtle,
          width: hasFocus ? 1.6 : 1.0,
        ),
        boxShadow: hasFocus ? AppShadows.goldGlow : const [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: hasFocus ? AppColors.primary : AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final isAr = locale.locale == 'ar';
    final isEdit = _isEditMode(auth);
    final canPop = Navigator.of(context).canPop();

    return Directionality(
      textDirection: locale.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AmbientGlowBackground(
          child: Column(
            children: [
              HwentiHeader(
                title: isEdit ? locale.t('editShop') : locale.t('setupShop'),
                showBack: canPop,
              ),

              Expanded(
                child: _initialLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: FadeSlideEntry(
                          index: 0,
                          child: GlassContainer(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            borderRadius: AppRadius.xl,
                            backgroundColor: AppColors.surface,
                            borderColor: AppColors.borderSubtle,
                            shadows: AppShadows.card,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Circular Logo Studio (116px with Royal Indigo Ring)
                                Center(
                                  child: BouncyTap(
                                    onTap: _pickAndUploadLogo,
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          width: 116,
                                          height: 116,
                                          padding: const EdgeInsets.all(3.5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: AppGradients.goldHero,
                                            boxShadow: AppShadows.goldGlow,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.surfaceElevated,
                                              image: _localLogoBytes != null
                                                  ? DecorationImage(
                                                      image: MemoryImage(
                                                        _localLogoBytes!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : (_logoUrl != null &&
                                                          _logoUrl!.isNotEmpty)
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                            _logoUrl!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                            ),
                                            child: (_localLogoBytes == null &&
                                                    (_logoUrl == null ||
                                                        _logoUrl!.isEmpty))
                                                ? const Icon(
                                                    Icons.storefront_rounded,
                                                    size: 46,
                                                    color: AppColors.primary,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        if (_uploadingLogo)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black.withValues(
                                                  alpha: 0.45,
                                                ),
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.goldHero,
                                            shape: BoxShape.circle,
                                            boxShadow: AppShadows.goldGlow,
                                            border: Border.all(
                                              color: AppColors.surface,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs + 2),
                                Text(
                                  isAr
                                      ? 'اضغط لاختيار شعار المتجر'
                                      : 'Appuyez pour choisir le logo du magasin',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                if (_errorMessage != null &&
                                    _errorMessage!.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.sm + 2,
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      border: Border.all(
                                        color: AppColors.error.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],

                                // Shop Name Input
                                Text(
                                  locale.t('shopName'),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                _buildAnimatedField(
                                  controller: _shopNameController,
                                  focusNode: _shopNameFocus,
                                  hint: locale.t('shopName'),
                                  prefixIcon: Icons.storefront_outlined,
                                ),
                                const SizedBox(height: AppSpacing.md),

                                // Phone Input (+216)
                                Text(
                                  locale.t('phone'),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                _buildAnimatedField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  hint: '+216 ...',
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Tactile Trade Type Chips (#F1F5F9 unselected, #4F46E5 selected)
                                Text(
                                  locale.t('tradeType'),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: TradeTypes.all.map((tt) {
                                    final selected = _tradeType == tt;
                                    return BouncyTap(
                                      onTap: () =>
                                          setState(() => _tradeType = tt),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm + 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.primary
                                              : AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                          border: Border.all(
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.borderSubtle,
                                            width: selected ? 1.5 : 1.0,
                                          ),
                                          boxShadow: selected
                                              ? AppShadows.goldGlow
                                              : const [],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              TradeTypes.icon(tt),
                                              size: 18,
                                              color: selected
                                                  ? Colors.white
                                                  : AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              TradeTypes.label(
                                                tt,
                                                locale.locale,
                                              ),
                                              style: TextStyle(
                                                color: selected
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                                fontWeight: selected
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Governorate Selector Pills
                                Text(
                                  locale.t('governorate'),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                SizedBox(
                                  height: 46,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _governorates.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: AppSpacing.xs),
                                    itemBuilder: (context, index) {
                                      final gov = _governorates[index];
                                      final selected = _governorateId == gov.id;
                                      return BouncyTap(
                                        onTap: () =>
                                            _onSelectGovernorate(gov.id),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.surfaceElevated,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.full,
                                            ),
                                            border: Border.all(
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.borderSubtle,
                                            ),
                                            boxShadow: selected
                                                ? AppShadows.goldGlow
                                                : const [],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.location_city_rounded,
                                                size: 15,
                                                color: selected
                                                    ? Colors.white
                                                    : AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                gov.localizedName(
                                                  locale.locale,
                                                ),
                                                style: TextStyle(
                                                  color: selected
                                                      ? Colors.white
                                                      : AppColors.textPrimary,
                                                  fontWeight: selected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Delegation Selector Pills
                                if (_delegations.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    locale.t('delegation'),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  SizedBox(
                                    height: 46,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _delegations.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: AppSpacing.xs),
                                      itemBuilder: (context, index) {
                                        final del = _delegations[index];
                                        final selected =
                                            _delegationId == del.id;
                                        return BouncyTap(
                                          onTap: () => setState(
                                            () => _delegationId = del.id,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.surfaceElevated,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadius.full,
                                              ),
                                              border: Border.all(
                                                color: selected
                                                    ? AppColors.primary
                                                    : AppColors.borderSubtle,
                                              ),
                                              boxShadow: selected
                                                  ? AppShadows.goldGlow
                                                  : const [],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.place_rounded,
                                                  size: 15,
                                                  color: selected
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  del.localizedName(
                                                    locale.locale,
                                                  ),
                                                  style: TextStyle(
                                                    color: selected
                                                        ? Colors.white
                                                        : AppColors.textPrimary,
                                                    fontWeight: selected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                    fontSize: 13,
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

                                const SizedBox(height: AppSpacing.xl),

                                // Royal Indigo / Emerald Save CTA
                                BouncyTap(
                                  onTap: _saving ? null : _handleSave,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: _saving ? 0.65 : 1.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.goldHero,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        boxShadow: AppShadows.goldGlow,
                                      ),
                                      child: Center(
                                        child: _saving
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    locale.t('save'),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
