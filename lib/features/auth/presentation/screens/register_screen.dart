import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 0;
  UserRole? _selectedRole;
  bool _isLoading = false;

  static const _roleOptions = [
    (
      role: UserRole.propertyOwner,
      icon: Icons.warehouse_rounded,
      descVi: 'Tôi muốn đăng tin cho thuê tài sản',
    ),
    (
      role: UserRole.broker,
      icon: Icons.handshake_rounded,
      descVi: 'Tôi là môi giới, muốn đăng và tìm kiếm',
    ),
    (
      role: UserRole.corporate,
      icon: Icons.business_rounded,
      descVi: 'Tôi cần thuê KCN / kho xưởng quy mô lớn',
    ),
    (
      role: UserRole.sme,
      icon: Icons.storefront_rounded,
      descVi: 'Tôi cần thuê kho / xưởng nhỏ',
    ),
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _register() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            role: _selectedRole!,
          );
      if (mounted) {
        context.go('/home/site-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
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

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 1) {
          setState(() => _step = 0);
        }
      },
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(_step == 0 ? l.authRegister : 'Chọn vai trò'),
            backgroundColor: AppColors.navy,
            foregroundColor: AppColors.textLight,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_step == 1) {
                  setState(() => _step = 0);
                } else {
                  context.pop();
                }
              },
            ),
          ),
          body: _step == 0 ? _buildStep1(l) : _buildStep2(),
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _StepIndicator(current: 0),
              const SizedBox(height: 24),
              AuthTextField(
                label: l.authFullName,
                hint: 'Nguyễn Văn A',
                controller: _fullNameController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập họ và tên' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: l.authEmail,
                hint: 'example@company.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: l.authPassword,
                controller: _passwordController,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: l.authConfirmPassword,
                controller: _confirmPasswordController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onEditingComplete: _goToStep2,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                  if (v != _passwordController.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _goToStep2,
                child: const Text('Tiếp theo'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l.authHaveAccount} ',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l.authLogin,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _StepIndicator(current: 1),
            const SizedBox(height: 24),
            const Text(
              'Bạn là ai?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chọn vai trò phù hợp để có trải nghiệm tốt nhất',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ...(_roleOptions.map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RoleSelectorCard(
                  role: opt.role,
                  title: opt.role.labelVi,
                  titleEn: opt.role.labelEn,
                  description: opt.descVi,
                  icon: opt.icon,
                  isSelected: _selectedRole == opt.role,
                  onTap: () => setState(() => _selectedRole = opt.role),
                ),
              ),
            )),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selectedRole != null ? _register : null,
              child: const Text('Hoàn tất đăng ký'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;

  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(0, 'Thông tin'),
        Expanded(
          child: Container(
            height: 1,
            color: current >= 1 ? AppColors.navy : AppColors.border,
          ),
        ),
        _dot(1, 'Vai trò'),
      ],
    );
  }

  Widget _dot(int step, String label) {
    final active = current >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.navy : AppColors.border,
          ),
          child: Center(
            child: active && current > step
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.navy : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
