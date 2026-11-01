import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../persian.dart';
import '../theme.dart';

/// کد تأیید — پورت `registry/ui/otp-field.tsx`.
///
/// جعبه‌ها چیدمان چپ‌چین دارند (همان‌طور که از پیامک خوانده می‌شوند)، ارقام
/// فارسی نمایش داده می‌شوند و چسباندن کدِ کامل همه‌ی جعبه‌ها را پُر می‌کند.
/// ورودی با رقم فارسی یا لاتین پذیرفته می‌شود.
///
/// ```dart
/// VibeOtpField(length: 6, onComplete: (code) => verify(code))
/// ```
class VibeOtpField extends StatefulWidget {
  const VibeOtpField({
    super.key,
    this.length = 6,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.onComplete,
    this.disabled = false,
    this.small = false,
    this.label = "کد تأیید",
  });

  final int length;

  /// کد کنترل‌شده (رقم لاتین).
  final String? value;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  /// یک‌بار وقتی همه‌ی جعبه‌ها پر شد.
  final ValueChanged<String>? onComplete;
  final bool disabled;

  /// جعبه‌های کوچک‌تر برای کارت‌های باریک.
  final bool small;

  /// برچسب گروه برای خواننده‌ی صفحه.
  final String label;

  @override
  State<VibeOtpField> createState() => _VibeOtpFieldState();
}

class _VibeOtpFieldState extends State<VibeOtpField> {
  late String _internal;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _internal = widget.initialValue;
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _syncControllers();
  }

  @override
  void didUpdateWidget(VibeOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _code) _syncControllers();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => widget.value ?? _internal;

  void _syncControllers() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < _code.length ? fa(_code[i]) : "";
    }
  }

  void _commit(String next) {
    final clean = en(next).replaceAll(RegExp(r"\D"), "");
    final capped = clean.length > widget.length ? clean.substring(0, widget.length) : clean;
    setState(() => _internal = capped);
    _syncControllers();
    widget.onChanged?.call(capped);
    if (capped.length == widget.length) {
      widget.onComplete?.call(capped);
      _focusNodes.last.unfocus();
    } else {
      _focusNodes[capped.length].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.small ? 40.0 : 44.0;
    final width = widget.small ? 32.0 : 36.0;

    return Semantics(
      label: widget.label,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) SizedBox(width: widget.small ? 4 : 6),
              _box(i, height, width),
            ],
          ],
        ),
      ),
    );
  }

  Widget _box(int i, double height, double width) {
    final t = context.vibe;
    return Opacity(
      opacity: widget.disabled ? 0.5 : 1,
      child: SizedBox(
        width: width,
        height: height,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.backspace): () {
              // جعبه‌ی خالی: جعبه‌ی قبلی پاک می‌شود، مثل وب.
              if (i > 0 && i >= _code.length) _commit(_code.substring(0, i - 1));
            },
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
              if (i > 0) _focusNodes[i - 1].requestFocus();
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight): () {
              if (i < widget.length - 1) _focusNodes[i + 1].requestFocus();
            },
          },
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            enabled: !widget.disabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩]"))],
            showCursor: false,
            style: TextStyle(fontSize: widget.small ? 14 : 16, fontWeight: FontWeight.w600, color: t.foreground),
            decoration: InputDecoration(
              filled: true,
              fillColor: t.card,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: t.input),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: t.foreground.withValues(alpha: 0.6)),
              ),
            ),
            onChanged: (v) {
              final typed = en(v).replaceAll(RegExp(r"\D"), "");
              if (typed.length > 1) {
                // چسباندن کد کامل یا چندرقمی.
                _commit(_code.substring(0, i) + typed);
              } else if (typed.isEmpty) {
                // پاک‌شدن رقم همین جعبه.
                _commit(_code.substring(0, i));
              } else {
                final padded = _code.padRight(i + 1).substring(0, i) + typed;
                final tail = _code.length > i + 1 ? _code.substring(i + 1) : "";
                _commit(padded + tail);
              }
            },
          ),
        ),
      ),
    );
  }
}
