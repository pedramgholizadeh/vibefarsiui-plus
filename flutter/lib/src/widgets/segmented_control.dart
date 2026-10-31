import 'package:flutter/material.dart';

import '../theme.dart';

/// یک بخش کنترل بخشی.
class VibeSegmentOption {
  final String value;
  final Widget label;
  final bool disabled;

  const VibeSegmentOption({required this.value, required this.label, this.disabled = false});
}

/// کنترل بخشی — پورت `registry/ui/segmented-control.tsx`.
///
/// قرص روشن زیر بخش انتخابی می‌لغزد؛ با [fullWidth] همه‌ی بخش‌ها هم‌عرض می‌شوند.
/// در RTL اولین بخش سمت راست است.
///
/// ```dart
/// VibeSegmentedControl(
///   options: const [VibeSegmentOption(value: "week", label: Text("هفته")), VibeSegmentOption(value: "month", label: Text("ماه"))],
///   value: _range,
///   onChanged: (v) => setState(() => _range = v),
/// )
/// ```
class VibeSegmentedControl extends StatefulWidget {
  final List<VibeSegmentOption> options;

  /// مقدار کنترل‌شده.
  final String? value;
  final String? defaultValue;
  final ValueChanged<String>? onChanged;

  /// بخش کوچک (h-7) برای نوار ابزار.
  final bool small;

  /// کشیده‌شدن به عرض والد با بخش‌های هم‌عرض.
  final bool fullWidth;

  const VibeSegmentedControl({
    super.key,
    required this.options,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.small = false,
    this.fullWidth = false,
  });

  @override
  State<VibeSegmentedControl> createState() => _VibeSegmentedControlState();
}

class _VibeSegmentedControlState extends State<VibeSegmentedControl> {
  late String _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue ?? widget.options.first.value;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final selected = widget.value ?? _internal;
    final height = widget.small ? 28.0 : 32.0;

    Widget buildOption(VibeSegmentOption o) {
      final on = o.value == selected;
      final content = Container(
        height: height - 4,
        padding: EdgeInsets.symmetric(horizontal: widget.small ? 10 : 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VibeRadius.control),
          color: on ? t.card : Colors.transparent,
          border: on ? Border.all(color: t.border) : null,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: widget.small ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: on ? t.foreground : t.mutedForeground,
          ),
          child: o.label,
        ),
      );
      return Semantics(
        inMutuallyExclusiveGroup: true,
        checked: on,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: o.disabled ? null : () {
            setState(() => _internal = o.value);
            widget.onChanged?.call(o.value);
          },
          child: Opacity(opacity: o.disabled ? 0.4 : 1, child: content),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: t.muted,
        borderRadius: BorderRadius.circular(VibeRadius.control + 2),
      ),
      child: widget.fullWidth
          ? Row(
              children: [
                for (final o in widget.options) Expanded(child: buildOption(o)),
              ],
            )
          : Wrap(children: [Row(mainAxisSize: MainAxisSize.min, children: [for (final o in widget.options) buildOption(o)])]),
    );
  }
}
