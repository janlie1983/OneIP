import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/site_selection_remote_datasource.dart';
import '../../data/repositories/site_selection_repository_impl.dart';
import '../../domain/models/industrial_zone_model.dart';
import '../../domain/models/site_selection_query_model.dart';
import '../../domain/repositories/site_selection_repository.dart';

// ── Data layer ────────────────────────────────────────────────────────────────

final siteSelectionRepositoryProvider = Provider<SiteSelectionRepository>((ref) {
  return SiteSelectionRepositoryImpl(SiteSelectionRemoteDataSource());
});

// ── State ─────────────────────────────────────────────────────────────────────

final siteSelectionQueryProvider = StateProvider<SiteSelectionQuery?>((ref) => null);

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.score);

final compareZonesProvider = StateProvider<List<IndustrialZone>>((ref) => []);

// ── Data providers ────────────────────────────────────────────────────────────

final industrialZonesProvider = FutureProvider<List<IndustrialZone>>((ref) {
  return ref.watch(siteSelectionRepositoryProvider).getAllZones();
});

final siteSelectionResultsProvider = FutureProvider<List<IndustrialZone>>((ref) async {
  final query = ref.watch(siteSelectionQueryProvider);
  if (query == null) return [];
  return ref.watch(siteSelectionRepositoryProvider).searchZones(query);
});

final scoredResultsProvider = Provider<AsyncValue<List<ScoredZone>>>((ref) {
  final resultsAsync = ref.watch(siteSelectionResultsProvider);
  final query = ref.watch(siteSelectionQueryProvider);
  final sortOption = ref.watch(sortOptionProvider);

  return resultsAsync.whenData((zones) {
    if (query == null) return [];

    final scored = zones
        .map((z) => ScoredZone(zone: z, score: scoreZone(z, query)))
        .toList();

    switch (sortOption) {
      case SortOption.score:
        scored.sort((a, b) => b.score.compareTo(a.score));
      case SortOption.price:
        scored.sort((a, b) =>
            (a.zone.leasePriceUsd ?? 999).compareTo(b.zone.leasePriceUsd ?? 999));
      case SortOption.area:
        scored.sort((a, b) =>
            (b.zone.availableAreaHa ?? 0).compareTo(a.zone.availableAreaHa ?? 0));
    }

    return scored;
  });
});

final zoneByIdProvider = Provider.family<IndustrialZone?, String>((ref, id) {
  return ref.watch(industrialZonesProvider).whenOrNull(
    data: (zones) {
      try {
        return zones.firstWhere((z) => z.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

// ── Models ────────────────────────────────────────────────────────────────────

class ScoredZone {
  final IndustrialZone zone;
  final double score;
  const ScoredZone({required this.zone, required this.score});
}

enum SortOption { score, price, area }

// ── Scoring algorithm ─────────────────────────────────────────────────────────

double scoreZone(IndustrialZone zone, SiteSelectionQuery query) {
  final infraWeight = query.priorityFactors.contains('infra') ? 2.0 : 1.0;
  final laborWeight = query.priorityFactors.contains('labor') ? 2.0 : 1.0;
  final logisticsWeight = query.priorityFactors.contains('logistics') ? 2.0 : 1.0;

  final baseScore = ((zone.infraScore ?? 5) * infraWeight +
          (zone.laborScore ?? 5) * laborWeight +
          (zone.logisticsScore ?? 5) * logisticsWeight) /
      (infraWeight + laborWeight + logisticsWeight);

  final priceScore = zone.leasePriceUsd != null
      ? ((200 - zone.leasePriceUsd!) / 150) * 10
      : 5.0;

  final taxBonus = zone.taxIncentiveYears != null
      ? (zone.taxIncentiveYears! / 15) * 2
      : 0.0;

  final industryBonus = zone.industriesSupported.any(
          (i) => i.toLowerCase().contains(query.industry.toLowerCase()))
      ? 1.5
      : 0.0;

  final areaPenalty =
      (zone.availableAreaHa ?? 0) * 10000 < query.requiredAreaM2 ? -3.0 : 0.0;

  return (baseScore + priceScore + taxBonus + industryBonus + areaPenalty)
      .clamp(0, 10)
      .toDouble();
}
