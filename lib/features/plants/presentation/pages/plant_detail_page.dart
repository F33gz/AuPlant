import 'package:flutter/material.dart';
import '../../../../core/models/plant_model.dart';
import '../../../../core/services/plant_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../widgets/real_time_data_section.dart';
import '../widgets/sensor_evolution_section.dart';
import '../widgets/plant_controls_section.dart';
import 'plant_settings_page.dart'; // Added import for PlantSettingsPage
import '../../../../core/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Plant detail page showing comprehensive information about a specific plant
/// including real-time sensor data, historical trends, and control options.
class PlantDetailPage extends StatefulWidget {
  final PlantModel plant;

  const PlantDetailPage({
    super.key,
    required this.plant,
  });

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final PlantService _plantService = PlantService();
  PlantWithSensorData? _plantWithSensorData;
  bool _isLoading = true;
  String? _error;
  bool? _isSubscribed;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
    _fetchSubscription();
  }

  Future<void> _loadPlantData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final plantsWithSensorData = await _plantService.getPlantsWithSensorData();
      final plantData = plantsWithSensorData.firstWhere(
        (p) => p.id == widget.plant.id,
        orElse: () => PlantWithSensorData(
          id: widget.plant.id,
          nombre: widget.plant.name,
          emoji: widget.plant.emoji,
          descripcion: widget.plant.description,
          ubicacion: widget.plant.location ?? '',
          deviceId: widget.plant.deviceId,
        ),
      );

      setState(() {
        _plantWithSensorData = plantData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSubscription() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() { _isSubscribed = false; });
      return;
    }
    final data = await supabase
        .from('users')
        .select('subscribed')
        .eq('id', user.id)
        .single();
    setState(() {
      _isSubscribed = data['subscribed'] ?? false;
    });
  }

  Future<void> _subscribeUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase.from('users').update({'subscribed': true}).eq('id', user.id);
    setState(() { _isSubscribed = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(widget.plant.name),
          backgroundColor: AppColors.backgroundWhite,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(widget.plant.name),
          backgroundColor: AppColors.backgroundWhite,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar los datos',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPlantData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final plantData = _plantWithSensorData!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Custom app bar with plant image and basic info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.backgroundWhite,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.plant.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.plant.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryGreenAlpha10,
                      AppColors.backgroundWhite,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Main content centered
                    Center(
                      child: Text(
                        widget.plant.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                    // Status indicator positioned in top-right corner
                    Positioned(
                      top: 50,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.plant.isOnline 
                              ? AppColors.online.withValues(alpha: 0.1)
                              : AppColors.offline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.plant.isOnline 
                                ? AppColors.online 
                                : AppColors.offline,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.plant.isOnline ? Icons.wifi : Icons.wifi_off,
                              color: widget.plant.isOnline 
                                  ? AppColors.online 
                                  : AppColors.offline,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.plant.isOnline ? 'En línea' : 'Desconectado',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: widget.plant.isOnline 
                                    ? AppColors.online 
                                    : AppColors.offline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Continuous scrollable content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real-time data section
                  _buildSectionTitle('Datos en Tiempo Real'),
                  const SizedBox(height: UIConstants.spacingL),
                  RealTimeDataSection(
                    plantData: plantData,
                  ),
                  
                  const SizedBox(height: UIConstants.spacingXXL),
                  
                  // Historical data section
                  if (_isSubscribed == null)
                    const Center(child: CircularProgressIndicator()),
                  if (_isSubscribed == false)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 48, color: AppColors.primaryGreen),
                          const SizedBox(height: 16),
                          Text(
                            'Estadísticas premium',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Para ver la evolución de sensores necesitas una suscripción activa.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _subscribeUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Suscribirse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isSubscribed == true) ...[
                    _buildSectionTitle('Evolución de Sensores'),
                    const SizedBox(height: UIConstants.spacingL),
                    SensorEvolutionSection(
                      humidityData: plantData.recentHumidityReadings,
                      lightData: plantData.recentLightReadings,
                    ),
                  ],
                  
                  const SizedBox(height: UIConstants.spacingXXL),
                  
                  // Controls section
                  _buildSectionTitle('Controles'),
                  const SizedBox(height: UIConstants.spacingL),
                  PlantControlsSection(
                    isOnline: widget.plant.isOnline,
                    isAutoMode: widget.plant.isAutoMode,
                    isWatering: false,
                    plantName: widget.plant.name,
                    plant: _plantWithSensorData != null ? _plantWithSensorData!.toPlantModel() : widget.plant,
                    onWaterNow: () {
                      _showWateringDialog();
                    },
                    onAutoModeToggle: (value) {
                      _showAutoModeDialog(value);
                    },
                    onSettingsPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlantSettingsPage(
                            plant: _plantWithSensorData != null ? _plantWithSensorData!.toPlantModel() : widget.plant,
                          ),
                        ),
                      );
                      if (result == 'deleted') {
                        // Navega a la pantalla principal y limpia el stack y la URL
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/plants', // Ajusta si tu ruta principal es diferente
                          (route) => false,
                          arguments: {'reload': true},
                        );
                      } else if (result != null && result is PlantModel) {
                        setState(() {
                          _plantWithSensorData = PlantWithSensorData(
                            id: result.id,
                            nombre: result.name,
                            emoji: result.emoji,
                            descripcion: result.description,
                            ubicacion: result.location ?? '',
                            deviceId: result.deviceId,
                            humedad: result.currentHumidity,
                            luz: result.currentLight,
                            humidityThresholdMin: result.thresholds.minHumidity,
                            humidityThresholdMax: result.thresholds.maxHumidity,
                          );
                        });
                      }
                    },
                  ),
                  
                  // Add some bottom padding for better scrolling
                  const SizedBox(height: UIConstants.spacingXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showWateringDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Regar ${widget.plant.name}'),
        content: const Text('¿Estás seguro de que quieres regar esta planta ahora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Regando ${widget.plant.name}...'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Regar'),
          ),
        ],
      ),
    );
  }

  void _showAutoModeDialog(bool value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(value ? 'Activar Modo Automático' : 'Desactivar Modo Automático'),
        content: Text(
          value 
            ? '¿Quieres activar el riego automático para ${widget.plant.name}?'
            : '¿Quieres desactivar el riego automático para ${widget.plant.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value 
                      ? 'Modo automático activado para ${widget.plant.name}'
                      : 'Modo automático desactivado para ${widget.plant.name}',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
