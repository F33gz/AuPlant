import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_token_storage.dart';

/// ThingsBoard WebSocket Client for real-time telemetry
/// 
/// Provides real-time data updates via WebSocket connection.
/// Endpoint: ws://host:port/api/ws
class ThingsBoardWebSocketClient {
  static const String _wsBaseUrl = 'ws://iot.ceisufro.cl:8080/api/ws';
  
  final AuthTokenStorage _tokenStorage;
  WebSocketChannel? _channel;
  bool _isAuthenticated = false;
  int _cmdIdCounter = 0;
  
  // Stream controllers for telemetry updates
  final _telemetryController = StreamController<TelemetryUpdate>.broadcast();
  StreamSubscription? _channelSubscription;
  
  // Track subscriptions by cmdId
  final Map<int, String> _subscriptionsByCmd = {};
  
  ThingsBoardWebSocketClient({
    required AuthTokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;
  
  /// Stream of telemetry updates
  Stream<TelemetryUpdate> get telemetryStream => _telemetryController.stream;
  
  /// Check if connected and authenticated
  bool get isConnected => _channel != null && _isAuthenticated;
  
  /// Connect to WebSocket and authenticate
  Future<bool> connect() async {
    try {
      final tokens = await _tokenStorage.getTokens();
      if (tokens == null) {
        throw Exception('No hay sesión activa');
      }
      
      // Close existing connection if any
      await disconnect();
      
      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_wsBaseUrl));
      
      // Listen for messages
      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
      
      // Send authentication command
      final authCmd = {
        'authCmd': {
          'cmdId': _getNextCmdId(),
          'token': tokens.token,
        }
      };
      
      _channel!.sink.add(jsonEncode(authCmd));
      
      // Wait briefly for auth response
      await Future.delayed(const Duration(milliseconds: 500));
      _isAuthenticated = true;
      
      return true;
    } catch (e) {
      _isAuthenticated = false;
      return false;
    }
  }
  
  /// Subscribe to telemetry updates for a device
  /// Returns the subscription cmdId for later unsubscription
  int subscribeToDevice(String deviceId, {List<String>? keys}) {
    if (!isConnected) {
      throw Exception('WebSocket not connected');
    }
    
    final cmdId = _getNextCmdId();
    
    final subscribeCmd = {
      'cmds': [
        {
          'entityType': 'DEVICE',
          'entityId': deviceId,
          'scope': 'LATEST_TELEMETRY',
          'cmdId': cmdId,
          'type': 'TIMESERIES',
          if (keys != null && keys.isNotEmpty) 'keys': keys.join(','),
        }
      ]
    };
    
    _channel!.sink.add(jsonEncode(subscribeCmd));
    _subscriptionsByCmd[cmdId] = deviceId;
    
    return cmdId;
  }
  
  /// Subscribe to multiple devices at once
  Map<String, int> subscribeToDevices(List<String> deviceIds, {List<String>? keys}) {
    if (!isConnected) {
      throw Exception('WebSocket not connected');
    }
    
    final subscriptions = <String, int>{};
    final cmds = <Map<String, dynamic>>[];
    
    for (final deviceId in deviceIds) {
      final cmdId = _getNextCmdId();
      cmds.add({
        'entityType': 'DEVICE',
        'entityId': deviceId,
        'scope': 'LATEST_TELEMETRY',
        'cmdId': cmdId,
        'type': 'TIMESERIES',
        if (keys != null && keys.isNotEmpty) 'keys': keys.join(','),
      });
      subscriptions[deviceId] = cmdId;
      _subscriptionsByCmd[cmdId] = deviceId;
    }
    
    final subscribeCmd = {'cmds': cmds};
    _channel!.sink.add(jsonEncode(subscribeCmd));
    
    return subscriptions;
  }
  
  /// Unsubscribe from a device
  void unsubscribeFromDevice(int cmdId) {
    if (!isConnected) return;
    
    final unsubscribeCmd = {
      'cmds': [
        {
          'cmdId': cmdId,
          'type': 'TIMESERIES',
          'unsubscribe': true,
        }
      ]
    };
    
    _channel!.sink.add(jsonEncode(unsubscribeCmd));
    _subscriptionsByCmd.remove(cmdId);
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      
      // Check for subscription update
      if (data.containsKey('subscriptionId') || data.containsKey('data')) {
        final subscriptionId = data['subscriptionId'] as int?;
        final telemetryData = data['data'] as Map<String, dynamic>?;
        
        if (telemetryData != null) {
          // Parse telemetry data
          // Format: { "soil": [[ts, value]], "hum": [[ts, value]], "temp": [[ts, value]] }
          final deviceId = subscriptionId != null 
              ? _subscriptionsByCmd[subscriptionId] 
              : null;
          
          final update = TelemetryUpdate.fromJson(
            deviceId: deviceId ?? 'unknown',
            subscriptionId: subscriptionId ?? 0,
            data: telemetryData,
          );
          
          _telemetryController.add(update);
        }
      }
      
      // Check for error response
      if (data.containsKey('errorCode')) {
        final errorMsg = data['errorMsg'] as String? ?? 'Unknown error';
        _telemetryController.addError(Exception(errorMsg));
      }
    } catch (e) {
      // Ignore parse errors for non-telemetry messages
    }
  }
  
  void _handleError(dynamic error) {
    _telemetryController.addError(error);
    _isAuthenticated = false;
  }
  
  void _handleDone() {
    _isAuthenticated = false;
    // Attempt to reconnect after delay
    Future.delayed(const Duration(seconds: 5), () {
      if (!_telemetryController.isClosed) {
        connect();
      }
    });
  }
  
  int _getNextCmdId() => ++_cmdIdCounter;
  
  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _isAuthenticated = false;
    _subscriptionsByCmd.clear();
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
  
  /// Dispose resources
  void dispose() {
    disconnect();
    _telemetryController.close();
  }
}

/// Telemetry update from WebSocket
class TelemetryUpdate {
  final String deviceId;
  final int subscriptionId;
  final double? soilHumidity;
  final double? ambientHumidity;
  final double? temperature;
  final DateTime timestamp;
  final Map<String, dynamic> rawData;
  
  TelemetryUpdate({
    required this.deviceId,
    required this.subscriptionId,
    this.soilHumidity,
    this.ambientHumidity,
    this.temperature,
    required this.timestamp,
    required this.rawData,
  });
  
  factory TelemetryUpdate.fromJson({
    required String deviceId,
    required int subscriptionId,
    required Map<String, dynamic> data,
  }) {
    // ThingsBoard WebSocket format: { "key": [[timestamp, "value"]] }
    double? parseValue(String key) {
      final values = data[key] as List<dynamic>?;
      if (values == null || values.isEmpty) return null;
      final entry = values.first as List<dynamic>?;
      if (entry == null || entry.length < 2) return null;
      final value = entry[1];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }
    
    DateTime? parseTimestamp(String key) {
      final values = data[key] as List<dynamic>?;
      if (values == null || values.isEmpty) return null;
      final entry = values.first as List<dynamic>?;
      if (entry == null || entry.isEmpty) return null;
      final ts = entry[0];
      if (ts is num) return DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      return null;
    }
    
    // ThingsBoard keys: soil, hum, temp
    final timestamp = parseTimestamp('soil') ?? 
                      parseTimestamp('hum') ?? 
                      parseTimestamp('temp') ?? 
                      DateTime.now();
    
    return TelemetryUpdate(
      deviceId: deviceId,
      subscriptionId: subscriptionId,
      soilHumidity: parseValue('soil'),
      ambientHumidity: parseValue('hum'),
      temperature: parseValue('temp'),
      timestamp: timestamp,
      rawData: data,
    );
  }
  
  @override
  String toString() {
    return 'TelemetryUpdate(device: $deviceId, soil: $soilHumidity, hum: $ambientHumidity, temp: $temperature)';
  }
}
