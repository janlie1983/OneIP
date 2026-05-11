import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/language_switcher.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirect;

  const LoginScreen({super.key, this.redirect});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String get _redirectTarget =>
      (widget.redirect?.isNotEmpty == true)
          ? widget.redirect!
          : '/home/site-selection';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go(_redirectTarget);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.authLogin} thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) context.go(_redirectTarget);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: LanguageSwitcher(
                        activeColor: AppColors.navy,
                        inactiveColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildHeader(l),
                  const SizedBox(height: 40),
                  AuthTextField(
                    label: l.authEmail,
                    hint: 'example@company.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                      if (!value.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: l.authPassword,
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _signIn,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppConstants.routeForgotPassword),
                      child: Text(
                        l.authForgotPassword,
                        style: const TextStyle(color: AppColors.navy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: Text(l.authLogin),
                  ),
                  const SizedBox(height: 24),
                  _buildDivider(l),
                  const SizedBox(height: 24),
                  SocialLoginButton(
                    label: l.authContinueGoogle,
                    icon: _googleIcon(),
                    onPressed: _signInWithGoogle,
                  ),
                  const SizedBox(height: 32),
                  _buildRegisterLink(l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.business, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'OneIP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.authLoginSubtitle,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDivider(AppLocalizations l) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l.authOr,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegisterLink(AppLocalizations l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l.authNoAccount} ',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {
            final r = widget.redirect;
            final dest = (r?.isNotEmpty == true)
                ? '/register?redirect=${Uri.encodeComponent(r!)}'
                : AppConstants.routeRegister;
            context.push(dest);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l.authRegister,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _googleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
