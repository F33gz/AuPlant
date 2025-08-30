import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: AppColors.border, width: UIConstants.borderThin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: UIConstants.elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: UIConstants.iconXL),
          const SizedBox(height: UIConstants.spacingS),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: UIConstants.spacingXS),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
