import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/network/blynk_api.dart';
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
  final _api = BlynkApi();
  double? _humidity;
  double? _light;
  double? _avgHumidity; // from simple rolling calc
  bool _watering = false;
  late final String _plantId;
  DateTime? _lastUpdate;
  late final ValueNotifier<int> _tick;

  @override
  void initState() {
    super.initState();
    _plantId = widget.plant.id;
    _tick = ValueNotifier<int>(0);
    _fetchLive();
    // light polling every 10s; simple approach without streams
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPolling();
    });
  }

  void _startPolling() async {
    if (!mounted) return;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return false;
      await _fetchLive();
      _tick.value++;
      return mounted;
    });
  }

  Future<void> _fetchLive() async {
    try {
      final live = await _api.getLive(_plantId);
      setState(() {
        _humidity = live.humidityPercent ?? live.humidityRaw;
        _light = live.lightPercent ?? live.lightRaw;
        _lastUpdate = DateTime.now();
        _avgHumidity = _avgHumidity == null
            ? _humidity
            : ((_avgHumidity! * 3 + (_humidity ?? _avgHumidity!)) / 4);
      });
    } catch (_) {
      // ignore for now; UI will show N/A
    }
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
                  Row(
                    children: [
                      Expanded(
                        child: RealTimeMetricCard(
                          icon: Icons.water_drop,
                          title: 'Humedad',
                          value: _humidity == null ? 'N/A' : '${_humidity!.toStringAsFixed(1)}%',
                          statusLabel: _statusLabelFor(_humidity, widget.plant.thresholds.minHumidity, widget.plant.thresholds.maxHumidity),
                          statusColor: _statusColorFor(_humidity, widget.plant.thresholds.minHumidity, widget.plant.thresholds.maxHumidity),
                          rangeText: 'Rango: ${widget.plant.thresholds.minHumidity.toStringAsFixed(0)}-${widget.plant.thresholds.maxHumidity.toStringAsFixed(0)}%',
                          minText: widget.plant.thresholds.minHumidity.toStringAsFixed(1),
                          avgText: (_avgHumidity ?? _humidity ?? 0).toStringAsFixed(1),
                          maxText: widget.plant.thresholds.maxHumidity.toStringAsFixed(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RealTimeMetricCard(
                          icon: Icons.light_mode,
                          title: 'Luz',
                          value: _light == null ? 'N/A' : '${_light!.toStringAsFixed(0)}',
                          statusLabel: _statusLabelFor(_light, widget.plant.thresholds.minLight, widget.plant.thresholds.maxLight),
                          statusColor: _statusColorFor(_light, widget.plant.thresholds.minLight, widget.plant.thresholds.maxLight),
                          showStatusDot: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text('Evolución de Sensores', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SensorEvolutionCard(plantId: widget.plant.id),

                  const SizedBox(height: 24),
                  Text('Controles', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  PlantControlsCard(
                    isOnline: _lastUpdate != null && DateTime.now().difference(_lastUpdate!).inSeconds < 30,
                    initialAutoMode: false, // TODO: bind to plant state
                    onWaterNow: _onWaterNow,
                    onAutoModeChanged: (v) => _onToggleAuto(v),
                    onOpenSettings: () async {
                      final result = await Navigator.of(context).pushNamed(
                        AppRoutes.plantSettings,
                        arguments: widget.plant,
                      );
                      if (!mounted) return;
                      if (result == 'deleted') {
                        Navigator.of(context).pop('deleted');
                      }
                    },
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
              colors: [
                cs.primary.withValues(alpha: 0.10),
                scaffold,
              ],
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

  Future<void> _onWaterNow() async {
    if (_watering) return;
    setState(() => _watering = true);
    try {
      await _api.controlPump(plantId: _plantId, on: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Regando ${widget.plant.name}...'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al regar: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _watering = false);
    }
  }

  void _onToggleAuto(bool value) {
    // TODO: persist auto mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modo automático ${value ? 'activado' : 'desactivado'}'), backgroundColor: AppColors.success),
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
