import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// اندازه‌ی قیمت.
enum VibePriceSize { sm, md, lg }

/// قیمت — پورت `registry/ui/price.tsx`.
///
/// عدد با جداکننده‌ی هزارگان «٬»، واحد بعد از عدد و تخفیفِ حساب‌شده:
/// با `original` (قیمت قبل از تخفیف) خط‌خورده و برچسب درصد چاپ می‌شود.
///
/// ```dart
/// VibePrice(amount: 12450000)
/// VibePrice(amount: 990000, original: 1200000, unit: "تومان", size: VibePriceSize.lg)
/// ```
class VibePrice extends StatelessWidget {
  const VibePrice({
    super.key,
    required this.amount,
    this.original,
    this.unit = "تومان",
    this.size = VibePriceSize.md,
  });

  /// مبلغ فعلی (تومان یا هر واحدی که `unit` می‌گوید).
  final num amount;

  /// قیمت قبل از تخفیف؛ فقط وقتی از `amount` بزرگ‌تر باشد نشان داده می‌شود.
  final num? original;

  /// واحد پول؛ بعد از عدد چاپ می‌شود.
  final String unit;

  final VibePriceSize size;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final off =
        original != null && original! > amount ? ((1 - amount / original!) * 100).round() : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              faNumber(amount),
              style: TextStyle(
                fontSize: switch (size) {
                  VibePriceSize.sm => 14,
                  VibePriceSize.md => 20,
                  VibePriceSize.lg => 24,
                },
                fontWeight: FontWeight.w700,
                color: t.foreground,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            Text(unit, style: TextStyle(fontSize: 13, color: t.mutedForeground)),
          ],
        ),
        if (off > 0) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                faNumber(original!),
                style: TextStyle(
                  fontSize: 12,
                  color: t.mutedForeground,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: t.mutedForeground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: t.foreground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "${faPercent(off)} تخفیف",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: t.background,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
