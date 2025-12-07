import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Sensor evolution card showing historical data charts
/// 
/// Displays line charts for soil humidity, ambient humidity, and temperature
class SensorEvolutionCard extends StatefulWidget {
  final String stationId;
  const SensorEvolutionCard({super.key, required this.stationId});

  @override
  State<SensorEvolutionCard> createState() => _SensorEvolutionCardState();
}

class _SensorEvolutionCardState extends State<SensorEvolutionCard> {
  int _selected = 0; // 0: soil humidity, 1: ambient humidity, 2: temperature
  List<double> _soilHumiditySeries = const [];
  List<double> _ambientHumiditySeries = const [];
  List<double> _temperatureSeries = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // TODO: Implement actual API call to get historical data
    // For now, simulate with placeholder values
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    setState(() {
      _soilHumiditySeries = _genSeries(12, base: 55, varAmp: 8, min: 30, max: 80);
      _ambientHumiditySeries = _genSeries(12, base: 60, varAmp: 5, min: 40, max: 90);
      _temperatureSeries = _genSeries(12, base: 24, varAmp: 3, min: 15, max: 35);
      _loading = false;
      _error = null;
    });
  }

  List<double> _genSeries(int count, {required double base, required double varAmp, required double min, required double max}) {
    final r = math.Random();
    return List.generate(count, (i) {
      final v = base + (r.nextDouble() - 0.5) * varAmp * 2;
      return v.clamp(min, max);
    });
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
          Row(
            children: [
              Icon(Icons.trending_up, color: cs.primary),
              const SizedBox(width: UIConstants.spacingS),
              Text('Evolución de Sensores', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                _buildTabs(context),
                const SizedBox(height: UIConstants.spacingL),
                SizedBox(
                  height: 140,
                  child: _buildChart(context),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: AppTextStyles.caption.copyWith(color: cs.error)),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final tabs = [
      {'label': 'Humedad Suelo', 'icon': Icons.water_drop},
      {'label': 'Humedad Amb.', 'icon': Icons.cloud},
      {'label': 'Temperatura', 'icon': Icons.thermostat},
    ];
    
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _selected == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? cs.primary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive ? Border.all(color: cs.primary) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tabs[i]['icon'] as IconData,
                    size: 14,
                    color: isActive ? cs.primary : theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tabs[i]['label'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive ? cs.primary : theme.hintColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 10,
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

  Widget _buildChart(BuildContext context) {
    final series = _selected == 0 
        ? _soilHumiditySeries 
        : _selected == 1 
            ? _ambientHumiditySeries 
            : _temperatureSeries;
    
    if (series.isEmpty) {
      return Center(
        child: Text('Sin datos disponibles', style: AppTextStyles.bodySmall),
      );
    }
    
    return CustomPaint(
      size: Size.infinite,
      painter: _SimpleLinePainter(
        series,
        Theme.of(context).colorScheme.primary,
        Theme.of(context).dividerColor,
      ),
    );
  }
}

class _SimpleLinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color gridColor;

  _SimpleLinePainter(this.data, this.lineColor, this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = maxV - minV == 0 ? 1 : maxV - minV;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw data line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minV) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
