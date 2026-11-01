import 'package:flutter/material.dart';

import '../theme.dart';

/// بازشو — پورت `registry/ui/collapsible.tsx`.
///
/// بلوکی را با دکمه‌ی برچسب‌دار نشان/پنهان می‌کند؛ ارتفاع با انیمیشنِ
/// ۲۰۰ میلی‌ثانیه‌ای زبان طراحی باز و بسته می‌شود و محتوا در درخت می‌ماند
/// (state آن حفظ می‌شود). با `openLabel` برچسب دکمه در حالت باز عوض می‌شود.
///
/// ```dart
/// VibeCollapsible(
///   trigger: Text("نمایش بیشتر"),
///   openLabel: Text("نمایش کمتر"),
///   child: Text("متن بلند…"),
/// )
/// ```
class VibeCollapsible extends StatefulWidget {
  const VibeCollapsible({
    super.key,
    required this.trigger,
    this.openLabel,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.disabled = false,
    required this.child,
  });

  /// برچسب دکمه‌ی باز/بسته.
  final Widget trigger;

  /// برچسب جایگزین در حالت باز (مثل «نمایش کمتر»).
  final Widget? openLabel;

  /// کنترل حالت باز از بیرون؛ خالی یعنی state داخلی.
  final bool? open;

  final bool defaultOpen;

  /// خبردادن تغییر حالت؛ هم برای controlled و هم uncontrolled صدا می‌شود.
  final ValueChanged<bool>? onOpenChange;

  final bool disabled;

  final Widget child;

  @override
  State<VibeCollapsible> createState() => _VibeCollapsibleState();
}

class _VibeCollapsibleState extends State<VibeCollapsible> {
  bool _internal = false;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultOpen;
  }

  bool get _isOpen => widget.open ?? _internal;

  void _toggle() {
    if (widget.open == null) {
      setState(() => _internal = !_internal);
    }
    widget.onOpenChange?.call(!_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final isOpen = _isOpen;
    final label = isOpen && widget.openLabel != null ? widget.openLabel! : widget.trigger;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: widget.disabled ? 0.5 : 1,
          child: MouseRegion(
            cursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.disabled ? null : _toggle,
              child: Semantics(
                button: true,
                enabled: !widget.disabled,
                expanded: isOpen,
                child: DefaultTextStyle.merge(
                  // text-sm font-medium text-foreground/90 وب
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: t.foreground.withValues(alpha: 0.90),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      label,
                      const SizedBox(width: 6), // gap-1.5
                      ExcludeSemantics(
                        child: AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: VibeMotion.duration,
                          curve: VibeMotion.ease,
                          child: Icon(
                            Icons.expand_more,
                            size: 16,
                            color: t.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _AnimatedReveal(open: isOpen, child: widget.child),
      ],
    );
  }
}

/// انیمیشن ارتفاع با ضریب ارتفاع (معادل grid-rows-[0fr→1fr] وب)؛
/// فرزند همیشه در درخت است و state آن حفظ می‌شود.
class _AnimatedReveal extends StatelessWidget {
  const _AnimatedReveal({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? 1 : 0),
      duration: VibeMotion.duration,
      curve: VibeMotion.ease,
      builder: (context, v, content) => ClipRect(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          heightFactor: v,
          child: content,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8), // pt-2
        child: child,
      ),
    );
  }
}
