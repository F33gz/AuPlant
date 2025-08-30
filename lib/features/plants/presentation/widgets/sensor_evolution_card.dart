import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Placeholder chart card to mimic historical evolution section
class SensorEvolutionCard extends StatefulWidget {
  const SensorEvolutionCard({super.key});

  @override
  State<SensorEvolutionCard> createState() => _SensorEvolutionCardState();
}

class _SensorEvolutionCardState extends State<SensorEvolutionCard> {
  int _selected = 0; // 0 humidity, 1 light
  late final List<double> _humiditySeries;
  late final List<double> _lightSeries;

  @override
  void initState() {
    super.initState();
  // Generate 12 points (0..55 min) -> 1h with 5-min intervals
  _humiditySeries = _genSeries(12, base: 62, varAmp: 4, min: 40, max: 80);
  _lightSeries = _genSeries(12, base: 1200, varAmp: 300, min: 100, max: 2200);
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
          _chartWithAxis(),
          const SizedBox(height: UIConstants.spacingL),
          Row(
            children: [
              _chip(context, 'Humedad', icon: Icons.water_drop, selected: _selected == 0, onTap: () => setState(() => _selected = 0)),
              const SizedBox(width: UIConstants.spacingS),
              _chip(context, 'Luz', icon: Icons.light_mode, selected: _selected == 1, onTap: () => setState(() => _selected = 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, {required IconData icon, required bool selected, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? cs.onPrimary : cs.primary),
            const SizedBox(width: 6),
            Text(label, style: selected ? AppTextStyles.buttonSmall : AppTextStyles.labelSmall.copyWith(color: cs.primary)),
          ],
        ),
      ),
    );
  }

  Widget _chartWithAxis() {
  final isHumidity = _selected == 0;
  final data = isHumidity ? _humiditySeries : _lightSeries;
  final maxY = isHumidity ? 100.0 : 2500.0; // axis scale
  final lineColor = AppColors.darkGreen;
  final fillColor = AppColors.primaryGreenAlpha10;

  // Y-axis ticks and labels
  final yTicks = isHumidity
    ? <double>[0, 25, 50, 75, 100]
    : <double>[0, 625, 1250, 1875, 2500];
  final yLabels = isHumidity
    ? ['0%', '25%', '50%', '75%', '100%']
    : ['0', '625', '1250', '1875', '2500'];

    final now = DateTime.now();
    // 1 hora con intervalos de 10 minutos -> 6 marcas (50,40,30,20,10,0)
    final labels = List.generate(6, (i) {
      final minutesAgo = 50 - i * 10;
      final t = now.subtract(Duration(minutes: minutesAgo));
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    });

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CustomPaint(
            painter: _ChartPainter(
              data: data,
              maxY: maxY,
              lineColor: lineColor,
        fillColor: fillColor,
        yTicks: yTicks,
        yLabels: yLabels,
        leftGutter: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
  // X-axis labels (1h, pasos de 10 minutos)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.map((t) => Text(t, style: AppTextStyles.caption)).toList(),
        ),
      ],
    );
  }

  List<double> _genSeries(int n, {required double base, required double varAmp, required double min, required double max}) {
    final rnd = math.Random(7);
    final out = <double>[];
    for (var i = 0; i < n; i++) {
      final jitter = (rnd.nextDouble() * 2 - 1) * varAmp;
      final v = (base + jitter + varAmp * math.sin(i / (n - 1) * 2 * math.pi / 1.5)).clamp(min, max);
      out.add(v.toDouble());
    }
    return out;
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double maxY;
  final Color lineColor;
  final Color fillColor;
  final List<double> yTicks;
  final List<String> yLabels;
  final double leftGutter;
  _ChartPainter({
    required this.data,
    required this.maxY,
    required this.lineColor,
    required this.fillColor,
    required this.yTicks,
    required this.yLabels,
    required this.leftGutter,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF2B2E31)
      ..strokeWidth = 1;

    final padX = leftGutter; // reserve space for Y labels
    final padTop = 8.0;
    final padBot = 8.0;
    final width = size.width - padX - 12; // 12 right padding
    final height = size.height - padTop - padBot;

    // Horizontal grid and Y labels (use provided ticks)
    for (int i = 0; i < yTicks.length; i++) {
      final yVal = yTicks[i];
      final y = padTop + height * (1 - (yVal / maxY));
      canvas.drawLine(Offset(padX, y), Offset(padX + width, y), grid);
      // Draw label at left gutter
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: AppTextStyles.caption),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftGutter - 6);
      tp.paint(canvas, Offset(padX - leftGutter + 4, y - tp.height / 2));
    }

    // Build path from data
    final n = data.length;
    if (n < 2) return;
  double xFor(int i) => padX + width * (i / (n - 1));
    double yFor(double v) => padTop + height * (1 - (v / maxY));

    final area = Path()..moveTo(xFor(0), yFor(data.first));
    for (int i = 1; i < n; i++) {
      area.lineTo(xFor(i), yFor(data[i]));
    }
    area
      ..lineTo(xFor(n - 1), padTop + height)
      ..lineTo(xFor(0), padTop + height)
      ..close();

    final bgPaint = Paint()..color = fillColor;
    canvas.drawPath(area, bgPaint);

    final stroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final line = Path()..moveTo(xFor(0), yFor(data.first));
    for (int i = 1; i < n; i++) {
      line.lineTo(xFor(i), yFor(data[i]));
    }
    canvas.drawPath(line, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// No external data source yet. TODO: bind to Supabase/Blynk historical series.
