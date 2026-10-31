import 'package:flutter/material.dart';

import '../theme.dart';

/// واریانت تب: قرصی (سگمنت) یا خط زیرین.
enum VibeTabsVariant { segmented, underline }

/// یک تب: مقدار و برچسب.
class VibeTab {
  final String value;
  final Widget label;

  const VibeTab({required this.value, required this.label});
}

/// تب‌ها — پورت `registry/ui/tabs.tsx`.
///
/// در RTL اولین تب سمت راست است. واریانت segmented قرص روشن متحرک دارد و
/// underline خط زیر تب فعال؛ هر دو با انیمیشن ۲۰۰ میلی‌ثانیه‌ای تم.
///
/// ```dart
/// VibeTabs(
///   tabs: const [VibeTab(value: "week", label: Text("هفته")), VibeTab(value: "month", label: Text("ماه"))],
///   value: _tab,
///   onChanged: (v) => setState(() => _tab = v),
///   content: (v) => Text("محتوای $v"),
/// )
/// ```
class VibeTabs extends StatefulWidget {
  final List<VibeTab> tabs;

  /// تب فعال؛ اگر خالی باشد state داخلی مقدار را نگه می‌دارد.
  final String? value;

  /// مقدار اولیه وقتی [value] داده نشده است (پیش‌فرض: اولین تب).
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VibeTabsVariant variant;

  /// محتوای تب فعال؛ مقدار فعال را می‌گیرد.
  final Widget Function(String value)? content;

  const VibeTabs({
    super.key,
    required this.tabs,
    this.value,
    this.initialValue,
    this.onChanged,
    this.variant = VibeTabsVariant.segmented,
    this.content,
  });

  @override
  State<VibeTabs> createState() => _VibeTabsState();
}

class _VibeTabsState extends State<VibeTabs> {
  late String _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.initialValue ?? widget.tabs.first.value;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final active = widget.value ?? _internal;
    final isSegmented = widget.variant == VibeTabsVariant.segmented;

    final list = Container(
      decoration: isSegmented
          ? BoxDecoration(
              color: t.muted,
              borderRadius: BorderRadius.circular(VibeRadius.control + 2),
              border: Border.all(color: t.border),
            )
          : BoxDecoration(border: Border(bottom: BorderSide(color: t.border))),
      padding: isSegmented ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tab in widget.tabs)
            _trigger(context, tab, active: tab.value == active, segmented: isSegmented),
        ],
      ),
    );

    final Widget listWrapped = isSegmented
        ? Wrap(children: [list])
        : SingleChildScrollView(scrollDirection: Axis.horizontal, child: list);

    if (widget.content == null) return listWrapped;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        listWrapped,
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: VibeMotion.duration,
          switchInCurve: VibeMotion.ease,
          child: KeyedSubtree(
            key: ValueKey(active),
            child: widget.content!(active),
          ),
        ),
      ],
    );
  }

  Widget _trigger(BuildContext context, VibeTab tab, {required bool active, required bool segmented}) {
    final t = context.vibe;
    void select() {
      setState(() => _internal = tab.value);
      widget.onChanged?.call(tab.value);
    }

    final label = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 14,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        color: active ? t.foreground : t.mutedForeground,
      ),
      child: tab.label,
    );

    return Semantics(
      selected: active,
      button: true,
      child: GestureDetector(
        onTap: select,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          padding: segmented
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: segmented
              ? BoxDecoration(
                  color: active ? t.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(VibeRadius.control),
                  border: active ? Border.all(color: t.border) : null,
                )
              : BoxDecoration(
                  border: Border(bottom: BorderSide(width: 2, color: active ? t.foreground : Colors.transparent)),
                ),
          child: label,
        ),
      ),
    );
  }
}
