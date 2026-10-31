import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';
import 'parts.dart';

/// ابزارهای پایه: اعداد فارسی، تومان، زمان نسبی و دکمه.
class FoundationShowcase extends StatelessWidget {
  const FoundationShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "اعداد فارسی",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("fa(1405) → ${fa(1405)}"),
              Text("faNumber(12450000) → ${faNumber(12450000)}"),
              Text("formatToman(12450000) → ${formatToman(12450000)}"),
              Text("faPercent(18.4, digits: 1) → ${faPercent(18.4, digits: 1)}"),
              Text("faFileSize(1258291) → ${faFileSize(1258291)}"),
              Text("timeAgo(۵ دقیقه پیش) → ${timeAgo(DateTime.now().subtract(const Duration(minutes: 5)))}"),
            ],
          ),
        ),
        ShowSection(
          title: "دکمه‌ها",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VibeButton(onPressed: () {}, child: const Text("ثبت سفارش")),
              VibeButton(
                variant: VibeButtonVariant.secondary,
                onPressed: () {},
                child: const Text("ذخیره"),
              ),
              VibeButton(
                variant: VibeButtonVariant.outline,
                size: VibeButtonSize.small,
                onPressed: () {},
                child: const Text("انصراف"),
              ),
              VibeButton(
                variant: VibeButtonVariant.brand,
                onPressed: () {},
                leading: const Icon(Icons.add),
                child: const Text("محصول جدید"),
              ),
              VibeButton(
                variant: VibeButtonVariant.destructive,
                onPressed: () {},
                child: const Text("حذف"),
              ),
              const VibeButton(onPressed: null, child: Text("غیرفعال")),
            ],
          ),
        ),
        ShowSection(
          title: "توکن‌های تم",
          child: Wrap(
            spacing: 8,
            children: [
              for (final (name, color) in [
                ("brand", t.brand),
                ("success", t.success),
                ("warning", t.warning),
                ("destructive", t.destructive),
                ("primary", t.primary),
              ])
                Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(VibeRadius.control),
                        border: Border.all(color: t.border),
                      ),
                    ),
                    Text(name, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

