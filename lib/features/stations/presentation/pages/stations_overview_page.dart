import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/network/thingsboard_websocket_client.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../widgets/overview_stat_card.dart';
import '../widgets/station_overview_tile.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/usecases/get_stations_usecase.dart';
import '../../domain/usecases/get_sensor_data_usecase.dart';

/// Stations Overview Page
/// 
/// The main page that displays all user greenhouse stations in a list format.
/// Uses WebSocket for real-time telemetry updates across all stations.
class StationsOverviewPage extends StatefulWidget {
  const StationsOverviewPage({super.key});

  @override
  State<StationsOverviewPage> createState() => _StationsOverviewPageState();
}

class _StationsOverviewPageState extends State<StationsOverviewPage> {
  final GetStationsUseCase _getStationsUseCase = GetIt.instance<GetStationsUseCase>();
  final GetSensorDataUseCase _getSensorDataUseCase = GetIt.instance<GetSensorDataUseCase>();
  final ThingsBoardWebSocketClient _wsClient = GetIt.instance<ThingsBoardWebSocketClient>();
  
  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;
  bool _wsConnected = false;
  
  // Live sensor data from ThingsBoard WebSocket
  final Map<String, double> _liveSoilHumidityByStation = {};
  final Map<String, double> _liveAmbientHumidityByStation = {};
  final Map<String, double> _liveTemperatureByStation = {};
  final Map<String, bool> _onlineByStation = {};
  int? _connectedCount;
  int? _alertsCount;
  
  // WebSocket subscriptions
  StreamSubscription<TelemetryUpdate>? _wsSubscription;
  final Map<String, int> _subscriptionCmdIds = {};

  @override
  void initState() {
    super.initState();
    _loadStations();
  }
  
  @override
  void dispose() {
    _cleanupWebSocket();
    super.dispose();
  }
  
  void _cleanupWebSocket() {
    // Unsubscribe from all devices
    for (final cmdId in _subscriptionCmdIds.values) {
      _wsClient.unsubscribeFromDevice(cmdId);
    }
    _subscriptionCmdIds.clear();
    _wsSubscription?.cancel();
    _wsSubscription = null;
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
        // First load initial data via REST, then connect WebSocket
        await _loadInitialData();
        await _connectWebSocket();
        break;
      case Error<List<Station>> error:
        setState(() {
          _error = error.failure.message;
          _isLoading = false;
        });
        break;
    }
  }

  /// Load initial telemetry data via REST API
  Future<void> _loadInitialData() async {
    for (final station in _stations) {
      final result = await _getSensorDataUseCase.call(station.id);
      
      if (result is Success<SensorData>) {
        final sensorData = result.data;
        if (mounted) {
          setState(() {
            if (sensorData.soilHumidity != null) {
              _liveSoilHumidityByStation[station.id] = sensorData.soilHumidity!;
            }
            if (sensorData.ambientHumidity != null) {
              _liveAmbientHumidityByStation[station.id] = sensorData.ambientHumidity!;
            }
            if (sensorData.temperature != null) {
              _liveTemperatureByStation[station.id] = sensorData.temperature!;
            }
            _onlineByStation[station.id] = sensorData.isOnline;
          });
        }
      }
    }
    _updateStats();
  }

  /// Connect WebSocket and subscribe to all stations for real-time updates
  Future<void> _connectWebSocket() async {
    if (_stations.isEmpty) return;
    
    try {
      // Cleanup any existing subscriptions
      _cleanupWebSocket();
      
      final connected = await _wsClient.connect();
      if (!connected || !mounted) return;
      
      // Subscribe to all stations at once
      final deviceIds = _stations.map((s) => s.id).toList();
      final subscriptions = _wsClient.subscribeToDevices(
        deviceIds,
        keys: ['soil', 'hum', 'temp'],
      );
      
      _subscriptionCmdIds.addAll(subscriptions);
      
      // Listen for telemetry updates
      _wsSubscription = _wsClient.telemetryStream.listen(
        _handleTelemetryUpdate,
        onError: (e) {
          // On error, mark as disconnected but keep existing data
          if (mounted) {
            setState(() {
              _wsConnected = false;
            });
          }
        },
      );
      
      if (mounted) {
        setState(() {
          _wsConnected = true;
        });
      }
    } catch (e) {
      // WebSocket failed, data will be stale but still visible
      if (mounted) {
        setState(() {
          _wsConnected = false;
        });
      }
    }
  }

  /// Handle incoming telemetry updates from WebSocket
  void _handleTelemetryUpdate(TelemetryUpdate update) {
    if (!mounted) return;
    
    final stationId = update.deviceId;
    
    setState(() {
      if (update.soilHumidity != null) {
        _liveSoilHumidityByStation[stationId] = update.soilHumidity!;
      }
      if (update.ambientHumidity != null) {
        _liveAmbientHumidityByStation[stationId] = update.ambientHumidity!;
      }
      if (update.temperature != null) {
        _liveTemperatureByStation[stationId] = update.temperature!;
      }
      _onlineByStation[stationId] = true;
    });
    
    _updateStats();
  }

  /// Update connected count and alerts
  void _updateStats() {
    _connectedCount = _onlineByStation.values.where((v) => v).length;
    _alertsCount = _calculateAlerts();
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Calculate alerts based on station thresholds
  int _calculateAlerts() {
    int alerts = 0;
    for (final station in _stations) {
      final soilHum = _liveSoilHumidityByStation[station.id];
      final ambHum = _liveAmbientHumidityByStation[station.id];
      final temp = _liveTemperatureByStation[station.id];
      
      if (soilHum != null) {
        if (soilHum < station.thresholds.minSoilHumidity ||
            soilHum > station.thresholds.maxSoilHumidity) {
          alerts++;
        }
      }
      if (ambHum != null) {
        if (ambHum < station.thresholds.minAmbientHumidity ||
            ambHum > station.thresholds.maxAmbientHumidity) {
          alerts++;
        }
      }
      if (temp != null) {
        if (temp < station.thresholds.minTemperature ||
            temp > station.thresholds.maxTemperature) {
          alerts++;
        }
      }
    }
    return alerts;
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
