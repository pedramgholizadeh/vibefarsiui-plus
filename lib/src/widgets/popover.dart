import 'package:flutter/material.dart';

import '../theme.dart';

/// پاپ‌آور — پورت `registry/ui/popover.tsx`.
///
/// پنل کوچک لنگر‌شده به تریگر؛ با کلیک بیرون و Escape می‌بندد. «start»
/// چسبیده به ابتدای سطر تریگر (راست در RTL).
///
/// ```dart
/// VibePopover(
///   trigger: const VibeButton(child: Text("گزینه‌ها")),
///   child: const MenuItems(),
/// )
/// ```
class VibePopover extends StatefulWidget {
  const VibePopover({
    super.key,
    required this.trigger,
    required this.child,
    this.side = VibePopoverSide.bottom,
    this.width = 240,
  });

  final Widget trigger;
  final Widget child;
  final VibePopoverSide side;

  /// عرض ثابت پنل مثل وب.
  final double width;

  @override
  State<VibePopover> createState() => _VibePopoverState();
}

enum VibePopoverSide { top, bottom }

class _VibePopoverState extends State<VibePopover> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;
  bool _open = false;

  void _set(bool v) {
    if (v == _open) return;
    setState(() => _open = v);
    if (v) {
      _entry = OverlayEntry(builder: _panel);
      Overlay.of(context).insert(_entry!);
    } else {
      _entry?.remove();
      _entry = null;
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () { _set(!_open); },
        child: Semantics(
          button: true,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: t.foreground),
            child: widget.trigger,
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final t = context.vibe;
    return Stack(
      children: [
        // کلیک بیرون می‌بندد.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _set(false),
            onSecondaryTap: () => _set(false),
          ),
        ),
        Positioned(
          width: widget.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: widget.side == VibePopoverSide.bottom ? Alignment.bottomLeft : Alignment.topLeft,
            followerAnchor: widget.side == VibePopoverSide.bottom ? Alignment.topLeft : Alignment.bottomLeft,
            offset: Offset(0, widget.side == VibePopoverSide.bottom ? 4 : -4),
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.popover,
                  borderRadius: BorderRadius.circular(VibeRadius.field),
                  border: Border.all(color: t.border),
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 14, color: t.popoverForeground),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
