import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../data/datasources/lease_tracker_remote_datasource.dart';
import '../../data/repositories/lease_tracker_repository_impl.dart';
import '../../domain/models/lease_rate_model.dart';
import '../../domain/models/market_insight_model.dart';
import '../../domain/models/rate_alert_model.dart';
import '../../domain/repositories/lease_tracker_repository.dart';

// ── Data layer ────────────────────────────────────────────────────────────────

final leaseTrackerRepositoryProvider = Provider<LeaseTrackerRepository>((ref) {
  return LeaseTrackerRepositoryImpl(LeaseTrackerRemoteDataSource());
});

// ── Filter state ──────────────────────────────────────────────────────────────

final selectedRegionProvider = StateProvider<String>((ref) => 'All');
final selectedAssetTypeProvider = StateProvider<String>((ref) => 'factory');
final selectedZoneProvider = StateProvider<String?>((ref) => 'VSIP Bac Ninh');

// Pro/free gating — derived from subscription
final isPremiumProvider = Provider<bool>((ref) => ref.watch(isProProvider));

// ── Data providers ────────────────────────────────────────────────────────────

final leaseRatesProvider = FutureProvider<List<LeaseRate>>((ref) {
  final region = ref.watch(selectedRegionProvider);
  final assetType = ref.watch(selectedAssetTypeProvider);
  return ref.watch(leaseTrackerRepositoryProvider).getRates(
        region: region == 'All' ? null : region,
        assetType: assetType,
      );
});

// All rates for stats (unfiltered by user selection)
final _allRatesProvider = FutureProvider<List<LeaseRate>>((ref) {
  return ref.watch(leaseTrackerRepositoryProvider).getRates();
});

final rateHistoryProvider = FutureProvider<List<LeaseRate>>((ref) {
  final zone = ref.watch(selectedZoneProvider);
  final assetType = ref.watch(selectedAssetTypeProvider);
  if (zone == null) return Future.value([]);
  return ref.watch(leaseTrackerRepositoryProvider).getRateHistory(zone, assetType);
});

final userAlertsProvider = FutureProvider<List<RateAlert>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value([]);
  return ref.watch(leaseTrackerRepositoryProvider).getUserAlerts(user.id);
});

final marketInsightsProvider = FutureProvider<List<MarketInsight>>((ref) {
  return ref.watch(leaseTrackerRepositoryProvider).getInsights();
});

// ── Computed stats ────────────────────────────────────────────────────────────

class MarketStats {
  final String region;
  final String regionLabel;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double trendPercent;

  const MarketStats({
    required this.region,
    required this.regionLabel,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.trendPercent,
  });
}

final marketStatsProvider = Provider<AsyncValue<List<MarketStats>>>((ref) {
  final ratesAsync = ref.watch(_allRatesProvider);
  return ratesAsync.whenData((rates) {
    return ['North', 'South', 'Central'].map((region) {
      final label = const {
        'North': 'Miền Bắc',
        'Central': 'Miền Trung',
        'South': 'Miền Nam',
      }[region]!;

      final regionRates = rates.where((r) => r.region == region).toList();
      if (regionRates.isEmpty) {
        return MarketStats(
          region: region,
          regionLabel: label,
          avgPrice: 0,
          minPrice: 0,
          maxPrice: 0,
          trendPercent: 0,
        );
      }

      regionRates.sort((a, b) => b.recordedMonth.compareTo(a.recordedMonth));

      final latestDate = regionRates.first.recordedMonth;
      final latestRates = regionRates
          .where((r) =>
              r.recordedMonth.year == latestDate.year &&
              r.recordedMonth.month == latestDate.month)
          .toList();

      final sixMonthsAgo = DateTime(latestDate.year, latestDate.month - 6, 1);
      final prevRates = regionRates
          .where((r) =>
              (r.recordedMonth.year * 12 + r.recordedMonth.month) <=
              (sixMonthsAgo.year * 12 + sixMonthsAgo.month))
          .take(5)
          .toList();

      final prices = regionRates.map((r) => r.priceUsd).toList();
      final avgPrice =
          latestRates.map((r) => r.priceUsd).reduce((a, b) => a + b) /
              latestRates.length;
      final minPrice = prices.reduce(math.min);
      final maxPrice = prices.reduce(math.max);

      double trendPercent = 0;
      if (prevRates.isNotEmpty) {
        final prevAvg =
            prevRates.map((r) => r.priceUsd).reduce((a, b) => a + b) /
                prevRates.length;
        trendPercent = ((avgPrice - prevAvg) / prevAvg) * 100;
      }

      return MarketStats(
        region: region,
        regionLabel: label,
        avgPrice: avgPrice,
        minPrice: minPrice,
        maxPrice: maxPrice,
        trendPercent: trendPercent,
      );
    }).toList();
  });
});

// ── Current prices (latest per zone) ─────────────────────────────────────────

class ZoneCurrentRate {
  final LeaseRate current;
  final double? changeUsd;

  const ZoneCurrentRate({required this.current, this.changeUsd});
}

final currentRatesProvider = Provider<AsyncValue<List<ZoneCurrentRate>>>((ref) {
  final ratesAsync = ref.watch(leaseRatesProvider);
  return ratesAsync.whenData((rates) {
    final grouped = <String, List<LeaseRate>>{};
    for (final r in rates) {
      grouped.putIfAbsent(r.zoneName, () => []).add(r);
    }

    final result = <ZoneCurrentRate>[];
    for (final entry in grouped.entries) {
      final sorted = [...entry.value]
        ..sort((a, b) => b.recordedMonth.compareTo(a.recordedMonth));
      final current = sorted.first;
      final changeUsd = sorted.length >= 2
          ? current.priceUsd - sorted[1].priceUsd
          : null;
      result.add(ZoneCurrentRate(current: current, changeUsd: changeUsd));
    }

    result.sort((a, b) => b.current.priceUsd.compareTo(a.current.priceUsd));
    return result;
  });
});
