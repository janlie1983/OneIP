import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/industrial_zone_model.dart';
import '../../domain/models/site_selection_query_model.dart';
import '../providers/site_selection_provider.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(compareZonesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'So sánh ${zones.length} KCN',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(compareZonesProvider.notifier).state = [],
            icon: const Icon(Icons.clear_all, color: Colors.white70, size: 18),
            label: const Text('Xóa tất cả', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: zones.isEmpty
          ? _EmptyCompare(onBack: () => context.pop())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _CompareTable(zones: zones),
                    ),
                  ),
                ),
                _SaveBar(zones: zones),
              ],
            ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final List<IndustrialZone> zones;

  const _CompareTable({required this.zones});

  @override
  Widget build(BuildContext context) {
    final colWidth = math.max(
        140.0, (MediaQuery.of(context).size.width - 120) / zones.length);

    return Table(
      defaultColumnWidth: FixedColumnWidth(colWidth),
      columnWidths: {
        0: const FixedColumnWidth(110),
        ...{for (var i = 0; i < zones.length; i++) i + 1: FixedColumnWidth(colWidth)},
      },
      border: TableBorder.all(color: AppColors.border, width: 0.5),
      children: [
        _headerRow(zones),
        ..._buildRows(zones),
      ],
    );
  }

  TableRow _headerRow(List<IndustrialZone> zones) {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.navy),
      children: [
        const _TableCell(text: 'Tiêu chí', isHeader: true, isLabel: true),
        ...zones.map((z) => _TableCell(text: z.name, isHeader: true)),
      ],
    );
  }

  List<TableRow> _buildRows(List<IndustrialZone> zones) {
    return [
      _textRow('Tỉnh', zones.map((z) => z.province).toList()),
      _textRow('Vùng', zones.map((z) => _regionLabel(z.region)).toList()),
      _numericRow('Điểm hạ tầng', zones.map((z) => z.infraScore?.toDouble()).toList(), higherBetter: true),
      _numericRow('Điểm lao động', zones.map((z) => z.laborScore?.toDouble()).toList(), higherBetter: true),
      _numericRow('Điểm logistics', zones.map((z) => z.logisticsScore?.toDouble()).toList(), higherBetter: true),
      _numericRow(
        'Giá thuê (USD/m²/năm)',
        zones.map((z) => z.leasePriceUsd).toList(),
        higherBetter: false,
        format: (v) => '\$${v.toStringAsFixed(0)}',
      ),
      _numericRow(
        'Diện tích trống (ha)',
        zones.map((z) => z.availableAreaHa).toList(),
        higherBetter: true,
        format: (v) => '${v.toStringAsFixed(0)} ha',
      ),
      _numericRow(
        'Tỷ lệ lấp đầy (%)',
        zones.map((z) => z.occupancyRate).toList(),
        higherBetter: false,
        format: (v) => '${v.toStringAsFixed(0)}%',
      ),
      _numericRow(
        'Ưu đãi thuế (năm)',
        zones.map((z) => z.taxIncentiveYears?.toDouble()).toList(),
        higherBetter: true,
        format: (v) => '${v.toStringAsFixed(0)}n',
      ),
      _numericRow(
        'Đến cảng biển (km)',
        zones.map((z) => z.distanceToSeaportKm).toList(),
        higherBetter: false,
        format: (v) => '${v.toStringAsFixed(0)} km',
      ),
      _numericRow(
        'Đến sân bay (km)',
        zones.map((z) => z.distanceToAirportKm).toList(),
        higherBetter: false,
        format: (v) => '${v.toStringAsFixed(0)} km',
      ),
      _textRow('Chủ đầu tư', zones.map((z) => z.developer ?? '-').toList()),
    ];
  }

  TableRow _textRow(String label, List<String> values) {
    return TableRow(
      children: [
        _TableCell(text: label, isLabel: true),
        ...values.map((v) => _TableCell(text: v)),
      ],
    );
  }

  TableRow _numericRow(
    String label,
    List<double?> values, {
    required bool higherBetter,
    String Function(double)? format,
  }) {
    final colors = _cellColors(values, higherBetter);
    return TableRow(
      children: [
        _TableCell(text: label, isLabel: true),
        ...List.generate(values.length, (i) {
          final v = values[i];
          return _TableCell(
            text: v != null ? (format != null ? format(v) : v.toStringAsFixed(1)) : '-',
            bgColor: colors[i],
          );
        }),
      ],
    );
  }

  List<Color?> _cellColors(List<double?> values, bool higherBetter) {
    final valid = values.whereType<double>().toList();
    if (valid.length < 2) return List.filled(values.length, null);

    final maxVal = valid.reduce(math.max);
    final minVal = valid.reduce(math.min);
    if (maxVal == minVal) return List.filled(values.length, null);

    return values.map((v) {
      if (v == null) return null;
      if (higherBetter) {
        if (v == maxVal) return AppColors.success.withValues(alpha: 0.18);
        if (v == minVal) return AppColors.error.withValues(alpha: 0.12);
      } else {
        if (v == minVal) return AppColors.success.withValues(alpha: 0.18);
        if (v == maxVal) return AppColors.error.withValues(alpha: 0.12);
      }
      return null;
    }).toList();
  }

  String _regionLabel(String region) {
    switch (region) {
      case 'North':
        return 'Miền Bắc';
      case 'Central':
        return 'Miền Trung';
      case 'South':
        return 'Miền Nam';
      default:
        return region;
    }
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool isLabel;
  final Color? bgColor;

  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.isLabel = false,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (isHeader) {
      bg = AppColors.navy;
    } else if (isLabel) {
      bg = AppColors.backgroundLight;
    } else {
      bg = bgColor ?? Colors.white;
    }

    Color textColor;
    if (isHeader) {
      textColor = Colors.white;
    } else if (isLabel) {
      textColor = AppColors.textSecondary;
    } else {
      textColor = AppColors.navy;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: bg,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isLabel ? 12 : 13,
          fontWeight: isHeader || (!isLabel) ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SaveBar extends ConsumerWidget {
  final List<IndustrialZone> zones;
  const _SaveBar({required this.zones});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton.icon(
          onPressed: () => _saveResult(context, ref),
          icon: const Icon(Icons.save_alt, size: 18),
          label: const Text('Lưu kết quả so sánh'),
        ),
      ),
    );
  }

  Future<void> _saveResult(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để lưu kết quả'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final repo = ref.read(siteSelectionRepositoryProvider);
      await repo.saveResult(
        user.id,
        ref.read(siteSelectionQueryProvider) ??
            const SiteSelectionQuery(industry: '', requiredAreaM2: 0, headcount: 0),
        zones,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu kết quả thành công!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu. Vui lòng thử lại.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _EmptyCompare extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyCompare({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.compare, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Chưa có KCN để so sánh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm KCN vào danh sách so sánh từ kết quả tìm kiếm',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBack,
              child: const Text('Quay lại tìm kiếm'),
            ),
          ],
        ),
      ),
    );
  }
}

