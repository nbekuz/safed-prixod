import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/api_config.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/auth_strings.dart';
import 'package:safed_prixod/core/widgets/auth_legal_footer.dart';
import 'package:safed_prixod/core/push_notifications.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/widgets/uzbek_phone_input_formatter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _loading = false;
  bool _obscurePassword = true;

  bool get _phoneComplete =>
      UzbekPhoneInputFormatter.digitsOnly(_phoneController.text).length == 9;

  bool get _canSubmit => _phoneComplete && _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onChanged);
    _passwordController.addListener(_onChanged);
    _phoneFocus.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onChanged);
    _passwordController.removeListener(_onChanged);
    _phoneFocus.removeListener(_onChanged);
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  bool _isStaff(AuthSession s) =>
      s.hasGroup('Operator') ||
      s.hasGroup('Admin') ||
      s.hasGroup('Super Admin');

  Future<void> _signIn() async {
    const l10n = prixodAuthStrings;
    final digits = UzbekPhoneInputFormatter.digitsOnly(_phoneController.text);
    if (digits.length != 9 || _passwordController.text.isEmpty) {
      ref.read(appToastProvider.notifier).warning(l10n.credentialsRequired);
      return;
    }

    setState(() => _loading = true);
    try {
      final session = await ref
          .read(authApiProvider)
          .staffLogin(phone: '998$digits', password: _passwordController.text);
      if (!_isStaff(session)) {
        ref.read(appToastProvider.notifier).error(l10n.staffOnly);
        return;
      }
      await ref
          .read(tokenStorageProvider)
          .saveTokens(access: session.access, refresh: session.refresh);
      ref.read(accessTokenProvider.notifier).state = session.access;
      await PushNotifications.syncToken(ref);
      if (mounted) {
        ref
            .read(appToastProvider.notifier)
            .success('${l10n.welcome}, ${ApiConfig.brandName}');
        context.go('/orders');
      }
    } catch (e) {
      showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const l10n = prixodAuthStrings;
    final baseStyle = Theme.of(context).textTheme.titleMedium;
    final inputStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 0.2,
      height: 1.2,
    );
    final hintStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w400,
      color: AppTheme.textSecondary.withValues(alpha: 0.55),
      letterSpacing: 0.2,
      height: 1.2,
    );
    final prefixStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.black87,
      height: 1.2,
    );
    final focused = _phoneFocus.hasFocus;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 380;
    final shortScreen = size.height < 700;
    final horizontalPadding = compact ? 16.0 : 24.0;
    final topGap = shortScreen ? 20.0 : 32.0;
    final formGap = shortScreen ? 24.0 : 36.0;

    return SafedScaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topGap),
              Text(
                ApiConfig.brandName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.prixodSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: formGap),
              Text(
                l10n.staffLoginSubtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('+998', style: prefixStyle),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: focused
                              ? AppTheme.primaryGreen
                              : AppTheme.borderLight,
                          width: focused ? 1.5 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        keyboardType: TextInputType.number,
                        style: inputStyle,
                        cursorColor: AppTheme.primaryGreen,
                        inputFormatters: [UzbekPhoneInputFormatter()],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          hintText: '(99)-123-45-67',
                          hintStyle: hintStyle,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                onSubmitted: (_) => _signIn(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_loading || !_canSubmit) ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.signIn),
                ),
              ),
              const SizedBox(height: 16),
              const AuthLegalFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
