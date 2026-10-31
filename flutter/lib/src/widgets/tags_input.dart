import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../persian.dart';
import '../theme.dart';

/// برچسب‌ها — پورت `registry/ui/tags-input.tsx`.
///
/// تایپ و Enter (یا «،») چیپ می‌سازد؛ Backspace روی فیلد خالی آخرین چیپ را
/// حذف می‌کند و چسباندن فهرست‌ها به چیپ‌های جدا تبدیل می‌شود.
///
/// ```dart
/// VibeTagsInput(value: _tags, onChanged: (t) => setState(() => _tags = t), max: 5)
/// ```
class VibeTagsInput extends StatefulWidget {
  const VibeTagsInput({
    super.key,
    this.value,
    this.initialValue = const [],
    this.onChanged,
    this.placeholder = "برچسب را بنویسید و Enter بزنید",
    this.max,
    this.separators = const ["،", ","],
    this.validate,
    this.disabled = false,
  });

  final List<String>? value;
  final List<String> initialValue;
  final ValueChanged<List<String>>? onChanged;
  final String placeholder;

  /// سقف تعداد؛ با مقدار، شمارنده‌ی «۳ / ۵» نمایش داده می‌شود.
  final int? max;

  /// کاراکترهایی که در حین تایپ چیپ می‌سازند؛ Enter همیشه می‌سازد.
  final List<String> separators;

  /// نرمال‌سازی یا رد برچسب پیش از افزودن؛ برای رد کردن null برگردانید.
  final String? Function(String tag)? validate;
  final bool disabled;

  @override
  State<VibeTagsInput> createState() => _VibeTagsInputState();
}

class _VibeTagsInputState extends State<VibeTagsInput> {
  late List<String> _internal;
  final _controller = TextEditingController();
  final _focus = FocusNode();

  String? _defaultValidate(String tag) => tag.trim().isEmpty ? null : tag.trim();

  @override
  void initState() {
    super.initState();
    _internal = [...widget.initialValue];
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<String> get _tags => widget.value ?? _internal;

  void _commit(List<String> next) {
    setState(() => _internal = next);
    widget.onChanged?.call(next);
  }

  void _add(String raw) {
    final validate = widget.validate ?? _defaultValidate;
    final tag = validate(raw);
    if (tag == null) {
      _controller.clear();
      return;
    }
    final merged = [..._tags];
    if (widget.max != null && merged.length >= widget.max!) return;
    if (!merged.contains(tag)) _commit([...merged, tag]);
    _controller.clear();
  }

  void _removeAt(int i) {
    _commit([..._tags]..removeAt(i));
    _focus.requestFocus();
  }

  void _onChanged(String s) {
    // جداکنه‌های وب: «،»، «,» و خط جدید.
    final separators = [...widget.separators, "\n"];
    if (separators.any(s.contains)) {
      for (final part in s.split(RegExp("[${separators.map(_escape).join()}]"))) {
        _add(part);
      }
    }
  }

  static String _escape(String s) => "\\${s[0]}";

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final full = widget.max != null && _tags.length >= widget.max!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _focus.requestFocus,
          child: Opacity(
            opacity: widget.disabled ? 0.5 : 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: t.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(VibeRadius.field),
                border: Border.all(color: t.input),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var i = 0; i < _tags.length; i++)
                    Container(
                      height: 24,
                      padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: t.secondary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tags[i],
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: t.secondaryForeground),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.disabled ? null : () => _removeAt(i),
                            child: Icon(Icons.close, size: 12, color: t.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  if (!widget.disabled && !full)
                    CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.backspace): () {
                          if (_controller.text.isEmpty && _tags.isNotEmpty) _removeAt(_tags.length - 1);
                        },
                        const SingleActivator(LogicalKeyboardKey.escape): _controller.clear,
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 96),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            enabled: !widget.disabled,
                            textInputAction: TextInputAction.done,
                            onChanged: _onChanged,
                            onSubmitted: (v) {
                              if (v.isNotEmpty) _add(v);
                            },
                            style: TextStyle(fontSize: 14, color: t.foreground),
                            cursorColor: t.foreground,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                              hintText: _tags.isEmpty ? widget.placeholder : "",
                              hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.max != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${fa(_tags.length)} / ${fa(widget.max!)}",
                style: TextStyle(fontSize: 11, color: t.mutedForeground),
              ),
            ),
          ),
      ],
    );
  }
}
