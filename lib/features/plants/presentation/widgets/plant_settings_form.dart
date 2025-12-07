import 'package:flutter/material.dart';
import '../../../../shared/widgets/forms/plant_form_field.dart';
import '../../../../shared/widgets/forms/emoji_selector.dart';
import '../../../../shared/utils/form_validators.dart';
import '../../../../app/theme/app_colors.dart';

class PlantSettingsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController locationController;
  final TextEditingController deviceIdController;
  final String selectedEmoji;
  final double minHumidity;
  final Function(String) onEmojiChanged;
  final Function(double) onMinHumidityChanged;

  static const List<String> plantEmojis = [
    '🌱', '🌿', '🌾', '🌵', '🌳', '🌲', '🌴', 
    '🌸', '🌼', '🌹', '💐', '🌻', '🌺', '🌷'
  ];

  const PlantSettingsForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.locationController,
    required this.deviceIdController,
    required this.selectedEmoji,
    required this.minHumidity,
    required this.onEmojiChanged,
    required this.onMinHumidityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlantFormField(
            label: 'Nombre de la planta',
            hintText: 'Ej: Mi tomate cherry',
            controller: nameController,
            validator: FormValidators.validatePlantName,
          ),
          SizedBox(height: 24),
          
          EmojiSelector(
            selectedEmoji: selectedEmoji,
            onEmojiSelected: onEmojiChanged,
            emojis: plantEmojis,
          ),
          SizedBox(height: 24),
          
          PlantFormField(
            label: 'Ubicación',
            hintText: 'Ej: Jardín trasero, Balcón',
            controller: locationController,
            validator: FormValidators.validateLocation,
          ),
          SizedBox(height: 24),
          
          PlantFormField(
            label: 'ID del Dispositivo',
            hintText: 'ID del dispositivo IoT',
            controller: deviceIdController,
            validator: FormValidators.validateDeviceId,
          ),
          SizedBox(height: 24),
          
          _buildHumiditySlider(context),
        ],
      ),
    );
  }

  Widget _buildHumiditySlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Humedad Mínima',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Valor: ${minHumidity.toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${minHumidity.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.info,
                  inactiveTrackColor: AppColors.info.withValues(alpha: 0.3),
                  thumbColor: AppColors.info,
                  overlayColor: AppColors.info.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: minHumidity,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: onMinHumidityChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
