import 'package:flutter/material.dart';

import '../theme.dart';

/// جعبه‌ی پرامپت — پورت `registry/ui/prompt-input.tsx`.
///
/// تکست‌اریای خودرشد؛ Enter می‌فرستد و Shift+Enter خط می‌شکند. دکمه‌ی ارسال
/// در لبه‌ی پایان (چپ در RTL) مثل هر اپ چت فارسی.
///
/// ```dart
/// VibePromptInput(onSubmit: ask, loading: busy, onStop: cancel)
/// ```
class VibePromptInput extends StatefulWidget {
  const VibePromptInput({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.onSubmit,
    this.onStop,
    this.loading = false,
    this.placeholder = "از هوش مصنوعی بپرسید…",
    this.tools,
  });

  final String? value;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  /// با Enter و متن غیرخالی صدا می‌شود.
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onStop;

  /// دکمه‌ی ارسال به دکمه‌ی توقف تبدیل می‌شود.
  final bool loading;
  final String placeholder;

  /// ابزار در نوار پایین، مثل انتخاب مدل.
  final Widget? tools;

  @override
  State<VibePromptInput> createState() => _VibePromptInputState();
}

class _VibePromptInputState extends State<VibePromptInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? widget.initialValue);
  }

  @override
  void didUpdateWidget(VibePromptInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.value;
    if (external != null && external != _controller.text) {
      _controller.value = TextEditingValue(text: external, selection: TextSelection.collapsed(offset: external.length));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _controller.text.trim();
    if (v.isEmpty || widget.loading) return;
    widget.onSubmit?.call(v);
    if (widget.value == null) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: null,
            minLines: 1,
            onChanged: (v) {
              setState(() {});
              widget.onChanged?.call(v);
            },
            // Enter ارسال می‌کند (textInputAction.send)؛ Shift+Enter در موبایل خط جدید.
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            cursorColor: t.foreground,
            style: TextStyle(fontSize: 14, height: 1.7, color: t.foreground),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: widget.placeholder,
              hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(Icons.attach_file, size: 16, color: t.mutedForeground),
              ),
              const SizedBox(width: 4),
              if (widget.tools != null) widget.tools!,
              const Spacer(),
              if (widget.loading)
                GestureDetector(
                  onTap: widget.onStop,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: t.foreground,
                    ),
                    child: Icon(Icons.stop, size: 12, color: t.background),
                  ),
                )
              else
                Opacity(
                  opacity: hasText ? 1 : 0.4,
                  child: GestureDetector(
                    onTap: hasText ? _submit : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: t.primary,
                      ),
                      child: Icon(Icons.arrow_upward, size: 16, color: t.primaryForeground),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
