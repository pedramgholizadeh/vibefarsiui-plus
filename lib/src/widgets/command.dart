import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// یک دستور پالت.
class VibeCommandItem {
  final String id;
  final String label;
  final IconData? icon;
  final String? shortcut;

  /// کلیدواژه‌های جست‌وجوی اضافه.
  final List<String> keywords;

  /// نام گروه برای سرفصل.
  final String? group;
  final VoidCallback? onSelect;

  const VibeCommandItem({
    required this.id,
    required this.label,
    this.icon,
    this.shortcut,
    this.keywords = const [],
    this.group,
    this.onSelect,
  });
}

/// پالت دستور — پورت `registry/ui/command.tsx`.
///
/// فهرست فیلترشونده با فولد فارسی (ي/ك/آ و نیم‌فاصله)؛ به‌صورت دیالوگ ⌘K
/// با [VibeCommandDialog.show] باز می‌شود.
///
/// ```dart
/// VibeCommandDialog.show(
///   context,
///   items: [VibeCommandItem(id: "new", label: "سفارش جدید", shortcut: "⌘N", onSelect: () {})],
/// );
/// ```
abstract final class VibeCommandDialog {
  static Future<void> show(
    BuildContext context, {
    required List<VibeCommandItem> items,
    String placeholder = "دستور یا جست‌وجو…",
    String emptyText = "چیزی پیدا نشد",
    ValueChanged<VibeCommandItem>? onSelect,
  }) {
    final t = VibeTokens.of(context);
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 400),
          child: Container(
            decoration: BoxDecoration(
              color: t.popover,
              borderRadius: BorderRadius.circular(VibeRadius.overlay),
              border: Border.all(color: t.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VibeRadius.overlay),
              child: VibeCommand(
                items: items,
                placeholder: placeholder,
                emptyText: emptyText,
                onSelect: onSelect,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// فهرست فیلترشونده‌ی دستورها — بدنه‌ی پالت.
class VibeCommand extends StatefulWidget {
  const VibeCommand({
    super.key,
    required this.items,
    this.placeholder = "دستور یا جست‌وجو…",
    this.emptyText = "چیزی پیدا نشد",
    this.onSelect,
    this.autofocus = true,
  });

  final List<VibeCommandItem> items;
  final String placeholder;
  final String emptyText;
  final ValueChanged<VibeCommandItem>? onSelect;
  final bool autofocus;

  @override
  State<VibeCommand> createState() => _VibeCommandState();
}

/// فولد فارسی برای تطبیق نرم: ی/ك/آ و نیم‌فاصله مهم نیستند.
String _fold(String s) {
  return en(s)
      .toLowerCase()
      .replaceAll("‌", "")
      .replaceAll("ي", "ی")
      .replaceAll("ك", "ک")
      .replaceAll("آ", "ا")
      .replaceAll(RegExp(r"[_\s-]+"), " ")
      .trim();
}

class _VibeCommandState extends State<VibeCommand> {
  String _q = "";

  List<VibeCommandItem> get _filtered {
    final f = _fold(_q);
    if (f.isEmpty) return widget.items;
    return widget.items.where((i) => _fold(i.label).contains(f) || i.keywords.any((k) => _fold(k).contains(f))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final filtered = _filtered;
    final groups = <String, List<VibeCommandItem>>{};
    for (final item in filtered) {
      groups.putIfAbsent(item.group ?? "", () => []).add(item);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            autofocus: widget.autofocus,
            onChanged: (v) => setState(() => _q = v),
            cursorColor: t.foreground,
            style: TextStyle(fontSize: 14, color: t.foreground),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              icon: Icon(Icons.search, size: 16, color: t.mutedForeground),
              hintText: widget.placeholder,
              hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
            ),
          ),
        ),
        Divider(height: 1, color: t.border),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            children: [
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(widget.emptyText, style: TextStyle(fontSize: 14, color: t.mutedForeground)),
                ),
              for (final entry in groups.entries) ...[
                if (entry.key.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(entry.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: t.mutedForeground)),
                  ),
                for (final item in entry.value)
                  InkWell(
                    onTap: () {
                      item.onSelect?.call();
                      widget.onSelect?.call(item);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            Icon(item.icon, size: 16, color: t.mutedForeground),
                            const SizedBox(width: 10),
                          ],
                          Expanded(child: Text(item.label, style: TextStyle(fontSize: 14, color: t.foreground))),
                          if (item.shortcut != null)
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(item.shortcut!, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
