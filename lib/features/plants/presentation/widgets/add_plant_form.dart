import 'package:flutter/material.dart';
import '../../../../shared/widgets/forms/plant_form_field.dart';
import '../../../../shared/widgets/forms/emoji_selector.dart';
import '../../../../shared/widgets/forms/plant_type_dropdown.dart';
import '../../../../shared/utils/form_validators.dart';
import '../../../../shared/widgets/qr_scanner_page.dart';

class AddPlantForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController locationController;
  final TextEditingController deviceIdController;
  final TextEditingController descriptionController;
  final String selectedEmoji;
  final String selectedPlantType;
  final Function(String) onEmojiChanged;
  final Function(String?) onPlantTypeChanged;

  static const List<String> plantEmojis = [
    '🌱', '🌿', '🌾', '🌵', '🌳', '🌲', '🌴', 
    '🌸', '🌼', '🌹', '💐', '🌻', '🌺', '🌷'
  ];

  static const List<String> plantTypes = [
    'Vegetable Garden',
    'Flower Garden',
    'Herb Garden',
    'Fruit Tree',
    'Houseplant',
    'Succulent',
    'Tree',
    'Grass/Lawn',
    'Other',
  ];

  const AddPlantForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.locationController,
    required this.deviceIdController,
    required this.descriptionController,
    required this.selectedEmoji,
    required this.selectedPlantType,
    required this.onEmojiChanged,
    required this.onPlantTypeChanged,
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
          
          PlantTypeDropdown(
            selectedType: selectedPlantType,
            onChanged: onPlantTypeChanged,
            plantTypes: plantTypes,
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
            label: 'Dispositivo IoT',
            hintText: 'Ingresa el ID del dispositivo o escanea el código QR',
            controller: deviceIdController,
            validator: FormValidators.validateDeviceId,
            suffixIcon: IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final scanned = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const QrScannerPage()),
                );
                if (scanned != null && scanned.isNotEmpty) {
                  deviceIdController.text = scanned.trim();
                }
              },
            ),
          ),
          SizedBox(height: 16),
          
          // Access token removed; deviceId serves as Blynk token
          
          PlantFormField(
            label: 'Descripción (opcional)',
            hintText: 'Describe tu planta...',
            controller: descriptionController,
            validator: FormValidators.validateDescription,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
