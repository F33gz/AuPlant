import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/entities/plant.dart';

/// Simple Plant List Item Widget
/// 
/// A simple list item for displaying plants in the overview
class PlantListItem extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantListItem({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingM,
          vertical: UIConstants.paddingS,
        ),
        child: ListTile(
          leading: Text(
            plant.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          title: Text(
            plant.name,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            plant.location ?? 'Sin ubicación',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
