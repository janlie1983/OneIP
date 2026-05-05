import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/permit_checklist_provider.dart';
import '../widgets/checklist_card.dart';

class PermitChecklistScreen extends ConsumerWidget {
  const PermitChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final checklistsAsync = ref.watch(userChecklistsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(l.permitTitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userChecklistsProvider),
          ),
        ],
      ),
      body: checklistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 8),
              Text('${l.commonError}: $e',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(userChecklistsProvider),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white),
                child: Text(l.commonRetry),
              ),
            ],
          ),
        ),
        data: (checklists) {
          if (checklists.isEmpty) {
            return _EmptyState(onAdd: () => context.push('/permit-templates'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: checklists.length,
            itemBuilder: (_, i) {
              final cl = checklists[i];
              return ChecklistCard(
                checklist: cl,
                animationIndex: i,
                onTap: () => context.push(
                  '/checklist-detail/${cl.id}',
                  extra: cl,
                ),
                onDelete: () => _confirmDelete(context, ref, l, cl.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/permit-templates'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          l.permitCreateChecklist,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AppLocalizations l, String checklistId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.permitDeleteTitle),
        content: Text(l.permitDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(permitChecklistRepositoryProvider)
                  .deleteChecklist(checklistId);
              ref.invalidate(userChecklistsProvider);
            },
            child: Text(l.commonDelete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rtl_outlined,
                size: 40,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.permitNoChecklist,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.permitNoChecklistSub,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(
                l.permitChooseType,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
