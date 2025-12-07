import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Station Threshold Settings Widget
/// 
/// Widget for configuring station sensor thresholds:
/// - Soil humidity (min/max)
/// - Ambient humidity (min/max)
/// - Temperature (min/max)
class StationThresholdSettings extends StatelessWidget {
  final double minSoilHumidity;
  final double maxSoilHumidity;
  final double minAmbientHumidity;
  final double maxAmbientHumidity;
  final double minTemperature;
  final double maxTemperature;
  
  final Function(double) onMinSoilHumidityChanged;
  final Function(double) onMaxSoilHumidityChanged;
  final Function(double) onMinAmbientHumidityChanged;
  final Function(double) onMaxAmbientHumidityChanged;
  final Function(double) onMinTemperatureChanged;
  final Function(double) onMaxTemperatureChanged;

  const StationThresholdSettings({
    super.key,
    required this.minSoilHumidity,
    required this.maxSoilHumidity,
    required this.minAmbientHumidity,
    required this.maxAmbientHumidity,
    required this.minTemperature,
    required this.maxTemperature,
    required this.onMinSoilHumidityChanged,
    required this.onMaxSoilHumidityChanged,
    required this.onMinAmbientHumidityChanged,
    required this.onMaxAmbientHumidityChanged,
    required this.onMinTemperatureChanged,
    required this.onMaxTemperatureChanged,
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
          // Soil Humidity Section
          _buildSectionTitle(context, 'Humedad del Suelo', Icons.water_drop, Colors.blue),
          const SizedBox(height: 8),
          _buildSliderSection(
            context,
            'Mínima',
            '${minSoilHumidity.round()}%',
            minSoilHumidity,
            0.0,
            100.0,
            onMinSoilHumidityChanged,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context,
            'Máxima',
            '${maxSoilHumidity.round()}%',
            maxSoilHumidity,
            0.0,
            100.0,
            onMaxSoilHumidityChanged,
          ),
          
          const SizedBox(height: 24),
          
          // Ambient Humidity Section
          _buildSectionTitle(context, 'Humedad Ambiente', Icons.cloud, Colors.cyan),
          const SizedBox(height: 8),
          _buildSliderSection(
            context,
            'Mínima',
            '${minAmbientHumidity.round()}%',
            minAmbientHumidity,
            0.0,
            100.0,
            onMinAmbientHumidityChanged,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context,
            'Máxima',
            '${maxAmbientHumidity.round()}%',
            maxAmbientHumidity,
            0.0,
            100.0,
            onMaxAmbientHumidityChanged,
          ),
          
          const SizedBox(height: 24),
          
          // Temperature Section
          _buildSectionTitle(context, 'Temperatura', Icons.thermostat, Colors.orange),
          const SizedBox(height: 8),
          _buildSliderSection(
            context,
            'Mínima',
            '${minTemperature.round()}°C',
            minTemperature,
            -10.0,
            50.0,
            onMinTemperatureChanged,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context,
            'Máxima',
            '${maxTemperature.round()}°C',
            maxTemperature,
            -10.0,
            50.0,
            onMaxTemperatureChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ],
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
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textMutedOnDark : AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenAlpha10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGreen,
            inactiveTrackColor: isDark ? AppColors.borderDark : AppColors.border,
            thumbColor: AppColors.primaryGreen,
            overlayColor: AppColors.primaryGreenAlpha30,
            trackHeight: 4,
          ),
          child: Slider(
            value: currentValue.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
