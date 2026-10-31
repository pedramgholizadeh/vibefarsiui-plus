import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// اندازه‌ی کارت آمار.
enum VibeStatSize { sm, md }

/// کارت آمار — پورت `registry/ui/stat.tsx`.
///
/// یک عدد کلیدی با برچسب و درصد تغییر نسبت به دوره‌ی قبل؛ فلش به سمت
/// بالا-چپ اشاره می‌کند (جهتِ «بالا و جلو» در راست‌چین). رنگ مثبت `success`
/// و رنگ منفی `destructive` است.
///
/// ```dart
/// VibeStat(label: "فروش امروز", value: "۱۲٬۴۵۰٬۰۰۰", unit: Text("تومان"), delta: 12.4)
/// VibeStat(label: "مرجوعی", value: "۳", delta: -4, size: VibeStatSize.sm)
/// ```
class VibeStat extends StatelessWidget {
  const VibeStat({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    this.deltaLabel = "نسبت به دوره‌ی قبل",
    this.size = VibeStatSize.md,
  });

  /// برچسب آمار؛ معمولاً متن کم‌رنگ کوتاه.
  final Widget label;

  /// عدد اصلی؛ اعداد را از قبل با `faNumber` فارسی کنید.
  final Widget value;

  /// واحد کنار عدد (مثل «تومان»)، کوچک و کم‌رنگ.
  final Widget? unit;

  /// درصد تغییر نسبت به دوره‌ی قبل؛ علامت، جهت فلش و رنگ را تعیین می‌کند.
  final num? delta;

  /// توضیح درصد (برای tooltip وب)؛ به‌عنوان برچسب دسترس‌پذیری هم استفاده می‌شود.
  final String deltaLabel;

  final VibeStatSize size;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final small = size == VibeStatSize.sm;
    final up = (delta ?? 0) >= 0;

    return Container(
      padding: EdgeInsets.all(small ? 12 : 16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.overlay), // rounded-xl وب
        border: Border.all(color: t.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: t.mutedForeground, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: label,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: small ? 16 : 20,
                    fontWeight: FontWeight.w700,
                    color: t.foreground,
                    height: 1.25,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: value,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                    child: unit!,
                  ),
                ),
              ],
              if (delta != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Semantics(
                    label: "$deltaLabel ${faPercent(delta!.abs())}",
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            up ? Icons.north_west : Icons.south_west,
                            size: 14,
                            color: up ? t.success : t.destructive,
                          ),
                          Text(
                            faPercent(delta!.abs()),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: up ? t.success : t.destructive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
