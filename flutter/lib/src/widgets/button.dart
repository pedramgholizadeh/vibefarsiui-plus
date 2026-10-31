import 'package:flutter/material.dart';

import '../theme.dart';

/// واریانت دکمه — همان واریانت‌های دکمه‌ی وب وایب‌فارسی.
enum VibeButtonVariant { primary, secondary, outline, ghost, brand, destructive }

/// اندازه‌ی دکمه.
enum VibeButtonSize { small, medium, large, icon }

/// دکمه‌ی وایب‌فارسی — پورت `registry/ui/button.tsx`.
///
/// شش واریانت و چهار اندازه، حالت غیرفعال با کاهش شفافیت، فشردگی با مقیاس ۰٫۹۸
/// و انیمیشن ۲۰۰ میلی‌ثانیه‌ای؛ همه از توکن‌های تم می‌آیند.
///
/// ```dart
/// VibeButton(onPressed: submit, child: Text("ثبت سفارش"))
/// VibeButton(variant: VibeButtonVariant.outline, onPressed: cancel, child: Text("انصراف"))
/// VibeButton(variant: VibeButtonVariant.brand, onPressed: add, leading: Icon(Icons.add), child: Text("محصول جدید"))
/// ```
class VibeButton extends StatefulWidget {
  const VibeButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = VibeButtonVariant.primary,
    this.size = VibeButtonSize.medium,
    this.leading,
    this.trailing,
    this.autofocus = false,
  });

  /// عمل دکمه؛ null یعنی غیرفعال (شفافیت ۵۰٪).
  final VoidCallback? onPressed;
  final Widget child;
  final VibeButtonVariant variant;
  final VibeButtonSize size;

  /// آیکون یا ویجت قبل از متن (در RTL سمت راست می‌نشیند).
  final Widget? leading;

  /// آیکون یا ویجت بعد از متن (در RTL سمت چپ می‌نشیند).
  final Widget? trailing;
  final bool autofocus;

  @override
  State<VibeButton> createState() => _VibeButtonState();
}

class _VibeButtonState extends State<VibeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final (background, foreground, border) = switch (widget.variant) {
      VibeButtonVariant.primary => (t.primary, t.primaryForeground, Colors.transparent),
      VibeButtonVariant.secondary => (t.secondary, t.secondaryForeground, t.border),
      VibeButtonVariant.outline => (Colors.transparent, t.foreground, t.input),
      VibeButtonVariant.ghost => (Colors.transparent, t.foreground, Colors.transparent),
      VibeButtonVariant.brand => (t.brand, t.brandForeground, Colors.transparent),
      VibeButtonVariant.destructive => (t.destructive, Colors.white, Colors.transparent),
    };

    final (height, padding, gap, fontSize, iconSize) = switch (widget.size) {
      VibeButtonSize.small => (32.0, 12.0, 6.0, 13.0, 16.0),
      VibeButtonSize.medium => (40.0, 16.0, 8.0, 14.0, 16.0),
      VibeButtonSize.large => (48.0, 24.0, 10.0, 16.0, 20.0),
      VibeButtonSize.icon => (40.0, 0.0, 0.0, 14.0, 18.0),
    };

    final enabled = widget.onPressed != null;

    Widget content;
    if (widget.size == VibeButtonSize.icon) {
      content = IconTheme(
        data: IconThemeData(size: iconSize, color: foreground),
        child: widget.child,
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null)
            IconTheme.merge(
              data: IconThemeData(size: iconSize, color: foreground),
              child: widget.leading!,
            ),
          if (widget.leading != null) SizedBox(width: gap),
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: foreground,
              height: 1.2,
            ),
            child: widget.child,
          ),
          if (widget.trailing != null) SizedBox(width: gap),
          if (widget.trailing != null)
            IconTheme.merge(
              data: IconThemeData(size: iconSize, color: foreground),
              child: widget.trailing!,
            ),
        ],
      );
    }

    return AnimatedScale(
      scale: _pressed && enabled ? VibePress.scale : 1.0,
      duration: VibeMotion.duration,
      curve: VibeMotion.ease,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: FocusableActionDetector(
          autofocus: widget.autofocus,
          mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onShowFocusHighlight: (_) {},
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
            onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: VibeMotion.duration,
              curve: VibeMotion.ease,
              height: height,
              padding: widget.size == VibeButtonSize.icon ? null : EdgeInsets.symmetric(horizontal: padding),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(VibeRadius.control),
                border: Border.all(color: border),
              ),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
