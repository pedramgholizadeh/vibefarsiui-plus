import 'package:flutter/material.dart';

import '../theme.dart';

/// وضعیت چک‌باکس: خاموش، روشن یا نامشخص.
enum VibeCheckboxState { off, on, indeterminate }

/// چک‌باکس — پورت `registry/ui/checkbox.tsx`.
///
/// جعبه در ابتدای سطر (در RTL سمت راست) و برچسب بعد از آن؛ وضعیت نامشخص با
/// خط تیره رسم می‌شود.
///
/// ```dart
/// VibeCheckbox(label: Text("قوانین را می‌پذیرم"), value: _ok, onChanged: (v) => setState(() => _ok = v))
/// ```
class VibeCheckbox extends StatelessWidget {
  /// وضعیت کنترل‌شده؛ null یعنی state داخلی والدِ خود را نگه می‌دارد.
  final bool? value;

  /// وضعیت نامشخص (خط تیره) وقتی [value] روشن نیست.
  final bool indeterminate;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final Widget? label;
  final Widget? description;

  const VibeCheckbox({
    super.key,
    this.value,
    this.indeterminate = false,
    this.onChanged,
    this.disabled = false,
    this.label,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final on = value ?? false;
    final state = indeterminate ? VibeCheckboxState.indeterminate : (on ? VibeCheckboxState.on : VibeCheckboxState.off);

    Widget box = GestureDetector(
      onTap: disabled || onChanged == null ? null : () => onChanged!(!on),
      child: Semantics(
        checked: state == VibeCheckboxState.on,
        mixed: state == VibeCheckboxState.indeterminate,
        button: true,
        child: AnimatedContainer(
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: state == VibeCheckboxState.off ? t.input : Colors.transparent),
            color: state == VibeCheckboxState.off ? t.background.withValues(alpha: 0.6) : t.primary,
          ),
          child: state == VibeCheckboxState.off
              ? null
              : Icon(
                  state == VibeCheckboxState.indeterminate ? Icons.remove : Icons.check,
                  size: 12,
                  color: t.primaryForeground,
                ),
        ),
      ),
    );

    if (disabled) box = Opacity(opacity: 0.5, child: box);

    if (label == null) return box;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled || onChanged == null ? null : () => onChanged!(!on),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 14, height: 1.45),
                    child: label!,
                  ),
                  if (description != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 12, height: 1.5, color: t.mutedForeground),
                      child: description!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// یک گزینه‌ی گروه چک‌باکس.
class VibeCheckboxOption {
  final String value;
  final Widget label;
  final Widget? description;
  final bool disabled;

  const VibeCheckboxOption({required this.value, required this.label, this.description, this.disabled = false});
}

/// گروه چک‌باکس با وضعیت مشترک — پورت `CheckboxGroup` وب.
class VibeCheckboxGroup extends StatefulWidget {
  final List<VibeCheckboxOption> options;

  /// مقادیر انتخاب‌شده‌ی کنترل‌شده.
  final List<String>? value;
  final List<String> initialValue;
  final ValueChanged<List<String>>? onChanged;

  const VibeCheckboxGroup({
    super.key,
    required this.options,
    this.value,
    this.initialValue = const [],
    this.onChanged,
  });

  @override
  State<VibeCheckboxGroup> createState() => _VibeCheckboxGroupState();
}

class _VibeCheckboxGroupState extends State<VibeCheckboxGroup> {
  late List<String> _internal;

  @override
  void initState() {
    super.initState();
    _internal = [...widget.initialValue];
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.value ?? _internal;
    return Column(
      children: [
        for (final o in widget.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: VibeCheckbox(
              label: o.label,
              description: o.description,
              disabled: o.disabled,
              value: selected.contains(o.value),
              onChanged: (on) {
                final next = on ? [...selected, o.value] : selected.where((x) => x != o.value).toList();
                setState(() => _internal = next);
                widget.onChanged?.call(next);
              },
            ),
          ),
      ],
    );
  }
}
