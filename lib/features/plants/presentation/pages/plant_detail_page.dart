import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/plant.dart';
import '../widgets/real_time_metric_card.dart';
import '../widgets/sensor_evolution_card.dart';
import '../widgets/plant_controls_card.dart';
import '../../../../app/routes/app_routes.dart';

/// Plant Detail Page
/// 
/// Displays detailed information about a specific plant
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
  // TODO: bind to Supabase/Blynk real-time values
  final double _currentHumidity = 65.0;
  final double _avgHumidity = 64.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos en Tiempo Real', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RealTimeMetricCard(
                          icon: Icons.water_drop,
                          title: 'Humedad',
                          value: '${_currentHumidity.toStringAsFixed(1)}%',
                          statusLabel: 'Óptimo',
                          statusColor: AppColors.success,
                          rangeText: 'Rango: ${widget.plant.thresholds.minHumidity.toStringAsFixed(0)}-${widget.plant.thresholds.maxHumidity.toStringAsFixed(0)}%',
                          minText: widget.plant.thresholds.minHumidity.toStringAsFixed(1),
                          avgText: _avgHumidity.toStringAsFixed(1),
                          maxText: widget.plant.thresholds.maxHumidity.toStringAsFixed(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: RealTimeMetricCard(
                          icon: Icons.light_mode,
                          title: 'Luz',
                          value: 'N/A',
                          statusLabel: 'Sin datos',
                          statusColor: AppColors.warning,
                          showStatusDot: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text('Evolución de Sensores', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const SensorEvolutionCard(),

                  const SizedBox(height: 24),
                  Text('Controles', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  PlantControlsCard(
                    isOnline: true, // TODO: derive from device status
                    initialAutoMode: false, // TODO: bind to plant state
                    onWaterNow: _onWaterNow,
                    onAutoModeChanged: (v) => _onToggleAuto(v),
                    onOpenSettings: () => Navigator.of(context).pushNamed(
                      AppRoutes.plantSettings,
                      arguments: widget.plant,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 180,
      backgroundColor: AppColors.backgroundWhite,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 12, end: 16),
        title: Row(
          children: [
            Text(widget.plant.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.plant.name, overflow: TextOverflow.ellipsis, style: AppTextStyles.titleSmall),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryGreenAlpha10, AppColors.backgroundWhite],
            ),
          ),
          child: Center(child: Text(widget.plant.emoji, style: const TextStyle(fontSize: 80))),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: _onlinePill(true), // TODO: bind online/offline
        ),
      ],
    );
  }

  Widget _onlinePill(bool online) {
    final color = online ? AppColors.online : AppColors.offline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(online ? Icons.wifi : Icons.wifi_off, size: 14, color: color),
          const SizedBox(width: 6),
          Text(online ? 'En línea' : 'Desconectada', style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }

  void _onWaterNow() {
    // TODO: trigger device action via Blynk/Supabase functions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Regando ${widget.plant.name}...'), backgroundColor: AppColors.success),
    );
  }

  void _onToggleAuto(bool value) {
    // TODO: persist auto mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modo automático ${value ? 'activado' : 'desactivado'}'), backgroundColor: AppColors.success),
    );
  }
}
