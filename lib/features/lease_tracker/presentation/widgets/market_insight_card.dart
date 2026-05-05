import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/market_insight_model.dart';
import '../providers/lease_tracker_provider.dart';

class MarketInsightCard extends ConsumerStatefulWidget {
  final MarketInsight insight;

  const MarketInsightCard({super.key, required this.insight});

  @override
  ConsumerState<MarketInsightCard> createState() => _MarketInsightCardState();
}

class _MarketInsightCardState extends ConsumerState<MarketInsightCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);
    final insight = widget.insight;
    final isLocked = insight.isPremium && !isPremium;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(insight),
                  const SizedBox(height: 8),
                  Text(
                    insight.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedCrossFade(
                    firstChild: Text(
                      insight.content,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary,
                          height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      insight.content,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? l.insightCollapse : l.insightExpand,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked) _buildPremiumOverlay(context, l),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MarketInsight insight) {
    return Row(
      children: [
        if (insight.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              insight.category!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.navy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (insight.province != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              insight.province!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (insight.isPremium) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.gold, width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 10, color: AppColors.gold),
                SizedBox(width: 3),
                Text(
                  'Premium',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        Text(
          DateFormat('dd/MM/yy').format(insight.publishedAt),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPremiumOverlay(BuildContext context, AppLocalizations l) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.white.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 32, color: AppColors.gold),
                  const SizedBox(height: 6),
                  Text(
                    l.insightPremiumContent,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.insightPremiumUpgradePrompt,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 36),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: Text(l.insightUpgradePro),
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
