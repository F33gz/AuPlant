import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/telemetry_history.dart';
import '../../domain/usecases/get_sensor_history_usecase.dart';

/// Sensor evolution card showing historical data charts
/// 
/// Displays line charts for soil humidity, ambient humidity, and temperature
/// using real data from ThingsBoard API
class SensorEvolutionCard extends StatefulWidget {
  final String stationId;
  const SensorEvolutionCard({super.key, required this.stationId});

  @override
  State<SensorEvolutionCard> createState() => _SensorEvolutionCardState();
}

class _SensorEvolutionCardState extends State<SensorEvolutionCard> {
  final _getSensorHistoryUseCase = GetIt.instance<GetSensorHistoryUseCase>();
  
  int _selected = 0; // 0: soil humidity, 1: ambient humidity, 2: temperature
  HistoryTimeRange _timeRange = HistoryTimeRange.last24Hours;
  
  SensorHistoryData? _historyData;
  bool _loading = true;
  String? _error;
  
  // Para interactividad táctil
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant SensorEvolutionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stationId != widget.stationId) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _getSensorHistoryUseCase.call(
      widget.stationId,
      timeRange: _timeRange,
    );

    if (!mounted) return;

    switch (result) {
      case Success<SensorHistoryData> success:
        setState(() {
          _historyData = success.data;
          _loading = false;
        });
        break;
      case Error<SensorHistoryData> error:
        setState(() {
          _error = error.failure.message;
          _loading = false;
        });
        break;
    }
  }

  List<double> get _currentSeries {
    if (_historyData == null) return [];
    
    switch (_selected) {
      case 0:
        return _historyData!.soilHumidity?.valuesOldestFirst ?? [];
      case 1:
        return _historyData!.ambientHumidity?.valuesOldestFirst ?? [];
      case 2:
        return _historyData!.temperature?.valuesOldestFirst ?? [];
      default:
        return [];
    }
  }

  String get _currentUnit {
    switch (_selected) {
      case 0:
      case 1:
        return '%';
      case 2:
        return '°C';
      default:
        return '';
    }
  }

  double? get _currentLatestValue {
    if (_historyData == null) return null;
    
    switch (_selected) {
      case 0:
        return _historyData!.soilHumidity?.latestValue;
      case 1:
        return _historyData!.ambientHumidity?.latestValue;
      case 2:
        return _historyData!.temperature?.latestValue;
      default:
        return null;
    }
  }

  /// Get timestamps for current series (oldest first)
  List<DateTime> get _currentTimestamps {
    if (_historyData == null) return [];
    
    switch (_selected) {
      case 0:
        return _historyData!.soilHumidity?.points.reversed.map((p) => p.timestamp).toList() ?? [];
      case 1:
        return _historyData!.ambientHumidity?.points.reversed.map((p) => p.timestamp).toList() ?? [];
      case 2:
        return _historyData!.temperature?.points.reversed.map((p) => p.timestamp).toList() ?? [];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: UIConstants.spacingM),
          _buildTimeRangeSelector(context),
          const SizedBox(height: UIConstants.spacingL),
          if (_loading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _buildErrorWidget(context)
          else
            Column(
              children: [
                _buildTabs(context),
                const SizedBox(height: UIConstants.spacingL),
                _buildCurrentValue(context),
                const SizedBox(height: UIConstants.spacingM),
                SizedBox(
                  height: 140,
                  child: _buildChart(context),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Row(
      children: [
        Icon(Icons.trending_up, color: cs.primary),
        const SizedBox(width: UIConstants.spacingS),
        Text('Evolución de Sensores', style: AppTextStyles.titleSmall),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.refresh, color: cs.primary, size: 20),
          onPressed: _loading ? null : _loadHistory,
          tooltip: 'Actualizar',
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HistoryTimeRange.values.map((range) {
          final isActive = _timeRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (_timeRange != range) {
                  setState(() => _timeRange = range);
                  _loadHistory();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? cs.primary : theme.dividerColor,
                  ),
                ),
                child: Text(
                  range.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? cs.onPrimary : theme.hintColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error al cargar datos',
              style: AppTextStyles.bodySmall.copyWith(color: cs.error),
            ),
            Text(
              _error ?? 'Error desconocido',
              style: AppTextStyles.caption.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final theme = Theme.of(context);
    
    final tabs = [
      {'label': 'Humedad Suelo', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'label': 'Humedad Amb.', 'icon': Icons.cloud, 'color': Colors.teal},
      {'label': 'Temperatura', 'icon': Icons.thermostat, 'color': Colors.orange},
    ];
    
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _selected == i;
        final tabColor = tabs[i]['color'] as Color;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? tabColor.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive ? Border.all(color: tabColor) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tabs[i]['icon'] as IconData,
                    size: 14,
                    color: isActive ? tabColor : theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      tabs[i]['label'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: isActive ? tabColor : theme.hintColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentValue(BuildContext context) {
    final theme = Theme.of(context);
    final latestValue = _currentLatestValue;
    
    if (latestValue == null) return const SizedBox.shrink();
    
    final colors = [Colors.blue, Colors.teal, Colors.orange];
    final color = colors[_selected];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Valor actual: ',
          style: AppTextStyles.caption.copyWith(color: theme.hintColor),
        ),
        Text(
          '${latestValue.toStringAsFixed(_selected == 2 ? 1 : 0)}$_currentUnit',
          style: AppTextStyles.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    final series = _currentSeries;
    final timestamps = _currentTimestamps;
    
    if (series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Theme.of(context).hintColor, size: 32),
            const SizedBox(height: 8),
            Text(
              'Sin datos para este período',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }
    
    final colors = [Colors.blue, Colors.teal, Colors.orange];
    final lineColor = colors[_selected];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanDown: (details) => _handleTouch(details.localPosition, constraints.maxWidth, series.length),
          onPanUpdate: (details) => _handleTouch(details.localPosition, constraints.maxWidth, series.length),
          onPanEnd: (_) => setState(() => _touchedIndex = null),
          onPanCancel: () => setState(() => _touchedIndex = null),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _InteractiveLinePainter(
                  data: series,
                  lineColor: lineColor,
                  gridColor: Theme.of(context).dividerColor,
                  touchedIndex: _touchedIndex,
                ),
              ),
              // Tooltip cuando se toca
              if (_touchedIndex != null && _touchedIndex! < series.length)
                _buildTooltip(
                  context,
                  series[_touchedIndex!],
                  timestamps.isNotEmpty && _touchedIndex! < timestamps.length 
                      ? timestamps[_touchedIndex!] 
                      : null,
                  constraints,
                  series,
                  lineColor,
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleTouch(Offset localPosition, double width, int dataLength) {
    if (dataLength <= 1) return;
    
    final spacing = width / (dataLength - 1);
    final index = (localPosition.dx / spacing).round().clamp(0, dataLength - 1);
    
    if (index != _touchedIndex) {
      setState(() => _touchedIndex = index);
    }
  }

  Widget _buildTooltip(
    BuildContext context,
    double value,
    DateTime? timestamp,
    BoxConstraints constraints,
    List<double> series,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    // Calcular posición del tooltip
    final dataLength = series.length;
    final minV = series.reduce((a, b) => a < b ? a : b);
    final maxV = series.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV == 0 ? 1 : maxV - minV;
    
    final x = _touchedIndex! * constraints.maxWidth / (dataLength - 1);
    final y = constraints.maxHeight - ((value - minV) / range) * constraints.maxHeight * 0.9 - constraints.maxHeight * 0.05;
    
    // Formato del valor
    final valueText = _selected == 2 
        ? '${value.toStringAsFixed(1)}°C'
        : '${value.toStringAsFixed(0)}%';
    
    // Formato de la hora
    final timeText = timestamp != null 
        ? DateFormat('HH:mm').format(timestamp)
        : '';
    
    // Calcular posición del tooltip para que no se salga
    double tooltipX = x - 35;
    if (tooltipX < 0) tooltipX = 0;
    if (tooltipX > constraints.maxWidth - 70) tooltipX = constraints.maxWidth - 70;
    
    double tooltipY = y - 55;
    if (tooltipY < 0) tooltipY = y + 15;
    
    return Positioned(
      left: tooltipX,
      top: tooltipY,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              valueText,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (timeText.isNotEmpty)
              Text(
                timeText,
                style: AppTextStyles.caption.copyWith(
                  color: theme.hintColor,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Interactive line chart painter with touch highlight
class _InteractiveLinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color gridColor;
  final int? touchedIndex;

  _InteractiveLinePainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV == 0 ? 1 : maxV - minV;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw fill gradient
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minV) / range) * size.height * 0.9 - size.height * 0.05;
      if (i == 0) {
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw data line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minV) / range) * size.height * 0.9 - size.height * 0.05;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw vertical line at touched point
    if (touchedIndex != null && touchedIndex! < data.length) {
      final touchX = touchedIndex! * size.width / (data.length - 1);
      final touchY = size.height - ((data[touchedIndex!] - minV) / range) * size.height * 0.9 - size.height * 0.05;
      
      // Vertical dashed line
      final dashPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      // Draw dashed line
      const dashHeight = 4.0;
      const dashSpace = 3.0;
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(touchX, startY),
          Offset(touchX, (startY + dashHeight).clamp(0, size.height)),
          dashPaint,
        );
        startY += dashHeight + dashSpace;
      }
      
      // Highlight point with glow effect
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(touchX, touchY), 12, glowPaint);
      
      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(touchX, touchY), 7, pointBorderPaint);
      
      final pointPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(touchX, touchY), 5, pointPaint);
    }
    
    // Draw regular points (only if few data points and not on touched index)
    if (data.length <= 30) {
      final pointPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      
      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (int i = 0; i < data.length; i++) {
        // Skip the touched point as it's drawn separately with highlight
        if (touchedIndex != null && i == touchedIndex) continue;
        
        final x = i * size.width / (data.length - 1);
        final y = size.height - ((data[i] - minV) / range) * size.height * 0.9 - size.height * 0.05;
        canvas.drawCircle(Offset(x, y), 4, pointBorderPaint);
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveLinePainter oldDelegate) {
    return data != oldDelegate.data || 
           lineColor != oldDelegate.lineColor ||
           gridColor != oldDelegate.gridColor ||
           touchedIndex != oldDelegate.touchedIndex;
  }
}
