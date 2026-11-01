import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// جست‌وجو — پورت `registry/ui/search-input.tsx`.
///
/// ذره‌بین در ابتدای سطر (در RTL سمت راست)، دکمه‌ی پاک‌کردن پس از تایپ،
/// Escape برای پاک‌کردن و [onSearch] با دیبانس پس از توقف تایپ یا با Enter.
///
/// ```dart
/// VibeSearchInput(onSearch: (q) => search(q), debounce: 300)
/// ```
class VibeSearchInput extends StatefulWidget {
  const VibeSearchInput({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.onSearch,
    this.debounce = 300,
    this.loading = false,
    this.small = false,
    this.shortcut,
    this.hintText = "جست‌وجو…",
    this.enabled = true,
  });

  final String? value;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  /// پس از توقف تایپ به مدت [debounce]، با Enter و هنگام پاک‌شدن.
  final ValueChanged<String>? onSearch;

  /// تأخیر دیبانس (میلی‌ثانیه).
  final int debounce;

  /// ذره‌بین به چرخنده تبدیل می‌شود.
  final bool loading;

  /// اندازه‌ی کوچک (h-8) برای نوار ابزار.
  final bool small;

  /// میانبر کنار فیلد (مثل «⌘K») تا وقتی خالی است.
  final String? shortcut;
  final String hintText;
  final bool enabled;

  @override
  State<VibeSearchInput> createState() => _VibeSearchInputState();
}

class _VibeSearchInputState extends State<VibeSearchInput> {
  late final TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? widget.initialValue);
  }

  @override
  void didUpdateWidget(VibeSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.value;
    if (external != null && external != _controller.text) {
      _controller.value = TextEditingValue(text: external, selection: TextSelection.collapsed(offset: external.length));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _set(String next, {bool immediate = false}) {
    if (widget.value == null) _controller.value = TextEditingValue(text: next, selection: TextSelection.collapsed(offset: next.length));
    widget.onChanged?.call(next);
    if (widget.onSearch == null) return;
    _timer?.cancel();
    if (immediate || next.isEmpty) {
      widget.onSearch!(next);
    } else {
      _timer = Timer(Duration(milliseconds: widget.debounce), () => widget.onSearch!(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final v = _controller.text;
    final hasValue = v.isNotEmpty;

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (hasValue) {
              _set("", immediate: true);
            }
          },
        },
        child: Container(
          height: widget.small ? 32 : 40,
          padding: EdgeInsets.symmetric(horizontal: widget.small ? 10 : 12),
          decoration: BoxDecoration(
            color: t.background.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(VibeRadius.field),
            border: Border.all(color: t.input),
          ),
          child: Row(
            children: [
              if (widget.loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: t.mutedForeground),
                )
              else
                Icon(Icons.search, size: 16, color: t.mutedForeground),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  textInputAction: TextInputAction.search,
                  onChanged: (next) {
                    setState(() {});
                    _set(next);
                  },
                  onSubmitted: (v) => _set(v, immediate: true),
                  cursorColor: t.foreground,
                  style: TextStyle(fontSize: 14, color: t.foreground),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
                  ),
                ),
              ),
              if (hasValue)
                GestureDetector(
                  onTap: () {
                    _set("", immediate: true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 14, color: t.mutedForeground),
                  ),
                )
              else if (widget.shortcut != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: t.border),
                    color: t.muted,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.shortcut!,
                      style: TextStyle(fontSize: 11, height: 1.6, color: t.mutedForeground),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
