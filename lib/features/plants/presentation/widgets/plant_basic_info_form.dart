import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

/// Plant Basic Info Form Widget
/// 
/// Form section for editing basic plant information
class PlantBasicInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController locationController;
  final Function(String) onChanged;

  const PlantBasicInfoForm({
    super.key,
    required this.nameController,
    required this.locationController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información básica',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: nameController,
            label: 'Nombre de la planta',
            hintText: 'Ingresa el nombre de la planta',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre de la planta';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: locationController,
            label: 'Ubicación',
            hintText: 'e.g., Jardín, Invernadero, Sala de estar',
          ),
        ],
      ),
    );
  }
}
