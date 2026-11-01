import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «پس‌زمینه‌ها» مثل سایت اصلی: هر الگو پشت یک کارت متن.
class BackgroundsShowcase extends StatelessWidget {
  const BackgroundsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    Widget card(String title, Widget background, {Color textColor = Colors.transparent}) {
      return SizedBox(
        width: 280,
        height: 170,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(VibeRadius.field),
              child: background,
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.foreground),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "الگوهای ثابت",
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              card("گرید", const VibeGridBackground()),
              card("نقطه‌چین", const VibeDotsBackground()),
              card("موج", const VibeWavesBackground()),
              card("ستاره", const VibeStarsBackground()),
              card("نور گوشه", const VibeLightLeakBackground()),
              card("مش رنگی", const VibeMeshBackground()),
            ],
          ),
        ),
        ShowSection(
          title: "گرادیان متحرک",
          child: SizedBox(
            width: double.infinity,
            height: 190,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VibeRadius.field),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const VibeAuroraBackground(),
                  Center(
                    child: Text(
                      "شفق قطبی",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: t.foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
