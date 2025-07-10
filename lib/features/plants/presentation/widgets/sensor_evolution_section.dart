import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'plant_detail_constants.dart';
import '../../../../core/services/plant_service.dart';

/// Sensor Evolution Section
/// 
/// Displays a historical chart for sensor data with metric selection.
/// This section shows historical sensor data evolution over time.
/// 
/// Features:
/// - Real chart display with fl_chart
/// - Metric selector (Humidity/Light)
/// - Historical data visualization
/// - Professional styling consistent with the app theme
class SensorEvolutionSection extends StatefulWidget {
  final List<SensorDataPoint> humidityData;
  final List<SensorDataPoint> lightData;
  final String selectedMetric;
  final ValueChanged<String>? onMetricChanged;

  const SensorEvolutionSection({
    super.key,
    required this.humidityData,
    required this.lightData,
    this.selectedMetric = 'humidity',
    this.onMetricChanged,
  });

  @override
  State<SensorEvolutionSection> createState() => _SensorEvolutionSectionState();
}

class _SensorEvolutionSectionState extends State<SensorEvolutionSection> {
  late String _selectedMetric;
  static const Map<String, String> _metricLabels = {
    'humidity': 'Humedad',
    'light': 'Luz',
  };

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.selectedMetric;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PlantDetailConstants.spacingL),
      decoration: PlantDetailConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: PlantDetailConstants.spacingL),
          _buildChart(),
          const SizedBox(height: PlantDetailConstants.spacingM),
          _buildMetricSelector(),
        ],
      ),
    );
  }

  /// Builds the section header with title and icon
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.timeline,
          color: PlantDetailConstants.primaryGreen,
          size: PlantDetailConstants.iconSizeL,
        ),
        const SizedBox(width: PlantDetailConstants.spacingM),
        Text(
          'Evolución de Sensores',
          style: PlantDetailConstants.titleMedium,
        ),
      ],
    );
  }

  /// Builds the actual chart using fl_chart
  Widget _buildChart() {
    final rawData = _selectedMetric == 'humidity' ? widget.humidityData : widget.lightData;
    
    if (rawData.isEmpty) {
      return _buildEmptyChart();
    }

    // Sort data by timestamp from oldest to newest (left to right)
    final data = List<SensorDataPoint>.from(rawData)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Container(
      height: PlantDetailConstants.chartHeight,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: _selectedMetric == 'humidity' ? 20 : 50,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: PlantDetailConstants.textTertiary.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: PlantDetailConstants.textTertiary.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return _buildBottomTitle(value, data);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _selectedMetric == 'humidity' ? 20 : 50,
                getTitlesWidget: (value, meta) {
                  return _buildLeftTitle(value);
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: PlantDetailConstants.textTertiary.withValues(alpha: 0.2),
            ),
          ),
          minX: 0,
          maxX: data.length > 1 ? data.length - 1 : 1,
          minY: _selectedMetric == 'humidity' ? 0 : 0,
          maxY: _selectedMetric == 'humidity' ? 100 : 1000,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  _selectedMetric == 'humidity' 
                      ? PlantDetailConstants.primaryGreen 
                      : Colors.orange,
                  _selectedMetric == 'humidity' 
                      ? PlantDetailConstants.primaryGreen.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    _selectedMetric == 'humidity' 
                        ? PlantDetailConstants.primaryGreen.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                    _selectedMetric == 'humidity' 
                        ? PlantDetailConstants.primaryGreen.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty chart placeholder
  Widget _buildEmptyChart() {
    return Container(
      height: PlantDetailConstants.chartHeight,
      decoration: PlantDetailConstants.chartPlaceholderDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: PlantDetailConstants.iconSizeXL,
              color: PlantDetailConstants.primaryGreen.withValues(alpha: 0.3),
            ),
            const SizedBox(height: PlantDetailConstants.spacingM),
            Text(
              'Sin datos históricos',
              style: PlantDetailConstants.titleSmall.copyWith(
                color: PlantDetailConstants.primaryGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: PlantDetailConstants.spacingXS),
            Text(
              'Los datos aparecerán aquí\ncuando estén disponibles',
              textAlign: TextAlign.center,
              style: PlantDetailConstants.bodySmall.copyWith(
                color: PlantDetailConstants.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds bottom title for chart
  Widget _buildBottomTitle(double value, List<SensorDataPoint> data) {
    if (value.toInt() >= data.length || value.toInt() < 0) {
      return Container();
    }
    
    final dataPoint = data[value.toInt()];
    return Text(
      '${dataPoint.timestamp.day}/${dataPoint.timestamp.month}',
      style: PlantDetailConstants.bodySmall.copyWith(
        color: PlantDetailConstants.textTertiary,
      ),
    );
  }

  /// Builds left title for chart
  Widget _buildLeftTitle(double value) {
    return Text(
      '${value.toInt()}${_selectedMetric == 'humidity' ? '%' : ''}',
      style: PlantDetailConstants.bodySmall.copyWith(
        color: PlantDetailConstants.textTertiary,
      ),
    );
  }

  /// Builds the metric selector buttons
  Widget _buildMetricSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _metricLabels.entries.map((entry) {
        final isSelected = entry.key == _selectedMetric;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PlantDetailConstants.spacingXS,
          ),
          child: _buildMetricButton(entry.key, entry.value, isSelected),
        );
      }).toList(),
    );
  }

  /// Builds individual metric button
  Widget _buildMetricButton(String key, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleMetricSelection(key),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PlantDetailConstants.spacingL,
          vertical: PlantDetailConstants.spacingS,
        ),
        decoration: PlantDetailConstants.timePeriodButtonDecoration(isSelected),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              key == 'humidity' ? Icons.water_drop : Icons.light_mode,
              size: 16,            color: isSelected 
                ? Colors.white 
                : PlantDetailConstants.primaryGreen,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: PlantDetailConstants.timePeriodButtonTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles metric selection
  void _handleMetricSelection(String metric) {
    if (metric != _selectedMetric) {
      setState(() {
        _selectedMetric = metric;
      });
      
      // Notify parent widget of the change
      widget.onMetricChanged?.call(metric);
    }
  }
}
