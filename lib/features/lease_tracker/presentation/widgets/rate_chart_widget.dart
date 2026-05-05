import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/lease_rate_model.dart';

class RateChartWidget extends StatefulWidget {
  final List<LeaseRate> rates;
  final String zoneName;

  const RateChartWidget({
    super.key,
    required this.rates,
    required this.zoneName,
  });

  @override
  State<RateChartWidget> createState() => _RateChartWidgetState();
}

class _RateChartWidgetState extends State<RateChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(RateChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoneName != widget.zoneName) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rates.isEmpty) {
      return _EmptyChart(zoneName: widget.zoneName);
    }

    final sorted = [...widget.rates]
      ..sort((a, b) => a.recordedMonth.compareTo(b.recordedMonth));

    final spots = sorted
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.priceUsd))
        .toList();

    final prices = sorted.map((r) => r.priceUsd).toList();
    final minY = (prices.reduce((a, b) => a < b ? a : b) - 10).floorToDouble();
    final maxY = (prices.reduce((a, b) => a > b ? a : b) + 10).ceilToDouble();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: AppColors.border,
                strokeWidth: 0.8,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: AppColors.border),
                left: BorderSide(color: AppColors.border),
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: 10,
                  getTitlesWidget: (value, _) => Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: sorted.length <= 6
                      ? 1
                      : (sorted.length / 6).ceilToDouble(),
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= sorted.length) return const SizedBox();
                    final d = sorted[i].recordedMonth;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('M/yy').format(d),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: AppColors.navy,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.navy.withValues(alpha: 0.18),
                      AppColors.navy.withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (barData, spotIndexes) =>
                  spotIndexes.map((_) {
                return TouchedSpotIndicatorData(
                  const FlLine(color: AppColors.gold, strokeWidth: 1.5),
                  FlDotData(
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.gold,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.navy,
                tooltipRoundedRadius: 8,
                getTooltipItems: (spots) => spots.map((spot) {
                  final i = spot.x.toInt();
                  if (i >= sorted.length) return null;
                  final rate = sorted[i];
                  return LineTooltipItem(
                    '\$${rate.priceUsd.toStringAsFixed(0)}/m²\n',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('MM/yyyy').format(rate.recordedMonth),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String zoneName;
  const _EmptyChart({required this.zoneName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart, size: 48, color: AppColors.border),
          const SizedBox(height: 8),
          Text(
            'Không có dữ liệu lịch sử cho $zoneName',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
