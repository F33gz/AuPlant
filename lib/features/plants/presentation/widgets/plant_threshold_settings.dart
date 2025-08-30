import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Plant Threshold Settings Widget
/// 
/// Widget for configuring plant sensor thresholds
class PlantThresholdSettings extends StatelessWidget {
  final double minHumidity;
  final double minLight;
  final double maxLight;
  final Function(double) onMinHumidityChanged;
  final Function(double) onMinLightChanged;
  final Function(double) onMaxLightChanged;

  const PlantThresholdSettings({
    super.key,
    required this.minHumidity,
    required this.minLight,
    required this.maxLight,
    required this.onMinHumidityChanged,
    required this.onMinLightChanged,
    required this.onMaxLightChanged,
  });

  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
    color: isDark ? AppColors.surfaceDark : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Umbrales de Sensores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSliderSection(
            context,
            'Humedad Mínima',
            '${minHumidity.round()}%',
            minHumidity,
            0.0,
            100.0,
            onMinHumidityChanged,
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildSliderSection(
            context,
            'Luz Mínima',
            '${minLight.round()} lux',
            minLight,
            0.0,
            2000.0,
            onMinLightChanged,
            Icons.wb_sunny,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildSliderSection(
            context,
            'Luz Máxima',
            '${maxLight.round()} lux',
            maxLight,
            0.0,
            5000.0,
            onMaxLightChanged,
            Icons.wb_sunny_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection(
    BuildContext context,
    String title,
    String value,
    double currentValue,
    double min,
    double max,
    Function(double) onChanged,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
        color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.textMutedOnDark
          : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.3),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
