import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// یک مرحله.
class VibeStep {
  final Widget label;
  final Widget? description;

  const VibeStep({required this.label, this.description});
}

/// مراحل — پورت `registry/ui/stepper.tsx`.
///
/// مرحله‌ی تمام‌شده تیک، فعلی حلقه‌ی ضخیم و بقیه خاکستری؛ جریان از راست به
/// چپ (در Row راست‌چین خودکار است).
///
/// ```dart
/// VibeStepper(
///   steps: const [VibeStep(label: Text("سبد خرید")), VibeStep(label: Text("پرداخت"))],
///   current: _step,
/// )
/// ```
class VibeStepper extends StatelessWidget {
  final List<VibeStep> steps;

  /// اندیس صفرمبنیای مرحله‌ی جاری.
  final int current;
  final bool vertical;

  const VibeStepper({super.key, required this.steps, required this.current, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _circle(context, t, i),
                      if (i != steps.length - 1)
                        Expanded(
                          child: Container(width: 1, color: i < current ? t.primary : t.border),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 20),
                      child: _text(context, t, steps[i], i),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            flex: i == steps.length - 1 ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _circle(context, t, i),
                    if (i != steps.length - 1) ...[
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 1, color: i < current ? t.primary : t.border)),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _text(context, t, steps[i], i),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _circle(BuildContext context, VibeTokens t, int i) {
    final done = i < current;
    final active = i == current;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? t.primary : Colors.transparent,
        border: Border.all(
          color: active ? t.primary : (done ? Colors.transparent : t.border),
          width: active ? 2 : 1,
        ),
      ),
      child: done
          ? Icon(Icons.check, size: 14, color: t.primaryForeground)
          : Text(fa(i + 1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? t.foreground : t.mutedForeground)),
    );
  }

  Widget _text(BuildContext context, VibeTokens t, VibeStep step, int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: i == current ? FontWeight.w600 : FontWeight.w400,
            color: i == current ? t.foreground : (i < current ? t.foreground : t.mutedForeground),
          ),
          child: step.label,
        ),
        if (step.description != null)
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, height: 1.5, color: t.mutedForeground),
            child: step.description!,
          ),
      ],
    );
  }
}
