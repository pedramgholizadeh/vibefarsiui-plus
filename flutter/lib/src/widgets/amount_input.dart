import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../persian.dart';
import '../theme.dart';

/* ---------- عدد به حروف (پورت محلی amountToWords از lib/number-to-words.ts) ---------- */

const List<String> _ones = ["", "یک", "دو", "سه", "چهار", "پنج", "شش", "هفت", "هشت", "نه"];
const List<String> _teens = [
  "ده", "یازده", "دوازده", "سیزده", "چهارده", "پانزده", "شانزده", "هفده", "هجده", "نوزده",
];
const List<String> _tens = ["", "", "بیست", "سی", "چهل", "پنجاه", "شصت", "هفتاد", "هشتاد", "نود"];
const List<String> _hundreds = [
  "", "صد", "دویست", "سیصد", "چهارصد", "پانصد", "ششصد", "هفتصد", "هشتصد", "نهصد",
];
const List<String> _scales = [
  "", "هزار", "میلیون", "میلیارد", "تریلیون", "کوادریلیون", "کوینتیلیون", "سکستیلیون",
];
const String _and = " و ";

/// کلمات گروه سه‌رقمی ۰ تا ۹۹۹ (صفر → رشته‌ی خالی).
String _group3(int n) {
  final parts = <String>[];
  final h = n ~/ 100;
  final rest = n % 100;
  if (h != 0) parts.add(_hundreds[h]);
  if (rest >= 10 && rest < 20) {
    parts.add(_teens[rest - 10]);
  } else {
    final tens = rest ~/ 10;
    final ones = rest % 10;
    if (tens != 0) parts.add(_tens[tens]);
    if (ones != 0) parts.add(_ones[ones]);
  }
  return parts.join(_and);
}

/// «یک میلیون و دویست و پنجاه هزار» برای عدد صحیح نامنفی.
String _intWords(int n) {
  if (n == 0) return "صفر";
  final digits = n.toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = end - 3 > 0 ? end - 3 : 0;
    groups.insert(0, digits.substring(start, end));
  }
  if (groups.length > _scales.length) return digits;
  final parts = <String>[];
  for (var i = 0; i < groups.length; i++) {
    final g = int.parse(groups[i]);
    if (g == 0) continue;
    final scale = _scales[groups.length - 1 - i];
    if (scale == "هزار" && g == 1) {
      parts.add("هزار");
    } else {
      parts.add(scale.isEmpty ? _group3(g) : "${_group3(g)} $scale");
    }
  }
  return parts.join(_and);
}

/// «یک میلیون و دویست و پنجاه هزار تومان».
String _amountToWords(int n, String unit) => "${_intWords(n)} $unit";

/* ---------- کامپوننت ---------- */

/// ۱۰۰۰۰۰ → «۱۰۰ هزار»، ۲۵۰۰۰۰۰ → «۲٫۵ میلیون»، ۱۲۰۰ → «۱٬۲۰۰».
String shortAmount(int n) {
  if (n >= 1000000 && n % 100000 == 0) {
    return "${fa((n / 1000000).toString().replaceAll(".", "٫"))} میلیون";
  }
  if (n >= 1000 && n % 1000 == 0) return "${fa(n / 1000)} هزار";
  return faNumber(n);
}

/// مبلغ — پورت `registry/ui/amount-input.tsx`.
///
/// جداکننده‌ی هزارگان «٬» و ارقام فارسی هنگام تایپ، واحد بعد از عدد و مبلغ
/// حروف‌شده زیر فیلد تا کسی ۱۲٬۵۰۰٬۰۰۰ را به‌جای ۱٬۲۵۰٬۰۰۰ پرداخت نکند.
/// مقدار یک عدد ساده است.
///
/// ```dart
/// VibeAmountInput(
///   value: _amount,
///   quick: const [100000, 500000, 1000000],
///   onChanged: (v) => setState(() => _amount = v),
/// )
/// ```
class VibeAmountInput extends StatefulWidget {
  const VibeAmountInput({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.unit = "تومان",
    this.min,
    this.max,
    this.words = true,
    this.quick,
    this.placeholder = "۰",
    this.disabled = false,
  });

  /// مقدار کنترل‌شده (null مجاز است = خالی)؛ داده نشود باشد state داخلی نگه داشته می‌شود.
  final int? value;

  /// مقدار اولیه‌ی حالت غیرکنترل‌شده.
  final int? initialValue;

  final ValueChanged<int?>? onChanged;

  /// واحدِ انتهای فیلد و بعد از مبلغ حروف‌شده.
  final String unit;

  final int? min;
  final int? max;

  /// مبلغ حروف‌شده زیر فیلد (پیش‌فرض روشن).
  final bool words;

  /// چیپ‌های مقدار سریع، مثل `[100000, 500000, 1000000]`.
  final List<int>? quick;

  final String placeholder;

  final bool disabled;

  @override
  State<VibeAmountInput> createState() => _VibeAmountInputState();
}

class _VibeAmountInputState extends State<VibeAmountInput> {
  late final TextEditingController _controller;
  late int? _internal;

  int? get _amount => widget.value ?? _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.initialValue;
    _controller = TextEditingController(text: _display(widget.initialValue));
  }

  static String _display(int? amount) => amount == null ? '' : faNumber(amount);

  @override
  void didUpdateWidget(covariant VibeAmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _parse(_controller.text)) {
      _syncDisplay(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ورودی نمایشی («۱٬۲۵۰٬۰۰۰») را به عدد برمی‌گرداند یا null اگر خالی باشد.
  int? _parse(String display) {
    final digits = en(display).replaceAll(RegExp(r"\D"), "");
    return digits.isEmpty ? null : int.tryParse(digits.length > 15 ? digits.substring(0, 15) : digits);
  }

  void _syncDisplay(int? amount) {
    final text = _display(amount);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _set(int? next) {
    if (widget.value == null) setState(() => _internal = next);
    _syncDisplay(next);
    widget.onChanged?.call(next);
  }

  void _onType(String raw) {
    var digits = en(raw).replaceAll(RegExp(r"\D"), "").replaceFirst(RegExp(r"^0+(?=\d)"), "");
    if (digits.length > 15) digits = digits.substring(0, 15);
    _set(digits.isEmpty ? null : int.parse(digits));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final amount = _amount;
    final tooLow = amount != null && widget.min != null && amount < widget.min!;
    final tooHigh = amount != null && widget.max != null && amount > widget.max!;
    final invalid = tooLow || tooHigh;

    final field = Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: _controller,
        enabled: !widget.disabled,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩٬,]")),
        ],
        onChanged: _onType,
        cursorColor: t.foreground,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.foreground),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.5)),
          filled: true,
          fillColor: t.background.withValues(alpha: 0.6),
          isDense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4, top: 11, bottom: 11),
          suffix: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Text(
              widget.unit,
              style: TextStyle(fontSize: 14, color: t.mutedForeground),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(VibeRadius.field),
            borderSide: BorderSide(color: invalid ? t.destructive.withValues(alpha: 0.6) : t.input),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(VibeRadius.field),
            borderSide: BorderSide(width: 2, color: t.ring.withValues(alpha: 0.6)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(VibeRadius.field),
            borderSide: BorderSide(color: invalid ? t.destructive.withValues(alpha: 0.6) : t.input),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(opacity: widget.disabled ? 0.5 : 1, child: field),
        if (widget.words || invalid) ...[
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: Container(
              constraints: const BoxConstraints(minHeight: 16),
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                tooLow
                    ? "حداقل ${faNumber(widget.min!)} ${widget.unit}"
                    : tooHigh
                        ? "حداکثر ${faNumber(widget.max!)} ${widget.unit}"
                        : amount != null
                            ? _amountToWords(amount, widget.unit)
                            : " ",
                style: TextStyle(
                  fontSize: 11,
                  color: invalid ? t.destructive : t.mutedForeground,
                ),
              ),
            ),
          ),
        ],
        if (widget.quick != null && widget.quick!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final q in widget.quick!)
                _QuickChip(
                  label: shortAmount(q),
                  active: amount == q,
                  enabled: !widget.disabled,
                  onTap: () => _set(q),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickChip extends StatefulWidget {
  const _QuickChip({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final active = widget.active;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: _pressed ? VibePress.scale : 1,
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          child: AnimatedContainer(
            duration: VibeMotion.duration,
            curve: VibeMotion.ease,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: active ? t.foreground : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? t.foreground : t.border),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                color: active ? t.background : t.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
