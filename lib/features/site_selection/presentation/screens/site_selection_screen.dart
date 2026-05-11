import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/paywall_gate.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/models/site_selection_query_model.dart';
import '../providers/site_selection_provider.dart';
import '../widgets/industrial_zone_card.dart';

const _industries = [
  'Electronics',
  'Auto Parts',
  'Garment & Footwear',
  'Food Processing',
  'Heavy Industry',
  'Logistics',
  'Petrochemical',
  'High-Tech',
  'Manufacturing',
  'Other',
];

String _industryLabel(AppLocalizations l, String industry) {
  switch (industry) {
    case 'Electronics':      return l.industryElectronics;
    case 'Auto Parts':       return l.industryAutoParts;
    case 'Garment & Footwear': return l.industryGarment;
    case 'Food Processing':  return l.industryFoodProcessing;
    case 'Heavy Industry':   return l.industryHeavy;
    case 'Logistics':        return l.industryLogistics;
    case 'Petrochemical':    return l.industryPetrochemical;
    case 'High-Tech':        return l.industryHighTech;
    case 'Manufacturing':    return l.industryManufacturing;
    default:                 return l.industryOther;
  }
}

class SiteSelectionScreen extends ConsumerStatefulWidget {
  const SiteSelectionScreen({super.key});

  @override
  ConsumerState<SiteSelectionScreen> createState() => _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends ConsumerState<SiteSelectionScreen> {
  String _selectedIndustry = '';
  double _requiredAreaM2 = 2000;
  int _headcount = 100;
  String? _preferredRegion;
  final Set<String> _selectedPriorities = {};
  double? _maxBudgetUsd;
  bool _showBudget = false;

  final _areaController = TextEditingController();
  final _headcountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _areaController.text = _requiredAreaM2.toStringAsFixed(0);
    _headcountController.text = _headcount.toString();
  }

  @override
  void dispose() {
    _areaController.dispose();
    _headcountController.dispose();
    super.dispose();
  }

  void _runSearch() {
    if (_selectedIndustry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngành công nghiệp'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final query = SiteSelectionQuery(
      industry: _selectedIndustry,
      requiredAreaM2: _requiredAreaM2,
      headcount: _headcount,
      preferredRegion: _preferredRegion,
      maxBudgetUsd: _showBudget ? _maxBudgetUsd : null,
      priorityFactors: _selectedPriorities.toList(),
    );
    ref.read(siteSelectionQueryProvider.notifier).state = query;
    ref.read(sortOptionProvider.notifier).state = SortOption.score;
  }

  void _resetSearch() {
    ref.read(siteSelectionQueryProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(siteSelectionQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: query == null
            ? _FormView(
                key: const ValueKey('form'),
                selectedIndustry: _selectedIndustry,
                requiredAreaM2: _requiredAreaM2,
                headcount: _headcount,
                preferredRegion: _preferredRegion,
                selectedPriorities: _selectedPriorities,
                maxBudgetUsd: _maxBudgetUsd,
                showBudget: _showBudget,
                areaController: _areaController,
                headcountController: _headcountController,
                onIndustrySelected: (v) => setState(() => _selectedIndustry = v),
                onAreaChanged: (v) => setState(() => _requiredAreaM2 = v),
                onHeadcountChanged: (v) => setState(() => _headcount = v),
                onRegionChanged: (v) => setState(() => _preferredRegion = v),
                onPriorityToggled: (v) => setState(() {
                  if (_selectedPriorities.contains(v)) {
                    _selectedPriorities.remove(v);
                  } else {
                    _selectedPriorities.add(v);
                  }
                }),
                onBudgetToggled: (v) => setState(() => _showBudget = v),
                onBudgetChanged: (v) => setState(() => _maxBudgetUsd = v),
                onSearch: _runSearch,
              )
            : _ResultsView(
                key: const ValueKey('results'),
                onReset: _resetSearch,
              ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final String selectedIndustry;
  final double requiredAreaM2;
  final int headcount;
  final String? preferredRegion;
  final Set<String> selectedPriorities;
  final double? maxBudgetUsd;
  final bool showBudget;
  final TextEditingController areaController;
  final TextEditingController headcountController;
  final ValueChanged<String> onIndustrySelected;
  final ValueChanged<double> onAreaChanged;
  final ValueChanged<int> onHeadcountChanged;
  final ValueChanged<String?> onRegionChanged;
  final ValueChanged<String> onPriorityToggled;
  final ValueChanged<bool> onBudgetToggled;
  final ValueChanged<double> onBudgetChanged;
  final VoidCallback onSearch;

  const _FormView({
    super.key,
    required this.selectedIndustry,
    required this.requiredAreaM2,
    required this.headcount,
    required this.preferredRegion,
    required this.selectedPriorities,
    required this.maxBudgetUsd,
    required this.showBudget,
    required this.areaController,
    required this.headcountController,
    required this.onIndustrySelected,
    required this.onAreaChanged,
    required this.onHeadcountChanged,
    required this.onRegionChanged,
    required this.onPriorityToggled,
    required this.onBudgetToggled,
    required this.onBudgetChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(l),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStep(number: 1, title: l.siteSelectionIndustry, child: _buildIndustrySelector(l)),
              const SizedBox(height: 12),
              _buildStep(number: 2, title: l.siteSelectionArea, child: _buildAreaInput(context)),
              const SizedBox(height: 12),
              _buildStep(number: 3, title: l.siteSelectionHeadcount, child: _buildHeadcountInput(l)),
              const SizedBox(height: 12),
              _buildStep(number: 4, title: l.siteSelectionRegion, child: _buildRegionSelector(l)),
              const SizedBox(height: 12),
              _buildStep(number: 5, title: l.siteSelectionPriority, child: _buildPrioritySelector(l)),
              const SizedBox(height: 12),
              _buildStep(number: 6, title: l.siteSelectionBudget, child: _buildBudgetInput(context, l)),
              const SizedBox(height: 24),
              PrimaryButton(label: l.siteSelectionSearch, onPressed: onSearch),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(AppLocalizations l) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l.siteSelectionTitle,
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy, Color(0xFF2C4A7A)],
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 20),
              child: Text(
                l.siteSelectionSubtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({required int number, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildIndustrySelector(AppLocalizations l) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _industries.map((industry) {
        final isSelected = industry == selectedIndustry;
        return FilterChip(
          label: Text(_industryLabel(l, industry)),
          selected: isSelected,
          onSelected: (_) => onIndustrySelected(industry),
          selectedColor: AppColors.navy,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.navy,
            fontSize: 13,
          ),
          checkmarkColor: Colors.white,
          backgroundColor: AppColors.backgroundLight,
          side: BorderSide(color: isSelected ? AppColors.navy : AppColors.border),
        );
      }).toList(),
    );
  }

  Widget _buildAreaInput(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.navy,
                  thumbColor: AppColors.navy,
                  inactiveTrackColor: AppColors.border,
                  overlayColor: AppColors.navy.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: requiredAreaM2.clamp(500, 50000),
                  min: 500,
                  max: 50000,
                  divisions: 99,
                  onChanged: (v) {
                    onAreaChanged(v);
                    areaController.text = v.toStringAsFixed(0);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: TextField(
                controller: areaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  suffixText: 'm²',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) onAreaChanged(parsed.clamp(500, 50000));
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('500 m²',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(
              '${requiredAreaM2.toStringAsFixed(0)} m²',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            const Text('50,000 m²',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeadcountInput(AppLocalizations l) {
    return Row(
      children: [
        _CounterButton(
          icon: Icons.remove,
          onTap: () {
            if (headcount > 10) {
              final newVal = headcount - 10;
              onHeadcountChanged(newVal);
              headcountController.text = newVal.toString();
            }
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: headcountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: l.commonPerson,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) onHeadcountChanged(parsed.clamp(10, 100000));
            },
          ),
        ),
        const SizedBox(width: 12),
        _CounterButton(
          icon: Icons.add,
          onTap: () {
            final newVal = headcount + 10;
            onHeadcountChanged(newVal);
            headcountController.text = newVal.toString();
          },
        ),
      ],
    );
  }

  Widget _buildRegionSelector(AppLocalizations l) {
    final regions = <String?, String>{
      null: l.regionAll,
      'North': l.regionNorth,
      'Central': l.regionCentral,
      'South': l.regionSouth,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: regions.entries.map((entry) {
        final isSelected = preferredRegion == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (_) => onRegionChanged(entry.key),
          selectedColor: AppColors.navy,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
          backgroundColor: AppColors.backgroundLight,
          side: BorderSide(color: isSelected ? AppColors.navy : AppColors.border),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector(AppLocalizations l) {
    final priorities = {
      'infra': l.priorityInfra,
      'labor': l.priorityLabor,
      'logistics': l.priorityLogistics,
      'price': l.priorityPrice,
      'tax': l.priorityTax,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: priorities.entries.map((entry) {
        final isSelected = selectedPriorities.contains(entry.key);
        return FilterChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (_) => onPriorityToggled(entry.key),
          selectedColor: AppColors.gold,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
          checkmarkColor: Colors.white,
          backgroundColor: AppColors.backgroundLight,
          side: BorderSide(color: isSelected ? AppColors.gold : AppColors.border),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetInput(BuildContext context, AppLocalizations l) {
    return Column(
      children: [
        Row(
          children: [
            Switch(
              value: showBudget,
              onChanged: onBudgetToggled,
              activeThumbColor: AppColors.navy,
            ),
            const SizedBox(width: 8),
            Text(
              showBudget
                  ? 'Tối đa \$${(maxBudgetUsd ?? 100).toStringAsFixed(0)}/m²${l.commonPerYear}'
                  : l.commonNoLimit,
              style: TextStyle(
                fontSize: 14,
                color: showBudget ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (showBudget) ...[
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              thumbColor: AppColors.gold,
              inactiveTrackColor: AppColors.border,
              overlayColor: AppColors.gold.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: (maxBudgetUsd ?? 100).clamp(50, 200),
              min: 50,
              max: 200,
              divisions: 30,
              label: '\$${(maxBudgetUsd ?? 100).toStringAsFixed(0)}',
              onChanged: onBudgetChanged,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$50', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text('\$200', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Results View ──────────────────────────────────────────────────────────────

class _ResultsView extends ConsumerWidget {
  final VoidCallback onReset;

  const _ResultsView({super.key, required this.onReset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final scoredAsync = ref.watch(scoredResultsProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final compareZones = ref.watch(compareZonesProvider);

    final sortLabels = {
      SortOption.score: l.zoneOverallScore,
      SortOption.price: l.priorityPrice,
      SortOption.area: l.zoneAvailableArea,
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: onReset,
        ),
        title: scoredAsync.whenOrNull(
              data: (zones) => Text(
                l.siteSelectionResults(zones.length),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ) ??
            const Text('...', style: TextStyle(fontSize: 16, color: Colors.white)),
        actions: [
          if (compareZones.isNotEmpty)
            TextButton.icon(
              onPressed: () => context.push('/zone-compare'),
              icon: const Icon(Icons.compare, color: AppColors.gold, size: 18),
              label: Text(
                '${l.siteSelectionCompare} (${compareZones.length})',
                style: const TextStyle(color: AppColors.gold, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSortBar(context, ref, sortOption, sortLabels),
          Expanded(
            child: scoredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navy)),
              error: (e, _) => _ErrorState(onRetry: onReset),
              data: (zones) => zones.isEmpty
                  ? _EmptyState(onReset: onReset)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 100),
                      itemCount: zones.length,
                      itemBuilder: (context, i) {
                        final scored = zones[i];
                        final card = IndustrialZoneCard(
                          zone: scored.zone,
                          score: scored.score,
                          animationIndex: i,
                          onTap: () => context.push(
                            '/zone-detail/${scored.zone.id}',
                            extra: scored.zone,
                          ),
                        );
                        if (i < 3) return card;
                        return PaywallGate(lockedChild: card, child: card);
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.tune, size: 18),
            label: Text(l.siteSelectionSearchAgain),
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar(BuildContext context, WidgetRef ref, SortOption current,
      Map<SortOption, String> sortLabels) {
    final l = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${l.commonSort}: ',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          ...SortOption.values.map((option) {
            final isSelected = option == current;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => ref.read(sortOptionProvider.notifier).state = option,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.navy : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.navy : AppColors.border,
                    ),
                  ),
                  child: Text(
                    sortLabels[option]!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              l.siteSelectionNoResults,
              style: const TextStyle(fontSize: 16, color: AppColors.navy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: l.siteSelectionSearchAgain, onPressed: onReset),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              l.commonError,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navy),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: l.commonRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.navy),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.navy, size: 20),
      ),
    );
  }
}
