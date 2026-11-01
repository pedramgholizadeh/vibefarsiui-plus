import 'package:flutter/material.dart';

import '../theme.dart';

/// کارت وایب‌فارسی — پورت `registry/ui/card.tsx`.
///
/// سطح کارت: پس‌زمینه‌ی `card`، حاشیه‌ی `border`، شعاع `surface` و یک خط نوری
/// داخلی (سایه‌ی سطح وب). محتوا با [VibeCardHeader] و [VibeCardContent] چیده می‌شود.
///
/// ```dart
/// VibeCard(
///   child: Column(
///     children: [
///       VibeCardHeader(title: Text("سفارش"), description: Text("جزئیات آخرین سفارش")),
///       VibeCardContent(child: Text("متن کارت")),
///     ],
///   ),
/// )
/// ```
class VibeCard extends StatelessWidget {
  const VibeCard({super.key, required this.child, this.padding});

  /// محتوای کارت؛ معمولاً ستونی از [VibeCardHeader] و [VibeCardContent].
  final Widget child;

  /// پدینگ داخلی اختیاری؛ خود کارت وب پدینگ ندارد و بخش‌ها جدا پدینگ می‌گیرند.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.surface),
        border: Border.all(color: t.border),
        // shadow-surface وب: خط نوری یک‌پیکسلی در لبه‌ی بالای کارت
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FFFFFFF), // سفید ۶٪ — مثل oklch(1 0 0 / 6%) تم گرافیت
            offset: Offset(0, 1),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: t.cardForeground),
        child: child,
      ),
    );
  }
}

/// سربرگ کارت — پورت `CardHeader` + `CardTitle` + `CardDescription` از `registry/ui/card.tsx`.
///
/// پدینگ ۲۰ و فاصله‌ی ۴ بین عنوان و توضیح، مثل وب. اگر عناوین سفارشی می‌خواهید
/// `title` و `description` را کنار بگذارید و `child` بدهید.
class VibeCardHeader extends StatelessWidget {
  const VibeCardHeader({super.key, this.title, this.description, this.child});

  /// عنوان کارت — `text-base` (۱۴) و وزن نیمه‌ضخیم.
  final Widget? title;

  /// توضیح زیر عنوان — `text-sm` (۱۳) با رنگ کم‌رنگ.
  final Widget? description;

  /// چیدمان کاملاً سفارشی به‌جای عنوان/توضیح.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (child != null)
            child!
          else ...[
            if (title != null)
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: t.cardForeground,
                  height: 1.45,
                ),
                child: title!,
              ),
            if (title != null && description != null) const SizedBox(height: 4),
            if (description != null)
              DefaultTextStyle.merge(
                style: TextStyle(fontSize: 13, color: t.mutedForeground, height: 1.7),
                child: description!,
              ),
          ],
        ],
      ),
    );
  }
}

/// بدنه‌ی کارت — پورت `CardContent` از `registry/ui/card.tsx`.
///
/// پدینگ ۲۰ از هر طرف و بدون پدینگ بالا (چون سربرگ بالایش است): `p-5 pt-0`.
class VibeCardContent extends StatelessWidget {
  const VibeCardContent({super.key, required this.child, this.padding});

  final Widget child;

  /// پدینگ سفارشی؛ پیش‌فرض همان `p-5 pt-0` وب.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: child,
    );
  }
}
