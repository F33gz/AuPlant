import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/entities/plant.dart';

/// List tile styled like the mock for Plants overview
class PlantOverviewTile extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  /// Placeholder current humidity, to be wired to live data later
  final double? currentHumidity;
  /// Placeholder average humidity
  final double? averageHumidity;

  const PlantOverviewTile({
    super.key,
    required this.plant,
    this.onTap,
    this.currentHumidity,
    this.averageHumidity,
  });

  @override
  Widget build(BuildContext context) {
    final humidityNow = currentHumidity ?? 65.0; // TODO: bind to Supabase/Blynk
    final avg = averageHumidity ?? 64.2;

    return Material(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(UIConstants.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(UIConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _emojiCircle(plant.emoji),
                  const SizedBox(width: UIConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name, style: AppTextStyles.titleMedium),
                        Text(
                          plant.description,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: UIConstants.spacingXS),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: AppColors.online),
                            const SizedBox(width: 6),
                            Text('En línea', style: AppTextStyles.statusOnline),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: UIConstants.spacingL),
              _humidityCard(humidityNow, plant.thresholds.minHumidity),
              const SizedBox(height: UIConstants.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Umbral: ${plant.thresholds.minHumidity.toStringAsFixed(0)}%', style: AppTextStyles.caption),
                  Text('Prom: ${avg.toStringAsFixed(1)}%', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emojiCircle(String emoji) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryGreenAlpha10,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }

  Widget _humidityCard(double current, double thresholdMin) {
    final isGood = current >= thresholdMin;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.paddingM,
        horizontal: UIConstants.paddingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.humidityBackground,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: AppColors.humidity),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Text('Humedad', style: AppTextStyles.labelMedium),
          ),
          Text(
            '${current.toStringAsFixed(1)}%',
            style: AppTextStyles.titleSmall.copyWith(
              color: isGood ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
