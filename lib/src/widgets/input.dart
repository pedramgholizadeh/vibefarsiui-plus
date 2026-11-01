import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// ورودی متن — پورت `registry/ui/input.tsx`.
///
/// متن فارسی به‌طور پیش‌فرض راست‌چین است؛ برای شماره‌ی موبایل، ایمیل و
/// کدها [textDirection] را `TextDirection.ltr` بدهید تا ارقام ترتیب طبیعی
/// خود را نگه دارند. خطا زیر فیلد و با رنگ destructive رسم می‌شود.
///
/// ```dart
/// VibeField(
///   label: const Text("نام فروشگاه"),
///   child: VibeInput(hintText: "مثلاً فروشگاه پدرم"),
/// )
/// ```
class VibeInput extends StatefulWidget {
  const VibeInput({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.hintText,
    this.startAddon,
    this.endAddon,
    this.error,
    this.enabled = true,
    this.obscure = false,
    this.autofocus = false,
    this.keyboardType,
    this.textDirection,
    this.inputFormatters,
  });

  /// مقدار کنترل‌شده؛ داده نشود باشد state داخلی نگه داشته می‌شود.
  final String? value;

  /// مقدار اولیه‌ی حالت غیرکنترل‌شده.
  final String initialValue;

  final ValueChanged<String>? onChanged;

  /// متن جایگاه (placeholder) وب.
  final String? hintText;

  /// محتوای لبه‌ی شروع (مثل کد کشور «+98»).
  final Widget? startAddon;

  /// محتوای لبه‌ی پایان (مثل واحد یا آیکون).
  final Widget? endAddon;

  /// پیام خطا؛ زیر فیلد رسم و فیلد aria-invalid می‌شود.
  final String? error;

  final bool enabled;

  /// مانند `type="password"` وب.
  final bool obscure;

  final bool autofocus;

  final TextInputType? keyboardType;

  /// جهت متن خودِ فیلد (کل گروه جهت را می‌گیرد، مثل وب).
  final TextDirection? textDirection;

  final List<TextInputFormatter>? inputFormatters;

  @override
  State<VibeInput> createState() => _VibeInputState();
}

class _VibeInputState extends State<VibeInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? widget.initialValue);
  }

  @override
  void didUpdateWidget(VibeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.value;
    if (external != null && external != _controller.text) {
      _controller.value = TextEditingValue(
        text: external,
        selection: TextSelection.collapsed(offset: external.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final invalid = widget.error != null;
    final errorColor = t.destructive.withValues(alpha: 0.6);

    final field = TextField(
      controller: _controller,
      enabled: widget.enabled,
      obscureText: widget.obscure,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      cursorColor: t.foreground,
      style: TextStyle(fontSize: 14, height: 1.2, color: t.foreground),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
        filled: true,
        fillColor: t.background.withValues(alpha: 0.6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        prefix: widget.startAddon == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 14, color: t.mutedForeground),
                  child: IconTheme.merge(
                    data: IconThemeData(size: 16, color: t.mutedForeground),
                    child: widget.startAddon!,
                  ),
                ),
              ),
        suffix: widget.endAddon == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 14, color: t.mutedForeground),
                  child: IconTheme.merge(
                    data: IconThemeData(size: 16, color: t.mutedForeground),
                    child: widget.endAddon!,
                  ),
                ),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          borderSide: BorderSide(color: invalid ? errorColor : t.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          borderSide: BorderSide(width: 2, color: invalid ? errorColor : t.ring.withValues(alpha: 0.6)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          borderSide: BorderSide(color: invalid ? errorColor : t.input),
        ),
        errorText: widget.error,
        errorStyle: TextStyle(fontSize: 12, color: t.destructive),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          borderSide: BorderSide(width: 2, color: t.ring.withValues(alpha: 0.6)),
        ),
      ),
    );

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: widget.textDirection == null
          ? field
          : Directionality(textDirection: widget.textDirection!, child: field),
    );
  }
}

/// برچسب فیلد — متن ۱۴ نیمه‌ضخیم با ۹۰٪ رنگ متن.
class VibeLabel extends StatelessWidget {
  const VibeLabel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.foreground.withValues(alpha: 0.9)),
      child: child,
    );
  }
}

/// برچسب را با فاصله‌ی ثابت بالای کنترل می‌گذارد و راهنما را زیرش — پورت `Field` وب.
///
/// ```dart
/// const VibeField(
///   label: Text("ایمیل"),
///   hint: Text("برای بازیابی حساب لازم است"),
///   child: VibeInput(hintText: "you@example.com", textDirection: TextDirection.ltr),
/// )
/// ```
class VibeField extends StatelessWidget {
  const VibeField({super.key, required this.label, required this.child, this.hint});

  final Widget label;

  /// راهنمای زیر کنترل، متن ۱۲ با رنگ mutedForeground.
  final Widget? hint;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VibeLabel(child: label),
        const SizedBox(height: 6),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: t.mutedForeground, height: 1.5),
            child: hint!,
          ),
        ],
      ],
    );
  }
}
