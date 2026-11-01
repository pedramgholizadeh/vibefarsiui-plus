import 'package:flutter/material.dart';

import '../theme.dart';

/// کارت شناور — پورت `registry/ui/hover-card.tsx`.
///
/// با hover در دسکتاپ و نگه‌داشتن انگشت در موبایل؛ مثل کارت پروفایل یا
/// پیش‌نمایش لینک.
///
/// ```dart
/// VibeHoverCard(
///   trigger: const Text("@sara"),
///   child: const ProfileCard(),
/// )
/// ```
class VibeHoverCard extends StatefulWidget {
  const VibeHoverCard({super.key, required this.trigger, required this.child, this.width = 280});

  final Widget trigger;
  final Widget child;
  final double width;

  @override
  State<VibeHoverCard> createState() => _VibeHoverCardState();
}

class _VibeHoverCardState extends State<VibeHoverCard> {
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
      child: MouseRegion(
        onEnter: (_) => _set(true),
        onExit: (_) => _set(false),
        child: GestureDetector(
          onLongPressStart: (_) => _set(true),
          onLongPressEnd: (_) => _set(false),
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
    return Positioned(
      width: widget.width,
      child: CompositedTransformFollower(
        link: _layerLink,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 4),
        showWhenUnlinked: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.popover,
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.border),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: 14, color: t.popoverForeground, height: 1.6),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
