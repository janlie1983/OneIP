import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProgressCircle extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;

  const ProgressCircle({
    super.key,
    required this.percent,
    this.size = 72,
    this.strokeWidth = 7,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    final color = clamped >= 1.0
        ? AppColors.success
        : clamped >= 0.5
            ? AppColors.gold
            : AppColors.navy;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clamped),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
