import 'package:flutter/material.dart';

import '../theme.dart';
import 'button.dart';

/// پنجره‌ی مودال — پورت `registry/ui/dialog.tsx`.
///
/// با Escape و کلیک روی پس‌زمینه بسته می‌شود؛ [VibeAlertDialog.show] نسخه‌ی
/// بلاک‌کننده برای عمل مخرب است.
///
/// ```dart
/// await VibeDialog.show(
///   context,
///   title: const Text("حذف حساب"),
///   description: const Text("این کار برگشت‌پذیر نیست."),
///   child: …,
///   footer: …,
/// );
/// ```
abstract final class VibeDialog {
  /// بازکردن پنجره‌ی مودال با استایل وب و بستن با Navigator.
  static Future<T?> show<T>(
    BuildContext context, {
    Widget? title,
    Widget? description,
    Widget? child,
    Widget? footer,
    bool barrierDismissible = true,
  }) {
    final t = VibeTokens.of(context);
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.popover,
              borderRadius: BorderRadius.circular(VibeRadius.surface),
              border: Border.all(color: t.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || description != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              DefaultTextStyle.merge(
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                child: title,
                              ),
                            if (description != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(fontSize: 14, height: 1.6, color: t.mutedForeground),
                                  child: description,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (barrierDismissible)
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Icon(Icons.close, size: 16, color: t.mutedForeground),
                        ),
                    ],
                  ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: child,
                  ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// تأیید عمل — پورت `registry/ui/alert-dialog.tsx`.
///
/// پنجره‌ی بلاک‌کننده برای عمل برگشت‌ناپذیر؛ «انصراف» فوکوس اول را دارد.
///
/// ```dart
/// final ok = await VibeAlertDialog.show(
///   context,
///   title: const Text("حذف سفارش؟"),
///   description: const Text("این کار برگشت‌پذیر نیست."),
///   destructive: true,
///   onConfirm: deleteOrder,
/// );
/// ```
abstract final class VibeAlertDialog {
  /// true اگر تأیید شود.
  static Future<bool> show(
    BuildContext context, {
    required Widget title,
    Widget? description,
    String confirmText = "تأیید",
    String cancelText = "انصراف",
    bool destructive = false,
    required Future<void> Function() onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) {
        final t = VibeTokens.of(dialogContext);
        bool busy = false;
        return StatefulBuilder(
          builder: (dialogContext, setState) => Dialog(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.popover,
                  borderRadius: BorderRadius.circular(VibeRadius.surface),
                  border: Border.all(color: t.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      child: title,
                    ),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: DefaultTextStyle.merge(
                          style: TextStyle(fontSize: 14, height: 1.6, color: t.mutedForeground),
                          child: description,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        VibeButton(
                          variant: destructive ? VibeButtonVariant.destructive : VibeButtonVariant.primary,
                          onPressed: busy
                              ? null
                              : () async {
                                  setState(() => busy = true);
                                  try {
                                    await onConfirm();
                                    if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                                  } finally {
                                    if (dialogContext.mounted) setState(() => busy = false);
                                  }
                                },
                          child: Text(busy ? "لطفاً صبر کنید…" : confirmText),
                        ),
                        const SizedBox(width: 8),
                        VibeButton(
                          variant: VibeButtonVariant.outline,
                          autofocus: true,
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: Text(cancelText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
