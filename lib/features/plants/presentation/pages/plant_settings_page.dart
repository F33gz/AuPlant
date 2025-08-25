import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../widgets/plant_basic_info_form.dart';
import '../widgets/plant_emoji_selector.dart';
import '../widgets/plant_threshold_settings.dart';
import '../widgets/plant_danger_zone.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';

class PlantSettingsPage extends StatefulWidget {
  final Plant plant;

  const PlantSettingsPage({
    super.key,
    required this.plant,
  });

  @override
  State<PlantSettingsPage> createState() => _PlantSettingsPageState();
}

class _PlantSettingsPageState extends State<PlantSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  
  late double _minHumidity;
  late double _minLight;
  late double _maxLight;
  late String _selectedEmoji;
  
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  final List<String> _plantEmojis = [
    '🌱', '🌿', '🌾', '🌵', '🌳', '🌲', '🌴', 
    '🌸', '🌼', '🌹', '💐', '🌻', '🌺', '🌷'
  ];

  final UpdatePlantUseCase _updatePlantUseCase = GetIt.instance<UpdatePlantUseCase>();
  final DeletePlantUseCase _deletePlantUseCase = GetIt.instance<DeletePlantUseCase>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeValues();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.plant.name);
    _locationController = TextEditingController(text: widget.plant.location ?? '');
  }

  void _initializeValues() {
    _selectedEmoji = widget.plant.emoji;
    _minHumidity = widget.plant.thresholds.minHumidity;
    _minLight = widget.plant.thresholds.minLight;
    _maxLight = widget.plant.thresholds.maxLight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Configuración de Planta',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_hasUnsavedChanges)
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Guardar',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlantBasicInfoForm(
            nameController: _nameController,
            locationController: _locationController,
            onChanged: (_) => _markAsChanged(),
          ),
          const SizedBox(height: 24),
          PlantEmojiSelector(
            selectedEmoji: _selectedEmoji,
            plantEmojis: _plantEmojis,
            onEmojiSelected: (emoji) {
              setState(() {
                _selectedEmoji = emoji;
                _markAsChanged();
              });
            },
          ),
          const SizedBox(height: 24),
          PlantThresholdSettings(
            minHumidity: _minHumidity,
            minLight: _minLight,
            maxLight: _maxLight,
            onMinHumidityChanged: (value) {
              setState(() {
                _minHumidity = value;
                _markAsChanged();
              });
            },
            onMinLightChanged: (value) {
              setState(() {
                _minLight = value;
                _markAsChanged();
              });
            },
            onMaxLightChanged: (value) {
              setState(() {
                _maxLight = value;
                _markAsChanged();
              });
            },
          ),
          const SizedBox(height: 24),
          PlantDangerZone(
            onDelete: _deletePlant,
            plantName: widget.plant.name,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _markAsChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }
  
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _updatePlantUseCase.call(
        plantId: widget.plant.id,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        location: _locationController.text.trim(),
        deviceId: widget.plant.deviceId,
      );
      
      switch (result) {
        case Success():
          setState(() {
            _hasUnsavedChanges = false;
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Configuración guardada'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
          break;
        case Error(failure: final failure):
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          break;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePlant() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _deletePlantUseCase.call(widget.plant.id);
      
      switch (result) {
        case Success():
          if (mounted) {
            Navigator.of(context).pop('deleted');
          }
          break;
        case Error(failure: final failure):
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          break;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
