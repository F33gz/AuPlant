import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/widgets/forms/custom_dropdown.dart';
import '../../../../shared/widgets/buttons/action_buttons.dart';
import '../widgets/plant_emoji_selector.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/add_plant_usecase.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _accessTokenController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AddPlantUseCase _addPlantUseCase = GetIt.instance<AddPlantUseCase>();
  
  String _selectedEmoji = '🌱';
  bool _isLoading = false;


  final List<String> _plantTypes = [
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

  String _selectedPlantType = 'Vegetable Garden';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _deviceIdController.dispose();
    _accessTokenController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textOnDark : AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Agregar Nueva Planta',
        style: TextStyle(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlantNameField(),
            const SizedBox(height: 24),
            _buildEmojiSelector(),
            const SizedBox(height: 24),
            _buildPlantTypeDropdown(),
            const SizedBox(height: 24),
            _buildLocationField(),
            const SizedBox(height: 24),
            _buildDeviceField(),
            const SizedBox(height: 16),
            _buildAccessTokenField(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantNameField() {
    return CustomTextField(
      controller: _nameController,
      label: 'Nombre de la planta',
      hintText: 'Ingresa el nombre de la planta',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el nombre de la planta';
        }
        return null;
      },
    );
  }

  Widget _buildEmojiSelector() {
    return PlantEmojiSelector(
      selectedEmoji: _selectedEmoji,
      onEmojiSelected: (emoji) {
        setState(() {
          _selectedEmoji = emoji;
        });
      },
    );
  }

  Widget _buildPlantTypeDropdown() {
    return CustomDropdown<String>(
      value: _selectedPlantType,
      items: _plantTypes,
      label: 'Tipo de planta',
      getDisplayText: (type) => type,
      onChanged: (String? newValue) {
        setState(() {
          _selectedPlantType = newValue!;
        });
      },
    );
  }

  Widget _buildLocationField() {
    return CustomTextField(
      controller: _locationController,
      label: 'Ubicación',
      hintText: 'e.g., Jardín, Invernadero, Sala de estar',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa una ubicación';
        }
        return null;
      },
    );
  }

  Widget _buildDeviceField() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomTextField(
      controller: _deviceIdController,
      label: 'Dispositivo IoT',
      hintText: 'Ingresa el ID del dispositivo o escanea el código QR',
      suffixIcon: IconButton(
    icon: Icon(Icons.qr_code_scanner, color: isDark ? AppColors.textMutedOnDark : AppColors.textSecondary),
        onPressed: () {
          // TODO: Implement QR code scanner
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el ID del dispositivo';
        }
        return null;
      },
    );
  }

  Widget _buildAccessTokenField() {
    return CustomTextField(
      controller: _accessTokenController,
      label: 'Token de acceso',
      hintText: 'Ingresa el token de acceso',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un token de acceso';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: 'Agregar Planta',
            isLoading: _isLoading,
            onPressed: _savePlant,
          ),
        ),
      ],
    );
  }
  
  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _addPlantUseCase.call(
      name: _nameController.text.trim(),
      deviceId: _deviceIdController.text.trim(),
      emoji: _selectedEmoji,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );
    
    switch (result) {
      case Success<Plant> success:
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.of(context).pop(success.data);
        }
        break;
      case Error<Plant> error:
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        break;
    }
  }
}
