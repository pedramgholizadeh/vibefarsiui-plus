import 'package:flutter/material.dart';

import '../jalali.dart';
import '../persian.dart';
import '../theme.dart';

/// انتخابگر ساعت — پورت `registry/ui/time-picker.tsx`.
///
/// دو ستون لغزان ساعت و دقیقه با ارقام فارسی؛ خروجی DateTime با ساعت ست‌شده.
///
/// ```dart
/// VibeTimePicker(
///   value: _time,
///   onChanged: (t) => setState(() => _time = t),
/// )
/// ```
class VibeTimePicker extends StatefulWidget {
  const VibeTimePicker({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
  });

  /// زمان کنترل‌شده (فقط ساعت/دقیقه معنا دارند).
  final DateTime? value;
  final DateTime? initialValue;
  final ValueChanged<DateTime>? onChanged;
  final bool enabled;

  @override
  State<VibeTimePicker> createState() => _VibeTimePickerState();
}

class _VibeTimePickerState extends State<VibeTimePicker> {
  late DateTime _internal;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _internal = widget.initialValue ?? DateTime(now.year, now.month, now.day, 9, 0);
  }

  DateTime get _value => widget.value ?? _internal;

  void _set(int hour, int minute) {
    final v = _value;
    final next = DateTime(v.year, v.month, v.day, hour, minute);
    if (widget.value == null) setState(() => _internal = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final v = _value;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _wheel(
            context,
            t,
            count: 24,
            selected: v.hour,
            label: (i) => fa(i.toString().padLeft(2, "0")),
            onChanged: (h) => _set(h, v.minute),
            enabled: widget.enabled,
          ),
          Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.foreground)),
          _wheel(
            context,
            t,
            count: 60,
            selected: v.minute,
            label: (i) => fa(i.toString().padLeft(2, "0")),
            onChanged: (m) => _set(v.hour, m),
            step: 5,
            enabled: widget.enabled,
          ),
        ],
      ),
    );
  }

  Widget _wheel(
    BuildContext context,
    VibeTokens t, {
    required int count,
    required int selected,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
    required bool enabled,
    int step = 1,
  }) {
    final values = [for (var i = 0; i < count; i += step) i];
    return SizedBox(
      height: 180,
      width: 56,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 36,
        controller: FixedExtentScrollController(initialItem: values.indexOf(selected).clamp(0, values.length - 1)),
        physics: enabled ? const FixedExtentScrollPhysics() : const NeverScrollableScrollPhysics(),
        onSelectedItemChanged: (index) => onChanged(values[index]),
        perspective: 0.003,
        diameterRatio: 1.6,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: values.length,
          builder: (context, index) {
            final value = values[index];
            final active = value == selected;
            return Center(
              child: Text(
                label(value),
                style: TextStyle(
                  fontSize: active ? 18 : 15,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? t.foreground : t.mutedForeground,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// شمارش معکوس — پورت `registry/ui/countdown.tsx`.
///
/// جعبه‌های روز/ساعت/دقیقه/ثانیه با ارقام فارسی تا یک زمان هدف.
///
/// ```dart
/// VibeCountdown(target: DateTime(2026, 3, 21), label: const Text("تا نوروز"))
/// ```
class VibeCountdown extends StatefulWidget {
  const VibeCountdown({super.key, required this.target, this.label, this.onDone});

  final DateTime target;
  final Widget? label;

  /// وقتی به هدف رسید.
  final VoidCallback? onDone;

  @override
  State<VibeCountdown> createState() => _VibeCountdownState();
}

class _VibeCountdownState extends State<VibeCountdown> {
  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {});
      if (DateTime.now().isBefore(widget.target)) {
        _tick();
      } else {
        widget.onDone?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final diff = widget.target.difference(DateTime.now());
    final neg = diff.isNegative;
    final d = diff.abs();
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final j = JalaliDate.fromDateTime(widget.target);

    return Column(
      children: [
        if (widget.label != null) ...[
          DefaultTextStyle.merge(style: TextStyle(fontSize: 14, color: t.mutedForeground), child: widget.label!),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _box(context, t, neg ? fa(days) : fa(days), "روز"),
            _sep(t),
            _box(context, t, fa(hours.toString().padLeft(2, "0")), "ساعت"),
            _sep(t),
            _box(context, t, fa(minutes.toString().padLeft(2, "0")), "دقیقه"),
            _sep(t),
            _box(context, t, fa(seconds.toString().padLeft(2, "0")), "ثانیه"),
          ],
        ),
        const SizedBox(height: 8),
        Text("تا ${j.format(weekday: true)}", style: TextStyle(fontSize: 11, color: t.mutedForeground)),
      ],
    );
  }

  Widget _sep(VibeTokens t) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.mutedForeground)),
      );

  Widget _box(BuildContext context, VibeTokens t, String value, String label) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.field),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.foreground)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: t.mutedForeground)),
        ],
      ),
    );
  }
}
