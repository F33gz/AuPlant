import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../widgets/overview_stat_card.dart';
import '../widgets/station_overview_tile.dart';
import '../../domain/entities/station.dart';
import '../../domain/usecases/get_stations_usecase.dart';

/// Stations Overview Page
/// 
/// The main page that displays all user greenhouse stations in a list format.
class StationsOverviewPage extends StatefulWidget {
  const StationsOverviewPage({super.key});

  @override
  State<StationsOverviewPage> createState() => _StationsOverviewPageState();
}

class _StationsOverviewPageState extends State<StationsOverviewPage> {
  final GetStationsUseCase _getStationsUseCase = GetIt.instance<GetStationsUseCase>();
  
  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;
  
  // TODO: Wire to real sensor data from API
  final Map<String, double> _liveSoilHumidityByStation = {};
  final Map<String, double> _liveAmbientHumidityByStation = {};
  final Map<String, double> _liveTemperatureByStation = {};
  final Map<String, bool> _onlineByStation = {};
  int? _connectedCount;
  int? _alertsCount;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getStationsUseCase.call();
    
    switch (result) {
      case Success<List<Station>> success:
        setState(() {
          _stations = success.data;
          _isLoading = false;
        });
        _loadLiveData();
        break;
      case Error<List<Station>> error:
        setState(() {
          _error = error.failure.message;
          _isLoading = false;
        });
        break;
    }
  }

  Future<void> _loadLiveData() async {
    // TODO: Implement real-time data fetching from API
    // For now, simulate with placeholder values
    for (final station in _stations) {
      setState(() {
        // Placeholder values - replace with actual API calls
        _liveSoilHumidityByStation[station.id] = 65.0;
        _liveAmbientHumidityByStation[station.id] = 55.0;
        _liveTemperatureByStation[station.id] = 24.5;
        _onlineByStation[station.id] = true;
      });
    }
    
    // Calculate connected count and alerts
    _connectedCount = _onlineByStation.values.where((v) => v).length;
    _alertsCount = 0; // TODO: Calculate based on thresholds
    
    if (mounted) {
      setState(() {});
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
    );
  }

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
              onPressed: _loadStations,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_stations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadStations,
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
              _buildMyStationsSection(),
              const SizedBox(height: UIConstants.spacingM),
              _buildStationList(),
              const SizedBox(height: UIConstants.spacingXXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationList() {
    return Column(
      children: List.generate(_stations.length, (index) {
        final station = _stations[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _stations.length - 1 ? 0 : UIConstants.spacingL,
          ),
          child: StationOverviewTile(
            station: station,
            soilHumidity: _liveSoilHumidityByStation[station.id],
            ambientHumidity: _liveAmbientHumidityByStation[station.id],
            temperature: _liveTemperatureByStation[station.id],
            online: _onlineByStation[station.id],
            onTap: () => _navigateToStationDetail(station),
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
            icon: Icons.sensors,
            title: 'Total',
            value: _stations.length.toString(),
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: OverviewStatCard(
            icon: Icons.wifi,
            title: 'Conectadas',
            value: '$connected/${_stations.length}',
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

  Widget _buildMyStationsSection() {
    return Text('Mis Estaciones (${_stations.length})', style: AppTextStyles.titleLarge);
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.sensors,
      title: 'No tienes estaciones aún',
      subtitle: 'Añade tu primera estación para empezar a monitorear tu invernadero',
      actionText: 'Añadir estación',
      onActionPressed: _handleAddStation,
    );
  }

  Widget _buildFloatingActionButton() {
    if (_stations.isEmpty) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: _navigateToAddStation,
      backgroundColor: AppColors.primaryGreen,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _navigateToStationDetail(Station station) {
    Navigator.pushNamed(
      context,
      '/station-detail',
      arguments: station,
    ).then((result) {
      if (result == 'deleted') {
        _loadStations();
      }
    });
  }

  void _navigateToAddStation() {
    Navigator.pushNamed(context, '/add-station').then((_) {
      _loadStations();
    });
  }

  void _handleAddStation() {
    Navigator.pushNamed(context, '/add-station').then((_) {
      _loadStations();
    });
  }
}
