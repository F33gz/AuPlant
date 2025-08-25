import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
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
  late TextEditingController _deviceIdController;
  late TextEditingController _accessTokenController;
  
  late double _minHumidity;
  // Elimino _maxHumidity
  late bool _isAutoMode;
  late String _selectedEmoji;
  
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  bool _isSubscribed = false; // Add missing subscription state

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
    _deviceIdController = TextEditingController(text: widget.plant.deviceId ?? '');
    _accessTokenController = TextEditingController();
  }

  void _initializeValues() {
    _selectedEmoji = widget.plant.emoji;
    _minHumidity = widget.plant.thresholds.minHumidity;
    _isAutoMode = false; // Default value since Plant entity doesn't have isAutoMode
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _deviceIdController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
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
                ? SizedBox(
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            _buildBasicInformationSection(),
            SizedBox(height: 24),
            
            // Plant Icon Section
            _buildPlantIconSection(),
            SizedBox(height: 24),
            
            // Sensor Thresholds Section
            _buildSensorThresholdsSection(),
            SizedBox(height: 24),
            
            // Automation Section
            _buildAutomationSection(),
            SizedBox(height: 24),
            
            // Device Management Section
            _buildDeviceManagementSection(),
            SizedBox(height: 24),
            
            // Danger Zone Section
            _buildDangerZoneSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformationSection() {
    return Container(
      padding: EdgeInsets.all(16),
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
          SizedBox(height: 16),
          // Nombre de la planta
          Text(
            'Nombre de la planta',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ingresa el nombre de la planta',
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryGreen),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 16),
          // Ubicación
          Text(
            'Ubicación',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Ingresa la ubicación',
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryGreen),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlantIconSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Icono de la planta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _plantEmojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmoji = emoji;
                      _hasUnsavedChanges = true;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreenAlpha10 : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorThresholdsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Umbrales de sensores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Configura la humedad mínima para tu planta',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          if (_isSubscribed == null)
            const Center(child: CircularProgressIndicator()),
          if (_isSubscribed == false)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 40, color: AppColors.primaryGreen),
                  const SizedBox(height: 12),
                  Text(
                    'Función premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para cambiar el umbral de humedad necesitas una suscripción activa.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _subscribeUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Suscribirse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          if (_isSubscribed == true)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenAlpha10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.opacity, color: AppColors.humidity, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Humedad mínima (%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Min: ${_minHumidity.toInt()}', style: TextStyle(fontSize: 12)),
                  Slider(
                    value: _minHumidity,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: Colors.grey[300],
                    onChanged: (double value) {
                      setState(() {
                        _minHumidity = value;
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAutomationSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Automatización',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo automático',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Riego automático según los sensores',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isAutoMode,
                onChanged: (value) {
                  setState(() {
                    _isAutoMode = value;
                    _hasUnsavedChanges = true;
                  });
                },
                activeColor: AppColors.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceManagementSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión del dispositivo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'ID del dispositivo',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _deviceIdController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el ID del dispositivo',
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.qr_code, color: AppColors.primaryGreen),
                onPressed: () {
                  // TODO: Implementar escaneo de QR
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Token de acceso',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: _accessTokenController,
            decoration: InputDecoration(
              hintText: 'Ingresa el token de acceso',
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryGreen),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: AppColors.primaryGreen,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'En línea',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zona peligrosa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deletePlant,
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text('Eliminar planta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Plant'),
          content: Text('Are you sure you want to delete this plant? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Cierra el diálogo
                setState(() { _isLoading = true; });
                try {
                  final result = await _deletePlantUseCase.call(widget.plant.id);
                  switch (result) {
                    case Success():
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Planta eliminada exitosamente.'), backgroundColor: AppColors.success),
                        );
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    case Error(failure: final failure):
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al eliminar planta: ${failure.message}'), backgroundColor: AppColors.error),
                        );
                      }
                  }
                } finally {
                  if (mounted) setState(() { _isLoading = false; });
                }
              },
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar planta'),
        content: const Text('¿Estás seguro de que deseas eliminar esta planta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      final result = await _deletePlantUseCase.call(widget.plant.id);
      switch (result) {
        case Success():
          if (mounted) {
            Navigator.of(context).pop('deleted');
          }
        case Error(failure: final failure):
          throw Exception(failure.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la planta: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      // Create updated plant entity
      final updatedPlant = Plant(
        id: widget.plant.id,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        description: widget.plant.description,
        location: _locationController.text.trim(),
        deviceId: _deviceIdController.text.trim().isNotEmpty 
            ? _deviceIdController.text.trim() 
            : widget.plant.deviceId,
        thresholds: PlantThresholds(
          minHumidity: _minHumidity,
          maxHumidity: widget.plant.thresholds.maxHumidity,
          minLight: widget.plant.thresholds.minLight,
          maxLight: widget.plant.thresholds.maxLight,
        ),
        createdAt: widget.plant.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _updatePlantUseCase.call(
        plantId: widget.plant.id,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        location: _locationController.text.trim(),
        deviceId: _deviceIdController.text.trim().isNotEmpty 
            ? _deviceIdController.text.trim() 
            : null,
      );
      
      switch (result) {
        case Success(data: final plant):
          setState(() {
            _hasUnsavedChanges = false;
          });
        case Error(failure: final failure):
          throw Exception(failure.message);
      }
      // Navegar a la MainPage y limpiar el stack
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Configuración de la planta guardada exitosamente!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _subscribeUser() {
    // TODO: Implement subscription logic
    setState(() {
      _isSubscribed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suscripción activada (demo)'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
