import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// یک آیتم سایدبار.
class VibeSidebarItem {
  final IconData? icon;
  final Widget label;

  /// نشان عددی یا متنی کنار آیتم.
  final Object? badge;
  final bool active;
  final VoidCallback? onTap;

  const VibeSidebarItem({this.icon, required this.label, this.badge, this.active = false, this.onTap});
}

/// یک بخش سایدبار: سرفصل اختیاری + آیتم‌ها.
class VibeSidebarSection {
  final Widget? label;
  final List<VibeSidebarItem> items;

  const VibeSidebarSection({this.label, required this.items});
}

/// سایدبار — پورت `registry/ui/sidebar.tsx`.
///
/// ناوبری با آیتم فعال accent و نشان عددی؛ عرض کشویی با [VibeSidebarShell].
///
/// ```dart
/// VibeSidebar(sections: [
///   VibeSidebarSection(items: [
///     VibeSidebarItem(icon: Icons.home_outlined, label: Text("خانه"), active: true),
///   ]),
/// ])
/// ```
class VibeSidebar extends StatelessWidget {
  final List<VibeSidebarSection> sections;
  final double width;

  const VibeSidebar({super.key, required this.sections, this.width = 240});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      width: width,
      decoration: BoxDecoration(border: BorderDirectional(end: BorderSide(color: t.border))),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in sections) ...[
            if (section.label != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: t.mutedForeground),
                  child: section.label!,
                ),
              ),
            for (final item in section.items) _item(context, t, item),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _item(BuildContext context, VibeTokens t, VibeSidebarItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: item.onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: item.active ? t.accent : Colors.transparent,
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 16, color: item.active ? t.foreground : t.mutedForeground),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: item.active ? FontWeight.w500 : FontWeight.w400,
                      color: item.active ? t.foreground : t.mutedForeground,
                    ),
                    child: item.label,
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: t.foreground,
                    ),
                    child: Text(
                      item.badge is int ? fa(item.badge as int) : "${item.badge}",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.6, color: t.background),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// پوسته‌ی سایدبار جمع‌شونده — محتوای اصلی کنار سایدبار.
class VibeSidebarShell extends StatefulWidget {
  final List<VibeSidebarSection> sections;
  final Widget child;
  final double sidebarWidth;

  // جمع‌شده باز شود؟ از بیرون کنترل می‌شود.
  final bool collapsed;

  const VibeSidebarShell({super.key, required this.sections, required this.child, this.sidebarWidth = 240, this.collapsed = false});

  @override
  State<VibeSidebarShell> createState() => _VibeSidebarShellState();
}

class _VibeSidebarShellState extends State<VibeSidebarShell> {

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          width: widget.collapsed ? 0 : widget.sidebarWidth,
          child: ClipRect(child: VibeSidebar(sections: widget.sections, width: widget.sidebarWidth)),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
