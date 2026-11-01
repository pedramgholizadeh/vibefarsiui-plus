import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// متن چندخطی با شمارنده‌ی فارسی و ارتفاع خودکار — پورت `registry/ui/textarea.tsx`.
///
/// ```dart
/// VibeTextarea(showCount: true, maxLength: 120, hintText: "توضیحات دوره…")
/// ```
class VibeTextarea extends StatefulWidget {
  const VibeTextarea({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.hintText,
    this.autoResize = false,
    this.showCount = false,
    this.maxLength,
    this.enabled = true,
  });

  /// مقدار کنترل‌شده؛ داده نشود باشد state داخلی نگه داشته می‌شود.
  final String? value;

  /// مقدار اولیه‌ی حالت غیرکنترل‌شده.
  final String initialValue;

  final ValueChanged<String>? onChanged;

  final String? hintText;

  /// با محتوا بلند می‌شود به‌جای اسکرول (`autoResize` وب).
  final bool autoResize;

  /// شمارنده‌ی «۲۴ / ۱۲۰» زیر فیلد (نیازمند [maxLength]).
  final bool showCount;

  final int? maxLength;

  final bool enabled;

  @override
  State<VibeTextarea> createState() => _VibeTextareaState();
}

class _VibeTextareaState extends State<VibeTextarea> {
  late final TextEditingController _controller;
  int _len = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? widget.initialValue);
    _len = _controller.text.length;
    _controller.addListener(_onText);
  }

  void _onText() {
    final len = _controller.text.length;
    if (len != _len) setState(() => _len = len);
  }

  @override
  void didUpdateWidget(VibeTextarea oldWidget) {
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
    _controller.removeListener(_onText);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final showCount = widget.showCount && widget.maxLength != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            maxLines: widget.autoResize ? null : 6,
            minLines: 3,
            onChanged: widget.onChanged,
            cursorColor: t.foreground,
            style: TextStyle(fontSize: 14, height: 1.75, color: t.foreground),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(fontSize: 14, height: 1.75, color: t.mutedForeground.withValues(alpha: 0.7)),
              counterText: '',
              filled: true,
              fillColor: t.background.withValues(alpha: 0.6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VibeRadius.field),
                borderSide: BorderSide(color: t.input),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VibeRadius.field),
                borderSide: BorderSide(width: 2, color: t.ring.withValues(alpha: 0.6)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VibeRadius.field),
                borderSide: BorderSide(color: t.input),
              ),
            ),
          ),
        ),
        if (showCount) ...[
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Semantics(
                liveRegion: true,
                child: Text(
                  "${fa(_len)} / ${fa(widget.maxLength!)}",
                  style: TextStyle(fontSize: 11, color: t.mutedForeground),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
