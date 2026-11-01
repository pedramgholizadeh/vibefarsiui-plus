import 'package:flutter/material.dart';

import '../theme.dart';

/// یک گزینه‌ی رادیو.
class VibeRadioOption {
  final String value;
  final Widget label;
  final Widget? description;
  final bool disabled;

  const VibeRadioOption({required this.value, required this.label, this.description, this.disabled = false});
}

/// واریانت گروه رادیویی: فهرست ساده یا کارت‌های انتخابی.
enum VibeRadioVariant { list, cards }

/// گروه رادیویی — پورت `registry/ui/radio-group.tsx`.
///
/// گزینه‌ی فعال دایره‌ی توپُر می‌گیرد؛ واریانت cards هر گزینه را به کارت
/// انتخابی با حاشیه برجسته تبدیل می‌کند.
///
/// ```dart
/// VibeRadioGroup(
///   options: [VibeRadioOption(value: "post", label: Text("پست پیشتاز"))],
///   value: _shipping,
///   onChanged: (v) => setState(() => _shipping = v),
/// )
/// ```
class VibeRadioGroup extends StatefulWidget {
  final List<VibeRadioOption> options;

  /// مقدار کنترل‌شده.
  final String? value;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final VibeRadioVariant variant;

  const VibeRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.variant = VibeRadioVariant.list,
  });

  @override
  State<VibeRadioGroup> createState() => _VibeRadioGroupState();
}

class _VibeRadioGroupState extends State<VibeRadioGroup> {
  late String _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final selected = widget.value ?? _internal;
    final cards = widget.variant == VibeRadioVariant.cards;

    return Column(
      children: [
        for (final o in widget.options)
          Padding(
            padding: EdgeInsets.only(bottom: cards ? 8 : 10),
            child: Semantics(
              inMutuallyExclusiveGroup: true,
              checked: selected == o.value,
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: o.disabled ? null : () {
                  setState(() => _internal = o.value);
                  widget.onChanged?.call(o.value);
                },
                child: AnimatedContainer(
                  duration: VibeMotion.duration,
                  curve: VibeMotion.ease,
                  padding: cards ? const EdgeInsets.all(12) : EdgeInsets.zero,
                  decoration: cards
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(VibeRadius.control),
                          border: Border.all(color: selected == o.value ? t.foreground.withValues(alpha: 0.5) : t.border),
                          color: selected == o.value ? t.accent.withValues(alpha: 0.6) : Colors.transparent,
                        )
                      : null,
                  child: Opacity(
                    opacity: o.disabled ? 0.5 : 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: selected == o.value ? t.primary : t.input),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: selected == o.value
                              ? Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: t.primary),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultTextStyle.merge(
                                style: const TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                                child: o.label,
                              ),
                              if (o.description != null)
                                DefaultTextStyle.merge(
                                  style: TextStyle(fontSize: 12, height: 1.5, color: t.mutedForeground),
                                  child: o.description!,
                                ),
                            ],
                          ),
                        ),
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
}
