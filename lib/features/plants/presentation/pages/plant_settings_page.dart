import 'package:flutter/material.dart';
import '../../../../core/models/plant_model.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/plant_service.dart';

class PlantSettingsPage extends StatefulWidget {
  final PlantModel plant;

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

  final List<String> _plantEmojis = [
    '🌱', '🌿', '🌾', '🌵', '🌳', '🌲', '🌴', 
    '🌸', '🌼', '🌹', '💐', '🌻', '🌺', '🌷'
  ];

  final PlantService _plantService = PlantService();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeValues();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.plant.name);
    _locationController = TextEditingController(text: widget.plant.location);
    _deviceIdController = TextEditingController(text: widget.plant.deviceId);
    _accessTokenController = TextEditingController(text: widget.plant.accessToken);
  }

  void _initializeValues() {
    // Solo inicializo el mínimo
    _minHumidity = (widget.plant.thresholds.minHumidity).clamp(0.0, 100.0);
    
    // Ensure min is less than max, use default values if invalid
    // Elimino la lógica de _maxHumidity
    
    _isAutoMode = widget.plant.isAutoMode;
    _selectedEmoji = widget.plant.emoji;
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
          'Plant Settings',
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
                    'Save',
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
            'Basic Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          
          // Plant Name
          Text(
            'Plant Name',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
            SizedBox(height: 4),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter plant name',
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
          
          // ...existing code...
          
          // Location
          Text(
            'Location',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter location',
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
            'Plant Icon',
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
            'Sensor Thresholds',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Set the minimum humidity for your plant',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          // Humidity Slider SOLO MINIMO
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
                      'Min Humidity (%)',
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
            'Automation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Automatically water based on sensor readings',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAutoMode,
                onChanged: (bool value) {
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
            'Device Management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          
          // Device ID
          Text(
            'Device ID',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: _deviceIdController,
            decoration: InputDecoration(
              hintText: 'Enter device ID',
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
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: () {
                  // QR code scanner
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 16),
          // Access Token
          Text(
            'Access Token',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: _accessTokenController,
            decoration: InputDecoration(
              hintText: 'Enter access token',
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
          
          // Online Status
          Row(
            children: [
              Icon(Icons.wifi, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 8),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
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
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[800],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDeleteConfirmationDialog();
              },
              icon: Icon(Icons.delete, color: AppColors.error),
              label: Text(
                'Delete Plant',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: 12),
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
                  await _plantService.deletePlant(widget.plant.id);
                  // Muestra mensaje y navega a la raíz
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Planta eliminada exitosamente.'), backgroundColor: AppColors.success),
                    );
                    // Pop hasta la raíz
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar planta: $e'), backgroundColor: AppColors.error),
                    );
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

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      // Actualiza la planta en la base de datos
      await _plantService.updatePlant(
        plantId: widget.plant.id,
        nombre: _nameController.text,
        emoji: _selectedEmoji,
        descripcion: widget.plant.description,
        deviceId: _deviceIdController.text,
        ubicacion: _locationController.text,
        accessToken: _accessTokenController.text,
      );
      // Si el threshold cambió, envía el nuevo valor a ThingsBoard
      if (_minHumidity != widget.plant.thresholds.minHumidity && (widget.plant.accessToken ?? '').isNotEmpty) {
        await _plantService.sendRegadoCommand(
          accessToken: widget.plant.accessToken!,
          atributos: { 'threshold': _minHumidity.toInt() },
        );
      }
      setState(() {
        _hasUnsavedChanges = false;
      });
      // Refrescar el modelo de la planta desde la base de datos
      final refreshed = await _plantService.getUserPlants();
      final updatedPlant = refreshed.firstWhere((p) => p.id == widget.plant.id, orElse: () => widget.plant);
      // En vez de modificar widget.plant, navega hacia atrás pasando el modelo actualizado
      Navigator.of(context).pop(updatedPlant);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plant settings saved successfully!'),
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
}
