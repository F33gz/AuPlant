import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/models/plant_model.dart';
import '../../../../core/services/plant_service.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Plants Overview Page
/// 
/// The main page that displays all user plants in a list format.
/// Includes an app bar with navigation and add plant functionality.
class PlantsOverviewPage extends StatefulWidget {
  const PlantsOverviewPage({super.key});

  @override
  State<PlantsOverviewPage> createState() => _PlantsOverviewPageState();
}

class _PlantsOverviewPageState extends State<PlantsOverviewPage> with RouteAware {
  final PlantService _plantService = PlantService();
  List<PlantWithSensorData> _plants = [];
  bool _isLoading = true;
  String? _error;
  bool _shouldReloadOnResume = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Suscríbete al RouteObserver para saber cuándo la página vuelve a ser visible
    final routeObserver = ModalRoute.of(context)?.navigator?.widget.observers
      .whereType<RouteObserver<PageRoute>>().firstOrNull;
    routeObserver?.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    // Desuscríbete del RouteObserver
    final routeObserver = ModalRoute.of(context)?.navigator?.widget.observers
      .whereType<RouteObserver<PageRoute>>().firstOrNull;
    routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando vuelves a esta página desde otra
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final plants = await _plantService.getPlantsWithSensorData();
      setState(() {
        _plants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the app bar with title and actions
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      title: Text(
        'AuPlant',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        const SizedBox(width: UIConstants.spacingS),
      ],
    );
  }

  /// Builds the main body content
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.spacingL),
            Text(
              'Error al cargar las plantas',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingL),
            ElevatedButton(
              onPressed: _loadPlants,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: UIConstants.spacingXL),
          _buildQuickStats(),
          const SizedBox(height: UIConstants.spacingXXL),
          _buildPlantsList(),
        ],
      ),
    );
  }

  /// Builds the header section with description
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola! 👋',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.spacingS),
        Text(
          'Monitorea tus plantas y mantén tu jardín saludable',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds quick stats cards
  Widget _buildQuickStats() {
    final totalPlants = _plants.length;
    final onlinePlants = _plants.where((plant) => 
      plant.humedad != null || plant.luz != null).length;
    final plantsWithAlerts = _plants.where((plant) => 
      (plant.humedad != null && (plant.humedad! < plant.humidityThresholdMin || plant.humedad! > plant.humidityThresholdMax))
      // Elimino la condición de luz
    ).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total',
            value: totalPlants.toString(),
            icon: Icons.eco,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            title: 'Conectadas',
            value: '$onlinePlants/$totalPlants',
            icon: Icons.wifi,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            title: 'Alertas',
            value: plantsWithAlerts.toString(),
            icon: Icons.warning,
            color: plantsWithAlerts > 0 ? AppColors.warning : AppColors.success,
          ),
        ),
      ],
    );
  }

  /// Builds a stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the plants list
  Widget _buildPlantsList() {
    if (_plants.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Plantas (${_plants.length})',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.spacingL),
        ...List.generate(_plants.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
            child: PlantCardWithSensorData(plant: _plants[index]),
          );
        }),
      ],
    );
  }

  /// Builds the empty state when no plants are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: UIConstants.spacingL),
          Text(
            'No tienes plantas aún',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Añade tu primera planta para empezar a monitorear tu jardón',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingXL),
          ElevatedButton.icon(
            onPressed: _handleAddPlant,
            icon: const Icon(Icons.add),
            label: const Text('Añadir planta'),
          ),
        ],
      ),
    );
  }

  /// Builds the floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _handleAddPlant,
      backgroundColor: AppColors.primaryGreen,
      child: const Icon(
        Icons.add,
        color: AppColors.textLight,
      ),
    );
  }

  /// Handles add plant button press
  void _handleAddPlant() {
    Navigator.pushNamed(context, AppRoutes.addPlant).then((_) {
      // Reload plants after adding a new one
      _loadPlants();
    });
  }

  /// Handles refresh functionality
  Future<void> _handleRefresh() async {
    await _loadPlants();
  }
}

/// Widget for displaying plant card with sensor data
class PlantCardWithSensorData extends StatelessWidget {
  final PlantWithSensorData plant;

  const PlantCardWithSensorData({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Convert PlantWithSensorData to PlantModel for navigation
        final plantModel = _convertToPlantModel(plant);
        Navigator.of(context).pushNamed(
          AppRoutes.plantDetail,
          arguments: plantModel,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row with plant icon and info
            Row(
              children: [
                // Plant icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      plant.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingL),
                // Plant info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.nombre,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingXS),
                      if (plant.ubicacion.isNotEmpty) ...[
                        Text(
                          plant.ubicacion,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingXS),
                      ],
                      _buildConnectionStatus(),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: UIConstants.iconS,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            
            // Sensor data section
            if (plant.humedad != null) ...[
              const SizedBox(height: UIConstants.spacingM),
              _buildSensorDataSection(),
            ],
            
            // Error section
            if (plant.error != null) ...[
              const SizedBox(height: UIConstants.spacingM),
              _buildErrorSection(),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the connection status indicator
  Widget _buildConnectionStatus() {
    final isOnline = plant.humedad != null || plant.luz != null;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: UIConstants.spacingXS),
        Text(
          isOnline ? 'En línea' : 'Sin conexión',
          style: AppTextStyles.bodySmall.copyWith(
            color: isOnline ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  /// Builds the sensor data section
  Widget _buildSensorDataSection() {
    final plantService = PlantService();
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
      ),
      child: Column(
        children: [
          if (plant.humedad != null)
            FutureBuilder<double?>(
              future: plantService.getRealtimeThreshold(plant.deviceId ?? ''),
              builder: (context, snapshot) {
                final realtimeThreshold = snapshot.data;
                return _buildSensorRow(
                  icon: Icons.water_drop,
                  label: 'Humedad',
                  value: plant.humedad!,
                  unit: '%',
                  min: realtimeThreshold ?? plant.humidityThresholdMin,
                  max: plant.humidityThresholdMax,
                  statistics: plant.humidityStatistics,
                );
              },
            ),
          // Elimino la sección de luz
        ],
      ),
    );
  }

  /// Builds a sensor row with current value and statistics
  Widget _buildSensorRow({
    required IconData icon,
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    SensorStatistics? statistics,
  }) {
    final isWithinThresholds = value >= min && value <= max;
    final Color statusColor = isWithinThresholds ? AppColors.success : AppColors.warning;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: UIConstants.iconS, color: AppColors.textSecondary),
            const SizedBox(width: UIConstants.spacingS),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: AppTextStyles.titleSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Umbral: $min$unit',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (statistics != null)
              Text(
                'Prom: ${statistics.avg?.toStringAsFixed(1) ?? 'N/A'}$unit',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Builds the error section
  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingS),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            size: UIConstants.iconS,
            color: AppColors.error,
          ),
          const SizedBox(width: UIConstants.spacingS),
          Expanded(
            child: Text(
              plant.error!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Convert PlantWithSensorData to PlantModel for navigation
  PlantModel _convertToPlantModel(PlantWithSensorData sensorData) {
    return PlantModel(
      id: sensorData.id,
      name: sensorData.nombre,
      emoji: sensorData.emoji,
      description: sensorData.descripcion,
      currentHumidity: sensorData.humedad ?? 0.0,
      currentLight: sensorData.luz ?? 0.0,
      currentTemperature: null,
      currentSoilMoisture: null,
      isOnline: sensorData.humedad != null || sensorData.luz != null,
      isAutoMode: false,
      lastWatered: DateTime.now().subtract(const Duration(hours: 24)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      thresholds: PlantThresholds(
        minHumidity: sensorData.humidityThresholdMin,
        maxHumidity: sensorData.humidityThresholdMax,
        minLight: 0.0, // Valor dummy, ya que no hay umbral de luz
        maxLight: 0.0, // Valor dummy
      ),
      imageUrls: const [],
      deviceId: sensorData.deviceId,
      location: sensorData.ubicacion,
    );
  }
}
