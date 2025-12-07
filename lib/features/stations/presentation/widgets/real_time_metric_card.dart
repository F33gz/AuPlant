import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Real-time metric card for displaying sensor values
class RealTimeMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String statusLabel;
  final Color statusColor;
  final String? rangeText;
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(context, icon),
              const SizedBox(width: UIConstants.spacingS),
              Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
              if (showStatusDot)
                const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          Text(value, style: AppTextStyles.displaySmall.copyWith(color: cs.onSurface)),
          const SizedBox(height: UIConstants.spacingXS),
          Text(statusLabel, style: AppTextStyles.labelMedium.copyWith(color: statusColor)),
          if (rangeText != null) ...[
            const SizedBox(height: UIConstants.spacingXS),
            Text(rangeText!, style: AppTextStyles.caption),
          ],
          if (minText != null || avgText != null || maxText != null) ...[
            const SizedBox(height: UIConstants.spacingL),
            _footerStats(context, minText, avgText, maxText),
          ],
        ],
      ),
    );
  }

  Widget _iconBadge(BuildContext context, IconData d) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenAlpha10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(d, color: cs.primary, size: 20),
    );
  }

  Widget _footerStats(BuildContext context, String? min, String? avg, String? max) {
    TextStyle label = AppTextStyles.caption;
    final cs = Theme.of(context).colorScheme;
    TextStyle val = AppTextStyles.bodySmall.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600);

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
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingM),
      child: Row(
        children: [
          cell('Min', min),
          Container(width: 1, height: 28, color: Theme.of(context).dividerColor),
          cell('Prom', avg),
          Container(width: 1, height: 28, color: Theme.of(context).dividerColor),
          cell('Máx', max),
        ],
      ),
    );
  }
}
