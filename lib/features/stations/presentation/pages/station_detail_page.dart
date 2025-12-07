import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/station.dart';
import '../widgets/real_time_metric_card.dart';
import '../widgets/sensor_evolution_card.dart';
import '../../../../app/routes/app_routes.dart';

/// Station Detail Page
/// 
/// Displays detailed information about a specific greenhouse station
class StationDetailPage extends StatefulWidget {
  final Station station;

  const StationDetailPage({
    super.key,
    required this.station,
  });

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  // TODO: Replace with actual API data
  double? _soilHumidity;
  double? _ambientHumidity;
  double? _temperature;
  DateTime? _lastUpdate;
  bool? _online;

  @override
  void initState() {
    super.initState();
    _fetchLive();
    _startPolling();
  }

  void _startPolling() async {
    if (!mounted) return;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return false;
      await _fetchLive();
      return mounted;
    });
  }

  Future<void> _fetchLive() async {
    // TODO: Implement actual API call to get live data
    // For now, simulate with placeholder values
    setState(() {
      _soilHumidity = 62.5;
      _ambientHumidity = 55.0;
      _temperature = 24.3;
      _lastUpdate = DateTime.now();
      _online = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos en Tiempo Real', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // First row: Soil Humidity and Ambient Humidity
                  Row(
                    children: [
                      Expanded(
                        child: RealTimeMetricCard(
                          icon: Icons.water_drop,
                          title: 'Humedad Suelo',
                          value: _soilHumidity == null ? 'N/A' : '${_soilHumidity!.toStringAsFixed(1)}%',
                          statusLabel: _statusLabelFor(_soilHumidity, widget.station.thresholds.minSoilHumidity, widget.station.thresholds.maxSoilHumidity),
                          statusColor: _statusColorFor(_soilHumidity, widget.station.thresholds.minSoilHumidity, widget.station.thresholds.maxSoilHumidity),
                          rangeText: 'Rango: ${widget.station.thresholds.minSoilHumidity.toStringAsFixed(0)}-${widget.station.thresholds.maxSoilHumidity.toStringAsFixed(0)}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RealTimeMetricCard(
                          icon: Icons.cloud,
                          title: 'Humedad Ambiente',
                          value: _ambientHumidity == null ? 'N/A' : '${_ambientHumidity!.toStringAsFixed(1)}%',
                          statusLabel: _statusLabelFor(_ambientHumidity, widget.station.thresholds.minAmbientHumidity, widget.station.thresholds.maxAmbientHumidity),
                          statusColor: _statusColorFor(_ambientHumidity, widget.station.thresholds.minAmbientHumidity, widget.station.thresholds.maxAmbientHumidity),
                          rangeText: 'Rango: ${widget.station.thresholds.minAmbientHumidity.toStringAsFixed(0)}-${widget.station.thresholds.maxAmbientHumidity.toStringAsFixed(0)}%',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Second row: Temperature (full width)
                  RealTimeMetricCard(
                    icon: Icons.thermostat,
                    title: 'Temperatura',
                    value: _temperature == null ? 'N/A' : '${_temperature!.toStringAsFixed(1)}°C',
                    statusLabel: _statusLabelFor(_temperature, widget.station.thresholds.minTemperature, widget.station.thresholds.maxTemperature),
                    statusColor: _statusColorFor(_temperature, widget.station.thresholds.minTemperature, widget.station.thresholds.maxTemperature),
                    rangeText: 'Rango: ${widget.station.thresholds.minTemperature.toStringAsFixed(0)}-${widget.station.thresholds.maxTemperature.toStringAsFixed(0)}°C',
                  ),

                  const SizedBox(height: 24),
                  Text('Evolución de Sensores', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SensorEvolutionCard(stationId: widget.station.id),

                  const SizedBox(height: 24),
                  _buildSettingsButton(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed(
            AppRoutes.stationSettings,
            arguments: widget.station,
          );
          if (!mounted) return;
          if (result == 'deleted') {
            Navigator.of(context).pop('deleted');
          }
        },
        icon: Icon(Icons.settings, color: cs.primary),
        label: Text('Configuración', style: TextStyle(color: cs.primary)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: cs.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scaffold = Theme.of(context).scaffoldBackgroundColor;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 180,
      backgroundColor: cs.surface,
      iconTheme: IconThemeData(color: cs.onSurface),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 12, end: 16),
        title: Row(
          children: [
            Text(widget.station.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.station.name, overflow: TextOverflow.ellipsis, style: AppTextStyles.titleSmall),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.primary.withValues(alpha: 0.10),
                scaffold,
              ],
            ),
          ),
          child: Center(child: Text(widget.station.emoji, style: const TextStyle(fontSize: 80))),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: _onlinePill(_online ?? false),
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

  String _statusLabelFor(double? v, double min, double max) {
    if (v == null) return 'Sin datos';
    if (v < min) return 'Bajo';
    if (v > max) return 'Alto';
    return 'Óptimo';
  }

  Color _statusColorFor(double? v, double min, double max) {
    if (v == null) return AppColors.warning;
    if (v < min) return AppColors.info;
    if (v > max) return AppColors.error;
    return AppColors.success;
  }
}
