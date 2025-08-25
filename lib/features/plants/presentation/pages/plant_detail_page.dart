import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/usecases/get_sensor_data_usecase.dart';

/// Plant Detail Page - Refactored with Clean Architecture
/// 
/// Much shorter and focused. Uses new entities and use cases.
class PlantDetailPage extends StatefulWidget {
  final Plant plant;

  const PlantDetailPage({
    super.key,
    required this.plant,
  });

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final GetSensorDataUseCase _getSensorDataUseCase = GetIt.instance<GetSensorDataUseCase>();
  
  SensorData? _sensorData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildWaterButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            widget.plant.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: UIConstants.spacingS),
          Expanded(
            child: Text(
              widget.plant.name,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: AppColors.primaryGreen),
          onPressed: () => _navigateToSettings(),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.primaryGreen),
          onPressed: _loadSensorData,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadSensorData,
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(UIConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlantInfo(),
            const SizedBox(height: UIConstants.spacingL),
            _buildSensorDataSection(),
            const SizedBox(height: UIConstants.spacingL),
            _buildHealthStatus(),
            const SizedBox(height: UIConstants.spacingL),
            _buildThresholds(),
            const SizedBox(height: UIConstants.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantInfo() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: UIConstants.spacingS),
              Text(
                widget.plant.location ?? 'Sin ubicación',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (widget.plant.description?.isNotEmpty == true) ...[
            const SizedBox(height: UIConstants.spacingM),
            Text(
              widget.plant.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (widget.plant.deviceId != null) ...[
            const SizedBox(height: UIConstants.spacingM),
            Row(
              children: [
                Icon(Icons.sensors, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: UIConstants.spacingS),
                Text(
                  'Device: ${widget.plant.deviceId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorDataSection() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(UIConstants.paddingXL),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(UIConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: _loadSensorData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_sensorData == null) {
      return _buildNoDataCard();
    }

    return Column(
      children: [
        _buildSensorCards(),
        const SizedBox(height: UIConstants.spacingL),
        _buildLastUpdated(),
      ],
    );
  }

  Widget _buildSensorCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSensorCard(
            title: 'Humedad',
            value: '${_sensorData!.humidity?.toStringAsFixed(1) ?? '--'}%',
            icon: Icons.water_drop,
            color: Colors.blue,
            isGood: _isHumidityGood(),
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: _buildSensorCard(
            title: 'Luz',
            value: '${_sensorData!.light?.toStringAsFixed(0) ?? '--'} lux',
            icon: Icons.wb_sunny,
            color: Colors.orange,
            isGood: _isLightGood(),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isGood,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(
          color: isGood ? color.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isGood ? color : Colors.red,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatus() {
    final healthStatus = _calculateHealthStatus();
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: healthStatus.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(
          color: healthStatus.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            healthStatus.icon,
            color: healthStatus.color,
            size: 32,
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Salud',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  healthStatus.displayName,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: healthStatus.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholds() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Umbrales',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildThresholdRow(
            'Humedad',
            '${widget.plant.thresholds.minHumidity.toStringAsFixed(0)}% - ${widget.plant.thresholds.maxHumidity.toStringAsFixed(0)}%',
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: UIConstants.spacingS),
          _buildThresholdRow(
            'Luz',
            '${widget.plant.thresholds.minLight.toStringAsFixed(0)} - ${widget.plant.thresholds.maxLight.toStringAsFixed(0)} lux',
            Icons.wb_sunny,
            Colors.orange,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              Icon(
                Icons.auto_mode, // Default to auto mode icon
                color: AppColors.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: UIConstants.spacingS),
              Text(
                'Modo Manual', // Default since Plant entity doesn't have isAutoMode
                style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildThresholdRow(String label, String range, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: UIConstants.spacingS),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium,
        ),
        Text(
          range,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Text(
            'Sin datos de sensores',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Verifica la conexión del dispositivo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    if (_sensorData?.timestamp == null) return const SizedBox.shrink();
    
    return Text(
      'Última actualización: ${_formatTimestamp(_sensorData!.timestamp)}',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildWaterButton() {
    return FloatingActionButton.extended(
      onPressed: _waterPlant,
      backgroundColor: AppColors.primaryGreen,
      icon: const Icon(Icons.water_drop, color: Colors.white),
      label: const Text(
        'Regar',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  bool _isHumidityGood() {
    if (_sensorData?.humidity == null) return false;
    final humidity = _sensorData!.humidity!;
    return humidity >= widget.plant.thresholds.minHumidity && 
           humidity <= widget.plant.thresholds.maxHumidity;
  }

  bool _isLightGood() {
    if (_sensorData?.light == null) return false;
    final light = _sensorData!.light!;
    return light >= widget.plant.thresholds.minLight && 
           light <= widget.plant.thresholds.maxLight;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  Future<void> _loadSensorData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getSensorDataUseCase.call(widget.plant.id);
    
    switch (result) {
      case Success<SensorData> success:
        setState(() {
          _sensorData = success.data;
          _isLoading = false;
        });
        break;
      case Error<SensorData> error:
        setState(() {
          _error = error.failure.message;
          _isLoading = false;
        });
        break;
    }
  }

  PlantHealthStatus _calculateHealthStatus() {
    if (_sensorData == null || !_sensorData!.isOnline) {
      return PlantHealthStatus.offline;
    }
    
    final humidity = _sensorData!.humidity;
    final light = _sensorData!.light;
    
    if (humidity == null || light == null) {
      return PlantHealthStatus.offline;
    }
    
    // Simple health calculation based on thresholds
    final minHumidity = widget.plant.thresholds.minHumidity;
    final minLight = widget.plant.thresholds.minLight;
    
    if (humidity >= minHumidity && light >= minLight) {
      return PlantHealthStatus.healthy;
    } else if (humidity < minHumidity) {
      return PlantHealthStatus.needsWater;
    } else if (light < minLight) {
      return PlantHealthStatus.needsLight;
    } else {
      return PlantHealthStatus.warning;
    }
  }

  void _waterPlant() {
    // TODO: Implement watering using WaterPlantUseCase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Regando planta...'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.pushNamed(
      context,
      '/plant-settings',
      arguments: widget.plant,
    ).then((_) {
      _loadSensorData(); // Reload data after settings change
    });
  }
}
