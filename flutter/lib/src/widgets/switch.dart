import 'package:flutter/material.dart';

import '../theme.dart';

/// سوییچ — پورت `registry/ui/switch.tsx`.
///
/// حالت روشن به سمت ابتدای سطر (در RTL سمت راست) می‌رود؛ همان رفتار وب.
///
/// ```dart
/// VibeSwitch(value: _dark, onChanged: (v) => setState(() => _dark = v))
/// ```
class VibeSwitch extends StatefulWidget {
  /// وضعیت کنترل‌شده؛ null یعنی state داخلی نگه داشته می‌شود.
  final bool? value;

  /// وضعیت اولیه در حالت غیرکنترل‌شده.
  final bool defaultValue;
  final ValueChanged<bool>? onChanged;

  const VibeSwitch({super.key, this.value, this.defaultValue = false, this.onChanged});

  @override
  State<VibeSwitch> createState() => _VibeSwitchState();
}

class _VibeSwitchState extends State<VibeSwitch> {
  late bool _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final on = widget.value ?? _internal;
    return Semantics(
      toggled: on,
      button: true,
      child: GestureDetector(
        onTap: () {
          if (widget.value == null) setState(() => _internal = !on);
          widget.onChanged?.call(!on);
        },
        child: AnimatedContainer(
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: on ? t.primary : t.input,
          ),
          child: AnimatedAlign(
            duration: VibeMotion.duration,
            curve: VibeMotion.ease,
            // در RTL، «روشن» به سمت ابتدای سطر (راست) می‌رود.
            alignment: on ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? t.primaryForeground : t.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
