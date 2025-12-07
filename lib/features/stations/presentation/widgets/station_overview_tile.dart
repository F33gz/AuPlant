import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/entities/station.dart';

/// Overview tile for a station in the list
/// 
/// Displays station info with current sensor readings
class StationOverviewTile extends StatelessWidget {
  final Station station;
  final VoidCallback? onTap;
  final double? soilHumidity;
  final double? ambientHumidity;
  final double? temperature;
  final bool? online;

  const StationOverviewTile({
    super.key,
    required this.station,
    this.onTap,
    this.soilHumidity,
    this.ambientHumidity,
    this.temperature,
    this.online,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(UIConstants.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.all(UIConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with emoji, name, description, and online status
              Row(
                children: [
                  _emojiCircle(station.emoji),
                  const SizedBox(width: UIConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(station.name, style: AppTextStyles.titleMedium),
                        if (station.description.isNotEmpty)
                          Text(
                            station.description,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: UIConstants.spacingXS),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: (online ?? false) ? AppColors.online : AppColors.offline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (online ?? false) ? 'En línea' : 'Desconectada',
                              style: (online ?? false) ? AppTextStyles.statusOnline : AppTextStyles.statusOffline,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.dividerColor),
                ],
              ),
              const SizedBox(height: UIConstants.spacingL),
              
              // Sensor readings row
              _buildSensorReadingsRow(context),
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

  Widget _buildSensorReadingsRow(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.paddingM,
        horizontal: UIConstants.paddingM,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? cs.primary.withValues(alpha: 0.08)
            : AppColors.humidityBackground,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      child: Row(
        children: [
          // Soil Humidity
          Expanded(
            child: _buildMetricItem(
              context,
              icon: Icons.water_drop,
              label: 'Suelo',
              value: soilHumidity == null ? 'N/A' : '${soilHumidity!.toStringAsFixed(0)}%',
              isGood: soilHumidity != null && soilHumidity! >= station.thresholds.minSoilHumidity,
            ),
          ),
          _buildDivider(context),
          // Ambient Humidity
          Expanded(
            child: _buildMetricItem(
              context,
              icon: Icons.cloud,
              label: 'Ambiente',
              value: ambientHumidity == null ? 'N/A' : '${ambientHumidity!.toStringAsFixed(0)}%',
              isGood: ambientHumidity != null && ambientHumidity! >= station.thresholds.minAmbientHumidity,
            ),
          ),
          _buildDivider(context),
          // Temperature
          Expanded(
            child: _buildMetricItem(
              context,
              icon: Icons.thermostat,
              label: 'Temp',
              value: temperature == null ? 'N/A' : '${temperature!.toStringAsFixed(0)}°C',
              isGood: temperature != null && 
                      temperature! >= station.thresholds.minTemperature && 
                      temperature! <= station.thresholds.maxTemperature,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isGood,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: cs.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: isGood ? AppColors.success : cs.error,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
