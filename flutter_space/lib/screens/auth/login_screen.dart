import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/widgets/google_sign_in_button.dart';
import 'package:hwenti_flutter/widgets/kinetic_fx.dart';

class LoginScreen extends StatefulWidget {
  final bool initialIsSignup;

  const LoginScreen({
    super.key,
    this.initialIsSignup = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late bool _isSignup;
  String _role = 'visitor'; // 'visitor' | 'merchant'
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignup = widget.initialIsSignup;
    _nameFocus.addListener(_onChanged);
    _emailFocus.addListener(_onChanged);
    _passwordFocus.addListener(_onChanged);
    _confirmFocus.addListener(_onChanged);
    _passwordController.addListener(_onChanged);
    _confirmPasswordController.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameFocus.removeListener(_onChanged);
    _emailFocus.removeListener(_onChanged);
    _passwordFocus.removeListener(_onChanged);
    _confirmFocus.removeListener(_onChanged);
    _passwordController.removeListener(_onChanged);
    _confirmPasswordController.removeListener(_onChanged);
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(bool signup) {
    if (_isSignup == signup) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() {
      _isSignup = signup;
      _errorMessage = null;
    });
  }

  int _passwordStrengthScore(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z0-9]').hasMatch(password)) score++;
    if (password.length >= 10 || RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) {
      score++;
    }
    return score.clamp(1, 4);
  }

  Color _strengthColor(int score) {
    switch (score) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.primaryAmber;
      case 3:
        return AppColors.secondary;
      case 4:
        return AppColors.action;
      default:
        return AppColors.borderSubtle;
    }
  }

  String _strengthLabel(int score, bool isAr) {
    switch (score) {
      case 1:
        return isAr ? 'ضعيفة' : 'Faible';
      case 2:
        return isAr ? 'متوسطة' : 'Moyen';
      case 3:
        return isAr ? 'جيدة' : 'Bon';
      case 4:
        return isAr ? 'قوية جداً' : 'Fort';
      default:
        return '';
    }
  }

  Future<void> _handleLogin({String? demoEmail, String? demoPassword}) async {
    if (_submitting) return;
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';

    if (demoEmail != null && demoPassword != null) {
      _isSignup = false;
      _emailController.text = demoEmail;
      _passwordController.text = demoPassword;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = isAr
            ? 'الرجاء إدخال البريد الإلكتروني وكلمة المرور'
            : 'Veuillez saisir votre e-mail et votre mot de passe';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().login(email, password);
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _handleSignup() async {
    if (_submitting) return;
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = isAr
            ? 'الرجاء ملء جميع الحقول المطلوبة'
            : 'Veuillez remplir tous les champs obligatoires';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = isAr
            ? 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل'
            : 'Le mot de passe doit contenir au moins 8 caractères';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = isAr
            ? 'كلمتا المرور غير متطابقتين'
            : 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().signup(
            name: name,
            email: email,
            password: password,
            role: _role,
          );
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    final hasFocus = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2, right: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 50,
          decoration: BoxDecoration(
            color: hasFocus ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasFocus ? AppColors.primary : const Color(0xFFE2E8F0),
              width: hasFocus ? 1.6 : 1.0,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            autocorrect: false,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: hasFocus ? AppColors.primary : const Color(0xFF64748B),
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color selectedBg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: BouncyTap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? selectedBg : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accentColor : const Color(0xFFE2E8F0),
              width: selected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withValues(alpha: 0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 19,
                      color: selected ? accentColor : const Color(0xFF64748B),
                    ),
                  ),
                  AnimatedScale(
                    scale: selected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? accentColor : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.locale == 'ar';
    final canPop = Navigator.of(context).canPop();
    final passwordText = _passwordController.text;
    final confirmText = _confirmPasswordController.text;
    final strengthScore = _passwordStrengthScore(passwordText);
    final confirmMatches =
        confirmText.isNotEmpty && confirmText == passwordText;

    return Directionality(
      textDirection: locale.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AmbientGlowBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ──────────────────────────────────────────────────────
                  // 1. MINIMAL TOP UTILITY BAR (Back + Language Pill)
                  // ──────────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (canPop)
                        BouncyTap(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 38),
                      BouncyTap(
                        onTap: locale.toggleLocale,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.language_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isAr ? 'FR' : 'AR',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ──────────────────────────────────────────────────────
                  // 2. SINGLE CENTERED BRAND HEADER (No duplicate titles)
                  // ──────────────────────────────────────────────────────
                  FadeSlideEntry(
                    index: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            gradient: AppGradients.goldHero,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShadows.goldGlow,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          locale.t('appName'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            _isSignup
                                ? (isAr
                                    ? 'أنشئ حسابك مجاناً في ثوانٍ'
                                    : 'Créez votre compte gratuitement')
                                : (isAr
                                    ? 'السوق المحلي التونسي بين يديك'
                                    : 'Le marché local tunisien à portée de main'),
                            key: ValueKey<bool>(_isSignup),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ──────────────────────────────────────────────────────
                  // 3. MAIN AUTHENTICATION CARD
                  // ──────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Segmented Mode Toggle (Login | Signup)
                        Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _switchMode(false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    decoration: BoxDecoration(
                                      color: !_isSignup
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: !_isSignup
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x140F172A),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : const [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        locale.t('login'),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: !_isSignup
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: !_isSignup
                                              ? AppColors.primary
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _switchMode(true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    decoration: BoxDecoration(
                                      color: _isSignup
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _isSignup
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x140F172A),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : const [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        locale.t('signup'),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: _isSignup
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: _isSignup
                                              ? AppColors.primary
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Error Banner
                        if (_errorMessage != null &&
                            _errorMessage!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Animated Form Content (Login vs Signup)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isSignup) ...[
                                // Role Selector
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    left: 2,
                                    right: 2,
                                  ),
                                  child: Text(
                                    isAr ? 'نوع الحساب' : 'Type de compte',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildRoleCard(
                                      selected: _role == 'visitor',
                                      icon: Icons.shopping_bag_rounded,
                                      title: locale.t('visitor'),
                                      subtitle: isAr
                                          ? 'تصفح واشتري'
                                          : 'Explorer & acheter',
                                      accentColor: AppColors.primary,
                                      selectedBg: const Color(0xFFEEF2FF),
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _role = 'visitor');
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _buildRoleCard(
                                      selected: _role == 'merchant',
                                      icon: Icons.storefront_rounded,
                                      title: locale.t('merchant'),
                                      subtitle: isAr
                                          ? 'افتح متجرك وبع'
                                          : 'Ouvrir ma boutique',
                                      accentColor: AppColors.action,
                                      selectedBg: const Color(0xFFECFDF5),
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _role = 'merchant');
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Full Name Field
                                _buildInputField(
                                  controller: _nameController,
                                  focusNode: _nameFocus,
                                  label: locale.t('name'),
                                  hint: isAr
                                      ? 'الاسم الكامل أو اسم التاجر'
                                      : 'Votre nom complet',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Email Field
                              _buildInputField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: locale.t('email'),
                                hint: 'nom@exemple.tn',
                                prefixIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),

                              // Password Field
                              _buildInputField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                label: locale.t('password'),
                                hint: _isSignup
                                    ? (isAr
                                        ? '8 أحرف على الأقل'
                                        : '8 caractères minimum')
                                    : '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                onSubmitted: (_) => _isSignup
                                    ? _handleSignup()
                                    : _handleLogin(),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF64748B),
                                    size: 20,
                                  ),
                                ),
                              ),

                              if (_isSignup) ...[
                                if (passwordText.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ...List.generate(4, (i) {
                                        final active = i < strengthScore;
                                        return Expanded(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            height: 4,
                                            margin: EdgeInsetsDirectional.only(
                                              end: i < 3 ? 5 : 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: active
                                                  ? _strengthColor(
                                                      strengthScore,
                                                    )
                                                  : const Color(0xFFE2E8F0),
                                              borderRadius:
                                                  BorderRadius.circular(99),
                                            ),
                                          ),
                                        );
                                      }),
                                      Text(
                                        _strengthLabel(strengthScore, isAr),
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: _strengthColor(strengthScore),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 14),

                                // Confirm Password Field
                                _buildInputField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmFocus,
                                  label: locale.t('confirmPassword'),
                                  hint: '••••••••',
                                  prefixIcon: Icons.verified_user_outlined,
                                  obscureText: _obscureConfirm,
                                  onSubmitted: (_) => _handleSignup(),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (confirmText.isNotEmpty)
                                        Icon(
                                          confirmMatches
                                              ? Icons.check_circle_rounded
                                              : Icons.error_outline_rounded,
                                          color: confirmMatches
                                              ? AppColors.action
                                              : AppColors.error,
                                          size: 18,
                                        ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirm = !_obscureConfirm;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF64748B),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Primary Submit CTA Button with Liquid Shimmer Sheen
                        BouncyTap(
                          onTap: _submitting
                              ? null
                              : (_isSignup
                                  ? _handleSignup
                                  : () => _handleLogin()),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _submitting ? 0.65 : 1.0,
                            child: ShimmerSheenWrapper(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: (_isSignup && _role == 'merchant')
                                      ? AppGradients.emeraldAction
                                      : AppGradients.goldHero,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: (_isSignup && _role == 'merchant')
                                      ? AppShadows.emeraldGlow
                                      : AppShadows.goldGlow,
                                ),
                                child: Center(
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _isSignup
                                                  ? locale.t('signup')
                                                  : locale.t('login'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15.5,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              isAr
                                                  ? Icons.arrow_back_rounded
                                                  : Icons.arrow_forward_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Divider "OU / أو"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE2E8F0),
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                isAr ? 'أو' : 'OU',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE2E8F0),
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Google Sign-In / Sign-Up Button
                        GoogleSignInButton(
                          defaultRole: _isSignup ? _role : 'visitor',
                          onSuccess: () {
                            if (mounted && Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // Guest Browsing Mode CTA ("تصفح العروض كزائر / Explorer sans compte")
                        BouncyTap(
                          onTap: () async {
                            await context.read<AuthProvider>().enterGuestMode();
                            if (context.mounted &&
                                Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.explore_outlined,
                                  size: 18,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isAr
                                      ? 'تصفح العروض كزائر بدون حساب'
                                      : 'Explorer les offres sans compte',
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ──────────────────────────────────────────────────────
                  // 4. SUBTLE 1-TAP DEMO ACCESS STRIP (For Fast Testing)
                  // ──────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAr
                                  ? 'دخول تجريبي سريع بضغطة واحدة'
                                  : 'Accès démo instantané (1 clic)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: BouncyTap(
                                onTap: _submitting
                                    ? null
                                    : () => _handleLogin(
                                          demoEmail: 'visitor@hwenti.tn',
                                          demoPassword: 'password123',
                                        ),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAr ? 'حريف تجريبي' : 'Démo Client',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: BouncyTap(
                                onTap: _submitting
                                    ? null
                                    : () => _handleLogin(
                                          demoEmail: 'merchant@hwenti.tn',
                                          demoPassword: 'password123',
                                        ),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: AppColors.action
                                          .withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.storefront_rounded,
                                        size: 16,
                                        color: AppColors.action,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAr ? 'تاجر تجريبي' : 'Démo Marchand',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.action,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
