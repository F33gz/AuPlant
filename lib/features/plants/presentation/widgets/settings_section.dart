import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SettingsSection({super.key, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: UIConstants.spacingXS),
            Text(subtitle!, style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: UIConstants.spacingL),
          child,
        ],
      ),
    );
  }
}
