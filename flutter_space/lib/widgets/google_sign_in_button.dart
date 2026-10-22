import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';

class GoogleSignInButton extends StatefulWidget {
  final String? defaultRole;
  final VoidCallback? onSuccess;

  const GoogleSignInButton({
    super.key,
    this.defaultRole,
    this.onSuccess,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _openGoogleSheet() async {
    if (_isLoading) return;
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';

    final result = await showModalBottomSheet<_GoogleAccountChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoogleAccountPickerSheet(
        isAr: isAr,
        initialRole: widget.defaultRole ?? 'visitor',
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().signInWithGoogle(
            email: result.email,
            name: result.name,
            role: result.role,
          );
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.locale == 'ar';

    return BouncyTap(
      onTap: _isLoading ? null : _openGoogleSheet,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md + 2),
          border: Border.all(color: AppColors.borderSubtle, width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primary,
                ),
              )
            else
              const SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(painter: GoogleLogoPainter()),
              ),
            const SizedBox(width: 12),
            Text(
              isAr ? 'المتابعة باستخدام Google' : 'Continuer avec Google',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleAccountChoice {
  final String email;
  final String name;
  final String role;

  const _GoogleAccountChoice({
    required this.email,
    required this.name,
    required this.role,
  });
}

class _GoogleAccountPickerSheet extends StatefulWidget {
  final bool isAr;
  final String initialRole;

  const _GoogleAccountPickerSheet({
    required this.isAr,
    required this.initialRole,
  });

  @override
  State<_GoogleAccountPickerSheet> createState() =>
      _GoogleAccountPickerSheetState();
}

class _GoogleAccountPickerSheetState extends State<_GoogleAccountPickerSheet> {
  late String _selectedRole;
  bool _showCustomInput = false;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isAr = widget.isAr;

    final accounts = [
      (
        name: isAr ? 'ياسين التونسي' : 'Yassine Tounsi',
        email: 'merchant@hwenti.tn',
        role: 'merchant',
        badge: isAr ? 'حساب تاجر' : 'Compte Marchand',
        avatarBg: const Color(0xFF4F46E5),
      ),
      (
        name: isAr ? 'أمين بن علي' : 'Amine Ben Ali',
        email: 'visitor@hwenti.tn',
        role: 'visitor',
        badge: isAr ? 'حساب حريف' : 'Compte Client',
        avatarBg: const Color(0xFF0D9488),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.card,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(painter: GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAr ? 'تسجيل الدخول عبر Google' : 'Connexion avec Google',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isAr
                    ? 'اختر حساباً للمتابعة إلى حوانتي'
                    : 'Choisissez un compte pour continuer vers Hwenti',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if (!_showCustomInput) ...[
                ...accounts.map((acc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: BouncyTap(
                      onTap: () {
                        Navigator.of(context).pop(
                          _GoogleAccountChoice(
                            email: acc.email,
                            name: acc.name,
                            role: acc.role,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 21,
                              backgroundColor: acc.avatarBg,
                              child: Text(
                                acc.name.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          acc.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: acc.avatarBg.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          acc.badge,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: acc.avatarBg,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    acc.email,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => setState(() => _showCustomInput = true),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(
                    isAr ? 'استخدام حساب Google آخر' : 'Utiliser un autre compte Google',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: isAr ? 'حريف (زائر)' : 'Client',
                        icon: Icons.person_rounded,
                        selected: _selectedRole == 'visitor',
                        onTap: () => setState(() => _selectedRole = 'visitor'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RoleChip(
                        label: isAr ? 'تاجر (متجر)' : 'Marchand',
                        icon: Icons.storefront_rounded,
                        selected: _selectedRole == 'merchant',
                        onTap: () => setState(() => _selectedRole = 'merchant'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: isAr ? 'الاسم الكامل' : 'Nom complet',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'your.name@gmail.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                BouncyTap(
                  onTap: () {
                    final email = _emailCtrl.text.trim();
                    if (email.isEmpty || !email.contains('@')) return;
                    final name = _nameCtrl.text.trim().isNotEmpty
                        ? _nameCtrl.text.trim()
                        : email.split('@').first;
                    Navigator.of(context).pop(
                      _GoogleAccountChoice(
                        email: email,
                        name: name,
                        role: _selectedRole,
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppGradients.goldHero,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.goldGlow,
                    ),
                    child: Center(
                      child: Text(
                        isAr ? 'متابعة' : 'Continuer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderSubtle,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.20;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red top arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.35, 1.55, false, paint);

    // Yellow left arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.35, 1.58, false, paint);

    // Green bottom arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.85, 1.50, false, paint);

    // Blue right arc + crossbar
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.15, 1.05, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeWidth * 0.48,
        size.width * 0.48,
        strokeWidth * 0.96,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
