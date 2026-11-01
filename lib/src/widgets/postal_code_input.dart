import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../iran.dart';
import '../theme.dart';

/// کد پستی — پورت `registry/ui/postal-code-input.tsx`.
///
/// ارقام فارسی با گروه‌بندی «۸۱۶۳۸-۴۷۳۵۱» مثل قبض؛ پیست با یا بدون خط تیره
/// کار می‌کند و خطای طول تا خروج از فیلد (یا ۱۰ رقم کامل) صبر می‌کند.
///
/// ```dart
/// VibePostalCodeInput(onChanged: (digits, valid) => save(digits, valid))
/// ```
class VibePostalCodeInput extends StatefulWidget {
  const VibePostalCodeInput({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
    this.showInvalid = false,
  });

  final String? value;
  final String initialValue;
  final void Function(String digits, bool valid)? onChanged;
  final bool autofocus;
  final bool enabled;

  /// نمایش خطا پیش از blur (بعد از submit بدهید true).
  final bool showInvalid;

  @override
  State<VibePostalCodeInput> createState() => _VibePostalCodeInputState();
}

class _VibePostalCodeInputState extends State<VibePostalCodeInput> {
  String _internal = '';
  bool _touched = false;
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focus.addListener(() {
      if (!_focus.hasFocus) setState(() => _touched = true);
    });
    _sync();
  }

  String get _digits => normalizePostalCode(widget.value ?? _internal);

  void _sync() {
    final text = formatPostalCode(_digits);
    if (text != _controller.text) {
      _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  void _set(String next) {
    final d = normalizePostalCode(next);
    setState(() => _internal = d);
    _sync();
    widget.onChanged?.call(d, isPostalCode(d));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final digits = _digits;
    final valid = isPostalCode(digits);
    final showError = !valid && digits.isNotEmpty && (_touched || digits.length == 10 || widget.showInvalid);
    final missing = widget.showInvalid && digits.isEmpty;

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
                border: Border.all(color: showError || missing ? t.destructive.withValues(alpha: 0.6) : t.input),
              ),
              child: Row(
                children: [
                  Icon(Icons.markunread_mailbox_outlined, size: 16, color: t.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
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
                        hintText: "۱۲۳۴۵-۶۷۸۹۰",
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
          showError
              ? (digits.length < 10 ? "کد پستی باید ۱۰ رقم باشد." : "کد پستی معتبر نیست.")
              : missing
                  ? "کد پستی را وارد کنید."
                  : "ده رقم، بدون خط تیره هم قبول میشه",
          style: TextStyle(fontSize: 11, color: showError || missing ? t.destructive : t.mutedForeground),
        ),
      ],
    );
  }
}
