import 'package:flutter/material.dart';

import '../theme.dart';
import 'dropdown_menu.dart';

/// منوی راست‌کلیک — پورت `registry/ui/context-menu.tsx`.
///
/// سر مکان اشاره‌گر باز می‌شود؛ Escape و کلیک بیرون می‌بندد. همان `MenuItem`
/// منوی کشویی را می‌پذیرد.
///
/// ```dart
/// VibeContextMenu(
///   items: const [VibeMenuItem.item(label: Text("کپی"))],
///   child: const FileCard(),
/// )
/// ```
class VibeContextMenu extends StatefulWidget {
  const VibeContextMenu({super.key, required this.items, required this.child, this.width = 200});

  final List<VibeMenuItem> items;
  final Widget child;
  final double width;

  @override
  State<VibeContextMenu> createState() => _VibeContextMenuState();
}

class _VibeContextMenuState extends State<VibeContextMenu> {
  void _open(BuildContext context, Offset globalPosition) {
    final t = context.vibe;
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => entry.remove(),
              onSecondaryTap: () => entry.remove(),
            ),
          ),
          Positioned(
            left: (globalPosition.dx).clamp(0, MediaQuery.sizeOf(context).width - widget.width),
            top: globalPosition.dy,
            width: widget.width,
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
                          VibeMenuItemKind.item => InkWell(
                              onTap: item.disabled || item.onSelect == null
                                  ? null
                                  : () {
                                      entry.remove();
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
                                        Icon(item.icon, size: 16, color: item.danger ? t.destructive : t.popoverForeground),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: DefaultTextStyle.merge(
                                          style: TextStyle(color: item.danger ? t.destructive : t.popoverForeground),
                                          child: item.label!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        },
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _open(context, details.globalPosition),
      onSecondaryTapUp: (details) => _open(context, details.globalPosition),
      child: widget.child,
    );
  }
}
