import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// کارت نمودار — پورت `registry/charts/chart-core.tsx`.
///
/// قاب مشترک همه‌ی نمودارها: عنوان، زیرعنوان و ارتفاع؛ tooltip‌ها با استایل
/// popover تم رسم می‌شوند.
///
/// ```dart
/// VibeChartCard(
///   title: const Text("فروش هفته"),
///   subtitle: const Text("مبلغ به تومان"),
///   height: 240,
///   child: VibeLineChart(series: [...]),
/// )
/// ```
class VibeChartCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget child;
  final double height;
  final EdgeInsetsGeometry padding;

  const VibeChartCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.height = 240,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.surface),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              child: title!,
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: 12, color: t.mutedForeground),
                child: subtitle!,
              ),
            ),
          if (title != null || subtitle != null) const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// یک سری داده‌ی خطی/میله‌ای.
class VibeChartSeries {
  final String label;
  final List<double> points;
  final Color? color;

  const VibeChartSeries({required this.label, required this.points, this.color});
}

/// رنگ‌های سری‌ها به ترتیب وب: برند، primary، success، warning، destructive، muted.
List<Color> vibeChartPalette(VibeTokens t) => [t.brand, t.primary, t.success, t.warning, t.destructive, t.ring];

/// استایل‌های محور مشترک: خطوط grid از border و متن محور muted.
FlTitlesData vibeTitles(
  VibeTokens t, {
  List<String>? leftLabels,
  List<String>? bottomLabels,
  bool showLeft = true,
  bool showBottom = true,
}) {
  SideTitles side(List<String>? labels) => SideTitles(
        showTitles: labels != null,
        reservedSize: 32,
        getTitlesWidget: labels == null
            ? (v, meta) => const SizedBox.shrink()
            : (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(labels[i], style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                  ),
                );
              },
      );

  return FlTitlesData(
    topTitles: const SideTitles(showTitles: false).toAxis(),
    rightTitles: const SideTitles(showTitles: false).toAxis(),
    leftTitles: showLeft
        ? AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) {
                if (leftLabels != null) {
                  final i = v.toInt();
                  if (i < 0 || i >= leftLabels.length) return const SizedBox.shrink();
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(leftLabels[i], style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                  );
                }
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(faNumber(v), style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                );
              },
            ),
          )
        : const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(sideTitles: side(bottomLabels)),
  );
}

FlGridData vibeGrid(VibeTokens t) => FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (v) => FlLine(color: t.border, strokeWidth: 1),
    );

FlBorderData vibeBorder(VibeTokens t) => FlBorderData(
      show: true,
      border: Border(bottom: BorderSide(color: t.border), left: BorderSide(color: t.border)),
    );

extension _SideTitlesX on SideTitles {
  AxisTitles toAxis() => AxisTitles(sideTitles: this);
}

/// نمودار خط — پورت `registry/charts/line-chart.tsx`.
///
/// برچسب‌ها فارسی، خطوط grid از توکن border و tooltip با faNumber.
///
/// ```dart
/// VibeLineChart(
///   series: [VibeChartSeries(label: "فروش", points: [12, 40, 28])],
///   bottomLabels: const ["شنبه", "یکشنبه", "دوشنبه"],
/// )
/// ```
class VibeLineChart extends StatelessWidget {
  final List<VibeChartSeries> series;
  final List<String>? bottomLabels;
  final double height;
  final bool filled;
  final bool curved;

  const VibeLineChart({
    super.key,
    required this.series,
    this.bottomLabels,
    this.height = 240,
    this.filled = false,
    this.curved = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final palette = vibeChartPalette(t);
    final maxLen = series.map((s) => s.points.length).fold(0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: vibeGrid(t),
        borderData: vibeBorder(t),
        titlesData: vibeTitles(t, bottomLabels: bottomLabels),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => t.popover,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  "${series[spot.barIndex].label}: ${faNumber(spot.y)}",
                  TextStyle(fontSize: 12, color: t.popoverForeground),
                ),
            ],
          ),
        ),
        lineBarsData: [
          for (var i = 0; i < series.length; i++)
            LineChartBarData(
              spots: [
                for (var x = 0; x < series[i].points.length; x++) FlSpot(x.toDouble(), series[i].points[x]),
              ],
              color: series[i].color ?? palette[i % palette.length],
              barWidth: 2,
              isCurved: curved,
              curveSmoothness: 0.3,
              dotData: const FlDotData(show: false),
              belowBarData: filled
                  ? BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (series[i].color ?? palette[i % palette.length]).withValues(alpha: 0.25),
                          (series[i].color ?? palette[i % palette.length]).withValues(alpha: 0.0),
                        ],
                      ),
                    )
                  : BarAreaData(show: false),
            ),
        ],
        minY: 0,
        maxX: (maxLen - 1).toDouble(),
      ),
    );
  }
}

/// نمودار میله‌ای — پورت `registry/charts/bar-chart.tsx`.
class VibeBarChart extends StatelessWidget {
  final List<VibeChartSeries> series;
  final List<String>? bottomLabels;
  final double height;
  final double barWidth;

  const VibeBarChart({
    super.key,
    required this.series,
    this.bottomLabels,
    this.height = 240,
    this.barWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final palette = vibeChartPalette(t);
    final groupCount = series.map((s) => s.points.length).fold(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        gridData: vibeGrid(t),
        borderData: vibeBorder(t),
        titlesData: vibeTitles(t, bottomLabels: bottomLabels),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => t.popover,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(faNumber(rod.toY), TextStyle(fontSize: 12, color: t.popoverForeground)),
          ),
        ),
        barGroups: [
          for (var g = 0; g < groupCount; g++)
            BarChartGroupData(
              x: g,
              barRods: [
                for (var s = 0; s < series.length; s++)
                  if (g < series[s].points.length)
                    BarChartRodData(
                      toY: series[s].points[g],
                      color: series[s].color ?? palette[s % palette.length],
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
              ],
            ),
        ],
      ),
    );
  }
}

/// نمودار سطح — همان خط با پرکردن گرادیانی (پورت area-chart).
class VibeAreaChart extends VibeLineChart {
  const VibeAreaChart({super.key, required super.series, super.bottomLabels, super.height, super.curved})
      : super(filled: true);
}

/// برش نمودار دایره‌ای.
class VibePieSlice {
  final String label;
  final double value;
  final Color? color;

  const VibePieSlice({required this.label, required this.value, this.color});
}

/// نمودار دایره‌ای (دونات) — پورت `registry/charts/pie-chart.tsx`.
class VibePieChart extends StatelessWidget {
  final List<VibePieSlice> slices;
  final double height;

  /// شعاع مرکز خالی؛ 0 = دایره‌ی پر.
  final double holeRadius;
  final bool showLegend;

  const VibePieChart({
    super.key,
    required this.slices,
    this.height = 240,
    this.holeRadius = 40,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final palette = vibeChartPalette(t);
    final total = slices.fold(0.0, (a, s) => a + s.value);

    final chart = PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: holeRadius,
        // tooltip پیش‌فرض خود fl_chart عنوان بخش را نشان می‌دهد.
        pieTouchData: PieTouchData(
          enabled: true,
        ),
        sections: [
          for (var i = 0; i < slices.length; i++)
            PieChartSectionData(
              value: slices[i].value,
              color: slices[i].color ?? palette[i % palette.length],
              radius: 56,
              title: "${(slices[i].value / total * 100).round()}٪",
              titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.background),
            ),
        ],
      ),
    );

    if (!showLegend) return chart;

    return Row(
      children: [
        Expanded(child: chart),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < slices.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slices[i].color ?? palette[i % palette.length],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slices[i].label,
                      style: TextStyle(fontSize: 12, color: t.mutedForeground),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// اسپارک‌لاین — پورت `registry/charts/sparkline.tsx`.
///
/// خط کوچک بدون محور برای کارت‌های آمار.
class VibeSparkline extends StatelessWidget {
  final List<double> points;
  final Color? color;
  final double height;

  const VibeSparkline({super.key, required this.points, this.color, this.height = 32});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final c = color ?? t.brand;
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(points: points, color: c, gridColor: t.border),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final Color gridColor;

  _SparklinePainter({required this.points, required this.color, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final maxV = points.fold(points.first, (a, b) => a > b ? a : b);
    final minV = points.fold(points.first, (a, b) => a < b ? a : b);
    final range = maxV - minV == 0 ? 1 : maxV - minV;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - 2 - (points[i] - minV) / range * (size.height - 4);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.points != points || old.color != color;
}
