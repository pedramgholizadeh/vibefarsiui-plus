import 'package:flutter/material.dart';

import '../jalali.dart';
import '../theme.dart';

/// یک رویداد خط زمان: تاریخ (DateTime، JalaliDate یا رشته‌ی آماده)، عنوان و توضیح.
class VibeTimelineItem {
  final Object date;
  final Widget title;
  final Widget? description;

  const VibeTimelineItem({required this.date, required this.title, this.description});

  String get dateLabel {
    final d = date;
    return switch (d) {
      DateTime() => formatJalali(d),
      JalaliDate() => d.format(),
      _ => d.toString(),
    };
  }
}

/// خط زمان — پورت `registry/ui/timeline.tsx`.
///
/// ریل در ابتدای سطر (در RTL سمت راست) قرار دارد؛ نقطه‌ی رویداد فعال با رنگ
/// اصلی پر می‌شود و تاریخ‌ها با تقویم شمسی نمایش داده می‌شوند.
///
/// ```dart
/// VibeTimeline(items: [
///   VibeTimelineItem(date: JalaliDate.now(), title: Text("ثبت سفارش")),
///   VibeTimelineItem(date: "۱۴۰۵/۰۶/۲۵", title: Text("ارسال مرسوله")),
/// ], activeIndex: 1)
/// ```
class VibeTimeline extends StatelessWidget {
  final List<VibeTimelineItem> items;

  /// اندیس رویداد جاری؛ نقطه‌ی آن پر است.
  final int activeIndex;

  const VibeTimeline({super.key, required this.items, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ریل: خط عمودی + نقطه‌ی رویداد، همیشه در ابتدای سطر.
                SizedBox(
                  width: 20,
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == activeIndex ? t.primary : t.mutedForeground.withValues(alpha: 0.5),
                          border: Border.all(color: t.background, width: 2),
                        ),
                      ),
                      if (i != items.length - 1)
                        Expanded(
                          child: Container(width: 1, color: t.border),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle.merge(
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45),
                          child: items[i].title,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].dateLabel,
                          style: TextStyle(fontSize: 11, color: t.mutedForeground),
                        ),
                        if (items[i].description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: DefaultTextStyle.merge(
                              style: TextStyle(fontSize: 12, color: t.mutedForeground, height: 1.6),
                              child: items[i].description!,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
