import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «نمودارها» مثل سایت اصلی.
class ChartsShowcase extends StatelessWidget {
  const ChartsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShowSection(
          title: "خطی",
          child: VibeLineChart(
            series: [
              VibeChartSeries(label: "فروش", points: [12, 40, 28, 52, 44, 68]),
              VibeChartSeries(label: "بازدید", points: [22, 32, 38, 44, 56, 60]),
            ],
            bottomLabels: ["شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه"],
            height: 220,
          ),
        ),
        const ShowSection(
          title: "ناحیه‌ای",
          child: VibeAreaChart(
            series: [
              VibeChartSeries(label: "سود", points: [8, 18, 14, 30, 26, 42, 55]),
            ],
            bottomLabels: ["فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور", "مهر"],
            height: 200,
          ),
        ),
        const ShowSection(
          title: "میله‌ای",
          child: VibeBarChart(
            series: [
              VibeChartSeries(label: "سفارش", points: [34, 52, 41, 68, 58, 72]),
            ],
            bottomLabels: ["شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه"],
            height: 200,
          ),
        ),
        const ShowSection(
          title: "دایره‌ای",
          child: VibePieChart(
            slices: [
              VibePieSlice(label: "موبایل", value: 46),
              VibePieSlice(label: "دسکتاپ", value: 32),
              VibePieSlice(label: "تبلت", value: 22),
            ],
            height: 200,
          ),
        ),
        const ShowSection(
          title: "رادار",
          child: VibeRadarChart(
            labels: ["سرعت", "کیفیت", "پشتیبانی", "قیمت", "طراحی"],
            series: [
              VibeChartSeries(label: "ما", points: [80, 90, 70, 85, 95]),
            ],
            height: 220,
          ),
        ),
        ShowSection(
          title: "گیج",
          child: Wrap(
            spacing: 24,
            children: [
              const VibeRadialChart(progress: 0.72, label: "انبار"),
              VibeRadialChart(progress: 0.45, color: t.success, label: "ارسال"),
              VibeRadialChart(progress: 0.9, color: t.warning, label: "مرجوعی"),
            ],
          ),
        ),
        const ShowSection(
          title: "قیف فروش",
          child: VibeFunnelChart(slices: [
            VibePieSlice(label: "بازدید", value: 12400),
            VibePieSlice(label: "سبد خرید", value: 3600),
            VibePieSlice(label: "پرداخت", value: 1800),
            VibePieSlice(label: "تحویل", value: 1520),
          ]),
        ),
        const ShowSection(
          title: "نقشه‌ی حرارتی شمسی",
          child: VibeHeatmapChart(
            jy: 1405,
            jm: 8,
            intensities: {
              2: 0.9, 3: 0.6, 5: 0.3, 9: 1.0, 10: 0.7, 12: 0.5, 16: 0.8, 17: 0.4, 19: 0.95, 23: 0.6, 25: 0.75, 28: 0.35,
            },
          ),
        ),
      ],
    );
  }
}
