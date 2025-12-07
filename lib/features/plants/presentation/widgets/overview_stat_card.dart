import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Small stat card used in the Plants overview header
class OverviewStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const OverviewStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
    color: cs.surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
    border: Border.all(color: theme.dividerColor, width: UIConstants.borderThin),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: UIConstants.elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Icon(icon, color: cs.primary, size: UIConstants.iconXL),
          const SizedBox(height: UIConstants.spacingS),
      Text(value, style: AppTextStyles.headlineSmall.copyWith(color: cs.onSurface)),
          const SizedBox(height: UIConstants.spacingXS),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
