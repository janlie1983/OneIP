import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../lease_tracker/presentation/providers/lease_tracker_provider.dart';
import '../../domain/models/checklist_progress_model.dart';
import '../../domain/models/permit_item_model.dart';
import '../../domain/models/user_checklist_model.dart';
import '../../services/pdf_export_service.dart';
import '../providers/permit_checklist_provider.dart';
import '../widgets/permit_item_tile.dart';
import '../widgets/progress_circle.dart';

class ChecklistDetailScreen extends ConsumerStatefulWidget {
  final String checklistId;
  final UserChecklist? checklist;

  const ChecklistDetailScreen({
    super.key,
    required this.checklistId,
    this.checklist,
  });

  @override
  ConsumerState<ChecklistDetailScreen> createState() =>
      _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState
    extends ConsumerState<ChecklistDetailScreen> {
  // optimistic local status overrides: itemId -> status
  final Map<String, String> _localStatus = {};
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final progressAsync =
        ref.watch(checklistProgressProvider(widget.checklistId));
    final isPremium = ref.watch(isPremiumProvider);

    final checklist = widget.checklist;

    return LoadingOverlay(
      isLoading: _isExporting,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: progressAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('${l.commonError}: $e',
                style: const TextStyle(color: AppColors.error)),
          ),
          data: (progressList) {
            final progressMap = {
              for (final p in progressList) p.itemId: p.status
            };
            final effectiveStatus = {...progressMap, ..._localStatus};

            final templateId = checklist?.templateId;
            if (templateId == null) {
              return Center(child: Text(l.commonNoData));
            }

            final itemsAsync = ref.watch(checklistItemsProvider(templateId));

            return itemsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l.commonError}: $e')),
              data: (items) {
                final totalItems = items.length;
                final doneCount = effectiveStatus.values
                    .where((s) => s == 'done')
                    .length;
                final percent =
                    totalItems == 0 ? 0.0 : doneCount / totalItems;

                return CustomScrollView(
                  slivers: [
                    _buildHeader(
                      l: l,
                      checklist: checklist!,
                      percent: percent,
                      doneCount: doneCount,
                      totalItems: totalItems,
                      isPremium: isPremium,
                      items: items,
                      progressList: progressList,
                      effectiveStatus: effectiveStatus,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final item = items[i];
                          final status =
                              effectiveStatus[item.id] ?? 'pending';
                          return PermitItemTile(
                            item: item,
                            currentStatus: status,
                            onStatusChanged: (newStatus) =>
                                _onStatusChanged(
                              item: item,
                              newStatus: newStatus,
                              checklist: checklist,
                              items: items,
                              progressList: progressList,
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({
    required AppLocalizations l,
    required UserChecklist checklist,
    required double percent,
    required int doneCount,
    required int totalItems,
    required bool isPremium,
    required List<PermitItem> items,
    required List<ChecklistProgress> progressList,
    required Map<String, String> effectiveStatus,
  }) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      actions: [
        if (isPremium)
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l.permitExportPDF,
            onPressed: () => _exportPdf(
              l: l,
              checklist: checklist,
              items: items,
              progressList: progressList,
              effectiveStatus: effectiveStatus,
            ),
          )
        else
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.permitUpgradePdf),
                  backgroundColor: AppColors.navy,
                ),
              );
            },
            icon: const Icon(Icons.lock_outline,
                size: 16, color: AppColors.gold),
            label: const Text(
              'PDF',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.navy,
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checklist.projectName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (checklist.companyName != null) ...[
                const SizedBox(height: 2),
                Text(
                  checklist.companyName!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  ProgressCircle(percent: percent, size: 76, strokeWidth: 7),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.permitStepsCompleted(doneCount, totalItems),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _StepBreakdown(
                            items: items,
                            effectiveStatus: effectiveStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onStatusChanged({
    required PermitItem item,
    required String newStatus,
    required UserChecklist checklist,
    required List<PermitItem> items,
    required List<ChecklistProgress> progressList,
  }) async {
    setState(() => _localStatus[item.id] = newStatus);

    final existing = progressList.where((p) => p.itemId == item.id).firstOrNull;
    final progress = ChecklistProgress(
      id: existing?.id ?? '',
      checklistId: widget.checklistId,
      itemId: item.id,
      status: newStatus,
      completedAt: newStatus == 'done' ? DateTime.now() : null,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref
          .read(permitChecklistRepositoryProvider)
          .upsertProgress(progress);
      ref.invalidate(checklistProgressProvider(widget.checklistId));
      ref.invalidate(userChecklistsProvider);

      final effectiveStatus = {
        for (final p in progressList) p.itemId: p.status,
        ..._localStatus,
      };
      final allRequired = items.where((i) => i.isRequired);
      final allDone =
          allRequired.every((i) => effectiveStatus[i.id] == 'done');
      if (allDone && checklist.status == 'active') {
        await ref
            .read(permitChecklistRepositoryProvider)
            .updateChecklistStatus(widget.checklistId, 'completed');
        ref.invalidate(userChecklistsProvider);
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.permitCompletedCongrats),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _localStatus.remove(item.id));
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.commonError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportPdf({
    required AppLocalizations l,
    required UserChecklist checklist,
    required List<PermitItem> items,
    required List<ChecklistProgress> progressList,
    required Map<String, String> effectiveStatus,
  }) async {
    setState(() => _isExporting = true);
    try {
      final mergedProgress = items.map((item) {
        final existing = progressList.where((p) => p.itemId == item.id).firstOrNull;
        final status = effectiveStatus[item.id] ?? 'pending';
        return ChecklistProgress(
          id: existing?.id ?? '',
          checklistId: widget.checklistId,
          itemId: item.id,
          status: status,
          createdAt: existing?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      await PdfExportService.exportChecklist(
        checklist: checklist,
        items: items,
        progress: mergedProgress,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.commonError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _StepBreakdown extends StatelessWidget {
  final List<PermitItem> items;
  final Map<String, String> effectiveStatus;

  const _StepBreakdown({required this.items, required this.effectiveStatus});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    int inProgress = 0;
    int skipped = 0;

    for (final item in items) {
      final s = effectiveStatus[item.id] ?? 'pending';
      if (s == 'in_progress') inProgress++;
      if (s == 'skipped') skipped++;
    }

    return Wrap(
      spacing: 10,
      children: [
        if (inProgress > 0)
          _Chip(l.permitInProgressCount(inProgress), AppColors.gold),
        if (skipped > 0)
          _Chip(l.permitSkippedCount(skipped), Colors.white.withValues(alpha: 0.5)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
