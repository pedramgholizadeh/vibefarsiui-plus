import 'package:flutter/material.dart';

import '../theme.dart';

/// جهت بازشدن کشو.
enum VibeSheetSide { start, end, bottom }

/// کشو — پورت `registry/ui/sheet.tsx`.
///
/// پنل کناری برای فیلترها، سبد خرید و ناوبری موبایل؛ «start» از راست در RTL
/// باز می‌شود (سمت طبیعی فارسی) و انیمیشن فنری ۴۸۰ میلی‌ثانیه‌ای دارد.
///
/// ```dart
/// await VibeSheet.show(
///   context,
///   title: const Text("فیلترها"),
///   child: const FilterForm(),
/// );
/// ```
abstract final class VibeSheet {
  /// بازکردن کشو؛ وقتی کاربر ببندد null برمی‌گردد.
  static Future<T?> show<T>(
    BuildContext context, {
    Widget? title,
    Widget? child,
    VibeSheetSide side = VibeSheetSide.start,
    double width = 360,
    bool useSafeArea = true,
  }) {
    final t = VibeTokens.of(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "بستن کشو",
      barrierColor: const Color(0x99000000),
      pageBuilder: (dialogContext, _, __) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, __, panel) {
        // فنر ≈ stiffness:150, damping:22 وب.
        final curved = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.32, 0.72, 0, 1),
          reverseCurve: const Cubic(0.32, 0.72, 0, 1),
        );
        Widget slide(Widget content) {
          final slideIn = Tween<Offset>(
            begin: switch (side) {
              VibeSheetSide.start => const Offset(1, 0), // از راست بیرون
              VibeSheetSide.end => const Offset(-1, 0),
              VibeSheetSide.bottom => const Offset(0, 1),
            },
            end: Offset.zero,
          ).animate(curved);
          return SlideTransition(position: slideIn, child: content);
        }

        final panelBox = Container(
          width: side == VibeSheetSide.bottom ? double.infinity : width,
          height: side == VibeSheetSide.bottom ? null : double.infinity,
          decoration: BoxDecoration(
            color: t.popover,
            border: switch (side) {
              VibeSheetSide.start => Border(left: BorderSide(color: t.border)),
              VibeSheetSide.end => Border(right: BorderSide(color: t.border)),
              VibeSheetSide.bottom => Border(top: BorderSide(color: t.border)),
            },
            borderRadius: side == VibeSheetSide.bottom
                ? const BorderRadius.vertical(top: Radius.circular(22))
                : BorderRadius.zero,
          ),
          child: SafeArea(
            top: side != VibeSheetSide.bottom || !useSafeArea,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: DefaultTextStyle.merge(
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            child: title,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Icon(Icons.close, size: 16, color: t.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                if (child != null) Expanded(child: child),
              ],
            ),
          ),
        );

        return slide(Align(
          alignment: switch (side) {
            VibeSheetSide.start => AlignmentDirectional.centerStart,
            VibeSheetSide.end => AlignmentDirectional.centerEnd,
            VibeSheetSide.bottom => Alignment.bottomCenter,
          },
          child: panelBox,
        ));
      },
    );
  }
}
