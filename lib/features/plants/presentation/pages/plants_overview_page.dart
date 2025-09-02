import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../widgets/overview_stat_card.dart';
import '../widgets/plant_overview_tile.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../../../core/network/blynk_api.dart';

/// Plants Overview Page
/// 
/// The main page that displays all user plants in a list format.
/// Includes an app bar with navigation and add plant functionality.
class PlantsOverviewPage extends StatefulWidget {
  const PlantsOverviewPage({super.key});

  @override
  State<PlantsOverviewPage> createState() => _PlantsOverviewPageState();
}

class _PlantsOverviewPageState extends State<PlantsOverviewPage> {
  final GetPlantsUseCase _getPlantsUseCase = GetIt.instance<GetPlantsUseCase>();
  final _blynkApi = BlynkApi();
  
  List<Plant> _plants = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, double> _liveHumidityByPlant = {};
  int? _connectedCount;
  int? _alertsCount;
  final Map<String, bool> _onlineByPlant = {};

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getPlantsUseCase.call();
    
    switch (result) {
      case Success<List<Plant>> success:
        setState(() {
          _plants = success.data;
          _isLoading = false;
        });
  // Kick off connected count and live humidity loads (best-effort)
  _loadConnectedCount();
        _loadLiveForPlants();
        break;
      case Error<List<Plant>> error:
        setState(() {
          _error = error.failure.message;
          _isLoading = false;
        });
        break;
    }
  }

  Future<void> _loadLiveForPlants() async {
    // Fetch live humidity for each plant; best-effort, no blocking UI
    for (final p in _plants) {
      try {
        final live = await _blynkApi.getLive(p.id);
        final value = live.humidityPercent ?? live.humidityRaw;
        if (!mounted) return;
        setState(() {
          if (value != null) {
            _liveHumidityByPlant[p.id] = value;
          }
          if (live.online != null) {
            _onlineByPlant[p.id] = live.online!;
            _connectedCount = _onlineByPlant.values.where((v) => v == true).length;
          }
        });
      } catch (_) {
        // ignore per-plant failures
      }
    }
  }

  Future<void> _loadConnectedCount() async {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      if (session == null) {
        // Not logged in; cannot get protected function
        return;
      }
      final res = await client.functions.invoke(
        'get_plant_data',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      final data = (res.data as Map?)?.cast<String, dynamic>();
      final plantas = (data?['plantas'] as List?) ?? const [];
      int count = 0;
      int alerts = 0;
      final Map<String, bool> onlineById = {};
      for (final e in plantas) {
        if (e is Map) {
          final id = e['id']?.toString();
          final isOnline = e['online'] == true;
          if (id != null) onlineById[id] = isOnline;
          if (isOnline) count++;

          final h = e['humedad'];
          final minH = e['min_humedad'];
          final humidity = h is num ? h.toDouble() : (h is String ? double.tryParse(h) : null);
          final minHum = minH is num ? minH.toDouble() : (minH is String ? double.tryParse(minH) : null);
          if (humidity != null && minHum != null && humidity < minHum) {
            alerts++;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _connectedCount = count;
        _alertsCount = alerts;
        _onlineByPlant
          ..clear()
          ..addAll(onlineById);
      });
    } catch (_) {
      // ignore errors; leave count null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  appBar: _buildAppBar(),
  body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the app bar with title and actions
  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
  backgroundColor: theme.scaffoldBackgroundColor,
  elevation: 0,
      title: Text(
        'AuPlant',
        style: AppTextStyles.titleLarge.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.dividerColor,
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
  final cs = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: cs.error,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: _loadPlants,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_plants.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPlants,
      color: cs.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(),
              const SizedBox(height: UIConstants.spacingL),
              _buildMyPlantsSection(),
              const SizedBox(height: UIConstants.spacingM),
              _buildPlantList(),
              const SizedBox(height: UIConstants.spacingXXXL),
            ],
          ),
        ),
      ),
    );
  }

  // Build plant list with spacing between tiles for better UX
  Widget _buildPlantList() {
    return Column(
      children: List.generate(_plants.length, (index) {
        final p = _plants[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _plants.length - 1 ? 0 : UIConstants.spacingL,
          ),
          child: PlantOverviewTile(
            plant: p,
            currentHumidity: _liveHumidityByPlant[p.id],
            online: _onlineByPlant[p.id],
            onTap: () => _navigateToPlantDetail(p),
          ),
        );
      }),
    );
  }

  Widget _buildStatsRow() {
  final connected = _connectedCount ?? 0;
  final alerts = _alertsCount ?? 0;
    return Row(
      children: [
        Expanded(
          child: OverviewStatCard(
            icon: Icons.eco,
            title: 'Total',
            value: _plants.length.toString(),
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: OverviewStatCard(
            icon: Icons.wifi,
            title: 'Conectadas',
            value: '$connected/${_plants.length}',
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: OverviewStatCard(
            icon: Icons.warning_amber_outlined,
            title: 'Alertas',
            value: alerts.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPlantsSection() {
    return Text('Mis Plantas (${_plants.length})', style: AppTextStyles.titleLarge);
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.eco,
      title: 'No tienes plantas aún',
      subtitle: 'Añade tu primera planta para empezar a monitorear tu jardín',
      actionText: 'Añadir planta',
      onActionPressed: _handleAddPlant,
    );
  }

  /// Builds the floating action button
  Widget _buildFloatingActionButton() {
    if (_plants.isEmpty) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: _navigateToAddPlant,
      backgroundColor: AppColors.primaryGreen,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _navigateToPlantDetail(Plant plant) {
    Navigator.pushNamed(
      context,
      '/plant-detail',
      arguments: plant,
    ).then((result) {
      if (result == 'deleted') {
        _loadPlants();
      }
    });
  }

  void _navigateToAddPlant() {
    Navigator.pushNamed(context, '/add-plant').then((_) {
      _loadPlants(); // Reload plants after adding
    });
  }

  void _handleAddPlant() {
    Navigator.pushNamed(context, '/add-plant').then((_) {
      _loadPlants();
    });
  }
}
