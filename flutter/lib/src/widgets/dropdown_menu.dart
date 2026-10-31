import 'package:flutter/material.dart';

import '../theme.dart';

/// نوع آیتم منو: گزینه، جداکننده یا برچسب بخش.
enum VibeMenuItemKind { item, separator, section }

/// یک آیتم منو — پورت `MenuItem` وب.
class VibeMenuItem {
  final VibeMenuItemKind kind;
  final Widget? label;
  final IconData? icon;
  final String? shortcut;
  final bool danger;
  final bool disabled;
  final VoidCallback? onSelect;

  const VibeMenuItem.item({
    required Widget this.label,
    this.icon,
    this.shortcut,
    this.danger = false,
    this.disabled = false,
    this.onSelect,
  }) : kind = VibeMenuItemKind.item;

  const VibeMenuItem.separator()
      : kind = VibeMenuItemKind.separator,
        label = null,
        icon = null,
        shortcut = null,
        danger = false,
        disabled = false,
        onSelect = null;

  const VibeMenuItem.section(Widget this.label)
      : kind = VibeMenuItemKind.section,
        icon = null,
        shortcut = null,
        danger = false,
        disabled = false,
        onSelect = null;
}

/// منوی کشویی — پورت `registry/ui/dropdown-menu.tsx`.
///
/// زیر تریگر و چسبیده به ابتدای سطر (راست در RTL) باز می‌شود؛ با کلیک بیرون
/// و Escape می‌بندد.
///
/// ```dart
/// VibeDropdownMenu(
///   trigger: const Icon(Icons.more_vert),
///   items: const [
///     VibeMenuItem.section(Text("عملیات")),
///     VibeMenuItem.item(label: Text("ویرایش"), icon: Icons.edit_outlined),
///     VibeMenuItem.separator(),
///     VibeMenuItem.item(label: Text("حذف"), danger: true),
///   ],
/// )
/// ```
class VibeDropdownMenu extends StatefulWidget {
  const VibeDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.width = 200,
  });

  final Widget trigger;
  final List<VibeMenuItem> items;
  final double width;

  @override
  State<VibeDropdownMenu> createState() => _VibeDropdownMenuState();
}

class _VibeDropdownMenuState extends State<VibeDropdownMenu> {
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
        onTap: () => _set(!_open),
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
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _set(false),
          ),
        ),
        Positioned(
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.popover,
                  borderRadius: BorderRadius.circular(VibeRadius.field),
                  border: Border.all(color: t.border),
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 14, color: t.popoverForeground),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in widget.items)
                        switch (item.kind) {
                          VibeMenuItemKind.separator => Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: t.border,
                            ),
                          VibeMenuItemKind.section => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: DefaultTextStyle.merge(
                                style: TextStyle(fontSize: 12, color: t.mutedForeground),
                                child: item.label!,
                              ),
                            ),
                          VibeMenuItemKind.item => _row(context, t, item),
                        },
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, VibeTokens t, VibeMenuItem item) {
    final color = item.danger ? t.destructive : t.popoverForeground;
    return InkWell(
      onTap: item.disabled || item.onSelect == null
          ? null
          : () {
              _set(false);
              item.onSelect!();
            },
      borderRadius: BorderRadius.circular(6),
      child: Opacity(
        opacity: item.disabled ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 16, color: color),
                const SizedBox(width: 8),
              ],
              Expanded(child: DefaultTextStyle.merge(style: TextStyle(color: color), child: item.label!)),
              if (item.shortcut != null)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(item.shortcut!, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
