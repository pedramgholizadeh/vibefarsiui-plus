import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../persian.dart';
import '../theme.dart';

/// عدد — پورت `registry/ui/number-field.tsx`.
///
/// دکمه‌ی «افزایش» در ابتدای خط (در RTL سمت راست)، نمایش با ارقام فارسی و
/// دکمه‌ی «کاهش» در انتهای خط. ورودی با رقم فارسی هم پذیرفته می‌شود.
///
/// ```dart
/// VibeNumberField(value: _n, min: 0, max: 10, onChanged: (v) => setState(() => _n = v))
/// ```
class VibeNumberField extends StatefulWidget {
  const VibeNumberField({
    super.key,
    this.value,
    this.initialValue = 0,
    this.onChanged,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    this.step = 1,
    this.disabled = false,
    this.semanticLabel,
  });

  /// مقدار کنترل‌شده؛ داده نشود باشد state داخلی نگه داشته می‌شود.
  final double? value;

  /// مقدار اولیه‌ی حالت غیرکنترل‌شده.
  final double initialValue;

  final ValueChanged<double>? onChanged;

  final double min;
  final double max;
  final double step;

  final bool disabled;

  /// برچسب دسترس‌پذیری برای کل گروه (`aria-label` وب).
  final String? semanticLabel;

  @override
  State<VibeNumberField> createState() => _VibeNumberFieldState();
}

class _VibeNumberFieldState extends State<VibeNumberField> {
  late final TextEditingController _controller;
  late double _internal;

  double get _current => widget.value ?? _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.initialValue;
    _controller = TextEditingController(text: _format(_current));
  }

  @override
  void didUpdateWidget(covariant VibeNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != oldWidget.value) {
      _syncDisplay(widget.value!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _format(double n) => fa(n);

  void _syncDisplay(double n) {
    final text = _format(n);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _set(double next) {
    final clamped = next.clamp(widget.min, widget.max);
    if (widget.value == null) setState(() => _internal = clamped);
    _syncDisplay(clamped);
    widget.onChanged?.call(clamped);
  }

  void _onType(String raw) {
    final cleaned = en(raw).replaceAll(RegExp(r"[^\d.\-]"), "");
    final parsed = double.tryParse(cleaned);
    if (parsed != null) _set(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final n = _current;
    final disabled = widget.disabled;

    final stepUp = IconButton(
      onPressed: disabled || n >= widget.max ? null : () => _set(n + widget.step),
      icon: const Icon(Icons.add),
      iconSize: 16,
      color: t.mutedForeground,
      disabledColor: t.mutedForeground.withValues(alpha: 0.4),
      hoverColor: t.accent,
      highlightColor: Colors.transparent,
      tooltip: "افزایش",
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
    );

    final stepDown = IconButton(
      onPressed: disabled || n <= widget.min ? null : () => _set(n - widget.step),
      icon: const Icon(Icons.remove),
      iconSize: 16,
      color: t.mutedForeground,
      disabledColor: t.mutedForeground.withValues(alpha: 0.4),
      hoverColor: t.accent,
      highlightColor: Colors.transparent,
      tooltip: "کاهش",
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
    );

    final input = Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: _controller,
        enabled: !disabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩.\-]")),
        ],
        onChanged: _onType,
        cursorColor: t.foreground,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.foreground),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: t.mutedForeground.withValues(alpha: 0.7)),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Container(
        height: 40,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: t.background.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(VibeRadius.field),
          border: Border.all(color: t.input),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            stepUp,
            Container(
              width: 56,
              decoration:
                  BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: t.input))),
              child: Center(child: input),
            ),
            stepDown,
          ],
        ),
      ),
    );
  }
}
