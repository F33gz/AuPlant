import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Plant Danger Zone Widget
/// 
/// Widget for dangerous actions like deleting the plant
class PlantDangerZone extends StatelessWidget {
  final VoidCallback onDelete;
  final String plantName;

  const PlantDangerZone({
    super.key,
    required this.onDelete,
    required this.plantName,
  });

  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
    color: isDark ? AppColors.surfaceDark : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
    border: Border.all(color: isDark ? AppColors.borderDark : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Zona de Peligro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Una vez eliminada la planta, no podrás recuperarla. Esta acción no se puede deshacer.',
            style: TextStyle(
              fontSize: 14,
        color: isDark ? AppColors.textMutedOnDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Planta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : null,
        title: Text(
          '¿Eliminar planta?',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textOnDark
                : null,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "$plantName"? Esta acción no se puede deshacer.',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMutedOnDark
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textOnDark
                    : null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
