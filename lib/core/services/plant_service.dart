import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plant_model.dart';

/// Plant Service
/// 
/// Service class for managing plant data operations including
/// CRUD operations for plants and real-time sensor data.
class PlantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all plants for the current user
  Future<List<PlantModel>> getUserPlants() async {
    try {
      final response = await _supabase
          .from('plantas')
          .select('*')
          .order('created_at', ascending: false);

      return response.map<PlantModel>((json) => PlantModel.fromSupabase(json)).toList();
    } catch (e) {
      throw Exception('Error fetching plants: $e');
    }
  }

  /// Get real-time plant data including sensor readings from ThingsBoard
  Future<List<PlantWithSensorData>> getPlantsWithSensorData() async {
    try {
      // Get current user's session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      // Call our Edge Function to get plant data with sensor readings
      final response = await _supabase.functions.invoke(
        'get_plant_data',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final List<dynamic> plantasData = response.data['plantas'] ?? [];
      
      return plantasData.map<PlantWithSensorData>((json) {
        return PlantWithSensorData.fromJson(json);
      }).toList();

    } catch (e) {
      throw Exception('Error fetching plants with sensor data: $e');
    }
  }

  /// Add a new plant
  Future<PlantModel> addPlant({
    required String nombre,
    required String deviceId,
    String? emoji,
    String? descripcion,
    String? ubicacion,
    String? accessToken,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final response = await _supabase
          .from('plantas')
          .insert({
            'nombre': nombre,
            'emoji': emoji ?? '🌱',
            'descripcion': descripcion,
            'device_id': deviceId,
            'ubicacion': ubicacion,
            'user_id': user.id,
            'access_token': accessToken,
          })
          .select()
          .single();
      return PlantModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Error adding plant: $e');
    }
  }

  /// Update an existing plant
  Future<PlantModel> updatePlant({
    required String plantId,
    String? nombre,
    String? emoji,
    String? descripcion,
    String? deviceId,
    String? ubicacion,
    String? accessToken,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }
      final updateData = <String, dynamic>{};
      if (nombre != null) updateData['nombre'] = nombre;
      if (emoji != null) updateData['emoji'] = emoji;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (deviceId != null) updateData['device_id'] = deviceId;
      if (ubicacion != null) updateData['ubicacion'] = ubicacion;
      if (accessToken != null) updateData['access_token'] = accessToken;
      final response = await _supabase.functions.invoke(
        'modify_plant',
        body: {
          'action': 'update',
          'plantId': plantId,
          'updateData': updateData,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.data == null || response.data['success'] != true) {
        throw Exception('Error updating plant: ' + (response.data?['error'] ?? 'Unknown error'));
      }
      // Refrescar el modelo desde la base de datos
      final refreshed = await _supabase
        .from('plantas')
        .select()
        .eq('id', plantId)
        .single();
      return PlantModel.fromSupabase(refreshed);
    } catch (e) {
      throw Exception('Error updating plant: $e');
    }
  }

  /// Delete a plant
  Future<void> deletePlant(String plantId) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }
      final response = await _supabase.functions.invoke(
        'modify_plant',
        body: {
          'action': 'delete',
          'plantId': plantId,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.data == null || response.data['success'] != true) {
        throw Exception('Error deleting plant: ' + (response.data?['error'] ?? 'Unknown error'));
      }
    } catch (e) {
      throw Exception('Error deleting plant: $e');
    }
  }

  /// Stream of real-time plant updates
  Stream<List<PlantModel>> watchUserPlants() {
    try {
      return _supabase
          .from('plantas')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((data) => data.map<PlantModel>((json) => PlantModel.fromSupabase(json)).toList());
    } catch (e) {
      throw Exception('Error watching plants: $e');
    }
  }

  /// Get real-time threshold from ThingsBoard via edge function
  Future<double?> getRealtimeThreshold(String deviceId) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }
      final response = await _supabase.functions.invoke(
        'thingsboard-proxy',
        body: {
          'action': 'getThreshold',
          'deviceId': deviceId,
        },
        headers: {
          'Authorization': 'Bearer  [36m [1msession.accessToken] [0m',
          'Content-Type': 'application/json',
        },
      );
      if (response.data == null || response.data['threshold'] == null) {
        return null;
      }
      // El threshold puede ser un número o un objeto, ajusta según tu ThingsBoard
      final value = response.data['threshold']['value'];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    } catch (e) {
      print('Error fetching realtime threshold: $e');
      return null;
    }
  }

  /// Envía comando de riego o cambio de threshold a ThingsBoard vía función edge
  Future<void> sendRegadoCommand({
    required String accessToken,
    required Map<String, dynamic> atributos,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }
      final response = await _supabase.functions.invoke(
        'regado',
        body: {
          'accessToken': accessToken,
          'atributos': atributos,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.data == null || response.data['success'] != true) {
        throw Exception('Error sending regado command: ' + (response.data?['error'] ?? 'Unknown error'));
      }
    } catch (e) {
      throw Exception('Error sending regado command: $e');
    }
  }
}

/// Represents sensor statistics (min, max, avg, count)
class SensorStatistics {
  final double? min;
  final double? max;
  final double? avg;
  final int count;

  SensorStatistics({
    this.min,
    this.max,
    this.avg,
    this.count = 0,
  });

  factory SensorStatistics.fromJson(Map<String, dynamic> json) {
    return SensorStatistics(
      min: _parseDouble(json['min']),
      max: _parseDouble(json['max']),
      avg: _parseDouble(json['avg']),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'avg': avg,
      'count': count,
    };
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

/// Plant model with sensor data from ThingsBoard
class PlantWithSensorData {
  final String id;
  final String nombre;
  final String emoji;
  final String descripcion;
  final String ubicacion;
  final double? humedad;
  final double? luz;
  final String? deviceId;
  final List<SensorDataPoint> historicalHumidity;
  final List<SensorDataPoint> historicalLight;
  final double humidityThresholdMin;
  final double humidityThresholdMax;
  // Elimino lightThresholdMin y lightThresholdMax
  
  // New fields for statistics and recent readings
  final SensorStatistics? humidityStatistics;
  final SensorStatistics? lightStatistics;
  final List<SensorDataPoint> recentHumidityReadings;
  final List<SensorDataPoint> recentLightReadings;
  final String? error;
  final String? accessToken;

  PlantWithSensorData({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.descripcion,
    required this.ubicacion,
    this.humedad,
    this.luz,
    this.deviceId,
    this.historicalHumidity = const [],
    this.historicalLight = const [],
    this.humidityThresholdMin = 30.0,
    this.humidityThresholdMax = 70.0,
    // Elimino lightThresholdMin y lightThresholdMax
    this.humidityStatistics,
    this.lightStatistics,
    this.recentHumidityReadings = const [],
    this.recentLightReadings = const [],
    this.error,
    this.accessToken,
  });

  factory PlantWithSensorData.fromJson(Map<String, dynamic> json) {
    return PlantWithSensorData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🌱',
      descripcion: json['descripcion']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      humedad: _parseDouble(json['humedad']),
      luz: _parseDouble(json['luz']),
      deviceId: json['device_id']?.toString(),
      
      // Legacy historical data (keeping for backward compatibility)
      historicalHumidity: _parseHistoricalData(json['historical_humidity']),
      historicalLight: _parseHistoricalData(json['historical_light']),
      
      // Thresholds - updated to use the new structure
      humidityThresholdMin: _parseThresholdValue(json, 'thresholds', 'humidity', 'min') ?? 30.0,
      humidityThresholdMax: _parseThresholdValue(json, 'thresholds', 'humidity', 'max') ?? 70.0,
      // Elimino lightThresholdMin y lightThresholdMax
      
      // New statistics
      humidityStatistics: _parseStatistics(json, 'statistics', 'humidity'),
      lightStatistics: _parseStatistics(json, 'statistics', 'light'),
      
      // New recent readings
      recentHumidityReadings: _parseRecentReadings(json, 'recentReadings', 'humidity'),
      recentLightReadings: _parseRecentReadings(json, 'recentReadings', 'light'),
      
      error: json['error']?.toString(),
      accessToken: json['access_token'] as String?,
    );
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper method to parse historical sensor data
  static List<SensorDataPoint> _parseHistoricalData(dynamic data) {
    if (data == null || data is! List) return [];
    
    return data.map<SensorDataPoint>((item) {
      if (item is Map<String, dynamic>) {
        return SensorDataPoint(
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            (item['ts'] as num?)?.toInt() ?? 0
          ),
          value: _parseDouble(item['value']) ?? 0.0,
        );
      }
      return SensorDataPoint(timestamp: DateTime.now(), value: 0.0);
    }).toList();
  }

  // Helper method to parse threshold values from nested JSON
  static double? _parseThresholdValue(Map<String, dynamic> json, String thresholdKey, String sensorType, String valueType) {
    try {
      final thresholds = json[thresholdKey] as Map<String, dynamic>?;
      if (thresholds == null) return null;
      
      final sensorThresholds = thresholds[sensorType] as Map<String, dynamic>?;
      if (sensorThresholds == null) return null;
      
      return _parseDouble(sensorThresholds[valueType]);
    } catch (e) {
      return null;
    }
  }

  // Helper method to parse statistics from nested JSON
  static SensorStatistics? _parseStatistics(Map<String, dynamic> json, String statisticsKey, String sensorType) {
    try {
      final statistics = json[statisticsKey] as Map<String, dynamic>?;
      if (statistics == null) return null;
      
      final sensorStats = statistics[sensorType] as Map<String, dynamic>?;
      if (sensorStats == null) return null;
      
      return SensorStatistics.fromJson(sensorStats);
    } catch (e) {
      return null;
    }
  }

  // Helper method to parse recent readings from nested JSON
  static List<SensorDataPoint> _parseRecentReadings(Map<String, dynamic> json, String readingsKey, String sensorType) {
    try {
      final readings = json[readingsKey] as Map<String, dynamic>?;
      if (readings == null) return [];
      
      final sensorReadings = readings[sensorType] as List<dynamic>?;
      if (sensorReadings == null) return [];
      
      return sensorReadings.map<SensorDataPoint>((item) {
        if (item is Map<String, dynamic>) {
          return SensorDataPoint(
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              (item['timestamp'] as num?)?.toInt() ?? 0
            ),
            value: _parseDouble(item['value']) ?? 0.0,
          );
        }
        return SensorDataPoint(timestamp: DateTime.now(), value: 0.0);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'emoji': emoji,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'humedad': humedad,
      'luz': luz,
      'device_id': deviceId,
      'historical_humidity': historicalHumidity.map((e) => e.toJson()).toList(),
      'historical_light': historicalLight.map((e) => e.toJson()).toList(),
      'humidity_threshold_min': humidityThresholdMin,
      'humidity_threshold_max': humidityThresholdMax,
      // Elimino lightThresholdMin y lightThresholdMax
      'statistics': {
        'humidity': humidityStatistics?.toJson(),
        'light': lightStatistics?.toJson(),
      },
      'recentReadings': {
        'humidity': recentHumidityReadings.map((e) => e.toJson()).toList(),
        'light': recentLightReadings.map((e) => e.toJson()).toList(),
      },
      'error': error,
      'access_token': accessToken,
    };
  }

  /// Convert PlantWithSensorData to PlantModel
  PlantModel toPlantModel() {
    return PlantModel(
      id: id,
      name: nombre,
      emoji: emoji,
      description: descripcion,
      currentHumidity: humedad ?? 0.0,
      currentLight: luz ?? 0.0,
      isOnline: humedad != null && luz != null,
      isAutoMode: false,
      lastWatered: DateTime.now().subtract(const Duration(hours: 24)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      thresholds: PlantThresholds(
        minHumidity: humidityThresholdMin,
        maxHumidity: humidityThresholdMax,
        minLight: 0,
        maxLight: 0,
      ),
      imageUrls: [],
      deviceId: deviceId,
      location: ubicacion,
      accessToken: accessToken, // <-- ¡AQUÍ!
    );
  }
}

/// Represents a single sensor data point with timestamp and value
class SensorDataPoint {
  final DateTime timestamp;
  final double value;

  SensorDataPoint({
    required this.timestamp,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'ts': timestamp.millisecondsSinceEpoch,
      'value': value,
    };
  }
}
