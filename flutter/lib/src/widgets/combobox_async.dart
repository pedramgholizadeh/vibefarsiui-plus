import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// گزینه‌ی کمبوباکس آنلاین: مقدار، برچسب و راهنمای اختیاری.
class VibeAsyncOption {
  final String value;
  final String label;
  final String? hint;

  const VibeAsyncOption({required this.value, required this.label, this.hint});
}

/// کمبوباکس آنلاین — پورت `registry/ui/combobox-async.tsx`.
///
/// جست‌وجوی دور با دیبانس، حالت بارگذاری/خالی/خطا؛ پاسخ‌های کهنه دور ریخته
/// می‌شوند (معادل AbortSignal وب با نسل‌شماری).
///
/// ```dart
/// VibeComboboxAsync(
///   loadOptions: (q) async => (await api.search(q)).map(VibeAsyncOption.new).toList(),
///   value: _picked,
///   onChanged: (o) => setState(() => _picked = o),
/// )
/// ```
class VibeComboboxAsync extends StatefulWidget {
  /// گزینه‌ها را برای یک عبارت می‌گیرد؛ خطا را با throw علامت بزنید.
  final Future<List<VibeAsyncOption>> Function(String query) loadOptions;

  /// انتخاب کنترل‌شده.
  final VibeAsyncOption? value;
  final ValueChanged<VibeAsyncOption?>? onChanged;
  final String placeholder;
  final int minChars;
  final int debounce;
  final String emptyText;
  final String errorText;

  const VibeComboboxAsync({
    super.key,
    required this.loadOptions,
    this.value,
    this.onChanged,
    this.placeholder = "جست‌وجو…",
    this.minChars = 1,
    this.debounce = 250,
    this.emptyText = "چیزی پیدا نشد",
    this.errorText = "خطا در دریافت نتایج",
  });

  @override
  State<VibeComboboxAsync> createState() => _VibeComboboxAsyncState();
}

enum _AsyncState { idle, loading, error }

class _VibeComboboxAsyncState extends State<VibeComboboxAsync> {
  late final TextEditingController _controller;
  Timer? _timer;
  int _generation = 0;
  List<VibeAsyncOption> _items = [];
  _AsyncState _state = _AsyncState.idle;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.label ?? "");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String q) async {
    _timer?.cancel();
    if (q.trim().length < widget.minChars) {
      setState(() {
        _state = _AsyncState.idle;
        _items = [];
      });
      return;
    }
    final gen = ++_generation;
    setState(() => _state = _AsyncState.loading);
    _timer = Timer(Duration(milliseconds: widget.debounce), () async {
      try {
        final res = await widget.loadOptions(q.trim());
        if (gen != _generation || !mounted) return; // پاسخ کهنه
        setState(() {
          _items = res;
          _state = _AsyncState.idle;
        });
      } catch (_) {
        if (gen != _generation || !mounted) return;
        setState(() => _state = _AsyncState.error);
      }
    });
  }

  void _pick(VibeAsyncOption o) {
    _controller.value = TextEditingValue(text: o.label, selection: TextSelection.collapsed(offset: o.label.length));
    widget.onChanged?.call(o);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final loading = _state == _AsyncState.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          decoration: BoxDecoration(
            color: t.background.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(VibeRadius.field),
            border: Border.all(color: _state == _AsyncState.error ? t.destructive.withValues(alpha: 0.6) : t.input),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (v) {
                    setState(() {});
                    _onChanged(v);
                  },
                  cursorColor: t.foreground,
                  style: TextStyle(fontSize: 14, color: t.foreground),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
                  ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: t.mutedForeground),
                )
              else
                Icon(Icons.expand_more, size: 16, color: t.mutedForeground),
            ],
          ),
        ),
        if (_state == _AsyncState.error)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(widget.errorText, style: TextStyle(fontSize: 11, color: t.destructive)),
          ),
        if (_controller.text.trim().length >= widget.minChars && !loading && _state != _AsyncState.error)
          ..._suggestions(context),
      ],
    );
  }

  List<Widget> _suggestions(BuildContext context) {
    final t = context.vibe;
    if (_items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(widget.emptyText, style: TextStyle(fontSize: 14, color: t.mutedForeground)),
          ),
        ),
      ];
    }
    return [
      const SizedBox(height: 4),
      Container(
        constraints: const BoxConstraints(maxHeight: 224),
        decoration: BoxDecoration(
          color: t.popover,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: t.border),
        ),
        child: ListView(
          padding: const EdgeInsets.all(4),
          shrinkWrap: true,
          children: [
            for (final o in _items)
              InkWell(
                onTap: () => _pick(o),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.label, style: TextStyle(fontSize: 14, height: 1.5, color: t.foreground)),
                            if (o.hint != null)
                              Text(o.hint!, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                          ],
                        ),
                      ),
                      if (widget.value?.value == o.value) Icon(Icons.check, size: 14, color: t.foreground),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }
}
