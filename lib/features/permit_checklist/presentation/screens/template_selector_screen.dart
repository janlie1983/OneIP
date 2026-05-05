import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../lease_tracker/presentation/providers/lease_tracker_provider.dart';
import '../../domain/models/permit_template_model.dart';
import '../providers/permit_checklist_provider.dart';

class TemplateSelectorScreen extends ConsumerStatefulWidget {
  const TemplateSelectorScreen({super.key});

  @override
  ConsumerState<TemplateSelectorScreen> createState() =>
      _TemplateSelectorScreenState();
}

class _TemplateSelectorScreenState
    extends ConsumerState<TemplateSelectorScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(permitTemplatesProvider);
    final checklistsAsync = ref.watch(userChecklistsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.permitChooseType),
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
        ),
        body: templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('${l.commonError}: $e',
                style: const TextStyle(color: AppColors.error)),
          ),
          data: (templates) {
            final freeTierFull = checklistsAsync.maybeWhen(
              data: (checklists) => !isPremium && checklists.isNotEmpty,
              orElse: () => false,
            );

            return Column(
              children: [
                if (freeTierFull)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: AppColors.gold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.permitFreeTierLimit,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisExtent: 200,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: templates.length,
                    itemBuilder: (context, i) {
                      final tpl = templates[i];
                      final locked = (tpl.isPremium && !isPremium) ||
                          (freeTierFull && !tpl.isPremium);
                      return _TemplateCard(
                        template: tpl,
                        locked: locked,
                        animationIndex: i,
                        onTap: () => _onSelectTemplate(tpl, locked),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onSelectTemplate(PermitTemplate template, bool locked) {
    if (locked) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.permitUpgradePrompt),
          backgroundColor: AppColors.navy,
        ),
      );
      return;
    }
    _showCreateSheet(template);
  }

  void _showCreateSheet(PermitTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateChecklistSheet(
        template: template,
        onCreate: (projectName, companyName, province) async {
          Navigator.pop(context);
          await _createChecklist(
            template: template,
            projectName: projectName,
            companyName: companyName,
            province: province,
          );
        },
      ),
    );
  }

  Future<void> _createChecklist({
    required PermitTemplate template,
    required String projectName,
    String? companyName,
    String? province,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final checklist = await ref
          .read(permitChecklistRepositoryProvider)
          .createChecklist(
            userId: user.id,
            templateId: template.id,
            projectName: projectName,
            companyName: companyName?.isEmpty == true ? null : companyName,
            province: province?.isEmpty == true ? null : province,
          );
      ref.invalidate(userChecklistsProvider);
      if (mounted) {
        context.push('/checklist-detail/${checklist.id}',
            extra: checklist);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.commonError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final PermitTemplate template;
  final bool locked;
  final int animationIndex;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.locked,
    required this.animationIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + animationIndex * 70),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.9 + 0.1 * value, child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: locked ? AppColors.border : AppColors.navy.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (locked ? AppColors.border : AppColors.navy)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        template.categoryIcon,
                        size: 22,
                        color: locked ? AppColors.textSecondary : AppColors.navy,
                      ),
                    ),
                    const Spacer(),
                    if (template.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Pro',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    if (locked)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.lock_outline,
                            size: 16, color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: locked ? AppColors.textSecondary : AppColors.navy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  template.description ?? '',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: template.difficultyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        template.difficultyLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: template.difficultyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l.permitDayEstimate(template.estimatedDays),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      l.permitStepCount(template.totalItems),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateChecklistSheet extends StatefulWidget {
  final PermitTemplate template;
  final void Function(String projectName, String? companyName, String? province)
      onCreate;

  const _CreateChecklistSheet({
    required this.template,
    required this.onCreate,
  });

  @override
  State<_CreateChecklistSheet> createState() => _CreateChecklistSheetState();
}

class _CreateChecklistSheetState extends State<_CreateChecklistSheet> {
  final _formKey = GlobalKey<FormState>();
  final _projectCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();

  @override
  void dispose() {
    _projectCtrl.dispose();
    _companyCtrl.dispose();
    _provinceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.template.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.permitStepDetail(widget.template.estimatedDays, widget.template.totalItems),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _projectCtrl,
              decoration: InputDecoration(
                labelText: l.permitProjectNameLabel,
                hintText: l.permitProjectNameHint,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.permitProjectNameValidation : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyCtrl,
              decoration: InputDecoration(
                labelText: l.permitCompanyName,
                hintText: l.permitCompanyNameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _provinceCtrl,
              decoration: InputDecoration(
                labelText: l.permitProvince,
                hintText: l.permitProvinceHint,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onCreate(
                      _projectCtrl.text.trim(),
                      _companyCtrl.text.trim().isEmpty
                          ? null
                          : _companyCtrl.text.trim(),
                      _provinceCtrl.text.trim().isEmpty
                          ? null
                          : _provinceCtrl.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  l.permitCreateChecklist,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
