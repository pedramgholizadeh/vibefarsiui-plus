import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../jalali.dart';
import '../persian.dart';
import '../theme.dart';
import 'charts.dart';

/// نمودار رادار — پورت `registry/charts/radar-chart.tsx`.
class VibeRadarChart extends StatelessWidget {
  final List<String> labels;
  final List<VibeChartSeries> series;
  final double height;

  const VibeRadarChart({super.key, required this.labels, required this.series, this.height = 260});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final palette = vibeChartPalette(t);
    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
        dataSets: [
          for (var i = 0; i < series.length; i++)
            RadarDataSet(
              dataEntries: [for (final p in series[i].points) RadarEntry(value: p)],
              borderColor: series[i].color ?? palette[i % palette.length],
              fillColor: (series[i].color ?? palette[i % palette.length]).withValues(alpha: 0.18),
              borderWidth: 2,
            ),
        ],
        radarShape: RadarShape.polygon,
        tickCount: 4,
        tickBorderData: BorderSide(color: t.border),
        gridBorderData: BorderSide(color: t.border),
        radarBorderData: BorderSide(color: t.border),
        titleTextStyle: TextStyle(fontSize: 11, color: t.mutedForeground),
        getTitle: (index, angle) => RadarChartTitle(
          text: labels[index],
          positionPercentageOffset: 0.12,
        ),
        ticksTextStyle: TextStyle(fontSize: 9, color: t.mutedForeground),
      ),
      ),
    );
  }
}

/// یک نقطه‌ی نمودار پراکندگی.
class VibeScatterPoint {
  final double x;
  final double y;
  final double size;
  final Color? color;

  const VibeScatterPoint(this.x, this.y, {this.size = 8, this.color});
}

/// نمودار پراکندگی — پورت `registry/charts/scatter-chart.tsx`.
class VibeScatterChart extends StatelessWidget {
  final List<VibeScatterPoint> points;
  final List<String>? bottomLabels;
  final double height;

  const VibeScatterChart({super.key, required this.points, this.bottomLabels, this.height = 240});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final palette = vibeChartPalette(t);
    return ScatterChart(
      ScatterChartData(
        gridData: vibeGrid(t),
        borderData: vibeBorder(t),
        titlesData: vibeTitles(t, bottomLabels: bottomLabels),
        scatterSpots: [
          for (var i = 0; i < points.length; i++)
            ScatterSpot(
              points[i].x,
              points[i].y,
              dotPainter: FlDotCirclePainter(
                radius: points[i].size / 2,
                color: points[i].color ?? palette[i % palette.length],
              ),
            ),
        ],
        minX: 0,
        maxX: 10,
        scatterTouchData: ScatterTouchData(
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipColor: (_) => t.popover,
            getTooltipItems: (spot) => ScatterTooltipItem(
              "(${faNumber(spot.x)}, ${faNumber(spot.y)})",
              textStyle: TextStyle(fontSize: 12, color: t.popoverForeground),
            ),
          ),
        ),
      ),
    );
  }
}

/// گیج (نمودار حلقه‌ای پیشرفت) — پورت `registry/charts/radial-chart.tsx`.
class VibeRadialChart extends StatelessWidget {
  /// ۰ تا ۱.
  final double progress;
  final Widget? center;
  final double size;
  final Color? color;
  final String? label;

  const VibeRadialChart({
    super.key,
    required this.progress,
    this.center,
    this.size = 120,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final c = color ?? t.brand;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _GaugePainter(progress: progress.clamp(0, 1), color: c, track: t.input, background: t.card),
          ),
          center ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    faPercent(progress * 100),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: t.foreground),
                  ),
                  if (label != null)
                    Text(label!, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                ],
              ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  final Color background;

  _GaugePainter({required this.progress, required this.color, required this.track, required this.background});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final stroke = 10.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius + stroke / 2, Paint()..color = background);
    canvas.drawArc(rect, 0, 6.2832, false, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = stroke);
    canvas.drawArc(
      rect,
      // شروع از راست (ساعت ۱۲) و پر شدن ساعتگرد.
      -1.5708,
      6.2832 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress || old.color != color;
}

/// قیف — پورت `registry/charts/funnel-chart.tsx`.
class VibeFunnelChart extends StatelessWidget {
  final List<VibePieSlice> slices;
  final double height;

  const VibeFunnelChart({super.key, required this.slices, this.height = 240});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final palette = vibeChartPalette(t);
    final max = slices.fold(0.0, (a, s) => s.value > a ? s.value : a);

    return Column(
      children: [
        for (var i = 0; i < slices.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    slices[i].label,
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      FractionallySizedBox(
                        widthFactor: (slices[i].value / max).clamp(0.05, 1),
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: slices[i].color ?? palette[i % palette.length],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Text(
                            faNumber(slices[i].value),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.background),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// هیت‌مپ — پورت `registry/charts/heatmap-chart.tsx`.
///
/// شبکه‌ی هفته (شنبه تا جمعه) × روزهای ماه با شدت رنگ برند.
class VibeHeatmapChart extends StatelessWidget {
  /// شدت ۰ تا ۱ برای هر روز از ماه شمسی.
  final int jy;
  final int jm;
  final Map<int, double> intensities;
  final double cellSize;

  const VibeHeatmapChart({
    super.key,
    required this.jy,
    required this.jm,
    required this.intensities,
    this.cellSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final length = jalaliMonthLength(jy, jm);
    // ستون هر روز: شنبه=۰. ۱ ماه = toGregorian(jy,jm,1) weekday.
    final firstWeekday = jalaliWeekday(toGregorian(jy, jm, 1));

    final cells = <Widget>[];
    for (var slot = 0; slot < firstWeekday; slot++) {
      cells.add(_cell(t, slot, 0, empty: true));
    }
    for (var jd = 1; jd <= length; jd++) {
      cells.add(_cell(t, (firstWeekday + jd - 1) % 7, jd));
    }
    while (cells.length % 7 != 0) {
      cells.add(_cell(t, cells.length % 7, 0, empty: true));
    }

    final rows = <Widget>[];
    for (var r = 0; r < cells.length / 7; r++) {
      rows.add(Row(children: cells.sublist(r * 7, r * 7 + 7)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final w in jalaliWeekdaysShort)
              SizedBox(
                width: cellSize,
                child: Center(child: Text(w, style: TextStyle(fontSize: 9, color: t.mutedForeground))),
              ),
          ],
        ),
        ...rows,
      ],
    );
  }

  Widget _cell(VibeTokens t, int column, int jd, {bool empty = false}) {
    final intensity = empty ? 0.0 : (intensities[jd] ?? 0).clamp(0.0, 1.0);
    return Container(
      width: cellSize,
      height: cellSize,
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: empty
            ? null
            : intensity == 0
                ? t.muted
                : Color.lerp(t.muted, t.brand, 0.15 + 0.85 * intensity),
      ),
      child: jd == 0
          ? null
          : Text(
              fa(jd),
              style: TextStyle(
                fontSize: 9,
                color: intensity > 0.55 ? t.brandForeground : t.mutedForeground,
              ),
            ),
    );
  }
}
