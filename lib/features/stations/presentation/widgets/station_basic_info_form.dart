import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

/// Station Basic Info Form Widget
/// 
/// Form section for editing basic station information
class StationBasicInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController locationController;
  final Function(String) onChanged;
  final bool showTitle;
  final bool useContainer;

  const StationBasicInfoForm({
    super.key,
    required this.nameController,
    required this.locationController,
    required this.onChanged,
    this.showTitle = true,
    this.useContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            'Información básica',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: nameController,
          label: 'Nombre de la estación',
          hintText: 'Ej: Estación Norte, Sector A',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el nombre de la estación';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: locationController,
          label: 'Ubicación',
          hintText: 'Ej: Invernadero 1, Zona Norte',
        ),
      ],
    );

    if (!useContainer) return content;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: content,
    );
  }
}
