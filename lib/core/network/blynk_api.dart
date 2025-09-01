import 'package:supabase_flutter/supabase_flutter.dart';

class BlynkApi {
  final SupabaseClient _supabase;

  BlynkApi({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<LiveData> getLive(String plantId) async {
    final res = await _supabase.functions.invoke('get_plant_live', body: {'plant_id': plantId});
    final data = (res.data as Map?)?.cast<String, dynamic>();
    if (data == null || data['success'] != true) {
      throw Exception(data?['error'] ?? 'Edge function error');
    }
    return LiveData.fromJson((data['data'] as Map).cast<String, dynamic>());
  }

  Future<void> controlPump({required String plantId, required bool on}) async {
    final res = await _supabase.functions.invoke('control_pump', body: {
      'plant_id': plantId,
      'value': on ? 1 : 0,
    });
    final data = (res.data as Map?)?.cast<String, dynamic>();
    if (data == null || data['success'] != true) {
      throw Exception(data?['error'] ?? 'Pump control failed');
    }
  }

  Future<HistoryData> getHistory({
    required String plantId,
    String pin = 'V0',
    String period = 'HOUR', // MINUTE, HOUR, DAY, WEEK, MONTH
    String granularityType = 'MINUTE',
  }) async {
    final res = await _supabase.functions.invoke('get_plant_history', body: {
      'plant_id': plantId,
      'pin': pin,
      'period': period,
      'granularityType': granularityType,
    });
    final data = (res.data as Map?)?.cast<String, dynamic>();
    if (data == null || data['success'] != true) {
      throw Exception(data?['error'] ?? 'History fetch failed');
    }
    return HistoryData.fromJson(data);
  }
}

class LiveData {
  final double? humidityRaw;
  final double? lightRaw;
  final double? humidityPercent; // Optional: normalized for UI
  final double? lightPercent; // Optional: normalized for UI

  LiveData({this.humidityRaw, this.lightRaw, this.humidityPercent, this.lightPercent});

  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      humidityRaw: (json['humidity_raw'] as num?)?.toDouble(),
      lightRaw: (json['light_raw'] as num?)?.toDouble(),
      humidityPercent: (json['humidity_percent'] as num?)?.toDouble(),
      lightPercent: (json['light_percent'] as num?)?.toDouble(),
    );
  }
}

class HistoryData {
  final List<HistoryPoint> points;
  final double? min;
  final double? max;
  final double? avg;
  final String? pin;
  final String? period;

  HistoryData({required this.points, this.min, this.max, this.avg, this.pin, this.period});

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    final pts = (json['datos'] as List<dynamic>?)
            ?.map((e) => HistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <HistoryPoint>[];
    return HistoryData(
      points: pts,
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      avg: (json['avg'] as num?)?.toDouble(),
      pin: json['pin'] as String?,
      period: json['period'] as String?,
    );
  }
}

class HistoryPoint {
  final String t; // ISO time
  final double v;

  HistoryPoint({required this.t, required this.v});

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      t: json['t'] as String,
      v: (json['v'] as num).toDouble(),
    );
  }
}
