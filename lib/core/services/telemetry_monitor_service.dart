import 'dart:async';
import 'package:get_it/get_it.dart';
import '../network/thingsboard_websocket_client.dart';
import '../utils/result.dart';
import 'local_thresholds_storage.dart';
import 'local_station_settings_storage.dart';
import '../../features/stations/domain/entities/station.dart';
import '../../features/stations/domain/usecases/get_stations_usecase.dart';
import '../../shared/utils/notifications_service.dart';

/// Servicio de monitoreo de telemetría en background
/// 
/// Mantiene una conexión WebSocket activa para recibir datos en tiempo real
/// y dispara notificaciones cuando los valores cruzan los umbrales configurados.
class TelemetryMonitorService {
  TelemetryMonitorService._();
  static final TelemetryMonitorService instance = TelemetryMonitorService._();

  ThingsBoardWebSocketClient? _wsClient;
  StreamSubscription<TelemetryUpdate>? _telemetrySubscription;
  bool _isRunning = false;
  
  // Cache de estaciones para acceder a thresholds
  final Map<String, Station> _stationsCache = {};
  // Map de deviceId -> stationId para lookup rápido
  final Map<String, String> _deviceToStationMap = {};
  // Subscripciones activas por deviceId
  final Map<String, int> _activeSubscriptions = {};

  /// Indica si el servicio está corriendo
  bool get isRunning => _isRunning;

  /// Inicia el servicio de monitoreo
  /// 
  /// Conecta al WebSocket y comienza a escuchar telemetría de todas las estaciones
  Future<bool> start() async {
    if (_isRunning) {
      return true;
    }

    try {
      // Inicializar servicio de notificaciones
      await NotificationsService.instance.initialize();

      // Obtener cliente WebSocket desde DI
      final sl = GetIt.instance;
      if (!sl.isRegistered<ThingsBoardWebSocketClient>()) {
        return false;
      }
      _wsClient = sl<ThingsBoardWebSocketClient>();

      // Conectar WebSocket
      final connected = await _wsClient!.connect();
      if (!connected) {
        return false;
      }

      // Escuchar actualizaciones de telemetría
      _telemetrySubscription = _wsClient!.telemetryStream.listen(
        _handleTelemetryUpdate,
        onError: _handleError,
      );

      // Cargar estaciones y suscribirse a sus dispositivos
      await _loadAndSubscribeStations();

      _isRunning = true;
      return true;
    } catch (e) {
      _isRunning = false;
      return false;
    }
  }

  /// Detiene el servicio de monitoreo
  Future<void> stop() async {
    _isRunning = false;
    
    await _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    
    // Cancelar todas las subscripciones
    for (final cmdId in _activeSubscriptions.values) {
      _wsClient?.unsubscribeFromDevice(cmdId);
    }
    _activeSubscriptions.clear();
    
    await _wsClient?.disconnect();
    _wsClient = null;
    
    _stationsCache.clear();
    _deviceToStationMap.clear();
  }

  /// Recarga las estaciones y actualiza subscripciones
  /// 
  /// Llamar este método cuando se agregan/eliminan estaciones
  Future<void> refreshStations() async {
    if (!_isRunning || _wsClient == null) return;
    
    // Cancelar subscripciones anteriores
    for (final cmdId in _activeSubscriptions.values) {
      _wsClient!.unsubscribeFromDevice(cmdId);
    }
    _activeSubscriptions.clear();
    _stationsCache.clear();
    _deviceToStationMap.clear();
    
    await _loadAndSubscribeStations();
  }

  /// Actualiza los umbrales de una estación específica
  void updateStationThresholds(String stationId, StationThresholds thresholds) {
    final station = _stationsCache[stationId];
    if (station != null) {
      _stationsCache[stationId] = station.copyWith(thresholds: thresholds);
    }
  }

  /// Carga las estaciones del usuario y se suscribe a sus dispositivos
  /// Usa los umbrales y la info básica guardados localmente si existen
  Future<void> _loadAndSubscribeStations() async {
    try {
      final sl = GetIt.instance;
      if (!sl.isRegistered<GetStationsUseCase>()) return;
      
      final getStationsUseCase = sl<GetStationsUseCase>();
      final result = await getStationsUseCase.call();
      
      result.when(
        failure: (_) {
          // No hacer nada en caso de error
        },
        success: (stations) async {
          for (final station in stations) {
            if (station.deviceId != null && station.deviceId!.isNotEmpty) {
              // Cargar umbrales locales si existen
              final localThresholds = await LocalThresholdsStorage.instance
                  .getThresholds(station.id);
              
              // Cargar info básica local si existe (nombre, emoji)
              final localSettings = await LocalStationSettingsStorage.instance
                  .getSettings(station.id);
              
              // Construir estación con datos locales
              var stationWithLocalData = station;
              
              if (localThresholds != null) {
                stationWithLocalData = stationWithLocalData.copyWith(thresholds: localThresholds);
              }
              
              if (localSettings != null) {
                stationWithLocalData = stationWithLocalData.copyWith(
                  name: localSettings.name,
                  emoji: localSettings.emoji,
                  location: localSettings.location,
                );
              }
              
              _stationsCache[station.id] = stationWithLocalData;
              _deviceToStationMap[station.deviceId!] = station.id;
              
              // Suscribirse a telemetría del dispositivo
              final cmdId = _wsClient!.subscribeToDevice(
                station.deviceId!,
                keys: ['soil', 'hum', 'temp'],
              );
              _activeSubscriptions[station.deviceId!] = cmdId;
            }
          }
        },
      );
    } catch (e) {
      // Ignorar errores de carga
    }
  }

  /// Maneja actualizaciones de telemetría del WebSocket
  void _handleTelemetryUpdate(TelemetryUpdate update) {
    // Buscar la estación correspondiente al dispositivo
    final stationId = _deviceToStationMap[update.deviceId];
    if (stationId == null) return;
    
    final station = _stationsCache[stationId];
    if (station == null) return;
    
    final thresholds = station.thresholds;
    
    // Verificar temperatura
    if (update.temperature != null) {
      _checkTemperatureThreshold(
        stationId: station.id,
        stationName: '${station.emoji} ${station.name}',
        temperature: update.temperature!,
        thresholds: thresholds,
      );
    }
    
    // Verificar humedad del suelo
    if (update.soilHumidity != null) {
      _checkSoilHumidityThreshold(
        stationId: station.id,
        stationName: '${station.emoji} ${station.name}',
        humidity: update.soilHumidity!,
        thresholds: thresholds,
      );
    }
    
    // Verificar humedad ambiente
    if (update.ambientHumidity != null) {
      _checkAmbientHumidityThreshold(
        stationId: station.id,
        stationName: '${station.emoji} ${station.name}',
        humidity: update.ambientHumidity!,
        thresholds: thresholds,
      );
    }
  }

  /// Verifica umbrales de temperatura y dispara notificación si es necesario
  void _checkTemperatureThreshold({
    required String stationId,
    required String stationName,
    required double temperature,
    required StationThresholds thresholds,
  }) {
    if (temperature < thresholds.minTemperature) {
      NotificationsService.instance.showThresholdAlert(
        stationId: stationId,
        stationName: stationName,
        alertType: ThresholdAlertType.temperatureLow,
        currentValue: temperature,
        thresholdValue: thresholds.minTemperature,
      );
    } else if (temperature > thresholds.maxTemperature) {
      NotificationsService.instance.showThresholdAlert(
        stationId: stationId,
        stationName: stationName,
        alertType: ThresholdAlertType.temperatureHigh,
        currentValue: temperature,
        thresholdValue: thresholds.maxTemperature,
      );
    }
  }

  /// Verifica umbrales de humedad del suelo y dispara notificación si es necesario
  void _checkSoilHumidityThreshold({
    required String stationId,
    required String stationName,
    required double humidity,
    required StationThresholds thresholds,
  }) {
    if (humidity < thresholds.minSoilHumidity) {
      NotificationsService.instance.showThresholdAlert(
        stationId: stationId,
        stationName: stationName,
        alertType: ThresholdAlertType.soilHumidityLow,
        currentValue: humidity,
        thresholdValue: thresholds.minSoilHumidity,
      );
    } else if (humidity > thresholds.maxSoilHumidity) {
      NotificationsService.instance.showThresholdAlert(
        stationId: stationId,
        stationName: stationName,
        alertType: ThresholdAlertType.soilHumidityHigh,
        currentValue: humidity,
        thresholdValue: thresholds.maxSoilHumidity,
      );
    }
  }

  /// Verifica umbrales de humedad ambiente y dispara notificación si es necesario
  void _checkAmbientHumidityThreshold({
    required String stationId,
    required String stationName,
    required double humidity,
    required StationThresholds thresholds,
  }) {
    if (humidity < thresholds.minAmbientHumidity) {
      NotificationsService.instance.showThresholdAlert(
        stationId: stationId,
        stationName: stationName,
        alertType: ThresholdAlertType.ambientHumidityLow,
        currentValue: humidity,
        thresholdValue: thresholds.minAmbientHumidity,
      );
    } else if (humidity > thresholds.maxAmbientHumidity) {
      NotificationsService.instance.showThresholdAlert(
        stationId: stationId,
        stationName: stationName,
        alertType: ThresholdAlertType.ambientHumidityHigh,
        currentValue: humidity,
        thresholdValue: thresholds.maxAmbientHumidity,
      );
    }
  }

  /// Maneja errores del WebSocket
  void _handleError(dynamic error) {
    // Intentar reconectar después de un tiempo
    Future.delayed(const Duration(seconds: 10), () {
      if (_isRunning) {
        _reconnect();
      }
    });
  }

  /// Intenta reconectar al WebSocket
  Future<void> _reconnect() async {
    if (!_isRunning) return;
    
    try {
      await _wsClient?.disconnect();
      final connected = await _wsClient?.connect() ?? false;
      
      if (connected) {
        // Re-suscribirse a telemetría
        _telemetrySubscription?.cancel();
        _telemetrySubscription = _wsClient!.telemetryStream.listen(
          _handleTelemetryUpdate,
          onError: _handleError,
        );
        
        // Recargar estaciones
        await _loadAndSubscribeStations();
      } else {
        // Intentar de nuevo más tarde
        Future.delayed(const Duration(seconds: 30), () {
          if (_isRunning) {
            _reconnect();
          }
        });
      }
    } catch (e) {
      // Ignorar errores de reconexión
    }
  }
}
