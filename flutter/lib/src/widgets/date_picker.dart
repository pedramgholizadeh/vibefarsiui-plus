import 'package:flutter/material.dart';

import '../calendar_utils.dart';
import '../jalali.dart';
import '../theme.dart';
import 'month_view.dart';

/// انتخابگر تاریخ — پورت `registry/ui/date-picker.tsx`.
///
/// فیلد نمایشی با تاریخ شمسی و دیالوگ `VibeMonthView`؛ پیش‌فرض‌های «امروز»
/// و پاک‌کردن انتخاب.
///
/// ```dart
/// VibeDatePicker(
///   value: _date,
///   onChanged: (d) => setState(() => _date = d),
/// )
/// ```
class VibeDatePicker extends StatefulWidget {
  const VibeDatePicker({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.hintText = "انتخاب تاریخ",
    this.secondary = VibeSecondary.none,
    this.enabled = true,
  });

  /// تاریخ انتخابی کنترل‌شده (نیمه‌شب آن روز).
  final DateTime? value;
  final DateTime? initialValue;
  final ValueChanged<DateTime?>? onChanged;
  final String hintText;
  final VibeSecondary secondary;
  final bool enabled;

  @override
  State<VibeDatePicker> createState() => _VibeDatePickerState();
}

class _VibeDatePickerState extends State<VibeDatePicker> {
  DateTime? _internal;
  DateTime? _dialogMonth;

  DateTime? get _value => widget.value ?? _internal;

  Future<void> _open() async {
    if (!widget.enabled) return;
    setState(() => _dialogMonth = _value ?? DateTime.now());
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        final t = context.vibe;
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.popover,
                borderRadius: BorderRadius.circular(VibeRadius.overlay),
                border: Border.all(color: t.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VibeMonthView(
                    month: _dialogMonth,
                    onMonthChange: (m) => setDialogState(() => _dialogMonth = m),
                    selected: _value == null ? null : _dateKey(_value!),
                    onDayClick: (date, info) => Navigator.of(dialogContext).pop(date),
                    secondary: widget.secondary,
                    showToolbar: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _internal = picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final v = _value;
    final label = v == null ? widget.hintText : formatJalali(v, weekday: true);

    return GestureDetector(
      onTap: _open,
      child: Container(
        height: 40,
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        decoration: BoxDecoration(
          color: t.background.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(VibeRadius.field),
          border: Border.all(color: t.input),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: v == null ? t.mutedForeground.withValues(alpha: 0.7) : t.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.calendar_month_outlined, size: 16, color: t.mutedForeground),
          ],
        ),
      ),
    );
  }
}

String _dateKey(DateTime d) {
  final m = d.month.toString().padLeft(2, "0");
  final day = d.day.toString().padLeft(2, "0");
  return "${d.year}-$m-$day";
}

/// انتخابگر بازه‌ی تاریخ — پورت `registry/ui/date-range-picker.tsx`.
///
/// دو تاریخ شروع/پایان با دیالوگ؛ پیش‌فرض‌های «امروز»، «این هفته»، «این ماه».
///
/// ```dart
/// VibeDateRangePicker(
///   value: _range,
///   onChanged: (r) => setState(() => _range = r),
/// )
/// ```
class VibeDateRangePicker extends StatefulWidget {
  const VibeDateRangePicker({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.hintText = "انتخاب بازه",
    this.enabled = true,
  });

  /// بازه‌ی کنترل‌شده (شروع ≤ پایان، نیمه‌شب هر روز).
  final (DateTime, DateTime)? value;
  final (DateTime, DateTime)? initialValue;
  final void Function((DateTime, DateTime)?)? onChanged;
  final String hintText;
  final bool enabled;

  @override
  State<VibeDateRangePicker> createState() => _VibeDateRangePickerState();
}

class _VibeDateRangePickerState extends State<VibeDateRangePicker> {
  (DateTime, DateTime)? _internal;

  (DateTime, DateTime)? get _value => widget.value ?? _internal;

  Future<void> _open() async {
    if (!widget.enabled) return;
    final initial = _value;
    (DateTime, DateTime)? result = initial;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final t = context.vibe;
        var month = initial?.$1 ?? DateTime.now();
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => Dialog(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.popover,
                borderRadius: BorderRadius.circular(VibeRadius.overlay),
                border: Border.all(color: t.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VibeMonthView(
                    month: month,
                    onMonthChange: (m) => setDialogState(() => month = m),
                    selected: result?.$1 == null ? null : _dateKey(result!.$1),
                    onDayClick: (date, info) {
                      setDialogState(() {
                        if (result == null || date.isBefore(result!.$1)) {
                          result = (date, date);
                        } else if (date.isAfter(result!.$1)) {
                          result = (result!.$1, date);
                        } else {
                          result = (date, date);
                        }
                      });
                    },
                    secondary: VibeSecondary.none,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result == null
                              ? widget.hintText
                              : "${formatJalali(result!.$1)} تا ${formatJalali(result!.$2)}",
                          style: TextStyle(fontSize: 13, color: t.mutedForeground),
                        ),
                      ),
                      VibePresetRow(onPreset: (r) => setDialogState(() => result = r)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(VibeRadius.control),
                              border: Border.all(color: t.input),
                            ),
                            child: Text("انصراف", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.foreground)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(VibeRadius.control),
                              color: t.primary,
                            ),
                            child: Text("تأیید", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.primaryForeground)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (confirmed == true) {
      setState(() => _internal = result);
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final v = _value;
    final label = v == null
        ? widget.hintText
        : "${formatJalali(v.$1)} تا ${formatJalali(v.$2)}";

    return GestureDetector(
      onTap: _open,
      child: Container(
        height: 40,
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        decoration: BoxDecoration(
          color: t.background.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(VibeRadius.field),
          border: Border.all(color: t.input),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: v == null ? t.mutedForeground.withValues(alpha: 0.7) : t.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.date_range_outlined, size: 16, color: t.mutedForeground),
          ],
        ),
      ),
    );
  }
}

/// ردیف بازه‌های آماده‌ی وب: امروز، این هفته، این ماه.
class VibePresetRow extends StatelessWidget {
  final void Function((DateTime, DateTime)) onPreset;

  const VibePresetRow({super.key, required this.onPreset});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final today = DateTime.now();
    final presets = [
      ("امروز", (today, today)),
      ("این هفته", (startOfJalaliWeek(today), today)),
      ("این ماه", (toGregorian(toJalali(today).jy, toJalali(today).jm, 1), today)),
    ];
    return Wrap(
      spacing: 4,
      children: [
        for (final (label, range) in presets)
          GestureDetector(
            onTap: () => onPreset(range),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: t.muted,
              ),
              child: Text(label, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
            ),
          ),
      ],
    );
  }
}
