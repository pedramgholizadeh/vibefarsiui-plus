import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../iran.dart';
import '../theme.dart';

/// کد ملی — پورت `registry/ui/national-id-input.tsx`.
///
/// ارقام فارسی با گروه‌بندی ۳-۶-۱ مثل کارت ملی؛ بررسی رقم کنترل فقط وقتی
/// ده رقم کامل شود و مقدار رشته بماند تا صفر ابتدایی از دست نرود.
///
/// ```dart
/// VibeNationalIdInput(onChanged: (digits, valid) => save(digits, valid))
/// ```
class VibeNationalIdInput extends StatefulWidget {
  const VibeNationalIdInput({super.key, this.value, this.initialValue = '', this.onChanged, this.autofocus = false, this.enabled = true});

  /// مقدار کنترل‌شده (ده رقم لاتین، ممکن است با صفر شروع شود).
  final String? value;
  final String initialValue;

  /// ده رقم خام (لاتین) و اعتبار آن.
  final void Function(String digits, bool valid)? onChanged;
  final bool autofocus;
  final bool enabled;

  @override
  State<VibeNationalIdInput> createState() => _VibeNationalIdInputState();
}

class _VibeNationalIdInputState extends State<VibeNationalIdInput> {
  String _internal = '';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _sync();
  }

  String get _digits => normalizeNationalId(widget.value ?? _internal);

  void _sync() {
    final text = formatNationalId(_digits);
    if (text != _controller.text) {
      _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  void _set(String next) {
    final d = normalizeNationalId(next);
    setState(() => _internal = d);
    _sync();
    widget.onChanged?.call(d, isNationalId(d));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final digits = _digits;
    final complete = digits.length == 10;
    final valid = isNationalId(digits);
    final invalid = complete && !valid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: t.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(VibeRadius.field),
                border: Border.all(color: invalid ? t.destructive.withValues(alpha: 0.6) : t.input),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge_outlined, size: 16, color: t.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      autofocus: widget.autofocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩-]"))],
                      onChanged: _set,
                      cursorColor: t.foreground,
                      style: TextStyle(fontSize: 14, color: t.foreground),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: "۰۰۱-۲۳۴۵۶۷-۸",
                        hintStyle: TextStyle(fontSize: 14, color: Color(0x8089898B)),
                      ),
                    ),
                  ),
                  if (valid) Icon(Icons.check_circle_outline, size: 16, color: t.success),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valid
              ? "کد ملی معتبر است"
              : invalid
                  ? "کد ملی معتبر نیست؛ رقم‌ها را دوباره بررسی کنید"
                  : "ده رقم، همان‌طور که روی کارت ملی چاپ شده",
          style: TextStyle(fontSize: 11, color: invalid ? t.destructive : t.mutedForeground),
        ),
      ],
    );
  }
}
