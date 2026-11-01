import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../iran.dart';
import '../theme.dart';

/// شماره‌ی موبایل ایران — پورت `registry/ui/phone-input.tsx`.
///
/// «+98» ثابت سمت چپ فیلد چپ‌چین، گروه‌بندی ۳-۳-۴، تشخیص اپراتور و پذیرش
/// رقم فارسی. [onChanged] عدد ۱۰ رقمی ملی («912…») و اعتبارش را می‌دهد.
///
/// ```dart
/// VibePhoneInput(onChanged: (digits, valid) => print(valid))
/// ```
class VibePhoneInput extends StatefulWidget {
  const VibePhoneInput({super.key, this.value, this.initialValue = '', this.onChanged, this.enabled = true});

  /// مقدار کنترل‌شده (همان شکل ۱۰ رقمی «912…»).
  final String? value;
  final String initialValue;

  /// عدد ۱۰ رقمی نرمال‌شده و اعتبار آن.
  final void Function(String digits, bool valid)? onChanged;
  final bool enabled;

  @override
  State<VibePhoneInput> createState() => _VibePhoneInputState();
}

class _VibePhoneInputState extends State<VibePhoneInput> {
  String _internal = '';

  String get _digits => normalizeIranMobile(widget.value ?? _internal);

  void _set(String next) {
    final d = normalizeIranMobile(next);
    setState(() => _internal = d);
    widget.onChanged?.call(d, isIranMobile(d));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final digits = _digits;
    final valid = isIranMobile(digits);
    final op = mobileOperator(digits);
    final invalidFull = digits.length == 10 && !valid;

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
                border: Border.all(color: invalidFull ? t.destructive.withValues(alpha: 0.6) : t.input),
              ),
              child: Row(
                children: [
                  Text("+98", style: TextStyle(fontSize: 14, color: t.mutedForeground)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: widget.enabled,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩]"))],
                      autofocus: false,
                      cursorColor: t.foreground,
                      style: TextStyle(fontSize: 14, color: t.foreground),
                      onChanged: _set,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: "912 345 6789",
                        hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.5)),
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
          op != null
              ? "اپراتور: $op"
              : invalidFull
                  ? "شماره باید با ۹ شروع شود و ۱۰ رقم باشد"
                  : "بدون صفر اول هم می‌توانید وارد کنید",
          style: TextStyle(
            fontSize: 11,
            color: invalidFull && op == null ? t.destructive : t.mutedForeground,
          ),
        ),
      ],
    );
  }
}
