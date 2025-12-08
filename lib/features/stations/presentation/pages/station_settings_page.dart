import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/services/telemetry_monitor_service.dart';
import '../../../../core/services/local_thresholds_storage.dart';
import '../../../../core/services/local_station_settings_storage.dart';
import '../widgets/station_basic_info_form.dart';
import '../widgets/station_emoji_selector.dart';
import '../widgets/station_threshold_settings.dart';
import '../widgets/station_danger_zone.dart';
import '../../domain/entities/station.dart';
import '../../domain/usecases/delete_station_usecase.dart';
import '../widgets/settings_section.dart';

/// Station Settings Page
/// 
/// Configuration page for a greenhouse monitoring station
/// Los umbrales se guardan localmente (SharedPreferences), no se envían al servidor.
class StationSettingsPage extends StatefulWidget {
  final Station station;

  const StationSettingsPage({
    super.key,
    required this.station,
  });

  @override
  State<StationSettingsPage> createState() => _StationSettingsPageState();
}

class _StationSettingsPageState extends State<StationSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  
  late double _minSoilHumidity;
  late double _maxSoilHumidity;
  late double _minAmbientHumidity;
  late double _maxAmbientHumidity;
  late double _minTemperature;
  late double _maxTemperature;
  late String _selectedEmoji;
  
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  bool _isLoadingThresholds = true;

  final DeleteStationUseCase _deleteStationUseCase = GetIt.instance<DeleteStationUseCase>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadLocalSettings();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.station.name);
    _locationController = TextEditingController(text: widget.station.location ?? '');
    _selectedEmoji = widget.station.emoji;
    
    // Inicializar con valores por defecto de la estación
    _minSoilHumidity = widget.station.thresholds.minSoilHumidity;
    _maxSoilHumidity = widget.station.thresholds.maxSoilHumidity;
    _minAmbientHumidity = widget.station.thresholds.minAmbientHumidity;
    _maxAmbientHumidity = widget.station.thresholds.maxAmbientHumidity;
    _minTemperature = widget.station.thresholds.minTemperature;
    _maxTemperature = widget.station.thresholds.maxTemperature;
  }

  /// Carga los ajustes guardados localmente (umbrales e info básica)
  Future<void> _loadLocalSettings() async {
    // Cargar umbrales locales
    final localThresholds = await LocalThresholdsStorage.instance
        .getThresholds(widget.station.id);
    
    // Cargar info básica local (nombre, emoji, ubicación)
    final localInfo = await LocalStationSettingsStorage.instance
        .getSettings(widget.station.id);
    
    if (mounted) {
      setState(() {
        // Aplicar umbrales locales si existen
        if (localThresholds != null) {
          _minSoilHumidity = localThresholds.minSoilHumidity;
          _maxSoilHumidity = localThresholds.maxSoilHumidity;
          _minAmbientHumidity = localThresholds.minAmbientHumidity;
          _maxAmbientHumidity = localThresholds.maxAmbientHumidity;
          _minTemperature = localThresholds.minTemperature;
          _maxTemperature = localThresholds.maxTemperature;
        }
        
        // Aplicar info básica local si existe
        if (localInfo != null) {
          _nameController.text = localInfo.name;
          _selectedEmoji = localInfo.emoji;
          _locationController.text = localInfo.location ?? '';
        }
        
        _isLoadingThresholds = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
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
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Ajustes de Estación',
        style: TextStyle(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
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
          SettingsSection(
            title: 'Información Básica',
            child: StationBasicInfoForm(
              nameController: _nameController,
              locationController: _locationController,
              onChanged: (_) => _markAsChanged(),
              showTitle: false,
              useContainer: false,
            ),
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Icono de la Estación',
            child: StationEmojiSelector(
              selectedEmoji: _selectedEmoji,
              onEmojiSelected: (emoji) {
                setState(() {
                  _selectedEmoji = emoji;
                  _markAsChanged();
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Umbrales de Sensores',
            subtitle: 'Configura los límites mínimos y máximos para alertas.',
            child: StationThresholdSettings(
              minSoilHumidity: _minSoilHumidity,
              maxSoilHumidity: _maxSoilHumidity,
              minAmbientHumidity: _minAmbientHumidity,
              maxAmbientHumidity: _maxAmbientHumidity,
              minTemperature: _minTemperature,
              maxTemperature: _maxTemperature,
              onMinSoilHumidityChanged: (value) {
                setState(() {
                  _minSoilHumidity = value;
                  _markAsChanged();
                });
              },
              onMaxSoilHumidityChanged: (value) {
                setState(() {
                  _maxSoilHumidity = value;
                  _markAsChanged();
                });
              },
              onMinAmbientHumidityChanged: (value) {
                setState(() {
                  _minAmbientHumidity = value;
                  _markAsChanged();
                });
              },
              onMaxAmbientHumidityChanged: (value) {
                setState(() {
                  _maxAmbientHumidity = value;
                  _markAsChanged();
                });
              },
              onMinTemperatureChanged: (value) {
                setState(() {
                  _minTemperature = value;
                  _markAsChanged();
                });
              },
              onMaxTemperatureChanged: (value) {
                setState(() {
                  _maxTemperature = value;
                  _markAsChanged();
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Eliminar estación',
            child: StationDangerZone(
              onDelete: _deleteStation,
              stationName: widget.station.name,
            ),
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
  
  /// Guarda todos los ajustes localmente (no envía nada al servidor)
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    
    try {
      // Crear los nuevos umbrales
      final newThresholds = StationThresholds(
        minSoilHumidity: _minSoilHumidity,
        maxSoilHumidity: _maxSoilHumidity,
        minAmbientHumidity: _minAmbientHumidity,
        maxAmbientHumidity: _maxAmbientHumidity,
        minTemperature: _minTemperature,
        maxTemperature: _maxTemperature,
      );
      
      // Guardar umbrales localmente
      await LocalThresholdsStorage.instance.saveThresholds(
        widget.station.id,
        newThresholds,
      );
      
      // Guardar info básica localmente (nombre, emoji, ubicación)
      await LocalStationSettingsStorage.instance.saveSettings(
        widget.station.id,
        LocalStationSettings(
          name: _nameController.text.trim(),
          emoji: _selectedEmoji,
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
        ),
      );
      
      // Actualizar los umbrales en el monitor de telemetría para las notificaciones
      TelemetryMonitorService.instance.updateStationThresholds(
        widget.station.id,
        newThresholds,
      );
      
      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Configuración guardada localmente'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteStation() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _deleteStationUseCase.call(widget.station.id);
      
      switch (result) {
        case Success():
          // Refrescar las estaciones en el monitor de telemetría
          TelemetryMonitorService.instance.refreshStations();
          
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
