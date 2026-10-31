import 'package:flutter/material.dart';

import '../theme.dart';

/// راهنمای ابزار — پورت `registry/ui/tooltip.tsx`.
///
/// با hover در دسکتاپ و لمس طولانی در موبایل نمایش داده می‌شود؛ همان
/// استایل وب: پس‌زمینه‌ی foreground با متن background.
///
/// ```dart
/// VibeTooltip(content: const Text("ذخیره"), child: const Icon(Icons.save))
/// ```
class VibeTooltip extends StatefulWidget {
  const VibeTooltip({super.key, required this.content, required this.child, this.side = VibeTooltipSide.top});

  final Widget content;
  final Widget child;
  final VibeTooltipSide side;

  @override
  State<VibeTooltip> createState() => _VibeTooltipState();
}

enum VibeTooltipSide { top, bottom }

class _VibeTooltipState extends State<VibeTooltip> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;
  bool _visible = false;

  void _show() {
    if (_visible) return;
    _visible = true;
    _entry = OverlayEntry(builder: _panel);
    Overlay.of(context).insert(_entry!);
  }

  void _hide() {
    if (!_visible) return;
    _visible = false;
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: GestureDetector(onLongPress: _show, onLongPressEnd: (_) => _hide(), child: widget.child),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final t = context.vibe;
    return Positioned(
      child: CompositedTransformFollower(
        link: _layerLink,
        targetAnchor: widget.side == VibeTooltipSide.top ? Alignment.topCenter : Alignment.bottomCenter,
        followerAnchor: widget.side == VibeTooltipSide.top ? Alignment.bottomCenter : Alignment.topCenter,
        offset: Offset(0, widget.side == VibeTooltipSide.top ? -8 : 8),
        showWhenUnlinked: false,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.foreground,
                borderRadius: BorderRadius.circular(VibeRadius.control),
              ),
              constraints: const BoxConstraints(maxWidth: 224),
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: 12, height: 1.5, color: t.background),
                child: widget.content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
