import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

class RealTimeMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String statusLabel; // e.g. "Óptimo" or "Sin datos"
  final Color statusColor;
  final String? rangeText; // e.g. "Rango: 45-70%"
  final String? minText;
  final String? avgText;
  final String? maxText;
  final bool showStatusDot;

  const RealTimeMetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.statusLabel,
    required this.statusColor,
    this.rangeText,
    this.minText,
    this.avgText,
    this.maxText,
    this.showStatusDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(icon),
              const SizedBox(width: UIConstants.spacingS),
              Text(title, style: AppTextStyles.titleSmall),
              const Spacer(),
              if (showStatusDot)
                const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          Text(value, style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: UIConstants.spacingXS),
          Text(statusLabel, style: AppTextStyles.labelMedium.copyWith(color: statusColor)),
          if (rangeText != null) ...[
            const SizedBox(height: UIConstants.spacingXS),
            Text(rangeText!, style: AppTextStyles.caption),
          ],
          if (minText != null || avgText != null || maxText != null) ...[
            const SizedBox(height: UIConstants.spacingL),
            _footerStats(minText, avgText, maxText),
          ],
        ],
      ),
    );
  }

  Widget _iconBadge(IconData d) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenAlpha10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(d, color: AppColors.primaryGreen),
    );
  }

  Widget _footerStats(String? min, String? avg, String? max) {
    TextStyle label = AppTextStyles.caption;
    TextStyle val = AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600);

    Widget cell(String labelText, String? v) => Expanded(
          child: Column(
            children: [
              Text(labelText, style: label),
              const SizedBox(height: 4),
              Text(v ?? '--', style: val),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingM),
      child: Row(
        children: [
          cell('Min', min),
          Container(width: 1, height: 28, color: AppColors.border),
          cell('Prom', avg),
          Container(width: 1, height: 28, color: AppColors.border),
          cell('Máx', max),
        ],
      ),
    );
  }
}
