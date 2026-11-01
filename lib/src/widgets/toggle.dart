import 'package:flutter/material.dart';

import '../theme.dart';

/// اندازه‌ی دکمه‌ی فشاری.
enum VibeToggleSize { small, medium, large }

/// دکمه‌ی فشاری — پورت `registry/ui/toggle.tsx`.
///
/// دکمه‌ی دومنظوره (aria-pressed) برای «پررنگ» یا «فقط موجود».
///
/// ```dart
/// VibeToggle(pressed: _bold, onPressed: (v) => setState(() => _bold = v), child: Text("پررنگ"))
/// ```
class VibeToggle extends StatefulWidget {
  const VibeToggle({
    super.key,
    required this.child,
    this.pressed,
    this.defaultPressed = false,
    this.onPressed,
    this.variant = VibeToggleVariant.filled,
    this.size = VibeToggleSize.medium,
  });

  final Widget child;

  /// وضعیت کنترل‌شده؛ null یعنی state داخلی.
  final bool? pressed;
  final bool defaultPressed;

  /// وضعیت جدید پس از فشردن.
  final ValueChanged<bool>? onPressed;
  final VibeToggleVariant variant;
  final VibeToggleSize size;

  @override
  State<VibeToggle> createState() => _VibeToggleState();
}

/// واریانت: پرشده یا با حاشیه.
enum VibeToggleVariant { filled, outline }

class _VibeToggleState extends State<VibeToggle> {
  late bool _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultPressed;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final on = widget.pressed ?? _internal;
    final (height, minW, padding, fontSize, iconSize) = switch (widget.size) {
      VibeToggleSize.small => (32.0, 32.0, 8.0, 12.0, 14.0),
      VibeToggleSize.medium => (36.0, 36.0, 10.0, 14.0, 16.0),
      VibeToggleSize.large => (40.0, 40.0, 12.0, 14.0, 16.0),
    };

    return Semantics(
      toggled: on,
      button: true,
      child: GestureDetector(
        onTap: () {
          if (widget.pressed == null) setState(() => _internal = !on);
          widget.onPressed?.call(!on);
        },
        child: AnimatedContainer(
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          constraints: BoxConstraints(minWidth: minW),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VibeRadius.control),
            color: on ? t.secondary : Colors.transparent,
            border: widget.variant == VibeToggleVariant.outline && !on ? Border.all(color: t.input) : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(size: iconSize, color: on ? t.foreground : t.mutedForeground),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: on ? t.foreground : t.mutedForeground,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// یک گزینه‌ی گروه فشاری.
class VibeToggleItem {
  final String value;
  final Widget label;
  final bool disabled;

  const VibeToggleItem({required this.value, required this.label, this.disabled = false});
}

/// گروه دکمه‌ی فشاری — پورت `ToggleGroup` وب.
///
/// حالت single مثل ردیف رادیویی (می‌تواند همه خاموش باشند) با قرص لغزان و
/// حالت multiple مثل ردیف چک‌باکس.
class VibeToggleGroup extends StatefulWidget {
  const VibeToggleGroup({
    super.key,
    required this.items,
    this.multiple = false,
    this.value,
    this.defaultValue = const [],
    this.onChange,
    this.variant = VibeToggleVariant.filled,
    this.size = VibeToggleSize.medium,
  });

  final List<VibeToggleItem> items;

  /// حالت چندانتخابی؛ پیش‌فرض تک‌انتخابی با قرص لغزان.
  final bool multiple;

  /// مقدار کنترل‌شده.
  final List<String>? value;
  final List<String> defaultValue;

  /// در حالت single همیشه فهرست با حداکثر یک عضو می‌آید.
  final ValueChanged<List<String>>? onChange;
  final VibeToggleVariant variant;
  final VibeToggleSize size;

  @override
  State<VibeToggleGroup> createState() => _VibeToggleGroupState();
}

class _VibeToggleGroupState extends State<VibeToggleGroup> {
  late List<String> _internal;

  @override
  void initState() {
    super.initState();
    _internal = [...widget.defaultValue];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final selected = widget.value ?? _internal;
    final (height, minW, padding, fontSize, iconSize) = switch (widget.size) {
      VibeToggleSize.small => (32.0, 32.0, 8.0, 12.0, 14.0),
      VibeToggleSize.medium => (36.0, 36.0, 10.0, 14.0, 16.0),
      VibeToggleSize.large => (40.0, 40.0, 12.0, 14.0, 16.0),
    };

    void pick(String v) {
      final next = widget.multiple
          ? (selected.contains(v) ? selected.where((x) => x != v).toList() : [...selected, v])
          : (selected.firstOrNull == v ? <String>[] : [v]);
      setState(() => _internal = next);
      widget.onChange?.call(next);
    }

    final children = <Widget>[];
    for (final it in widget.items) {
      final on = selected.contains(it.value);
      children.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: it.disabled ? null : () => pick(it.value),
          child: AnimatedContainer(
            duration: VibeMotion.duration,
            curve: VibeMotion.ease,
            constraints: BoxConstraints(minWidth: minW),
            height: height - 4,
            padding: EdgeInsets.symmetric(horizontal: padding),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VibeRadius.control),
              color: on ? t.card : Colors.transparent,
              border: on ? Border.all(color: t.border) : null,
            ),
            child: Opacity(
              opacity: it.disabled ? 0.4 : 1,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: on ? t.foreground : t.mutedForeground,
                ),
                child: it.label,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: t.muted,
        borderRadius: BorderRadius.circular(VibeRadius.control + 2),
        border: Border.all(color: t.input),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
